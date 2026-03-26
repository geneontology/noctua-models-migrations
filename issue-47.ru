PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX pav: <http://purl.org/pav/>
DELETE {
  GRAPH ?model {
    ?subject pav:providedBy ?from_id .
  }
}
INSERT {
  GRAPH ?model {
    ?subject pav:providedBy ?to_id .
  }
}
WHERE {
  GRAPH ?model {
    ?subject pav:providedBy ?from_id .
    VALUES (?from_id ?to_id) {
        ( "http://purl.obolibrary.org/go/groups/BHF-UCL" "http://www.ucl.ac.uk/functional-gene-annotation/cardiovascular"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/dictyBase" "http://dictybase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/FlyBase" "http://flybase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/GeneDB" "http://www.genedb.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/GO_Central" "http://geneontology.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/HGNC" "http://greekc.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/IntAct" "https://www.ebi.ac.uk/intact"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/InterPro" "https://www.ebi.ac.uk/interpro"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/MGI" "http://informatics.jax.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/NTNU_SB" "https://www.ntnu.edu"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/PINC" "https://www.proteomics.com"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/PomBase" "http://www.pombase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/Reactome" "https://reactome.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/RHEA" "https://www.rhea-db.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/SGD" "http://www.yeastgenome.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/UniProt" "https://www.uniprot.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/WB" "http://www.wormbase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/ZFIN" "http://zfin.org"^^xsd:string )

        ( "http://purl.obolibrary.org/go/groups/BHF-UCL"^^xsd:string "http://www.ucl.ac.uk/functional-gene-annotation/cardiovascular"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/dictyBase"^^xsd:string "http://dictybase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/FlyBase"^^xsd:string "http://flybase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/GeneDB"^^xsd:string "http://www.genedb.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/GO_Central"^^xsd:string "http://geneontology.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/HGNC"^^xsd:string "http://greekc.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/IntAct"^^xsd:string "https://www.ebi.ac.uk/intact"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/InterPro"^^xsd:string "https://www.ebi.ac.uk/interpro"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/MGI"^^xsd:string "http://informatics.jax.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/NTNU_SB"^^xsd:string "https://www.ntnu.edu"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/PINC"^^xsd:string "https://www.proteomics.com"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/PomBase"^^xsd:string "http://www.pombase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/Reactome"^^xsd:string "https://reactome.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/RHEA"^^xsd:string "https://www.rhea-db.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/SGD"^^xsd:string "http://www.yeastgenome.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/UniProt"^^xsd:string "https://www.uniprot.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/WB"^^xsd:string "http://www.wormbase.org"^^xsd:string )
        ( "http://purl.obolibrary.org/go/groups/ZFIN"^^xsd:string "http://zfin.org"^^xsd:string )
    }
  }
}
