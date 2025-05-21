PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
DELETE {
  GRAPH ?model {
    ?model biolink:in_taxon ?current_taxon .
  }
}
WHERE {
  VALUES ?model {
    <http://model.geneontology.org/5e72450500004237>
    <http://model.geneontology.org/5ee8120100000250>
    <http://model.geneontology.org/5f46c3b700002579>
    <http://model.geneontology.org/5f46c3b700004400>
    <http://model.geneontology.org/5fadbcf000002129>
    <http://model.geneontology.org/6086f4f200000298>
    <http://model.geneontology.org/60ad85f700000058>
    <http://model.geneontology.org/60ad85f700000612>
    <http://model.geneontology.org/60ad85f700002009>
    <http://model.geneontology.org/60ad85f700002598>
    <http://model.geneontology.org/60ad85f700002598>
    <http://model.geneontology.org/60ad85f700002598>
    <http://model.geneontology.org/6115be0900000430>
    <http://model.geneontology.org/61452e3d00000669>
    <http://model.geneontology.org/6205c24300000880>
    <http://model.geneontology.org/62183af000000536>
    <http://model.geneontology.org/627d95ee00001431>
    <http://model.geneontology.org/62900b6400001132>
    <http://model.geneontology.org/62900b6400001631>
    <http://model.geneontology.org/62b4ffe300000418>
    <http://model.geneontology.org/62b4ffe300002340>
    <http://model.geneontology.org/62b4ffe300002544>
    <http://model.geneontology.org/62b4ffe300002596>
    <http://model.geneontology.org/62b4ffe300002925>
    <http://model.geneontology.org/62b4ffe300003513>
    <http://model.geneontology.org/62b4ffe300005181>
    <http://model.geneontology.org/62e3212700001602>
    <http://model.geneontology.org/62f58d8800000011>
    <http://model.geneontology.org/62f58d8800000841>
    <http://model.geneontology.org/62f58d8800000841>
    <http://model.geneontology.org/62f58d8800000934>
    <http://model.geneontology.org/62f58d8800001022>
    <http://model.geneontology.org/62f58d8800001316>
    <http://model.geneontology.org/62f58d8800001368>
    <http://model.geneontology.org/62f58d8800001368>
    <http://model.geneontology.org/62f58d8800002115>
    <http://model.geneontology.org/62f58d8800002151>
    <http://model.geneontology.org/62f58d8800002151>
    <http://model.geneontology.org/62f58d8800002207>
    <http://model.geneontology.org/62f58d8800002485>
    <http://model.geneontology.org/62f58d8800004747>
    <http://model.geneontology.org/62f58d8800005908>
    <http://model.geneontology.org/62f58d8800006008>
    <http://model.geneontology.org/62f58d8800006248>
    <http://model.geneontology.org/62f58d8800006555>
    <http://model.geneontology.org/62f58d8800007064>
    <http://model.geneontology.org/633b013300000887>
    <http://model.geneontology.org/6348a65d00000519>
    <http://model.geneontology.org/6348a65d00000552>
    <http://model.geneontology.org/6348a65d00000809>
    <http://model.geneontology.org/6348a65d00002206>
    <http://model.geneontology.org/635b1e3e00002404>
    <http://model.geneontology.org/636d9ce800000749>
    <http://model.geneontology.org/63894f2500000826>
    <http://model.geneontology.org/63894f2500001789>
    <http://model.geneontology.org/63c0ac2b00000088>
    <http://model.geneontology.org/63c0ac2b00000464>
    <http://model.geneontology.org/63d320cd00000225>
    <http://model.geneontology.org/63e5937500000487>
    <http://model.geneontology.org/63e5937500001029>
    <http://model.geneontology.org/63f809ec00001167>
    <http://model.geneontology.org/6438950a00000074>
    <http://model.geneontology.org/645d887900000439>
    <http://model.geneontology.org/6494e2e900000134>
    <http://model.geneontology.org/6494e2e900002525>
    <http://model.geneontology.org/64d5781900001969>
    <http://model.geneontology.org/653b0ce600001230>
    <http://model.geneontology.org/65692e7e00000049>
    <http://model.geneontology.org/65692e7e00001542>
    <http://model.geneontology.org/657ba49f00000239>
    <http://model.geneontology.org/657ba49f00001402>
    <http://model.geneontology.org/65a1f4f800000368>
    <http://model.geneontology.org/65d7e4ac00002290>
    <http://model.geneontology.org/66187e4700000246>
    <http://model.geneontology.org/662af8fa00002332>
    <http://model.geneontology.org/663d668500000296>
    <http://model.geneontology.org/66b5638000002528>
    <http://model.geneontology.org/66b5638000002719>
    <http://model.geneontology.org/66b5638000002847>
    <http://model.geneontology.org/66c7d41500000754>
    <http://model.geneontology.org/66c7d41500000754>
    <http://model.geneontology.org/671ae02600001912>
    <http://model.geneontology.org/678073a900000226>
    <http://model.geneontology.org/678073a900000255>
    <http://model.geneontology.org/678073a900000353>
    <http://model.geneontology.org/678073a900001100>
    <http://model.geneontology.org/678073a900002053>
    <http://model.geneontology.org/6796b94c00006045>
    <http://model.geneontology.org/6796b94c00006250>
    <http://model.geneontology.org/67b1629100003101>
    <http://model.geneontology.org/67c10cc400009138>
    <http://model.geneontology.org/67e5e74400004286>
    <http://model.geneontology.org/MGI_MGI_1915183>
    <http://model.geneontology.org/MGI_MGI_1924903>
    <http://model.geneontology.org/YeastPathways_LYSDEGII-PWY>
    <http://model.geneontology.org/YeastPathways_PWY3O-1109>
 }
 GRAPH ?model {
   ?model biolink:in_taxon ?current_taxon .
 }
}
;
INSERT {
  GRAPH ?model { ?model biolink:in_taxon ?taxon }
}
WHERE {
  VALUES (?model ?taxon) {
    ( <http://model.geneontology.org/5e72450500004237> obo:NCBITaxon_2697049 )
    ( <http://model.geneontology.org/5ee8120100000250> obo:NCBITaxon_8355 )
    ( <http://model.geneontology.org/5f46c3b700002579> obo:NCBITaxon_8355 )
    ( <http://model.geneontology.org/5f46c3b700004400> obo:NCBITaxon_10116 )
    ( <http://model.geneontology.org/5fadbcf000002129> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/6086f4f200000298> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/60ad85f700000058> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/60ad85f700000612> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/60ad85f700002009> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/60ad85f700002598> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/6115be0900000430> obo:NCBITaxon_559292 )
    ( <http://model.geneontology.org/61452e3d00000669> obo:NCBITaxon_559292 )
    ( <http://model.geneontology.org/6205c24300000880> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62183af000000536> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/627d95ee00001431> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/62900b6400001132> obo:NCBITaxon_8355 )
    ( <http://model.geneontology.org/62b4ffe300000418> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62b4ffe300005181> obo:NCBITaxon_587200 )
    ( <http://model.geneontology.org/62b4ffe300005181> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62e3212700001602> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800000011> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800000841> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/62f58d8800000934> obo:NCBITaxon_11706 )
    ( <http://model.geneontology.org/62f58d8800000934> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800001022> obo:NCBITaxon_928302 )
    ( <http://model.geneontology.org/62f58d8800001022> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800001316> obo:NCBITaxon_11208 )
    ( <http://model.geneontology.org/62f58d8800001316> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800001368> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800002115> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800002151> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800002207> obo:NCBITaxon_226186 )
    ( <http://model.geneontology.org/62f58d8800002207> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800002485> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800004747> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800005908> obo:NCBITaxon_10360 )
    ( <http://model.geneontology.org/62f58d8800005908> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800006008> obo:NCBITaxon_10377 )
    ( <http://model.geneontology.org/62f58d8800006008> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800006248> obo:NCBITaxon_479437 )
    ( <http://model.geneontology.org/62f58d8800006248> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/62f58d8800007064> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/633b013300000887> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/633b013300000887> obo:NCBITaxon_226186 )
    ( <http://model.geneontology.org/6348a65d00000519> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/6348a65d00000552> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/6348a65d00000809> obo:NCBITaxon_390333 )
    ( <http://model.geneontology.org/6348a65d00000809> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/6348a65d00002206> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/635b1e3e00002404> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/636d9ce800000749> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/63894f2500000826> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/63894f2500001789> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/63c0ac2b00000088> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/63c0ac2b00000464> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/63d320cd00000225> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/63e5937500000487> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/63e5937500001029> obo:NCBITaxon_2697049 )
    ( <http://model.geneontology.org/63e5937500001029> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/63f809ec00001167> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/6438950a00000074> obo:NCBITaxon_694067 )
    ( <http://model.geneontology.org/6438950a00000074> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/645d887900000439> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/6494e2e900000134> obo:NCBITaxon_1392 )
    ( <http://model.geneontology.org/6494e2e900000134> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/6494e2e900002525> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/64d5781900001969> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/653b0ce600001230> obo:NCBITaxon_868565 )
    ( <http://model.geneontology.org/653b0ce600001230> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/65692e7e00000049> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/65692e7e00001542> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/657ba49f00000239> obo:NCBITaxon_7227 )
    ( <http://model.geneontology.org/657ba49f00001402> obo:NCBITaxon_7227 )
    ( <http://model.geneontology.org/65a1f4f800000368> obo:NCBITaxon_7227 )
    ( <http://model.geneontology.org/65d7e4ac00002290> obo:NCBITaxon_7227 )
    ( <http://model.geneontology.org/66187e4700000246> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/662af8fa00002332> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/663d668500000296> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/66b5638000002528> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/66b5638000002719> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/66b5638000002847> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/66c7d41500000754> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/671ae02600001912> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/678073a900000226> obo:NCBITaxon_10116 )
    ( <http://model.geneontology.org/678073a900000255> obo:NCBITaxon_10116 )
    ( <http://model.geneontology.org/678073a900000353> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/678073a900001100> obo:NCBITaxon_10116 )
    ( <http://model.geneontology.org/678073a900002053> obo:NCBITaxon_10090 )
    ( <http://model.geneontology.org/6796b94c00006045> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/6796b94c00006250> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/67b1629100003101> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/67c10cc400009138> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/67e5e74400004286> obo:NCBITaxon_9606 )
    ( <http://model.geneontology.org/MGI_MGI_1915183> obo:NCBITaxon_10090 )
  }
}
