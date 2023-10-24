script "lib_LexonDev"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_LexonDev
type: library
version: 0.1

/*Some help*/


--> Working on
-
function lexon_GetClauseData clauseText, dArray
   put lexon_GetContractTitleArray (dData) into titleArray
   put lexon_ConstructRowClauseData (clauseText, titleArray, defLineData) into clauseData
   return clauseData
end lexon_GetClauseData

--> Old | DV
-
getprop dv_LinkedDataView
   put the dv_MetadataObject of the target into metadataObject
   put the uLCW ["dv_LinkedDataView"] of metadataObject into dView
   return dView
end dv_LinkedDataView

setprop dv_LinkedDataView dView
   -- set this for a card, button or dataview to link menus or other tools to a specific instance
   if exists (dView) is false then return "error, dView does not exists:" && dView
   put revRuggedID (dView) into dView
   
   put the dv_MetadataObject of the target into metadataObject
   set the uLCW ["dv_LinkedDataView"] of metadataObject to dView
   return metadataObject
end dv_LinkedDataView

getprop dv_LinkedRowStack
   put the dvControl of the target into dView
   if exists (dView) is false then return empty
   
   put the dv_MetadataObject of dView into metadataObject
   put the uLCW ["dv_LinkedRowStack"] of metadataObject into stackName
   return stackName
end dv_LinkedRowStack

setprop dv_LinkedRowStack stackName
   if exists (stack stackName) is false then return "error, stack does not exists:" && stackName
   put the dvControl of the target into dView
   if exists (dView) is false then return empty
   
   put the short name of stack stackName into stackName -- could be a path
   --
   put the dv_MetadataObject of dView into metadataObject
   set the uLCW ["dv_LinkedRowStack"] of metadataObject to stackName
   --
   set the stackFile_Link of dView to stackName
   return metadataObject
end dv_LinkedRowStack


-- function lexon_ConstructRowContract clauseText, clauseTitle
local dData

put lexon_GetDefLineData (clauseText) into defData
put item 2 of the extents of defData into maxNum
set the itemdelimiter to "."
repeat with foundNum = maxNum down to 1
   put defData [foundNum]["lineNum"] into lineNum
   delete line lineNum of clauseText
end repeat
put word 1 to -1 of clauseText into someClause

if maxNum > 0 then
   repeat with foundNum = 1 to maxNum
      put defData [foundNum]["text"] into defLine
      put dv_ConstructItem (defLine, "definition") into itemArray
      put 3 into itemArray ["level"]
      --
      put defData [foundNum]["title"] into defPhrase
      put defPhrase into itemArray ["title"]
      put defData [foundNum]["sCharNum"] into itemArray ["sCharNum"]
      put defData [foundNum]["eCharNum"] into itemArray ["eCharNum"]
      --
      dv_AddItemArray itemArray, dData
   end repeat
end if
--
if someClause is not empty then
   put dv_ConstructItem (someClause, "clause") into itemArray
   put 3 into itemArray ["level"]
   put clauseTitle into itemArray ["title"]
   --
   dv_AddItemArray itemArray, dData
end if
--
return dData
end lexon_ConstructRowContract

-- function lexon_GetContractLinkArray dData
repeat with itemNum = 1 to item 2 of the extents of dData
   put dData [itemNum] into clauseData
   --
   put clauseData ["title"] into utf8Title
   put lexon_GetClauseTitle (utf8Title) into cTitle
   --
   if cTitle is not empty then
      put clause_GetUniqueTitleData (clauseData) into titleData
      put titleData into cLinkArray ["linkArray"][cTitle]
      put itemNum into cLinkArray ["meta"][cTitle]["itemNum"]
      put titleData into cLinkArray ["meta"][cTitle]["children"]
   end if
end repeat
return cLinkArray
end lexon_GetContractLinkArray

getprop clause_Text
   if the dvControl of me is empty then
      put the text of _TextField() into clauseText
   else
      put the dv_RowValue ["title"] of me into clauseTitle
      put the dv_RowValue ["text"] of me into utf8Clause
      --
      if clauseTitle is not empty then
         put word 1 to -1 of clauseTitle & CR before utf8Clause
      end if
      --
      put lexon_CleanClause (utf8Clause) into clauseText
   end if
   --
   set the itemdelimiter to ":"
   if item 1 of clauseText = "CLAUSE" then
      delete line 1 of clauseText
   end if
   --
   return clauseText
end clause_Text

setprop clause_Text [sColour] clauseText
   put the dvControl of me into dView
   if dView is empty then
      set the view_Text [sColour] of me to clauseText
   else
      set the dv_RowValue ["text"] of me to clauseText
      put the result into dData
      return dData
   end if
end clause_Text

setprop clause_CapsColour [clauseText] capsColour
put _TextField() into textField
--
if capsColour is not a color then return empty
if clauseText is empty then put the clause_Text of me into clauseText
--
put lexon_GetClauseCapsArray (clauseText) into clauseArray
--
put item 2 of the extents of clauseArray into maxNumm
repeat with itemNum = maxNumm down to 1
   put clauseArray [itemNum] into phraseArray
   put phraseArray ["sWordNum"] into sWordNum
   put phraseArray ["eWordNum"] into eWordNum
   put phraseArray ["text"] into somePhrase
   --
   -- set the textcolor of word sWordNum to eWordNum of textField to capsColour
   set the textstyle of word sWordNum to eWordNum of textField to "link"
end repeat
--
return clauseArray
end clause_CapsColour

private command _ColourDefWord
   -- quick hack
   put _TextField() into textField
   put the text of textField into sLine
   put _IsDef (sLine) into isDef
   if isDef is true then
      set the textcolor of word 1 of _TextField() to "purple"
   end if
end _ColourDefWord

private function _IsDef somePhrase, pWordNum
   if pWordNum is empty then put 2 into pWordNum
   get word pWordNum of somePhrase
   lexon_StripPunctuation it
   if it is among the items of "is,means" then
      return true
   else
      return false
   end if
end _IsDef

setprop clause_Colour [clauseText] defColour
   -- a slow ugly hack
   put _TextField() into textField
   put _GetDefColour() into defColour
   put _GetMissingColour() into missingColour
   put _GetClauseColour() into clauseColour
   put _GetTermColour() into termColour
   -- 
   if clauseText is empty then put the clause_Text of me into clauseText
   --
   put the contract_ClauseTitles of me into clauseTitles
   put the contract_DefTitles of me into defTitles
   put the contract_TermTitles of me into termTitles
   put lexon_GetClauseCapsArray (clauseText) into clauseArray
   --
   put item 2 of the extents of clauseArray into maxNumm
   repeat with itemNum = maxNumm down to 1
      put clauseArray [itemNum] into phraseArray
      put phraseArray ["sWordNum"] into sWordNum
      put phraseArray ["eWordNum"] into eWordNum
      --
      put phraseArray ["text"] into somePhrase
      lexon_StripPunctuation somePhrase
      --
      set the textstyle of word sWordNum to eWordNum of textField to "link"
      switch
         case somePhrase is among the lines of clauseTitles
            set the textcolor of word sWordNum to eWordNum of textField to clauseColour
            break
         case somePhrase is among the lines of termTitles
            set the textcolor of word sWordNum to eWordNum of textField to termColour
            break
         case somePhrase is among the lines of defTitles
            set the textcolor of word sWordNum to eWordNum of textField to defColour
            break
         default
            set the textcolor of word sWordNum to eWordNum of textField to missingColour
      end switch
   end repeat
   --
   _ColourDefWord
   --
   return clauseArray
end clause_Colour

setprop clause_Colour [clauseText] defColour
-- a slow ugly hack
put _TextField() into textField
put _GetDefColour() into defColour
put _GetMissingColour() into missingColour
put _GetClauseColour() into clauseColour
put _GetTermColour() into termColour
-- 
put the contract_ClauseTitles of me into clauseTitles
put the contract_DefTitles of me into defTitles
put the contract_Terms of me into contractTerms
--
if clauseText is empty then put the clause_Text of me into clauseText
--
put lexon_GetClauseCapsArray (clauseText) into clauseArray
put item 2 of the extents of clauseArray into maxNum
repeat with itemNum = maxNum down to 1
   put clauseArray [itemNum] into phraseArray
   put phraseArray ["sWordNum"] into sWordNum
   put phraseArray ["eWordNum"] into eWordNum
   --
   put phraseArray ["text"] into somePhrase
   lexon_StripPunctuation somePhrase
   --
   set the textstyle of word sWordNum to eWordNum of textField to "link"
   switch
      case somePhrase is among the lines of clauseTitles
         set the textcolor of word sWordNum to eWordNum of textField to clauseColour
         break
      case somePhrase is among the lines of contractTerms
         set the textcolor of word sWordNum to eWordNum of textField to termColour
         break
      case somePhrase is among the lines of defTitles
         set the textcolor of word sWordNum to eWordNum of textField to defColour
         break
      default
         set the textcolor of word sWordNum to eWordNum of textField to missingColour
   end switch
end repeat
--
return clauseArray
end clause_Colour

setprop clause_CapsColour [clauseText] capsColour
   put _TextField() into textField
   --
   if capsColour is not a color then return empty
   if clauseText is empty then put the clause_Text of me into clauseText
   --
   put lexon_GetClauseCapsArray (clauseText) into clauseArray
   --
   put item 2 of the extents of clauseArray into maxNum
   repeat with itemNum = maxNum down to 1
      put clauseArray [itemNum] into phraseArray
      put phraseArray ["sWordNum"] into sWordNum
      put phraseArray ["eWordNum"] into eWordNum
      put phraseArray ["text"] into somePhrase
      --
      -- set the textcolor of word sWordNum to eWordNum of textField to capsColour
      set the textstyle of word sWordNum to eWordNum of textField to "link"
   end repeat
   --
   return clauseArray
end clause_CapsColour

setprop clause_DefColour [capsColour] defColour   
   put _TextField() into textField
   put the clause_Text of me into clauseText
   put lexon_GetDefLineData (clauseText) into defData
   --
   lock screen
   --
   set the textstyle of word 1 to -1 of textField to "plain"
   --
   if defColour is a color then
      put item 2 of the extents of defData into maxNum
      repeat with itemNum = maxNum down to 1
         put defData [itemNum]["lineNum"] into lineNum
         put defData [itemNum]["text"] into defLine
         --
         lexon_SetDefWordOffsets defLine, clauseText, sWordNum, eWordNum
         put the result into fLine
         --
         if fLine = defLine then
            -- set the textcolor of word sWordNum to eWordNum of textField to defColour
            set the textcolor of word sWordNum of textField to defColour
         else
            throw "Error, defLine should match the phrase in utf8Clause"
         end if
      end repeat
   end if
   --
   if capsColour is a color then
      set the clause_Colour [clauseText] of textField to capsColour
   end if
   --
   unlock screen
end clause_DefColour

setprop phrase_DefColour [capsColour] defColour
   put _TextField() into textField
   put the clause_Text of me into clauseText
   put lexon_GetDefLineData (clauseText) into defData
   --
   lock screen
   --
   set the textstyle of word 1 to -1 of textField to "plain"
   --
   if defColour is a color then
      put item 2 of the extents of defData into maxNum
      repeat with itemNum = maxNum down to 1
         put defData [itemNum]["lineNum"] into lineNum
         put defData [itemNum]["text"] into defLine
         --
         lexon_SetDefWordOffsets defLine, clauseText, sWordNum, eWordNum
         put the result into fLine
         --
         if fLine = defLine then
            set the textcolor of word sWordNum to eWordNum of textField to defColour
         else
            throw "Error, defLine should match the phrase in utf8Clause"
         end if
      end repeat
   end if
   --
   if capsColour is a color then
      set the clause_CapsColour [clauseText] of textField to capsColour
   end if
   --
   unlock screen
end phrase_DefColour


--> Lexon | Dev
-
command lexon_SetDefWordOffsets defLine, utf8Clause, @sWordNum, @eWordNum
   -- wordoffset does not accept multi-word searche terms
   put offset (defLine, utf8Clause, 0) into sCharNum
   if sCharNum = 0 then
      return empty
   end if
   --
   get char 1 to (sCharNum - 1) of utf8Clause
   put (the number of words of it) + 1 into sWordNum
   -- 
   put sWordNum + the number of words of defLine into eWordNum
   subtract 1 from eWordNum
   put word sWordNum to eWordNum of utf8Clause into fLine
   if char -1 of fLine = "." then delete char -1 of fLine
   return fLine
end lexon_SetDefWordOffsets

-- function lexon_GetDefLineData utf8Clause
set the linedelimiter to "."
put 1 into foundNum
repeat with lineNum = 1 to the number of lines of utf8Clause
   put word 1 to -1  of line lineNum of utf8Clause into defLine
   --
   put _GetDefPhraseArray (defLine) into defPhraseArray
   if defPhraseArray is an array then
      put defPhraseArray into defData [foundNum]["defPhrase"]
      put defLine into defData [foundNum]["text"] -- misses ending "." which ,akes sense but may need to add when presenting
      --
      lexon_SetDefWordOffsets defLine, utf8Clause, sWordNum, eWordNum
      put the result into fLine
      put the number of lines of word 1 to sWordNum of utf8Clause into foundLineNum
      --
      put sWordNum into defData [foundNum]["sWordNum"]
      put eWordNum into defData [foundNum]["eWordNum"]
      --
      put foundLineNum into defData [foundNum]["lineNum"]
      --
      add 1 to foundNum
   end if
end repeat
return defData
end lexon_GetDefLineData

-- command text_StripOffsetArray @someText, someTitles, linkType
local offsetArray

sort descending lines of someTitles by the number of words of each
put 1 into foundNum
repeat for each line someTitle in someTitles
   text_StripTitles offsetArray, someText, someTitle, linkType, foundNum
end repeat
--
return offsetArray
end text_StripOffsetArray

-- command text_StripTitles @offsetArray, @someText, someTitle, linkType
repeat 100 -- for safety
   -- can be multiple instances
   put regExp_WordPhrase (someTitle) into regExp
   if matchChunk (someText, regExp, sCharNum, eCharNum) then
      put sCharNum into offsetArray [foundNum]["sCharNum"]
      put eCharNum into offsetArray [foundNum]["eCharNum"]
      put someTitle into offsetArray [foundNum]["text"]
      add 1 to foundNum
      --
      put eCharNum - sCharNum + 1 into repeatNum
      get text_RepeatString ("•", repeatNum)
      put it into char sCharNum to eCharNum of someText
   else
      exit repeat
   end if
end repeat
end text_StripTitles

-- function lexon_GetClauseTitleArray dData
repeat with itemNum = 1 to item 2 of the extents of dData
   put dData [itemNum] into itemArray
   if itemArray ["@style"] = "clause" then
      put itemArray ["title"] into utf8Title
      if utf8Title is empty then next repeat
      --
      put lexon_GetClauseTitle (utf8Title) into clauseTitle
      put itemNum into itemArray ["rowNum"]
      put itemArray into clauseTitleArray [clauseTitle]
   end if
end repeat
return clauseTitleArray
end lexon_GetClauseTitleArray
