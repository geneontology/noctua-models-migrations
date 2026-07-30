//> using scala 3.3.4
//> using dep net.sourceforge.owlapi:owlapi-distribution:4.5.29

// Collapse multiply-reified GO-CAM edges, in place.
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
// left completely untouched. A model file is only rewritten if at least one edge
// was collapsed.
//
// --union additionally handles the no_single_cover groups, where the evidence is
// genuinely SPLIT across reifications (reif A has PMID:x, reif B has PMID:y) so no
// single one covers the rest. There the keeper takes the union of ALL evidence in
// the group, again deduplicated by content. Nothing is dropped: the result is one
// edge carrying every evidence node, which is what Noctua would have produced had
// the duplicate-submission bug not fired. To stay lossless this only fires when
// every reification in the group carries IDENTICAL non-evidence, non-date
// annotations -- if the reifications disagree on contributor/providedBy/comment/
// created/dateAccepted then merging would invent a combination no curator
// asserted, so the group is left alone for manual review.
//
// Usage:
//   scala-cli run collapse-reifications.scala -- <folder-or-ttl-files> [--union] [--dry-run] [--threads N]
//   scala-cli run collapse-reifications.scala -- --models-from list.txt [--union] [--dry-run]
//
// Directory arguments are scanned recursively for *.ttl. Only models that
// actually change are rewritten, so running over the whole corpus leaves the
// other ~55k files byte-identical. Models annotated lego:modelstate "delete" are
// skipped, matching --import-owl-models, which refuses to load them.
//
// Intended full-corpus workflow (see also issue-58-drop-graphs.ru for the
// targeted alternative):
//   java -jar minerva-cli.jar --dump-owl-models -j blazegraph.jnl -f dump/
//   scala-cli run collapse-reifications.scala -- dump/ --union
//   java -jar minerva-cli.jar --import-owl-models -j NEW-blazegraph.jnl -f dump/
//
// The import MUST target a new/empty journal: --import-owl-models skips any model
// whose IRI is already a graph in the target, so re-importing into the journal
// that was dumped is a no-op.

import org.semanticweb.owlapi.apibinding.OWLManager
import org.semanticweb.owlapi.formats.TurtleDocumentFormat
import org.semanticweb.owlapi.io.{FileDocumentSource, StreamDocumentTarget}
import org.semanticweb.owlapi.model.*
import scala.jdk.CollectionConverters.*
import scala.collection.mutable.ListBuffer
import java.io.{BufferedOutputStream, File, FileOutputStream}
import java.util.concurrent.{Callable, Executors}
import java.util.concurrent.atomic.AtomicInteger

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

// The non-evidence, non-date annotations of a reification, as a comparable set.
// Two reifications agreeing here can be merged without inventing new metadata.
def metaKey(opa: OWLObjectPropertyAssertionAxiom): Set[(String, String)] =
  opa.getAnnotations.asScala.toList
    .filterNot(a => a.getProperty.getIRI.toString == EVIDENCE || a.getProperty.getIRI.toString == DATE)
    .map(a => (a.getProperty.getIRI.toString, litStr(a.getValue).orElse(iriOf(a.getValue).map(_.toString)).getOrElse("")))
    .toSet

case class Result(modified: Boolean, edgesCollapsed: Int, reifsRemoved: Int, evidenceRemoved: Int,
                  unionMerged: Int = 0, skipped: Boolean = false)

def process(file: File, dryRun: Boolean, union: Boolean): Result =
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
    var unionMerged = 0

    for (_, reifs) <- groups if reifs.size > 1 do
      // date-insensitive evidence-content set for each reification
      def contentSet(r: OWLObjectPropertyAssertionAxiom): Set[EvContent] =
        evidenceIris(r).map(i => evContent(ont, df.getOWLNamedIndividual(i))).toSet
      val unionContent = reifs.flatMap(contentSet).toSet
      val coverers = reifs.filter(r => contentSet(r) == unionContent)
      // no_single_cover groups only qualify under --union, and only when every
      // reification carries the same non-evidence metadata (see header).
      val mergeable = coverers.isEmpty && union && reifs.map(metaKey).toSet.size == 1
      if coverers.nonEmpty || mergeable then
        // keeper: the reification already carrying the most evidence
        val candidates = if coverers.nonEmpty then coverers else reifs
        val keeper = candidates.sortBy(r => (-evidenceIris(r).size, r.toString)).head
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
        // evidence to keep, deduplicated by content -> one representative each.
        // covers-all: the keeper's own evidence (already the full content set).
        // union merge: every evidence node in the group, so nothing is dropped.
        val evidenceSource =
          if coverers.nonEmpty then keeper.getAnnotations.asScala.toList
          else allAnns
        val repEvidence = evidenceSource
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
        if coverers.isEmpty then unionMerged += 1
      // else: leave the whole group untouched

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
      Result(true, edgesCollapsed, reifsRemoved, orphans.size, unionMerged)
  finally mgr.removeOntology(ont)

// Expand each argument to .ttl files: a directory contributes its *.ttl
// recursively (matching how --import-owl-models walks its input folder), a .ttl
// path contributes itself.
def resolveInputs(paths: List[String]): List[File] =
  def ttlsUnder(dir: File): List[File] =
    val (dirs, files) = Option(dir.listFiles).toList.flatten.partition(_.isDirectory)
    files.filter(f => f.isFile && f.getName.endsWith(".ttl")) ++ dirs.flatMap(ttlsUnder)
  paths.flatMap { p =>
    val f = File(p)
    if f.isDirectory then ttlsUnder(f)
    else if f.isFile && f.getName.endsWith(".ttl") then List(f)
    else
      System.err.println(s"Ignoring (not a directory or .ttl file): $p")
      Nil
  }

@main def run(args: String*): Unit =
  val dryRun = args.contains("--dry-run")
  val union = args.contains("--union")
  var modelsFrom: Option[String] = None
  var threads = Runtime.getRuntime.availableProcessors
  val positional = scala.collection.mutable.ListBuffer[String]()
  val it = args.iterator
  while it.hasNext do
    it.next() match
      case "--models-from"         => modelsFrom = Some(it.next())
      case "--threads"             => threads = it.next().toInt
      case "--dry-run" | "--union" => ()
      case other                   => positional += other

  val listed = modelsFrom.toList.flatMap { p =>
    scala.io.Source.fromFile(p).getLines().map(_.trim).filter(_.nonEmpty).toList
  }
  val files = (resolveInputs(listed) ++ resolveInputs(positional.toList)).distinct.sortBy(_.getName)
  if files.isEmpty then
    System.err.println("Usage: scala-cli run collapse-reifications.scala -- <folder-or-ttl-files> [--models-from list.txt] [--union] [--dry-run] [--threads N]")
    sys.exit(1)

  System.err.println(s"Processing ${files.size} .ttl files on $threads threads" +
    s"${if union then " (union merge enabled)" else ""}${if dryRun then " (dry-run)" else ""} ...")

  // Counters are touched from worker threads; each model is independent and is
  // parsed/written by exactly one thread, so only the tallies need guarding.
  val modified = AtomicInteger(); val edges = AtomicInteger(); val reifs = AtomicInteger()
  val evs = AtomicInteger(); val merged = AtomicInteger(); val failed = AtomicInteger()
  val skipped = AtomicInteger(); val done = AtomicInteger()
  val lock = Object()
  def emit(line: String): Unit = lock.synchronized(println(line))

  val pool = Executors.newFixedThreadPool(threads)
  try
    val tasks: List[Callable[Unit]] = files.map { f =>
      () =>
        try
          val r = process(f, dryRun, union)
          if r.skipped then
            skipped.incrementAndGet()
            emit(s"skipped-delete\t${f.getName}")
          else if r.modified then
            modified.incrementAndGet()
            edges.addAndGet(r.edgesCollapsed); reifs.addAndGet(r.reifsRemoved)
            evs.addAndGet(r.evidenceRemoved); merged.addAndGet(r.unionMerged)
            emit(s"${if dryRun then "would modify" else "modified"}\t${f.getName}\tedges=${r.edgesCollapsed}\tunion_merged=${r.unionMerged}\treifs_removed=${r.reifsRemoved}\tevidence_removed=${r.evidenceRemoved}")
        catch
          case e: Throwable =>
            failed.incrementAndGet()
            System.err.println(s"FAILED ${f.getName}: ${e.getClass.getSimpleName}: ${e.getMessage}")
        val n = done.incrementAndGet()
        if n % 5000 == 0 then System.err.println(s"  $n/${files.size}")
    }
    // invokeAll blocks until every model is finished
    pool.invokeAll(tasks.asJava)
  finally
    pool.shutdown()

  System.err.println("---")
  System.err.println(s"files ${if dryRun then "that would change" else "modified"}: ${modified.get} / ${files.size}  (skipped delete-state: ${skipped.get}, failed: ${failed.get})")
  System.err.println(s"edges collapsed: ${edges.get} (of which union-merged: ${merged.get})   reifications removed: ${reifs.get}   evidence individuals removed: ${evs.get}")
  if failed.get > 0 then
    System.err.println(s"WARNING: ${failed.get} model(s) failed to process and were left unchanged.")
    sys.exit(1)
