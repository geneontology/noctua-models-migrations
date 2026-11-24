# https://github.com/geneontology/noctua-models-migrations/issues/71
# Trim leading and trailing whitespace from all literals in all models, e.g. the
# dc:source " PMID:27060109" throughout gomodel:65288b2200000869. Noctua no
# longer accepts such values, but older ones remain: in the 2026-11-24 dump,
# 42,528 literals in 3,089 models, mostly rdfs:comment, plus dc:contributor
# (" https://orcid.org/..."), lego:evidence-with, dc:source and dc:title.
#
# Whitespace here is the Unicode White_Space set: tab, line feed and the other
# C0 separators, space, next line, no-break space and the other space
# separators, and the line/paragraph separators. Whitespace inside a value,
# such as the line breaks in a multi-line comment, is left alone.
#
# Tabs are left alone in tab-separated annotation rows imported from legacy
# files, where they are column separators. These are GAF rows that end with a
# tab after the 17th column, e.g. the dc:source
# "MGI<TAB>MGI:2151070<TAB>Ophn1<TAB>...<TAB>VEGA:OTTMUSP00000019600<TAB>";
# keeping that tab leaves each row exactly as imported. As in issue-68.ru, such
# a row is recognized as a literal with 10 or more tabs.
#
# There are three updates:
#
# 1. Delete values that are nothing but whitespace, which trimming would leave
#    empty. In the dump these are 3 lego:evidence-with values (" " and "\n"),
#    which is optional on an evidence (go-cam-shapes.shex).
#
# 2. Trim.
#
# 3. The issue-68.ru fallback again, for Blazegraph's lexicon quirk (see
#    issue-68.ru): it keys short literals by a collation key in which
#    zero-width characters don't count, and keeps whichever form of a key
#    entered the journal first. issue-68.ru couldn't delete the U+FEFF from 37
#    lego:evidence-with values (9 distinct, e.g. "MGI:95408<U+FEFF>"), because
#    the cleaned value resolved straight back to the dirty term, so it put a
#    space in its place ("MGI:95408 "). Trimming that space runs into the same
#    thing if the journal still holds the dirty term: the trimmed value comes
#    back with the U+FEFF. This update turns it into a space again, leaving
#    those values exactly as they were. They can only be trimmed for good in a
#    journal reloaded from the model files, whose lexicon has no dirty terms.
#    Where the trimmed value isn't held by a dirty term, this update finds
#    nothing to do: no literal in the 2026-11-24 dump has a zero-width
#    character.
#
# The patterns are Java regex syntax (\x{...}), which is what Blazegraph (and
# Jena) evaluate REGEX and REPLACE with. REPLACE keeps the original literal's
# datatype or language tag. (STR() because Blazegraph's REGEX rejects literals
# typed xsd:string.) Running this a second time changes nothing, though
# minerva-cli still counts the trim and restore of any issue-68.ru leftovers
# (4 changes each) in its "Applied N changes".

DELETE {
  GRAPH ?model {
    ?subject ?property ?old .
  }
}
WHERE {
  GRAPH ?model {
    ?subject ?property ?old .
    FILTER(isLiteral(?old))
    FILTER(REGEX(STR(?old), "^[\\x{9}-\\x{D}\\x{20}\\x{85}\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]+$"))
  }
}

;

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
    FILTER(REGEX(STR(?old), "^[\\x{9}-\\x{D}\\x{20}\\x{85}\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]|[\\x{9}-\\x{D}\\x{20}\\x{85}\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]$"))
    # In tab-separated annotation rows, trim everything but tabs.
    BIND(
      IF(REGEX(STR(?old), "(\\t[^\\t]*){10}"),
        REPLACE(?old, "^[\\x{A}-\\x{D}\\x{20}\\x{85}\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]+|[\\x{A}-\\x{D}\\x{20}\\x{85}\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]+$", ""),
        REPLACE(?old, "^[\\x{9}-\\x{D}\\x{20}\\x{85}\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]+|[\\x{9}-\\x{D}\\x{20}\\x{85}\\x{A0}\\x{1680}\\x{2000}-\\x{200A}\\x{2028}\\x{2029}\\x{202F}\\x{205F}\\x{3000}]+$", ""))
      AS ?new)
    FILTER(?new != ?old)
  }
}

;

# Fallback: trimmed values that came back with a zero-width character
# (same as the second update in issue-68.ru).
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
