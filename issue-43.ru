PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX lego: <http://geneontology.org/lego/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX UniProtKB: <http://identifiers.org/uniprot/>
PREFIX enabled_by: <http://purl.obolibrary.org/obo/RO_0002333>
PREFIX occurs_in: <http://purl.obolibrary.org/obo/BFO_0000066>
PREFIX cytoplasmic_side_of_plasma_membrane: <http://purl.obolibrary.org/obo/GO_0009898>
DELETE {
  GRAPH ?model {
    ?cc rdf:type ?cc_type .
  }
}
INSERT {
  GRAPH ?model {
    ?cc rdf:type cytoplasmic_side_of_plasma_membrane: .
  }
}
WHERE {
  GRAPH ?model {
    VALUES ?gp_type { UniProtKB:P63092 UniProtKB:P63096 UniProtKB::P50148 }
    ?gp rdf:type ?gp_type .
    ?mf enabled_by: ?gp .
    ?mf occurs_in: ?cc .
    ?cc rdf:type ?cc_type .
    FILTER(STRSTARTS(STR(?cc_type), "http://purl.obolibrary.org/obo/GO_"))
  }
}
;
DELETE {
  GRAPH ?model {
    ?evidence rdf:type ?evidence_type .
    ?evidence dc:source ?reference .
  }
}
INSERT {
  GRAPH ?model {
    ?evidence rdf:type obo:ECO_0000314 .
    ?evidence dc:source "PMID:12135370" .
  }
}
WHERE {
  GRAPH ?model {
    VALUES ?gp_type { UniProtKB:P63092 }
    ?gp rdf:type ?gp_type .
    ?mf enabled_by: ?gp .
    ?mf occurs_in: ?cc .
    ?cc rdf:type ?cc_type .
    ?axiom rdf:type owl:Axiom ;
        owl:annotatedSource ?mf ;
        owl:annotatedProperty occurs_in: ;
        owl:annotatedTarget ?cc ;
        lego:evidence ?evidence .
    ?evidence rdf:type ?evidence_type .
    ?evidence dc:source ?reference .
    FILTER(STRSTARTS(STR(?evidence_type), "http://purl.obolibrary.org/obo/ECO_"))
  }
}
