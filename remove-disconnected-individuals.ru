PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX pav: <http://purl.org/pav/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

DELETE {
    GRAPH ?model {
        ?individual ?p ?o .
    }
}
WHERE {
    GRAPH ?model {
        ?individual a owl:NamedIndividual .
        ?individual ?p ?o .
        MINUS {
            ?model pav:providedBy "https://reactome.org" .
        }
        MINUS {
            ?model pav:providedBy "https://reactome.org"^^xsd:string .
        }
        MINUS {
            ?subj ?rel1 ?individual .
        }
        MINUS {
            [
                owl:annotatedSource ?subjA ;
                owl:annotatedProperty ?rel1A ;
                owl:annotatedTarget ?individual
            ] .
        }
        MINUS {
            ?individual ?rel2 ?obj .
            ?obj a owl:NamedIndividual .
        }
        MINUS {
            [
                owl:annotatedSource ?individual ;
                owl:annotatedProperty ?rel2A ;
                owl:annotatedTarget ?objA
            ] .
            ?objA a owl:NamedIndividual ;
        }
        FILTER(!CONTAINS(STR(?model), "YeastPathways"))
    }
}
