# https://github.com/geneontology/noctua-models-migrations/issues/74
# Replace BFO:0000051 'has part' with RO:0019005 'has active component' between
# a protein-containing complex that enables an activity and its components
# (noctua#1133: curators agreed to the blanket change and will fix any edge
# where the component turns out to be accessory, RO:0019006, rather than active).
#
# A complex is recognized by its role, not its class: any individual that is the
# object of an 'enabled by' edge and the subject of a 'has part' edge. Besides GO
# protein-containing complex classes this catches complexes typed with
# ComplexPortal IRIs and SGD complex IDs. 'has part' from complexes that are not
# enablers (e.g. a complex that is an input) is left alone, as is 'has part'
# between other kinds of nodes (e.g. one activity having part another).
#
# The asserted edge and every owl:Axiom reifying it (with its evidence and
# other annotations) move to the new property together. Edges with no
# reification are migrated too.
#
# The 'has part' declaration cleanup runs BEFORE the migration, as in
# issue-64.ru: running first, it can name the models in scope by the same
# pattern the migration matches, and drop the declaration only where every use
# of 'has part' is about to be migrated. Run the other way round it could not
# tell those models from ones that already had an orphan declaration.
#
# The paired issue-74.rq lists the edges this changes; after the update it
# should return no rows.
#
# Tested 2026-11-24 on the 1,140 models in that day's noctua-models dump that
# mention 'has part', with minerva-cli --sparql-update against a scratch journal
# (and with Jena): 54,666 changes. 13,226 edges in 931 models (471 of them
# Reactome, 5 YeastPathways) and their 13,185 reifications moved to RO:0019005
# with annotations intact; 931 RO:0019005 declarations added; 913 'has part'
# declarations dropped. Nothing else changed.

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX has_part: <http://purl.obolibrary.org/obo/BFO_0000051>
PREFIX has_active_component: <http://purl.obolibrary.org/obo/RO_0019005>
PREFIX enabled_by: <http://purl.obolibrary.org/obo/RO_0002333>

DELETE {
  GRAPH ?model {
    has_part: rdf:type owl:ObjectProperty .
  }
}
WHERE {
  GRAPH ?model {
    has_part: rdf:type owl:ObjectProperty .

    # Only models the migration below actually touches.
    ?activity enabled_by: ?complex .
    ?complex has_part: ?part .

    # ...and only where nothing surviving the migration still needs 'has part':
    # no 'has part' edge or reification from a node that is not an enabler,
    # and no other mention of the IRI (e.g. in a class expression).
    FILTER NOT EXISTS {
      ?s has_part: ?o .
      FILTER NOT EXISTS { ?a enabled_by: ?s . }
    }
    FILTER NOT EXISTS {
      ?axiom owl:annotatedProperty has_part: ;
        owl:annotatedSource ?ax_source ;
        owl:annotatedTarget ?ax_target .
      FILTER NOT EXISTS {
        ?ax_activity enabled_by: ?ax_source .
        ?ax_source has_part: ?ax_target .
      }
    }
    FILTER NOT EXISTS { ?s2 ?p2 has_part: . FILTER(?p2 != owl:annotatedProperty) }
    FILTER NOT EXISTS { has_part: ?p3 ?o3 . FILTER(?p3 != rdf:type) }
  }
}

;

DELETE {
  GRAPH ?model {
    ?complex has_part: ?part .
    ?axiom owl:annotatedProperty has_part: .
  }
}
INSERT {
  GRAPH ?model {
    ?complex has_active_component: ?part .
    ?axiom owl:annotatedProperty has_active_component: .
    has_active_component: rdf:type owl:ObjectProperty .
  }
}
WHERE {
  GRAPH ?model {
    ?activity enabled_by: ?complex .
    ?complex has_part: ?part .
    OPTIONAL {
      ?axiom owl:annotatedSource ?complex ;
        owl:annotatedProperty has_part: ;
        owl:annotatedTarget ?part .
    }
  }
}
