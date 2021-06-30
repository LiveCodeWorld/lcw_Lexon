script "lib_Lexon"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_Lexon
type: library
version: 0.1

/*Some help*/


--> Working on
-
function clause_ListUniqueTitles clauseData
   put clause_GetUniqueTitleData (clauseData) into titleData
   put keys (titleData) into uniqueClauseTitles
   sort lines of uniqueClauseTitles
   return uniqueClauseTitles
end clause_ListUniqueTitles


--> Display | Lexon
-
on dv_ClearData dView
   -- so we can send in 2 ticks and issue form a dor that deletes itself
   if dView is empty then put the dvControl of the target into dView
   if dView is empty then breakpoint
   
   set the dvData of dView to empty
end dv_ClearData


--> Lexon | WikiText
-
getprop lexon_WikiText [rowNums]
   put the dvData of the target into dData
   if rowNums is empty then
   else
      repeat for each item rowNum in rowNums
         put dData [rowNum]["@style"] into dvStyle
         put dData [rowNum]["level"] into tLevel
         put dData [rowNum]["text"] into utf8Clause
         switch dvStyle
            case "clause"
               put dData [rowNum]["title"] into pClauseTitle
               --
               put lexon_GetWikiClause (utf8Clause, pClauseTitle, tLevel) into wikiSection
               put wikiSection & CR&CR after wikiText
               break
            default -- title
               put text_RepeatString ("#", tLevel) && utf8Clause & CR&CR after wikiText
         end switch
      end repeat
   end if
   return wikiText
end lexon_WikiText

function lexon_GetWikiClause utf8Clause, pClauseTitle, pLevel
   put 3 into pLevel
   put lexon_CleanClause (utf8Clause) into someClause
   put lexon_GetClauseCapsArray (someClause) into clauseArray
   put _ConstructWikiClause (someClause, clauseArray) into wikiClause
   --
   if pClauseTitle is not empty then
      get word 1 to -1 of pClauseTitle 
      -- put it & CR before wikiClause
      put text_RepeatString ("#", pLevel) && it & CR  before wikiClause
   end if
   return wikiClause
end lexon_GetWikiClause

private function _ConstructWikiClause someClause, clauseArray
   put someClause into wikiClause
   put item 2 of the extents of clauseArray into maxNumm
   repeat with itemNum = maxNumm down to 1
      put clauseArray [itemNum] into phraseArray
      put phraseArray ["sWordNum"] into sWordNum
      put phraseArray ["eWordNum"] into eWordNum
      put phraseArray ["text"] into somePhrase
      --
      if char 1 of somePhrase is quote then
         put "[[" after char 1 of somePhrase
         put "]]" before char -1 of somePhrase
      else
         put "[[" before somePhrase
         put "]]" after somePhrase
      end if
      put somePhrase into word sWordNum to eWordNum of wikiClause
   end repeat
   return wikiClause
end _ConstructWikiClause


--> Lexon
-
command lexon_Transfer rowView
   put the dv_RowData of the target into rowData
   put rowData ["@style"] into itemStyle
   switch itemStyle
      case "clause"
         -- put the clause_Text of rowView into clauseText
         put rowData ["text"] into utf8Clause
         put rowData ["title"] into clauseTitle
         --
         break
      case "markdown"
         get the markdown_Text of rowView
         put line 1 of it into clauseTitle
         put line 2 to -1 of it into utf8Clause
         break
      default
         breakpoint
   end switch
   --
   put lexon_CleanClause (utf8Clause) into someClause
   put view_GetTemplateObject ("View|Contract|Clause") into templateObject
   set the clause_Text ["red"] of templateObject to someClause
   --
   object_GoTo templateObject
end lexon_Transfer


--> Lexon | Clause
-
function lexon_CleanClause utf8Clause
   put utf8_Decode (utf8Clause) into someClause
   text_CleanQuotes someClause
   return word 1 to -1 of someClause
end lexon_CleanClause

command text_CleanQuotes @someText
   replace "“" with quote in someText
   replace "”" with quote in someText
end text_CleanQuotes


--> Private
-
private function utf8_Decode utf8Text
   -- put unidecode (uniencode (utf8Text, "UTF8")) into utf8Text
   put uniencode (utf8Text,"UTF8") into someU16
   put unidecode (someU16, "ANSI") into someText
   return someText
end utf8_Decode
