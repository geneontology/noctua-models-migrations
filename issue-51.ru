PREFIX ECO: <http://purl.obolibrary.org/obo/ECO_>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

DELETE {
  GRAPH ?model {
    ?evidence dc:source ?ref .
  }
}
INSERT {
  GRAPH ?model {
    ?evidence dc:source "GO_REF:0000024"^^xsd:string .
  }
}
WHERE {
  GRAPH ?model {
    ?evidence a ECO:0000250 ;
      dc:source ?ref .
    FILTER(STR(?ref) = "GO_REF:0000043")
  }
}