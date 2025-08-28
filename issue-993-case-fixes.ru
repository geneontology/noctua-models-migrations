PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
DELETE {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?from_id .
  }
}
INSERT {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?to_id .
  }
}
WHERE {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?from_id .
    FILTER(isLiteral(?from_id))
    FILTER(CONTAINS(LCASE(?from_id), "uniprot:"))
    BIND(DATATYPE(?from_id) AS ?dt)
    BIND(STRDT(REPLACE(?from_id, "uniprot:", "UniProtKB:", "i"), ?dt) AS ?to_id)
    FILTER(?from_id != ?to_id)
  }
}
;
DELETE {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?from_id .
  }
}
INSERT {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?to_id .
  }
}
WHERE {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?from_id .
    FILTER(isLiteral(?from_id))
    FILTER(CONTAINS(LCASE(?from_id), "uniprotkb:"))
    BIND(DATATYPE(?from_id) AS ?dt)
    BIND(STRDT(REPLACE(?from_id, "uniprotkb:", "UniProtKB:", "i"), ?dt) AS ?to_id)
    FILTER(?from_id != ?to_id)
  }
}
;
DELETE {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?from_id .
  }
}
INSERT {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?to_id .
  }
}
WHERE {
  GRAPH ?model {
    ?subject <http://geneontology.org/lego/evidence-with> ?from_id .
    FILTER(isLiteral(?from_id))
    BIND(DATATYPE(?from_id) AS ?dt)
    BIND(STRDT(REPLACE(?from_id, "pombase:", "PomBase:", "i"), ?dt) AS ?to_id)
    FILTER(?from_id != ?to_id)
  }
}
