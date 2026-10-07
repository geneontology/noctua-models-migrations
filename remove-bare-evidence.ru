# Remove lego:evidence references to "bare" IRIs: evidence individuals that no
# longer exist in the model. The IRI is still listed as evidence on an edge's
# owl:Axiom, but nothing in the model describes it (no type, no ECO class, no
# source, nothing). For example, in gomodel:5fadbcf000000632 the RO_0002333 edge
# :5fadbcf000000819 -> :5fadbcf000000820 lists :5fadbcf000000826 as evidence.
# That ECO_0000314 individual has been gone from the model since 2026-02-27.
#
# These seem to be left behind when an evidence individual shared by several
# edges is deleted: references from the other edges' axioms are not cleaned up.
# delete-ghost-nodes.ru fixed earlier cases by listing the IRIs; this update
# finds them by pattern instead, so it can be rerun.
#
# Only the dangling lego:evidence triple is deleted. The axiom keeps its other
# evidence and annotations. An IRI counts as bare only if it is not the subject
# of any triple in the same model, so an evidence node that is merely missing
# its type is left alone.
#
# The paired query-bare-evidence.rq lists the triples this deletes; after the
# update it should return no rows.

PREFIX lego: <http://geneontology.org/lego/>

DELETE {
  GRAPH ?model {
    ?axiom lego:evidence ?evidence .
  }
}
WHERE {
  GRAPH ?model {
    ?axiom lego:evidence ?evidence .
    FILTER(isIRI(?evidence))
    FILTER NOT EXISTS {
      ?evidence ?property ?value .
    }
  }
}
