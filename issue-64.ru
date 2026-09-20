# https://github.com/geneontology/noctua-models-migrations/issues/64
# Retype unknown enablers from CHEBI:36080 'protein' and
# CHEBI:33695 'information biomacromolecule' to PR:000000001 'protein'.
# Scoped to individuals that are the object of an 'enabled by' assertion;
# uses of these classes elsewhere (e.g. 'has input'/'has output') are left alone.
#
# The declaration cleanup deliberately runs BEFORE the retyping. Ordered the
# other way round it could not tell a model this update just emptied from one
# that already had a PR:000000001 enabler and an orphan CHEBI declaration
# predating this migration, and it would sweep up the latter. Running first, it
# can name the models in scope by the very pattern the retyping matches, so no
# model list has to be hardcoded.

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX CHEBI: <http://purl.obolibrary.org/obo/CHEBI_>
PREFIX PR: <http://purl.obolibrary.org/obo/PR_>
PREFIX enabled_by: <http://purl.obolibrary.org/obo/RO_0002333>

DELETE {
  GRAPH ?model {
    ?old_type rdf:type owl:Class .
  }
}
WHERE {
  GRAPH ?model {
    VALUES ?old_type { CHEBI:36080 CHEBI:33695 }
    ?old_type rdf:type owl:Class .

    # Only models the retyping below actually touches, for this same class.
    ?activity enabled_by: ?enabler .
    ?enabler rdf:type ?old_type ;
      rdf:type owl:NamedIndividual .

    # ...and only where nothing surviving the retyping still needs the class:
    # no individual of this type other than the enablers about to be retyped,
    # and no other mention of the IRI anywhere in the model.
    FILTER NOT EXISTS {
      ?other rdf:type ?old_type .
      FILTER NOT EXISTS { ?other_activity enabled_by: ?other . }
    }
    FILTER NOT EXISTS { ?s ?p ?old_type . FILTER(?p != rdf:type) }
    FILTER NOT EXISTS { ?old_type ?p2 ?o2 . FILTER(?p2 != rdf:type) }
  }
}

;

DELETE {
  GRAPH ?model {
    ?enabler rdf:type ?old_type .
  }
}
INSERT {
  GRAPH ?model {
    ?enabler rdf:type PR:000000001 .
    PR:000000001 rdf:type owl:Class .
  }
}
WHERE {
  GRAPH ?model {
    VALUES ?old_type { CHEBI:36080 CHEBI:33695 }
    ?activity enabled_by: ?enabler .
    ?enabler rdf:type ?old_type ;
      rdf:type owl:NamedIndividual .
  }
}
