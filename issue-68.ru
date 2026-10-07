# https://github.com/geneontology/noctua-models-migrations/issues/68
# Remove invisible characters from all literals in all models, e.g. the U+FEFF
# found trailing evidence-with IDs by the GOEx pipeline
# (https://github.com/geneontology/GOEx-pipeline/issues/2).
#
# Two kinds of character are handled differently:
#
# - Whitespace and control characters (tab and the other C0/C1 controls, no-break
#   space and the other Unicode space separators, line/paragraph separators) are
#   replaced with a regular space, so that text they separated is not run
#   together, e.g. "SGD:S000001904<TAB>SGD:S000004656,...". Line feed and
#   carriage return are left alone; they are deliberate line breaks in many
#   comments.
#
# - Zero-width format characters (BOM/zero width no-break space, zero width
#   space and joiners, soft hyphen, bidi marks and isolates, word joiner,
#   variation selectors, fillers) are deleted. They never displayed as a gap,
#   and a space in their place would still break the IDs they trail, e.g.
#   "PomBase:SPAC3G9.09c<U+FEFF>".
#
# A space this leaves in an evidence-with value, e.g. "<TAB>UniProtKB:P04637",
# is harmless: the GPAD export strips all whitespace from that column.
#
# The second update is a fallback for a Blazegraph quirk. Its lexicon keys short
# literals by a Unicode collation key in which zero-width characters don't
# count, so "MGI:95408<U+FEFF>" and "MGI:95408" are one and the same term, and
# whichever form entered the journal first is the one stored. Where the dirty
# form came first, deleting the character can't take: the cleaned literal
# resolves straight back to the dirty term. The second update finds those
# leftovers and replaces the character with a space instead, which is a
# distinct term (and stripped by the GPAD export).
#
# The patterns are Java regex syntax (\x{...}), which is what Blazegraph (and
# Jena) evaluate REPLACE with. REPLACE keeps the original literal's datatype or
# language tag. Running this a second time changes nothing.
#
# The paired issue-68.rq lists the first update's changes without making them;
# after the update it should return no rows.

DELETE {
  GRAPH ?model {
    ?subject ?property ?old .
  }
}
INSERT {
  GRAPH ?model {
    ?subject ?property ?new .
  }
}
WHERE {
  GRAPH ?model {
    ?subject ?property ?old .
    FILTER(isLiteral(?old))
    BIND(
      REPLACE(
        REPLACE(?old,
          "[\\x{0}-\\x{9}\\x{B}\\x{C}\\x{E}-\\x{1F}\\x{7F}-\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]",
          " "),
        "[\\x{AD}\\x{34F}\\x{61C}\\x{115F}\\x{1160}\\x{17B4}\\x{17B5}\\x{180B}-\\x{180F}\\x{200B}-\\x{200F}\\x{202A}-\\x{202E}\\x{2060}-\\x{206F}\\x{3164}\\x{FE00}-\\x{FE0F}\\x{FEFF}\\x{FFA0}\\x{FFF9}-\\x{FFFB}\\x{E0000}-\\x{E0FFF}]",
        "")
      AS ?new)
    FILTER(?new != ?old)
  }
}

;

# Fallback: zero-width characters the first update couldn't delete.
DELETE {
  GRAPH ?model {
    ?subject ?property ?old .
  }
}
INSERT {
  GRAPH ?model {
    ?subject ?property ?new .
  }
}
WHERE {
  GRAPH ?model {
    ?subject ?property ?old .
    FILTER(isLiteral(?old))
    BIND(
      REPLACE(?old,
        "[\\x{AD}\\x{34F}\\x{61C}\\x{115F}\\x{1160}\\x{17B4}\\x{17B5}\\x{180B}-\\x{180F}\\x{200B}-\\x{200F}\\x{202A}-\\x{202E}\\x{2060}-\\x{206F}\\x{3164}\\x{FE00}-\\x{FE0F}\\x{FEFF}\\x{FFA0}\\x{FFF9}-\\x{FFFB}\\x{E0000}-\\x{E0FFF}]",
        " ")
      AS ?new)
    FILTER(?new != ?old)
  }
}
