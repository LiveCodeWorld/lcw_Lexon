script "model_LexonDataView"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_LexonDataView
type: model
version: 0.1


--> Working on
-
private command _AddDvClause @dData, someClause, clauseTitle
   if clauseText is empty then return 0
   
   -- should not need this if
   -- put textDecode (lexBody, "utf8") into lexBody
   put lexon_CleanClause (someClause) into someClause
   
   put dv_ConstructItem (someClause, "clause") into itemArray
   --
   put clauseTitle into itemArray ["title"]
   --
   dv_AddItemArray itemArray, dData
   put the result into insertedIndexNum
   --
   return insertedIndexNum
end _AddDvClause


--> Lexon | DataViewArray
-
function lexon_ConstructDataViewArray termData
   local dData
   --
   repeat with termNum = 1 to item 2 of the extents of termData
      put termData [termNum] into termArray
      put termArray ["term"] into sectionData
      put termArray ["title"] into termTitle
      --
      if termTitle = "_Metadata" then
         -- this removes the section "PREAMBLE."
         next repeat
      end if
      --
      lexon_AddTitle dData, termTitle, 1
      --
      _ParseSectionData dData, sectionData
   end repeat
   --
   lexon_AddDefAndClauseData dData
   --
   return dData
end lexon_ConstructDataViewArray


--> Lexon | DataView | Add
-
command lexon_AddTitleFromItemArray @dData, itemArray, pLevel
   put itemArray ["title"] into someTitle
   if someTitle = "_Untitled" then return false
   
   _TitleFormat someTitle   
   lexon_AddTitle dData, someTitle, pLevel
   return true
end lexon_AddTitleFromItemArray

command lexon_AddTitle @dData, someTitle, pLevel
   -- dv_AddMarkdownTitle dData, someTitle, pLevel
   
   put dv_ConstructItem (someTitle, "title") into itemArray
   put pLevel into itemArray ["level"]
   --
   dv_AddItemArray itemArray, dData
   put the result into insertedIndexNum
   --
   return insertedIndexNum
end lexon_AddTitle


--> Lexon | Utils
-
command lexon_StripPunctuation @clauseTitle
   replace quote with empty in clauseTitle
   replace ":" with empty in clauseTitle
   replace ";" with empty in clauseTitle
   replace "," with empty in clauseTitle
   replace "." with empty in clauseTitle
end lexon_StripPunctuation


--> Private
-
private command _ParseSectionData @dData, sectionData
   repeat with sectionNum = 1 to item 2 of the extents of sectionData
      put sectionData [sectionNum] into sectionArray
      --
      lexon_AddTitleFromItemArray dData, sectionArray, 2
      put sectionArray ["section"] into clauseData
      _ParseClauseData dData, clauseData
   end repeat
end _ParseSectionData

private command _ParseClauseData @dData, clauseData
   repeat with clauseNum = 1 to item 2 of the extents of clauseData
      put clauseData [clauseNum] into clauseArray
      put clauseArray ["clause"] into clauseText
      put clauseArray ["title"] into clauseTitle
      _AddDvClause dData, clauseText, clauseTitle
   end repeat
end _ParseClauseData

private command _TitleFormat @someTitle
   if char -1 of someTitle is not "." then
      put "." after someTitle
   end if
end _TitleFormat
