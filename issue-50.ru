PREFIX GO: <http://purl.obolibrary.org/obo/GO_>
PREFIX ECO: <http://purl.obolibrary.org/obo/ECO_>
PREFIX lego: <http://geneontology.org/lego/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

DELETE {
    GRAPH ?model {
        ?evidence dc:source ?ref .
    }
}
INSERT {
    GRAPH ?model {
        ?evidence dc:source "GO_REF:0000015"^^xsd:string .
    }
}
WHERE {
    GRAPH ?model {
        VALUES ?root_term {
            GO:0003674
            GO:0005575
            GO:0008150
        }
        ?go_node a ?root_term .
        { 
            ?other_node ?p ?go_node .
            ?axiom a owl:Axiom ;
               owl:annotatedSource ?other_node ;
               owl:annotatedProperty ?p ;
               owl:annotatedTarget ?go_node ;
               lego:evidence ?evidence .
        }
        UNION
        {
            ?go_node ?p ?other_node .
            ?axiom a owl:Axiom ;
               owl:annotatedSource ?go_node ;
               owl:annotatedProperty ?p ;
               owl:annotatedTarget ?other_node ;
               lego:evidence ?evidence .
        }
        ?evidence a ECO:0000307 .
        ?evidence dc:source ?ref .
        FILTER(?ref != "GO_REF:0000015")
    }
}
