# See https://github.com/geneontology/noctua/issues/1132
#
# Replace every use of 'constitutively upstream of' (RO:0012009) with
# 'immediately constitutively upstream of' (RO:0019004), following the RO
# change in https://github.com/oborel/obo-relations/issues/884
#
# RO:0012009 appears in GO-CAM models in three places, each handled by one
# operation below:
#   1. the relation assertion between two activity individuals;
#   2. owl:annotatedProperty of the owl:Axiom that reifies that assertion
#      (this is what carries evidence, contributor, date, etc.);
#   3. the owl:ObjectProperty declaration triple.
# A fourth operation defensively covers owl:onProperty, in case the relation
# was ever used inside a class expression.

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX constitutively_upstream_of: <http://purl.obolibrary.org/obo/RO_0012009>
PREFIX immediately_constitutively_upstream_of: <http://purl.obolibrary.org/obo/RO_0019004>

# 1. Assertions between individuals.
DELETE {
  GRAPH ?model {
    ?subject constitutively_upstream_of: ?object .
  }
}
INSERT {
  GRAPH ?model {
    ?subject immediately_constitutively_upstream_of: ?object .
  }
}
WHERE {
  GRAPH ?model {
    ?subject constitutively_upstream_of: ?object .
  }
}
;
# 2. Reified axioms carrying evidence and other annotations on those assertions.
DELETE {
  GRAPH ?model {
    ?axiom owl:annotatedProperty constitutively_upstream_of: .
  }
}
INSERT {
  GRAPH ?model {
    ?axiom owl:annotatedProperty immediately_constitutively_upstream_of: .
  }
}
WHERE {
  GRAPH ?model {
    ?axiom owl:annotatedProperty constitutively_upstream_of: .
  }
}
;
# 3. Property declarations.
DELETE {
  GRAPH ?model {
    constitutively_upstream_of: rdf:type owl:ObjectProperty .
  }
}
INSERT {
  GRAPH ?model {
    immediately_constitutively_upstream_of: rdf:type owl:ObjectProperty .
  }
}
WHERE {
  GRAPH ?model {
    constitutively_upstream_of: rdf:type owl:ObjectProperty .
  }
}
;
# 4. Class expressions (defensive; no current uses in the model dump).
DELETE {
  GRAPH ?model {
    ?restriction owl:onProperty constitutively_upstream_of: .
  }
}
INSERT {
  GRAPH ?model {
    ?restriction owl:onProperty immediately_constitutively_upstream_of: .
  }
}
WHERE {
  GRAPH ?model {
    ?restriction owl:onProperty constitutively_upstream_of: .
  }
}
