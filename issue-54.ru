PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

DELETE {
  GRAPH ?model {
    ?subject dc:contributor ?from_id .
  }
}
INSERT {
  GRAPH ?model {
    ?subject dc:contributor ?to_id .
  }
}
WHERE {
  GRAPH ?model {
    ?subject dc:contributor ?from_id .
    VALUES (?from_id ?to_id) {
      ( "GOC:ab" "https://orcid.org/0000-0003-2148-9135"^^xsd:string )
      ( "GOC:als" "https://orcid.org/0000-0003-3829-1600"^^xsd:string )
      ( "GOC:dos" "https://orcid.org/0000-0002-7073-9172"^^xsd:string )
      ( "GOC:dr" "https://orcid.org/0000-0002-4945-5837"^^xsd:string )
      ( "GOC:hm" "https://orcid.org/0000-0001-8721-202X"^^xsd:string )
      ( "GOC:kltm" "https://orcid.org/0000-0001-8244-1536"^^xsd:string )
      ( "GOC:kmv" "https://orcid.org/0000-0002-1706-4196"^^xsd:string )
      ( "GOC:lb" "https://orcid.org/0000-0002-8075-8625"^^xsd:string )
      ( "GOC:pde" "https://orcid.org/0000-0002-5494-626X"^^xsd:string )
      ( "GOC:pt" "https://orcid.org/0000-0002-9074-3507"^^xsd:string )
      ( "GOC:sjc" "https://orcid.org/0000-0001-8244-1536"^^xsd:string )
      ( "GOC:sp" "https://orcid.org/0000-0001-7299-6685"^^xsd:string )

      ( "GOC:ab"^^xsd:string "https://orcid.org/0000-0003-2148-9135"^^xsd:string )
      ( "GOC:als"^^xsd:string "https://orcid.org/0000-0003-3829-1600"^^xsd:string )
      ( "GOC:dos"^^xsd:string "https://orcid.org/0000-0002-7073-9172"^^xsd:string )
      ( "GOC:dr"^^xsd:string "https://orcid.org/0000-0002-4945-5837"^^xsd:string )
      ( "GOC:hm"^^xsd:string "https://orcid.org/0000-0001-8721-202X"^^xsd:string )
      ( "GOC:kltm"^^xsd:string "https://orcid.org/0000-0001-8244-1536"^^xsd:string )
      ( "GOC:kmv"^^xsd:string "https://orcid.org/0000-0002-1706-4196"^^xsd:string )
      ( "GOC:lb"^^xsd:string "https://orcid.org/0000-0002-8075-8625"^^xsd:string )
      ( "GOC:pde"^^xsd:string "https://orcid.org/0000-0002-5494-626X"^^xsd:string )
      ( "GOC:pt"^^xsd:string "https://orcid.org/0000-0002-9074-3507"^^xsd:string )
      ( "GOC:sjc"^^xsd:string "https://orcid.org/0000-0001-8244-1536"^^xsd:string )
      ( "GOC:sp"^^xsd:string "https://orcid.org/0000-0001-7299-6685"^^xsd:string )
    }
  }
}
