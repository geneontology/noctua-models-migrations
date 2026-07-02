//> using scala 3.3.4
//> using dep net.sourceforge.owlapi:owlapi-distribution:4.5.29

// Collapse the "easy bucket" of multiply-reified GO-CAM edges, in place.
//
// For each logical edge (subject, property, target) that has MORE THAN ONE
// reified (annotated) OWLObjectPropertyAssertionAxiom, we act only when the group
// is "one_covers_all": some single reification already carries the union of all
// distinct evidence content (evidence compared by ECO type + dc:source + with +
// contributor + providedBy, ignoring the evidence individual's IRI and dc:date).
//
// When we act:
//   - keep one covering reification ("keeper"),
//   - union the non-evidence, non-date annotations (contributor, providedBy,
//     comment, created, dateAccepted, and anything else) from ALL reifications
//     onto it,
//   - keep a single dc:date = the latest value seen in the group,
//   - dedup the keeper's evidence individuals by content (one representative per
//     distinct content),
//   - delete the other reifications and every evidence individual in the group
//     that is no longer referenced (orphans), including the keeper's redundant
//     duplicates.
//
// Groups that are NOT one_covers_all, and edges with a single reification, are
// left completely untouched (handled separately). A model file is only rewritten
// if at least one edge was collapsed.
//
// Usage:
//   scala-cli run collapse-reifications.scala -- <folder-of-ttl-files> [--dry-run]
//
// Processes every *.ttl in <folder> (non-recursive) and overwrites changed files.

import org.semanticweb.owlapi.apibinding.OWLManager
import org.semanticweb.owlapi.formats.TurtleDocumentFormat
import org.semanticweb.owlapi.io.{FileDocumentSource, StreamDocumentTarget}
import org.semanticweb.owlapi.model.*
import scala.jdk.CollectionConverters.*
import scala.collection.mutable.ListBuffer
import java.io.{BufferedOutputStream, File, FileOutputStream}

val EVIDENCE  = "http://geneontology.org/lego/evidence"
val EV_WITH   = "http://geneontology.org/lego/evidence-with"
val SOURCE    = "http://purl.org/dc/elements/1.1/source"
val CONTRIB   = "http://purl.org/dc/elements/1.1/contributor"
val PROVIDED  = "http://purl.org/pav/providedBy"
val DATE      = "http://purl.org/dc/elements/1.1/date"
val MODELSTATE = "http://geneontology.org/lego/modelstate"
val NAMED_IND = "http://www.w3.org/2002/07/owl#NamedIndividual"

// date-insensitive, IRI-insensitive content of one evidence individual
type EvContent = (Set[String], Set[String], Set[String], Set[String], Set[String])

def litStr(v: OWLAnnotationValue): Option[String] = v match
  case l: OWLLiteral => Some(l.getLiteral)
  case _             => None

def iriOf(v: OWLAnnotationValue): Option[IRI] = v match
  case i: IRI => Some(i)
  case _      => None

def evContent(ont: OWLOntology, ind: OWLNamedIndividual): EvContent =
  val ecos = ont
    .getClassAssertionAxioms(ind).asScala
    .map(_.getClassExpression)
    .collect { case c if !c.isAnonymous => c.asOWLClass.getIRI.toString }
    .filterNot(_ == NAMED_IND)
    .toSet
  val anns = ont.getAnnotationAssertionAxioms(ind.getIRI).asScala.toList
  def v(p: String): Set[String] =
    anns.filter(_.getProperty.getIRI.toString == p).flatMap(a => litStr(a.getValue)).toSet
  (ecos, v(SOURCE), v(EV_WITH), v(CONTRIB), v(PROVIDED))

def evidenceIris(opa: OWLObjectPropertyAssertionAxiom): List[IRI] =
  opa.getAnnotations.asScala.toList
    .filter(_.getProperty.getIRI.toString == EVIDENCE)
    .flatMap(a => iriOf(a.getValue))

case class Result(modified: Boolean, edgesCollapsed: Int, reifsRemoved: Int, evidenceRemoved: Int, skipped: Boolean = false)

def process(file: File, dryRun: Boolean): Result =
  val mgr = OWLManager.createOWLOntologyManager()
  val cfg = mgr.getOntologyLoaderConfiguration
    .setMissingImportHandlingStrategy(MissingImportHandlingStrategy.SILENT)
  val ont = mgr.loadOntologyFromOntologyDocument(new FileDocumentSource(file), cfg)
  try
    val df = mgr.getOWLDataFactory
    // Skip models flagged for deletion (lego:modelstate "delete") entirely.
    val modelState = ont.getAnnotations.asScala.toList
      .filter(_.getProperty.getIRI.toString == MODELSTATE)
      .flatMap(a => litStr(a.getValue))
    if modelState.contains("delete") then return Result(false, 0, 0, 0, skipped = true)

    val opas = ont.getAxioms(AxiomType.OBJECT_PROPERTY_ASSERTION).asScala.toList
      .filter(o => o.getSubject.isNamed && o.getObject.isNamed && o.getProperty.isNamed)
    val groups = opas.groupBy(o =>
      (o.getSubject.asOWLNamedIndividual.getIRI, o.getProperty.asOWLObjectProperty.getIRI, o.getObject.asOWLNamedIndividual.getIRI)
    )

    val changes = ListBuffer[OWLOntologyChange]()
    var groupEvidence = Set[IRI]()
    var edgesCollapsed = 0
    var reifsRemoved = 0

    for (_, reifs) <- groups if reifs.size > 1 do
      // date-insensitive evidence-content set for each reification
      def contentSet(r: OWLObjectPropertyAssertionAxiom): Set[EvContent] =
        evidenceIris(r).map(i => evContent(ont, df.getOWLNamedIndividual(i))).toSet
      val union = reifs.flatMap(contentSet).toSet
      val coverers = reifs.filter(r => contentSet(r) == union)
      if coverers.nonEmpty then
        // --- one_covers_all: collapse this edge ---
        val keeper = coverers.sortBy(r => (-evidenceIris(r).size, r.toString)).head
        groupEvidence ++= reifs.flatMap(evidenceIris).toSet

        val allAnns = reifs.flatMap(_.getAnnotations.asScala)
        // non-evidence, non-date annotations: union across all reifications
        val otherAnns = allAnns.filter { a =>
          val p = a.getProperty.getIRI.toString; p != EVIDENCE && p != DATE
        }.toSet
        // single latest dc:date (string ISO dates sort lexically)
        val latestDate = allAnns
          .filter(_.getProperty.getIRI.toString == DATE)
          .sortBy(a => litStr(a.getValue).getOrElse(""))
          .lastOption
        // keeper's evidence, deduplicated by content -> one representative each
        val repEvidence = keeper.getAnnotations.asScala.toList
          .filter(_.getProperty.getIRI.toString == EVIDENCE)
          .groupBy(a => evContent(ont, df.getOWLNamedIndividual(iriOf(a.getValue).get)))
          .values
          .map(_.minBy(a => iriOf(a.getValue).get.toString))
          .toSet

        val newAnns: Set[OWLAnnotation] = otherAnns ++ latestDate.toSet ++ repEvidence
        reifs.foreach(r => changes += RemoveAxiom(ont, r))
        changes += AddAxiom(ont,
          df.getOWLObjectPropertyAssertionAxiom(keeper.getProperty, keeper.getSubject, keeper.getObject, newAnns.asJava))
        edgesCollapsed += 1
        reifsRemoved += (reifs.size - 1)
      // else: no_single_cover -> leave the whole group untouched

    if changes.isEmpty then Result(false, 0, 0, 0)
    else
      mgr.applyChanges(changes.asJava)
      // sweep evidence individuals from processed groups that nothing references now
      val stillReferenced = ont.getAxioms(AxiomType.OBJECT_PROPERTY_ASSERTION).asScala
        .flatMap(_.getAnnotations.asScala)
        .filter(_.getProperty.getIRI.toString == EVIDENCE)
        .flatMap(a => iriOf(a.getValue))
        .toSet
      val orphans = groupEvidence.filterNot(stillReferenced.contains)
      val removeEv = ListBuffer[OWLOntologyChange]()
      for iri <- orphans do
        val ind = df.getOWLNamedIndividual(iri)
        val about = (ont.getReferencingAxioms(ind).asScala
          ++ ont.getAnnotationAssertionAxioms(iri).asScala
          ++ ont.getDeclarationAxioms(ind).asScala).toSet
        about.foreach(ax => removeEv += RemoveAxiom(ont, ax))
      if removeEv.nonEmpty then mgr.applyChanges(removeEv.asJava)

      if !dryRun then
        val fmt = TurtleDocumentFormat()
        mgr.getOntologyFormat(ont) match
          case p: TurtleDocumentFormat => fmt.copyPrefixesFrom(p)
          case _                       => ()
        val out = BufferedOutputStream(FileOutputStream(file))
        try mgr.saveOntology(ont, fmt, StreamDocumentTarget(out)) finally out.close()
      Result(true, edgesCollapsed, reifsRemoved, orphans.size)
  finally mgr.removeOntology(ont)

@main def run(args: String*): Unit =
  val dryRun = args.contains("--dry-run")
  val positional = args.filterNot(_.startsWith("--"))
  if positional.isEmpty then
    System.err.println("Usage: scala-cli run collapse-reifications.scala -- <folder-of-ttl-files> [--dry-run]")
    sys.exit(1)
  val folder = File(positional.head)
  if !folder.isDirectory then
    System.err.println(s"Not a directory: ${folder.getPath}")
    sys.exit(1)

  val files = Option(folder.listFiles).toList.flatten
    .filter(f => f.isFile && f.getName.endsWith(".ttl")).sortBy(_.getName)
  System.err.println(s"Processing ${files.size} .ttl files in ${folder.getPath}${if dryRun then " (dry-run)" else ""} ...")

  var modified = 0; var edges = 0; var reifs = 0; var evs = 0; var failed = 0; var skipped = 0
  files.zipWithIndex.foreach { (f, i) =>
    if (i + 1) % 500 == 0 then System.err.println(s"  ${i + 1}/${files.size}")
    try
      val r = process(f, dryRun)
      if r.skipped then
        skipped += 1
        println(s"skipped-delete\t${f.getName}")
      else if r.modified then
        modified += 1; edges += r.edgesCollapsed; reifs += r.reifsRemoved; evs += r.evidenceRemoved
        println(s"${if dryRun then "would modify" else "modified"}\t${f.getName}\tedges=${r.edgesCollapsed}\treifs_removed=${r.reifsRemoved}\tevidence_removed=${r.evidenceRemoved}")
    catch
      case e: Throwable =>
        failed += 1
        System.err.println(s"FAILED ${f.getName}: ${e.getClass.getSimpleName}: ${e.getMessage}")
  }
  System.err.println("---")
  System.err.println(s"files ${if dryRun then "that would change" else "modified"}: $modified / ${files.size}  (skipped delete-state: $skipped, failed: $failed)")
  System.err.println(s"edges collapsed: $edges   reifications removed: $reifs   evidence individuals removed: $evs")
