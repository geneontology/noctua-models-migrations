# https://github.com/geneontology/noctua-models/issues/370
# remove-disconnected-individuals.ru scoped to the three go-cam-drop-box models ported
# on 2026-09-24 (noctua#1134): deletes their 14 orphan evidence individuals
# (noctua-models#367, #368, #369). Same pattern as the check query; nothing else in
# those models is disconnected. Tested locally on the three files: 85 changes.
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
        VALUES ?model {
            <http://model.geneontology.org/6a6ba88c00001743>
            <http://model.geneontology.org/6a6ba88c00001637>
            <http://model.geneontology.org/6a6ba88c00000472>
        }
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
