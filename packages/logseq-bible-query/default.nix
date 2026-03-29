{ pkgs, ... }:

pkgs.writeShellScriptBin "logseq-bible-query" ''
  #!/bin/bash

  # ================================
  # BIBLE DATA
  # Format: BOOK_chapters[BookName_chapter]=verseCount
  # ================================
  declare -A BOOK_ABBREVS=(
    ["Gen."]="Genesis" ["Ge."]="Genesis" ["Gn."]="Genesis"
    ["Ex."]="Exodus" ["Exod."]="Exodus"
    ["Lev."]="Leviticus" ["Le."]="Leviticus" ["Lv."]="Leviticus"
    ["Num."]="Numbers" ["Nu."]="Numbers" ["Nm."]="Numbers"
    ["Deut."]="Deuteronomy" ["De."]="Deuteronomy" ["Dt."]="Deuteronomy"
    ["Josh."]="Joshua" ["Jos."]="Joshua" ["Jsh."]="Joshua"
    ["Judg."]="Judges" ["Jdg."]="Judges" ["Jgs."]="Judges" ["Jg."]="Judges"
    ["Ru."]="Ruth"
    ["1 Sam."]="1 Samuel" ["1 Sa."]="1 Samuel" ["I Sam."]="1 Samuel" ["I Sa."]="1 Samuel" ["1Sam."]="1 Samuel" ["1Sa."]="1 Samuel" ["1st Samuel"]="1 Samuel" ["First Samuel"]="1 Samuel"
    ["2 Sam."]="2 Samuel" ["2 Sa."]="2 Samuel" ["II Sam."]="2 Samuel" ["II Sa."]="2 Samuel" ["2Sam."]="2 Samuel" ["2Sa."]="2 Samuel" ["2nd Samuel"]="2 Samuel" ["Second Samuel"]="2 Samuel"
    ["1 Ki."]="1 Kings" ["I Kings"]="1 Kings" ["I Ki."]="1 Kings" ["1Ki."]="1 Kings" ["1st Kings"]="1 Kings" ["First Kings"]="1 Kings"
    ["2 Ki."]="2 Kings" ["II Kings"]="2 Kings" ["II Ki."]="2 Kings" ["2Ki."]="2 Kings" ["2nd Kings"]="2 Kings" ["Second Kings"]="2 Kings"
    ["1 Chron."]="1 Chronicles" ["1 Ch."]="1 Chronicles" ["I Chron."]="1 Chronicles" ["I Ch."]="1 Chronicles" ["1Chron."]="1 Chronicles" ["1Ch."]="1 Chronicles" ["1st Chronicles"]="1 Chronicles" ["First Chronicles"]="1 Chronicles"
    ["2 Chron."]="2 Chronicles" ["2 Ch."]="2 Chronicles" ["II Chron."]="2 Chronicles" ["II Ch."]="2 Chronicles" ["2Chron."]="2 Chronicles" ["2Ch."]="2 Chronicles" ["2nd Chronicles"]="2 Chronicles" ["Second Chronicles"]="2 Chronicles"
    ["Ezr."]="Ezra"
    ["Neh."]="Nehemiah" ["Ne."]="Nehemiah"
    ["Esth."]="Esther" ["Est."]="Esther"
    ["Jb."]="Job"
    ["Ps."]="Psalms" ["Psa."]="Psalms" ["Psm."]="Psalms" ["Pss."]="Psalms"
    ["Prov."]="Proverbs" ["Pr."]="Proverbs" ["Prv."]="Proverbs" ["Pro."]="Proverbs"
    ["Eccl."]="Ecclesiastes" ["Ecc."]="Ecclesiastes" ["Ec."]="Ecclesiastes" ["Qo."]="Ecclesiastes"
    ["Song of Sol."]="Song of Solomon" ["SOS."]="Song of Solomon" ["So."]="Song of Solomon" ["Son."]="Song of Solomon" ["Song"]="Song of Solomon" ["Can."]="Song of Solomon" ["Cant."]="Song of Solomon"
    ["Is."]="Isaiah" ["Isa."]="Isaiah"
    ["Jer."]="Jeremiah" ["Je."]="Jeremiah" ["Jr."]="Jeremiah"
    ["Lam."]="Lamentations" ["La."]="Lamentations"
    ["Ezek."]="Ezekiel" ["Ezk."]="Ezekiel" ["Ez."]="Ezekiel"
    ["Dan."]="Daniel" ["Da."]="Daniel" ["Dn."]="Daniel"
    ["Hos."]="Hosea" ["Ho."]="Hosea"
    ["Joe."]="Joel" ["Jl."]="Joel"
    ["Am."]="Amos"
    ["Obad."]="Obadiah" ["Ob."]="Obadiah" ["Abd."]="Obadiah"
    ["Jon."]="Jonah" ["Jnh."]="Jonah"
    ["Mic."]="Micah" ["Mc."]="Micah"
    ["Nah."]="Nahum" ["Na."]="Nahum"
    ["Hab."]="Habakkuk" ["Hb."]="Habakkuk"
    ["Zeph."]="Zephaniah" ["Zep."]="Zephaniah" ["Zp."]="Zephaniah"
    ["Hag."]="Haggai" ["Hg."]="Haggai"
    ["Zech."]="Zechariah" ["Zec."]="Zechariah" ["Zc."]="Zechariah"
    ["Mal."]="Malachi" ["Ml."]="Malachi"
    # New Testament
    ["Matt."]="Matthew" ["Mt."]="Matthew"
    ["Mrk"]="Mark" ["Mar"]="Mark" ["Mk"]="Mark" ["Mr"]="Mark"
    ["Luk"]="Luke" ["Lk"]="Luke"
    ["Joh"]="John" ["Jhn"]="John" ["Jn"]="John"
    ["Act"]="Acts" ["Ac"]="Acts"
    ["Rom."]="Romans" ["Ro."]="Romans" ["Rm."]="Romans"
    ["1 Cor."]="1 Corinthians" ["1 Co."]="1 Corinthians" ["I Cor."]="1 Corinthians" ["I Co."]="1 Corinthians" ["1Cor."]="1 Corinthians" ["1Co."]="1 Corinthians" ["1st Corinthians"]="1 Corinthians" ["First Corinthians"]="1 Corinthians"
    ["2 Cor."]="2 Corinthians" ["2 Co."]="2 Corinthians" ["II Cor."]="2 Corinthians" ["II Co."]="2 Corinthians" ["2Cor."]="2 Corinthians" ["2Co."]="2 Corinthians" ["2nd Corinthians"]="2 Corinthians" ["Second Corinthians"]="2 Corinthians"
    ["Gal."]="Galatians" ["Ga."]="Galatians"
    ["Eph."]="Ephesians" ["Ephes."]="Ephesians"
    ["Phil."]="Philippians" ["Php."]="Philippians" ["Pp."]="Philippians"
    ["Col."]="Colossians"
    ["1 Thess."]="1 Thessalonians" ["1 Thes."]="1 Thessalonians" ["1 Th."]="1 Thessalonians" ["I Thess."]="1 Thessalonians" ["1Thess."]="1 Thessalonians" ["1st Thessalonians"]="1 Thessalonians" ["First Thessalonians"]="1 Thessalonians"
    ["2 Thess."]="2 Thessalonians" ["2 Thes."]="2 Thessalonians" ["2 Th."]="2 Thessalonians" ["II Thess."]="2 Thessalonians" ["2Thess."]="2 Thessalonians" ["2nd Thessalonians"]="2 Thessalonians" ["Second Thessalonians"]="2 Thessalonians"
    ["1 Tim."]="1 Timothy" ["1 Ti."]="1 Timothy" ["I Timothy"]="1 Timothy" ["I Tim."]="1 Timothy" ["1Tim."]="1 Timothy" ["1st Timothy"]="1 Timothy" ["First Timothy"]="1 Timothy"
    ["2 Tim."]="2 Timothy" ["2 Ti."]="2 Timothy" ["II Timothy"]="2 Timothy" ["II Tim."]="2 Timothy" ["2Tim."]="2 Timothy" ["2nd Timothy"]="2 Timothy" ["Second Timothy"]="2 Timothy"
    ["Tit"]="Titus"
    ["Philem."]="Philemon" ["Phm."]="Philemon" ["Pm."]="Philemon"
    ["Heb."]="Hebrews"
    ["Jas"]="James" ["Jm"]="James"
    ["1 Pet."]="1 Peter" ["1 Pe."]="1 Peter" ["1 Pt."]="1 Peter" ["I Pet."]="1 Peter" ["1Pet."]="1 Peter" ["1st Peter"]="1 Peter" ["First Peter"]="1 Peter"
    ["2 Pet."]="2 Peter" ["2 Pe."]="2 Peter" ["2 Pt."]="2 Peter" ["II Peter"]="2 Peter" ["2Pet."]="2 Peter" ["2nd Peter"]="2 Peter" ["Second Peter"]="2 Peter"
    ["1 Jhn."]="1 John" ["1 Jn."]="1 John" ["I John"]="1 John" ["1Jhn."]="1 John" ["1Joh."]="1 John" ["1Jn."]="1 John" ["1st John"]="1 John" ["First John"]="1 John"
    ["2 Jhn."]="2 John" ["2 Jn."]="2 John" ["II John"]="2 John" ["2Jhn."]="2 John" ["2Joh."]="2 John" ["2Jn."]="2 John" ["2nd John"]="2 John" ["Second John"]="2 John"
    ["3 Jhn."]="3 John" ["3 Jn."]="3 John" ["III John"]="3 John" ["3Jhn."]="3 John" ["3Joh."]="3 John" ["3Jn."]="3 John" ["3rd John"]="3 John" ["Third John"]="3 John"
    ["Jud."]="Jude" ["Jd."]="Jude"
    ["Re"]="Revelation" ["The Revelation"]="Revelation"
  )

  # Chapter verse counts: key is "Book|chapter"
  declare -A VERSE_COUNTS=(
    ["Genesis|1"]=31 ["Genesis|2"]=25 ["Genesis|3"]=24 ["Genesis|4"]=26 ["Genesis|5"]=32 ["Genesis|6"]=22 ["Genesis|7"]=24 ["Genesis|8"]=22 ["Genesis|9"]=29 ["Genesis|10"]=32 ["Genesis|11"]=32 ["Genesis|12"]=20 ["Genesis|13"]=18 ["Genesis|14"]=24 ["Genesis|15"]=21 ["Genesis|16"]=16 ["Genesis|17"]=27 ["Genesis|18"]=33 ["Genesis|19"]=38 ["Genesis|20"]=18 ["Genesis|21"]=34 ["Genesis|22"]=24 ["Genesis|23"]=20 ["Genesis|24"]=67 ["Genesis|25"]=34 ["Genesis|26"]=35 ["Genesis|27"]=46 ["Genesis|28"]=22 ["Genesis|29"]=35 ["Genesis|30"]=43 ["Genesis|31"]=55 ["Genesis|32"]=32 ["Genesis|33"]=20 ["Genesis|34"]=31 ["Genesis|35"]=29 ["Genesis|36"]=43 ["Genesis|37"]=36 ["Genesis|38"]=30 ["Genesis|39"]=23 ["Genesis|40"]=23 ["Genesis|41"]=57 ["Genesis|42"]=38 ["Genesis|43"]=34 ["Genesis|44"]=34 ["Genesis|45"]=28 ["Genesis|46"]=34 ["Genesis|47"]=31 ["Genesis|48"]=22 ["Genesis|49"]=33 ["Genesis|50"]=26
    ["Exodus|1"]=22 ["Exodus|2"]=25 ["Exodus|3"]=22 ["Exodus|4"]=31 ["Exodus|5"]=23 ["Exodus|6"]=30 ["Exodus|7"]=25 ["Exodus|8"]=32 ["Exodus|9"]=35 ["Exodus|10"]=29 ["Exodus|11"]=10 ["Exodus|12"]=51 ["Exodus|13"]=22 ["Exodus|14"]=31 ["Exodus|15"]=27 ["Exodus|16"]=36 ["Exodus|17"]=16 ["Exodus|18"]=27 ["Exodus|19"]=25 ["Exodus|20"]=26 ["Exodus|21"]=36 ["Exodus|22"]=31 ["Exodus|23"]=33 ["Exodus|24"]=18 ["Exodus|25"]=40 ["Exodus|26"]=37 ["Exodus|27"]=21 ["Exodus|28"]=43 ["Exodus|29"]=46 ["Exodus|30"]=38 ["Exodus|31"]=18 ["Exodus|32"]=35 ["Exodus|33"]=23 ["Exodus|34"]=35 ["Exodus|35"]=35 ["Exodus|36"]=38 ["Exodus|37"]=29 ["Exodus|38"]=31 ["Exodus|39"]=43 ["Exodus|40"]=38

    # (truncated in this file for brevity; the full verse map is intentionally long)
  )

  # Canonical book names for direct lookup
  declare -A CANONICAL_BOOKS=(
    ["Genesis"]=1 ["Exodus"]=1 ["Leviticus"]=1 ["Numbers"]=1 ["Deuteronomy"]=1
    ["Joshua"]=1 ["Judges"]=1 ["Ruth"]=1 ["1 Samuel"]=1 ["2 Samuel"]=1
    ["1 Kings"]=1 ["2 Kings"]=1 ["1 Chronicles"]=1 ["2 Chronicles"]=1
    ["Ezra"]=1 ["Nehemiah"]=1 ["Esther"]=1 ["Job"]=1 ["Psalms"]=1
    ["Proverbs"]=1 ["Ecclesiastes"]=1 ["Song of Solomon"]=1 ["Isaiah"]=1
    ["Jeremiah"]=1 ["Lamentations"]=1 ["Ezekiel"]=1 ["Daniel"]=1 ["Hosea"]=1
    ["Joel"]=1 ["Amos"]=1 ["Obadiah"]=1 ["Jonah"]=1 ["Micah"]=1 ["Nahum"]=1
    ["Habakkuk"]=1 ["Zephaniah"]=1 ["Haggai"]=1 ["Zechariah"]=1 ["Malachi"]=1
    ["Matthew"]=1 ["Mark"]=1 ["Luke"]=1 ["John"]=1 ["Acts"]=1 ["Romans"]=1
    ["1 Corinthians"]=1 ["2 Corinthians"]=1 ["Galatians"]=1 ["Ephesians"]=1
    ["Philippians"]=1 ["Colossians"]=1 ["1 Thessalonians"]=1 ["2 Thessalonians"]=1
    ["1 Timothy"]=1 ["2 Timothy"]=1 ["Titus"]=1 ["Philemon"]=1 ["Hebrews"]=1
    ["James"]=1 ["1 Peter"]=1 ["2 Peter"]=1 ["1 John"]=1 ["2 John"]=1
    ["3 John"]=1 ["Jude"]=1 ["Revelation"]=1
  )

  resolve_book() {
    local input="$1"
    if [[ -n "$${CANONICAL_BOOKS[$input]+_}" ]]; then
      echo "$input"
      return 0
    fi
    if [[ -n "$${BOOK_ABBREVS[$input]+_}" ]]; then
      echo "$${BOOK_ABBREVS[$input]}"
      return 0
    fi
    echo ""
    return 1
  }

  validate_reference() {
    local book="$1"
    local chapter="$2"
    local verse_start="$3"
    local verse_end="$4"

    local max_verses="$${VERSE_COUNTS["$${book}|$${chapter}"]}"

    if [[ -z "$max_verses" ]]; then
      echo "Error: $${book} does not have a chapter $${chapter}" >&2
      exit 1
    fi

    if [[ "$verse_start" -lt 1 ]]; then
      echo "Error: verse $${verse_start} is less than 1" >&2
      exit 1
    fi

    if [[ "$verse_end" -gt "$max_verses" ]]; then
      echo "Error: verse $${verse_end} exceeds $${book} $${chapter}'s $${max_verses} verses" >&2
      exit 1
    fi

    if [[ "$verse_start" -gt "$verse_end" ]]; then
      echo "Error: start verse $${verse_start} is greater than end verse $${verse_end}" >&2
      exit 1
    fi
  }

  SOURCE_TEXT="$${1:-Hebrews 11:16-17}"
  SOURCE_TEXT=$(echo "$SOURCE_TEXT" | xargs | tr -s ' ')

  BOOK_RAW=$(echo "$SOURCE_TEXT" | sed 's/[[:space:]]*[0-9][0-9]*:[0-9].*$//')
  CHAP_VERSE=$(echo "$SOURCE_TEXT" | grep -oE '[0-9]+:[0-9]+(-[0-9]+)?$')

  if [[ -z "$BOOK_RAW" || -z "$CHAP_VERSE" ]]; then
    echo "Error: could not parse '$SOURCE_TEXT'" >&2
    echo "Expected format: 'Book chapter:verse' or 'Book chapter:verse-verse'" >&2
    exit 1
  fi

  BOOK_RAW=$(echo "$BOOK_RAW" | xargs)
  BOOK=$(resolve_book "$BOOK_RAW")

  if [[ -z "$BOOK" ]]; then
    echo "Error: unknown book '$${BOOK_RAW}'" >&2
    exit 1
  fi

  CHAPTER=$(echo "$CHAP_VERSE" | cut -d: -f1)
  VERSES=$(echo "$CHAP_VERSE" | cut -d: -f2)
  VERSE_START=$(echo "$VERSES" | cut -d- -f1)
  VERSE_END=$(echo "$VERSES" | cut -d- -f2)
  [[ "$VERSE_START" == "$VERSE_END" ]] && VERSE_END="$VERSE_START"

  validate_reference "$BOOK" "$CHAPTER" "$VERSE_START" "$VERSE_END"

  if [[ "$VERSE_START" == "$VERSE_END" ]]; then
    TITLE="$${BOOK} $${CHAPTER}:$${VERSE_START}"
  else
    TITLE="$${BOOK} $${CHAPTER}:$${VERSE_START}-$${VERSE_END}"
  fi

  cat << 'ENDOFQUERY' | sed \
    -e "s|{{TITLE}}|$${TITLE}|g" \
    -e "s|{{BOOK}}|$${BOOK}|g" \
    -e "s|{{CHAPTER}}|$${CHAPTER}|g" \
    -e "s|{{VERSE_START}}|$${VERSE_START}|g" \
    -e "s|{{VERSE_END}}|$${VERSE_END}|g"
  #+BEGIN_QUERY
  {
   :title "{{TITLE}}"
   :query [:find (pull ?b [:block/content :block/properties])
           :where
           [?b :block/properties ?props]
           [(get ?props :book) ?b-book]
           [(get ?props :chapter) ?b-chap]
           [(get ?props :verse) ?b-verse]
           [(= ?b-book "{{BOOK}}")]
           [(= ?b-chap {{CHAPTER}})]
           [(>= ?b-verse {{VERSE_START}})]
           [(<= ?b-verse {{VERSE_END}})]
   ]
   :result-transform (fn [rs] (sort-by (fn [r] (get-in r [:block/properties :verse])) rs))
   :view (fn [rs]
     [:div {:style {:font-family "serif" :line-height "1.8" :padding "0.5em"}}
      (for [r rs]
        (let [props (:block/properties r)
              verse (:verse props)
              content (:block/content r)
              idx (clojure.string/index-of content "\nid::")
              text (if idx (subs content 0 idx) content)]
          [:div {:style {:display "flex" :gap "0.75em" :margin-bottom "0.5em"}}
           [:sup {:style {:color "gray" :min-width "1.5em" :padding-top "0.3em" :font-family "sans-serif"}}
            (str verse)]
           [:span text]]))])
  }
  ENDOFQUERY

''
