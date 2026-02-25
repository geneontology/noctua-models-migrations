DELETE {
    GRAPH ?model {
        ?s ?p ?ghost .
    }
}
WHERE {
  GRAPH ?model {
    VALUES ?ghost {
        <http://model.geneontology.org/693b3c0900004140/6994852c00002782>
        <http://model.geneontology.org/693b3c0900004140/6994852c00002783>
        <http://model.geneontology.org/696022cd00002025/696022cd00004021>
        <http://model.geneontology.org/696022cd00002025/696022cd00004021>
    }
    ?s ?p ?ghost .
  }
}
