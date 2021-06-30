script "model_LexonContract"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_LexonContract
type: model
version: 0.1


--> Variables
-
local LocalArray


--> Working on
-
function lexon_ConstructContractElementsData dData
   put 1 into insertNum
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum] into itemArray
      switch itemArray ["@style"]
         case "title"
            get item 2 of the extents of eData
            put it + 1 into nextNum
            put itemArray into eData [nextNum]
            break
         case "clause"
            put itemArray ["text"] into clauseText
            put itemArray ["title"] into clauseTitle
            put lexon_ConstructClauseSectionData (clauseText, clauseTitle) into cData
            --
            _AddIndexArray eData, cData
            break
         default
            breakpoint
      end switch
   end repeat
   return eData
end lexon_ConstructContractElementsData

private command _AddIndexArray @eData, indexedDataToAdd
   get item 2 of the extents of eData
   put it + 1 into lastNum
   --
   repeat with itemNum = 1 to item 2 of the extents of indexedDataToAdd
      put indexedDataToAdd [itemNum] into eData [lastNum]
      add 1 to lastNum
   end repeat
   return lastNum
end _AddIndexArray
   
function lexon_ConstructClauseSectionData clauseText, clauseTitle
   local dData
   
   put lexon_GetDefData (clauseText) into defData
   --
   put item 2 of the extents of defData into maxNum
   repeat with itemNum = maxNum down to 1
      put defData [itemNum]["sWordNum"] into sWordNum
      put defData [itemNum]["eWordNum"] into eWordNum
      delete word sWordNum to eWordNum of clauseText
   end repeat
   put word 1 to -1 of clauseText into someClause
   
   if maxNum > 0 then
      /*
      put dv_ConstructItem ("DEFINITIONS.", "title") into itemArray
      put 2 into itemArray ["level"]
      dv_AddItemArray itemArray, dData
      put the result into insertedIndexNum
      */
      
      repeat with itemNum = 1 to maxNum
         put defData [itemNum]["text"] into sDef
         --
         put dv_ConstructItem (sDef, "definition") into itemArray
         put 3 into itemArray ["level"]
         --
         put defData [itemNum]["defPhrase"]["text"] into defPhrase
         put defPhrase into itemArray ["title"]
         --
         put lexon_GetClauseCapsArray (sDef) into capsArray
         indexedArray_Delete capsArray, 1
         put capsArray into itemArray ["links"]
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
      put lexon_GetClauseCapsArray (someClause) into capsArray
      put capsArray into itemArray ["links"]
      --
      dv_AddItemArray itemArray, dData
   end if
   return dData
end lexon_ConstructClauseSectionData

function lexon_GetClauseCapsArray someClause
   -- change to distinguish between defined clauses and undefined ones
   local clauseArray
   
   put 0 into wordsToAdd
   put 1 into indexNum
   _CreateClauseLines someClause
   --
   repeat for each line clauseLine in someClause
      put word 1 to -1 of clauseLine into clauseLine
      if clauseLine is empty then next repeat
      --
      put the number of words of clauseLine into maxNum
      put 1 into lineWordNum
      repeat 
         put word lineWordNum of clauseLine into testWord
         put char 1 of testWord into testChar
         --
         put _IsLower (testChar) is false into isCaps
         if isCaps then
            put _PhraseIsLexon (testWord) is false into isNotlexon
            if isNotlexon then
               
               put _FindLastLineWord (lineWordNum, clauseLine) into lastLineWordNum
               put word lineWordNum to lastLineWordNum of clauseLine into somePhrase
               --
               _AddToClauseArray clauseArray, somePhrase, lineWordNum, lastLineWordNum, wordsToAdd, someClause, indexNum
               put lastLineWordNum into lineWordNum
               add 1 to indexNum
            end if
         end if
         --
         if lineWordNum = maxNum then
            exit repeat
         else
            add 1 to lineWordNum
         end if
      end repeat
      add maxNum to wordsToAdd
   end repeat
   return clauseArray
end lexon_GetClauseCapsArray

private command _AddDvClause @dData, utf8Clause, clauseTitle
   if clauseText is empty then return 0
   --
   put lexon_CleanClause (utf8Clause) into someClause
   put dv_ConstructItem (someClause, "clause") into itemArray
   --
   if clauseTitle is not "_Untitled" then
      put clauseTitle into itemArray ["title"]
      --
      put lexon_GetClauseCapsArray (someClause) into clauseArray
      --
      put clauseArray into itemArray ["links"]
      put 3 into itemArray ["level"]
   end if
   --
   dv_AddItemArray itemArray, dData
   put the result into insertedIndexNum
   --
   return insertedIndexNum
end _AddDvClause

private function _GetSynonym somePhrase
   lexon_StripPunctuation somePhrase
   put _GetSynDic() into synDic
   get synDic [somePhrase]
   return it
end _GetSynonym

private function _GetSynDic
   put "Member" into synDic ["Members"]
   put "Member" into synDic ["Membership"]
   put "Shares" into synDic ["Members Shares"]
   put "Last Vote" into synDic ["Members Last Vote"]
   put "Never Voted" into synDic ["Member Never Voted"]
   put "Initial Capital Offer" into synDic ["Initial Capital Offers"]
   put "Capital Topup Offer" into synDic ["Capital Topup Offers"]
   --
   return synDic
end _GetSynDic

private function _PhraseIsLexon somePhrase
   put "Monday,Tuesday,Wedensday,Thursday,Friday,Saturday,Sunday," after lexItems
   put "start,end,Afterwards,Finally," after lexItems
   
   put "in,set,on,declare," after lexItems
   put "if,a,the," after lexItems
   put "at," after lexItems
   
   put "Pay,Create,Amount,Assets,Pay Out,Terminate,Certify,Return" after lexItems
   --
   switch
      case somePhrase is among the items of lexItems
         return true
      case somePhrase contains "%"
         return true
      case somePhrase is a number
         return true
      case _GetSynonym (somePhrase) is not empty
         return true
      default
         return false
   end switch
end _PhraseIsLexon

command _CreateClauseLines @someClause
   -- this should not change the wordNum
   replace "." with CR in someClause
   replace "," with CR in someClause
   replace ";" with CR in someClause
   replace ":" with CR in someClause
end _CreateClauseLines

private command _AddToClauseArray @clauseArray, somePhrase, lineWordNum, lastLineWordNum, wordsToAdd, testClause, indexNum
   put lineWordNum + wordsToAdd + 0 into sWordNum
   put lastLineWordNum + wordsToAdd + 0 into eWordNum
   
   put somePhrase into clauseArray [indexNum]["text"]
   put sWordNum into clauseArray [indexNum]["sWordNum"]
   put eWordNum into clauseArray [indexNum]["eWordNum"]
   
   get word sWordNum to eWordNum of testClause
   if it is not somePhrase then
      put it into clauseArray [indexNum]["test_text"]
      breakpoint
   end if
end _AddToClauseArray

private function _FindLastLineWord startLineWordNum, clauseLine
   put the number of words of clauseLine into maxNum
   repeat with lineWordNum = (startLineWordNum + 1) to maxNum
      put word lineWordNum of clauseLine into testWord
      put char 1 of testWord into testChar
      if _IsLower (testChar) is true then
         return lineWordNum -1
      end if
   end repeat
   return lineWordNum
end _FindLastLineWord


--> Lexon | Contract | DataViewArray
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
      _AddTitle dData, termArray, 1
      _ParseSectionData dData, sectionData
   end repeat
   --
   _AddDefData dData
   --
   return dData
end lexon_ConstructDataViewArray

function lexon_ListContractTermTitles dData
   -- easier to take from termData
   put _GetTermTitleArray (dData) into termTitleArray
   put termTitleArray ["orderedTitles"] into orderedTitles
   return orderedTitles
end lexon_ListContractTermTitles

function _GetTermTitleArray dData
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum] into clauseData
      put clauseData ["@style"] into sStyle
      put clauseData ["text"] into utf8Title
      put clauseData ["level"] into titleLevel
      --
      if sStyle = "title" and titleLevel = 1 then
         put utf8Title into termPhrase
         if word -1 of termPhrase = "TERMS." then delete word -1 of termPhrase
         --
         -- if termPhrase is not among the items of "GENERAL" then
         put rowNum into termTitleDictionary [termPhrase]["rowNum"]
         put utf8Title into termTitleDictionary [termPhrase]["title"]
         -- end if
         --
         put utf8Title & CR after orderedTitles
      end if
   end repeat
   delete char -1 of orderedTitles
   --
   put orderedTitles into termTitleArray ["orderedTitles"]
   put termTitleDictionary into termTitleArray ["termTitleDictionary"]
   --
   return termTitleArray
end _GetTermTitleArray

private command _AddDefData @dData
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum] into clauseData
      --
      put clauseData ["text"] into utf8Clause
      put lexon_GetDefData (utf8Clause, itemNum) into defData
      if defData is an array then
         put defData into dData [itemNum]["defData"]
      end if
   end repeat
end _AddDefData

function lexon_GetDefData utf8Clause, rowNum
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
         put rowNum into defData [foundNum]["dData rowNum"]
         --
         add 1 to foundNum
      end if
   end repeat
   return defData
end lexon_GetDefData

private function _GetDefPhraseArray sLine
   put lexon_GetClauseCapsArray (sLine) into capsArray
   put capsArray [1] into defPhraseArray
   --
   put defPhraseArray ["eWordNum"] into eWordNum
   
   get word (eWordNum + 1) of sLine
   lexon_StripPunctuation it
   if it is among the items of "is,means" then
      -- is this necessary or useful?
      put defPhraseArray ["text"] into defPhrase
      replace quote with empty in defPhrase
      put defPhrase into defPhraseArray ["text"]
      --
      return defPhraseArray
   else
      return empty
   end if
end _GetDefPhraseArray

private command _ParseSectionData @dData, sectionData
   repeat with sectionNum = 1 to item 2 of the extents of sectionData
      put sectionData [sectionNum] into sectionArray
      --
      _AddTitle dData, sectionArray, 2
      put sectionArray ["section"] into clauseData
      _ParseClauseData dData, clauseData
   end repeat
end _ParseSectionData

private command _AddTitle @dData, someArray, pLevel
   put someArray ["title"] into someTitle
   if someTitle = "_Untitled" then return false
   
   _TitleFormat someTitle
   --
   -- dv_AddMarkdownTitle dData, someTitle, pLevel
   put dv_ConstructItem (someTitle, "title") into itemArray
   put pLevel into itemArray ["level"]
   dv_AddItemArray itemArray, dData
   put the result into insertedIndexNum
   --
   return true
end _AddTitle

private command _TitleFormat @someTitle
   if char -1 of someTitle is not "." then
      put "." after someTitle
   end if
end _TitleFormat

private command _ParseClauseData @dData, clauseData
   repeat with clauseNum = 1 to item 2 of the extents of clauseData
      put clauseData [clauseNum] into clauseArray
      put clauseArray ["clause"] into clauseText
      put clauseArray ["title"] into clauseTitle
      _AddDvClause dData, clauseText, clauseTitle
   end repeat
end _ParseClauseData


--> Lexon | Contract | TermData
-
function lexon_GetTermData lexText
   local nextTermPage
   put "_Metadata" into pageTitle
   put 1 into tSectionNum
   put word 1 to -1 of lexText into lexText
   --
   repeat for each line someLine in lexText
      put word 1 to -1 of someLine into someLine
      if someLine is empty then next repeat
      --
      if _EndsWithTerms (someLine) is true then
         put lexon_ParsePageSections (nextTermPage) into sectionArray
         --
         if sectionArray is an array then
            put pageTitle into pageArray [tSectionNum]["title"]
            put sectionArray into pageArray [tSectionNum]["term"]
            add 1 to tSectionNum
         end if
         
         -- now start next page section
         put word 1 to -1 of someLine into pageTitle
         if char -1 of pageTitle = "." then delete char -1 of pageTitle
         put empty into nextTermPage
      else
         put someLine & CR after nextTermPage
      end if
   end repeat
   --
   if nextTermPage is not empty then
      put lexon_ParsePageSections (nextTermPage) into sectionArray
      if sectionArray is an array then
         put pageTitle into pageArray [tSectionNum]["title"]
         put sectionArray into pageArray [tSectionNum]["term"]
      end if
   end if
   --
   return pageArray
end lexon_GetTermData

function lexon_ParsePageSections lexTermPage
   local sectionArray, nextSection
   
   put "_Untitled" into nextSectionTitle
   put 1 into tPageNum
   --
   set the itemdelimiter to ":"
   repeat for each line someLine in lexTermPage
      put word 1 to -1 of someLine into someLine
      if someLine is empty then next repeat
      --
      if _IsAllCaps (someLine) is true then
         put word 1 to -1 of nextSection into nextSection
         if nextSection is not empty then
            put lexon_ParseSection (nextSection) into clauseArray
            --
            put nextSectionTitle into sectionArray [tPageNum]["title"]
            put clauseArray into sectionArray [tPageNum]["section"]
            --
            add 1 to tPageNum
         end if
         
         -- now start next page section
         put _GetSectionTitle (someLine) into nextSectionTitle
         put empty into nextSection
      else
         put someLine & CR after nextSection
      end if
   end repeat
   --
   if nextSection is not empty then
      put lexon_ParseSection (nextSection) into clauseArray
      --
      put nextSectionTitle into sectionArray [tPageNum]["title"]
      put clauseArray into sectionArray [tPageNum]["section"]
   end if
   --
   return sectionArray
end lexon_ParsePageSections

function lexon_ParseSection someSection
   local nextClause, clauseArray
   
   put "_Untitled" into nextClauseTitle
   put 1 into tClauseNum
   put word 1 to -1 of someSection into someSection
   --
   set the itemdelimiter to ":"
   repeat for each line someLine in someSection
      put word 1 to -1 of someLine into someLine
      if someLine is empty then next repeat
      --
      put _TitleIsClause (someLine) into isClauseTitle
      --
      switch
         case isClauseTitle AND nextClause is empty
            put lexon_GetTitle (someLine) into nextClauseTitle
            break
         case isClauseTitle
            put nextClauseTitle into clauseArray [tClauseNum]["title"]
            put nextClause into clauseArray [tClauseNum]["clause"]
            add 1 to tClauseNum
            --
            put lexon_GetTitle (someLine) into nextClauseTitle
            put empty into nextClause
            break
         default
            put someLine & CR after nextClause
      end switch
   end repeat
   --
   if nextClause is not empty AND nextClauseTitle is not empty then
      put nextClauseTitle into clauseArray [tClauseNum]["title"]
      put nextClause into clauseArray [tClauseNum]["clause"]
   end if
   
   return clauseArray
end lexon_ParseSection


--> Lexon | LinkArray
-
function lexon_ListContractDefs dData
   put lexon_GetContractDefArray (dData) into contractDefArray
   put the keys of contractDefArray into contractDefs
   sort contractDefs
   return contractDefs
end lexon_ListContractDefs

function lexon_GetContractDefArray dData
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum]["defData"] into defData
      repeat with defItemNum = 1 to item 2 of the extents of defData
         get defData [defItemNum]["text"]
         put word 1 of it into defTitle
         lexon_StripPunctuation defTitle
         put defData into contractDefArray [defTitle]
      end repeat
   end repeat
   return contractDefArray
end lexon_GetContractDefArray

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


--> Lexon | ClauseTitle
-
function lexon_ListClauseTitles dData
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum] into itemArray
      if itemArray ["@style"] = "clause" then
         put itemArray ["title"] into utf8Title
         if utf8Title is empty then next repeat
         --
         put lexon_GetClauseTitle (utf8Title) into clauseTitle
         put clauseTitle & CR after clauseTitles
      end if
   end repeat
   delete char -1 of clauseTitles
   sort lines of clauseTitles
   return word 1 to -1 of clauseTitles
end lexon_ListClauseTitles

function lexon_GetClauseTitle utf8Title
   put lexon_GetTitle (utf8Title) into clauseTitle
   set the itemdelimiter to ":"
   if item 1 of clauseTitle = "CLAUSE" then
      delete item 1 of clauseTitle
      put word 1 to -1 of clauseTitle into clauseTitle
      return clauseTitle
   else
      return empty
   end if
end lexon_GetClauseTitle

function lexon_GetTitle sTitle
   if char -1 of sTitle = "." then delete char -1 of sTitle
   return sTitle
end lexon_GetTitle

command lexon_StripPunctuation @clauseTitle
   replace quote with empty in clauseTitle
   replace ":" with empty in clauseTitle
   replace ";" with empty in clauseTitle
   replace "," with empty in clauseTitle
   replace "." with empty in clauseTitle
end lexon_StripPunctuation


--> Clause
-
function clause_GetUniqueTitleData clauseData
   put clauseData ["links"] into linkData
   repeat with itemNum = 1 to item 2 of the extents of linkData
      put linkData [itemNum]["text"] into sPhrase
      replace quote with empty in sPhrase
      put empty into titleData [sPhrase]
   end repeat
   return titleData
end clause_GetUniqueTitleData


--> Private
-
private function text_IsCaps someText
   put "^[^a-z]*$" into someReg
   get matchtext (word 1 to -1 of someText, someReg)
   return it 
end text_IsCaps

private function _TitleIsClause sTitle
   set the itemdelimiter to ":"
   put word 1 to -1 of item 1 of sTitle into maybeClauseTitle
   put maybeClauseTitle = "CLAUSE" into isClauseTitle
   return isClauseTitle
end _TitleIsClause

private function _IsAllCaps someLine
   put word 1 to -1 of someLine into someLine
   switch
      case someLine = "---"
      case someLine is empty
         return false -- hack
      default
         return text_IsCaps (someLine)
   end switch
end _IsAllCaps

private function _EndsWithTerms someLine   
   switch word -1 of someLine
      case "TERMS."
      case "TERMS"
         return true
      default
         return false
   end switch
end _EndsWithTerms

private function _GetSectionTitle someLine
   put word 1 to -1 of someLine into titleLine
   if char -1 of titleLine = "." then delete char -1 of titleLine
   switch item 1 of titleLine
      case "SECTION"
         put word 1 to -1 of item 2 to -1 of titleLine into sectionTitle
         break
      default
         put titleLine into sectionTitle
   end switch
   return sectionTitle
end _GetSectionTitle

private function _IsLower testChar
   --  if text_StartsWithCaps (testChar) then
   put charToNum (testChar) into sCharNum
   put sCharNum >= 97 AND sCharNum <= 122 into isLower
   return isLower
end _IsLower
