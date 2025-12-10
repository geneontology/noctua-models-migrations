PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX lego: <http://geneontology.org/lego/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
DELETE {
  GRAPH ?model {
    ?evidence rdf:type ?evidence_class .
    ?evidence lego:evidence-with ?old_with .
    ?evidence dc:source ?pathway .
  }
}
INSERT {
  GRAPH ?model {
    ?model rdfs:comment "Automatically updated evidence code, reference, and With/From value 2025-12-11." .
    obo:ECO_0000245 rdf:type owl:Class .
    ?evidence rdf:type obo:ECO_0000245 .
    ?evidence lego:evidence-with ?pathway .
    ?evidence dc:source "GO_REF:0000123" .
  }
}
WHERE {
  GRAPH ?model {
    ?evidence dc:source ?pathway .
    FILTER(STRSTARTS(?pathway, "SGD_PWY:"))
    ?evidence rdf:type ?evidence_class .
    FILTER(STRSTARTS(STR(?evidence_class), "http://purl.obolibrary.org/obo/ECO_"))
    OPTIONAL {
        ?evidence lego:evidence-with ?old_with .
    }
  }
}
