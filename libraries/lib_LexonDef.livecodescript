script "lib_LexonDef"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_LexonDef
type: library
version: 0.1

/*
-- put the contract_DefTitles of dView into defTitles
*/


--> Working on
-
function lexon_ConstructRowClauseData clauseText, titleArray, defLineData
   -- search text for all links we know (in titleArray)
   
   local clauseData
   put the keys of titleArray into wordNums
   sort descending numeric wordNums
   put 1 into foundNum
   repeat for each line wordNum in wordNums
      put titleArray [wordNum] into wordTitleArray
      repeat for each key someTitle in wordTitleArray
         put wordTitleArray [someTitle]["linkType"] into linkType
         --
         repeat 100 -- for safety (can be multiple instances)
            put regExp_WordPhrase (someTitle) into regExp
            if matchChunk (clauseText, regExp, sCharNum, eCharNum) then
               put sCharNum into clauseData [foundNum]["sCharNum"]
               put eCharNum into clauseData [foundNum]["eCharNum"]
               put someTitle into clauseData [foundNum]["text"]
               --
               if linkType = "def" then
                  if _IsInDefLineData (someTitle, defLineData, clauseText, sCharNum, eCharNum) then
                     put "def line" into clauseData [foundNum]["linkType"]
                  else
                     put "def" into clauseData [foundNum]["linkType"]
                  end if
               else
                  put linkType into clauseData [foundNum]["linkType"]
               end if
               --
               add 1 to foundNum
               --
               put eCharNum - sCharNum + 1 into repeatNum
               get text_RepeatString ("•", repeatNum)
               put it into char sCharNum to eCharNum of clauseText
            else
               exit repeat
            end if
         end repeat
      end repeat
   end repeat
   --
   -- text_StarQuoted pClauseText
   -- put the result into quotedArray
   -- put quotedArray into clauseData ["quoted"]
   --
   return clauseData
end lexon_ConstructRowClauseData

private function _IsInDefLineData someTitle, defLineData, clauseText, sCharNum, eCharNum
   repeat for each key itemNum in defLineData
      put defLineData [itemNum]["title"] into testTitle
      --
      put defLineData [itemNum]["lineNum"] into lineNum
      put defLineData [itemNum]["sLineCharNum"] into sLineCharNum
      put defLineData [itemNum]["eLineCharNum"] into eLineCharNum
      
      if testTitle = someTitle then
         set the linedelimiter to "."
         get line 1 to (lineNum - 1) of clauseText
         put the number of chars of it into lineCharNum
         put lineCharNum + sLineCharNum into startTest
         put lineCharNum + eLineCharNum into endTest
         if lineCharNum > 0 then
            add 2 to startTest
            add 2 to endTest
         else
            -- breakpoint -- a hack for the first line
         end if
         
         if startTest = sCharNum AND startTest = sCharNum then
            return true
         else
            return false
         end if
      end if
   end repeat
   return false
end _IsInDefLineData
   
function clause_GetDataFromText someClause, rowData
   -- used by closeField
   if lexon_IsClauseTitle (line 1 of someClause) then
      put word 1 to -1 of line 1 of someClause into rowData ["title"]
      delete line 1 of someClause
   else
      put "_Untitled" into rowData ["title"]
   end if
   put someClause into rowData ["text"]
   
   -- re-calculate links
   put lexon_GetClauseCapsArray (someClause) into clauseArray
   put clauseArray into rowData ["links"]
   
   -- re-calculate defs
   put lexon_GetDefLineData (someClause) into defLineData
   if defLineData is an array then
      put defLineData into rowData ["defLineData"]
   end if
   --
   return rowData
end clause_GetDataFromText


--> Def | Data
-
/*
DefData is extracted using "lexon_GetDefLineData (utf8Clause)" to find lines of Lexon that define a term.
It is added to the dvData for a Lexon contract to each item.
This is not the sammee as teh phrases that link to defenitions.
*/

command lexon_AddDefAndClauseData @dData
   -- put lexon_GetContractTitleArray (dData) into titleArray -- relies on existing "defLineData" index
   put lexon_FindTitleArray (dData) into titleArray
   --
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum] into itemArray
      put itemArray ["@style"] into itemStyle
      switch itemStyle
         case "title"
            next repeat
            break
         default
            put itemArray ["text"] into utf8Clause
            
            -- fist lets see if there are any def lines
            put lexon_GetDefLineData (utf8Clause) into defLineData
            if defLineData is an array then
               put defLineData into dData [itemNum]["defLineData"]
            end if
            
            -- now let's use titleArray to look for and categorize links
            put lexon_ConstructRowClauseData (utf8Clause, titleArray, defLineData) into clauseData
            if clauseData is an array then
               put clauseData into dData [itemNum]["clauseData"]
            end if
      end switch
   end repeat
end lexon_AddDefAndClauseData

function lexon_GetDefLineData utf8Clause
   set the linedelimiter to "."
   put the number of lines of utf8Clause into maxNum
   put 1 into foundNum
   repeat with lineNum = 1 to maxNum
      put word 1 to -1  of line lineNum of utf8Clause into sLine
      --
      if lexon_IsDef (sLine) then
         put token 1 of sLine into defPhrase
         put offset (defPhrase, sLine) into sCharNum
         put sCharNum + the number of chars of defPhrase - 1 into eCharNum
         --
         put defPhrase into defLineData [foundNum]["title"]
         put sCharNum into defLineData [foundNum]["sLineCharNum"]
         put eCharNum into defLineData [foundNum]["eLineCharNum"]
         --
         put lineNum into defLineData [foundNum]["lineNum"]
         put sLine into defLineData [foundNum]["text"]
         --
         add 1 to foundNum
      end if
   end repeat
   return defLineData
end lexon_GetDefLineData


--> Lexon | Def
-
function lexon_FindTitleArray dData
   put lexon_FindContractDefs (dData) into defTitles
   --
   put lexon_ListContractTerms (dData) into contractTerms
   put lexon_ListClauseTitles (dData) into clauseTitles
   put lexon_ConstructTitleArray (contractTerms, clauseTitles, defTitles) into titleArray
   --
   return titleArray
end lexon_FindTitleArray

function lexon_FindContractDefs dData, pAddPlurals
   put lexon_FindContractDefArray (dData, pAddPlurals) into contractDefArray
   --
   put the keys of contractDefArray into contractDefs
   sort contractDefs
   return contractDefs
end lexon_FindContractDefs

function lexon_ListContractDefs dData, pAddPlurals
   put lexon_GetContractDefArray (dData, pAddPlurals) into contractDefArray
   put the keys of contractDefArray into contractDefs
   sort contractDefs
   return contractDefs
end lexon_ListContractDefs

function lexon_FindContractDefArray dData, pAddPlurals
   local contractDefArray
   
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum] into itemArray
      put itemArray ["@style"] into itemStyle
      switch itemStyle
         case "title"
            next repeat
         default
            put itemArray ["text"] into utf8Clause
            put lexon_GetDefLineData (utf8Clause) into defLineData
            --
            if defLineData is an array then
               _AddToDefLineArray contractDefArray, defLineData, rowNum, pAddPlurals
            end if
      end switch
   end repeat
   return contractDefArray
end lexon_FindContractDefArray

function lexon_GetContractDefArray dData, pAddPlurals
   -- get from already stored "defLineData"
   local contractDefArray
   
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum]["defLineData"] into defData
      --
      if defData is an array then
         _AddToDefLineArray contractDefArray, defData, rowNum, pAddPlurals
      end if
   end repeat
   return contractDefArray
end lexon_GetContractDefArray

private command _AddToDefLineArray @contractDefArray, defLineData, rowNum, pAddPlurals
   repeat with defItemNum = 1 to item 2 of the extents of defLineData 
      put defLineData [defItemNum]["title"] into defTitle
      put rowNum into contractDefArray [defTitle]["rowNum"]
      --
      if pAddPlurals is not false then
         _AddPlural contractDefArray, defTitle, rowNum
      end if
   end repeat
end _AddToDefLineArray

private command _AddPlural @contractDefArray, defTitle, rowNum
   switch char -1 of defTitle
      case "y"
         put defTitle into pDefTitle
         put "ies" into char -1 of pDefTitle
         break
      case "s"
         put defTitle into pDefTitle
         delete char -1 of pDefTitle
         break
      default
         put defTitle & "s" into pDefTitle
   end switch
   put rowNum into contractDefArray [pDefTitle]["rowNum"]
end _AddPlural

function lexon_IsDef somePhrase
   -- standard "def"
   -- with first phrase quoted and second word "is" or "means"
   
   if word_IsQuoted (somePhrase, 1) is false then return false
   --
   get word 2 of somePhrase
   lexon_StripPunctuation it
   if it is among the items of "is,means" then
      return true
   else
      return false
   end if
end lexon_IsDef

function word_IsQuoted somePhrase, wordNum
   if token wordNum of somePhrase is word wordNum of somePhrase then
      return false
   else
      return true
   end if
end word_IsQuoted


