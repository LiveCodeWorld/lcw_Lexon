script "lib_LexonContract"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_LexonContract
type: library
version: 0.1

/*Some help*/


--> Working on
-
function row_GetDataAbove rowNum, dData, pLevel
   put dData [rowNum] into startRowData
   if pLevel is empty then
      get startRowData ["level"]
      if it is empty then
         put 2 into levelAbove -- hack
      else
         put it - 1 into levelAbove
      end if
   else
      put pLevel into levelAbove
   end if
   --
   put rowNum - 1 into startRowNum
   repeat with itemNum = startRowNum down to 1
      put dData [itemNum] into rowData
      put rowData ["level"] into sLevel
      --
      if sLevel is empty then put 3 into sLevel -- hack
      --
      if sLevel <= levelAbove then
         return rowData
      end if
   end repeat
   return empty
end row_GetDataAbove

command clause_BlankFound @someClause, clauseData
   repeat for each key itemType in clauseData
      put clauseData [itemType] into itemData
      repeat with itemNum = 1 to item 2 of the extents of itemData
         put itemData [itemNum]["sWordNum"] into sWordNum
         put itemData [itemNum]["eWordNum"] into eWordNum
         --
         get token sWordNum to eWordNum of someClause
         put _GetFakeWords (sWordNum, eWordNum, someClause) into fakeWords
         --
         put fakeWords into token sWordNum to eWordNum of someClause --- same number of words but not chars
      end repeat
   end repeat
end clause_BlankFound


--> Lexon | TitleArray
-
function lexon_GetContractTitleArray dData
   -- works after indexing with lexon_AddDefAndClauseData
   put lexon_ListContractTerms (dData) into contractTerms
   put lexon_ListClauseTitles (dData) into clauseTitles
   put lexon_ListContractDefs (dData) into defTitles
   put lexon_ConstructTitleArray (contractTerms, clauseTitles, defTitles) into titleArray
   return titleArray
end lexon_GetContractTitleArray

function lexon_GetClauseCapsArray someClause
   -- not tested with quoted things
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
         put text_IsUpper (testChar) is true into isCaps
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


--> Lexon | ClauseData
-
function lexon_ConstructTitleArray contractTerms, clauseTitles, defTitles
   local titleArray
   
   lexon_AddToTitleArray titleArray, contractTerms, "term"
   lexon_AddToTitleArray titleArray, clauseTitles, "clause"
   lexon_AddToTitleArray titleArray, defTitles, "def"
   --
   return titleArray
end lexon_ConstructTitleArray

function lexon_GetUnknownCapsArray someClause, clauseData
   clause_Deconstruct someClause, clauseTitle
   clause_BlankFound someClause, clauseData
   put lexon_GetClauseCapsArray (someClause) into unknownCapsArray
   return unknownCapsArray
end lexon_GetUnknownCapsArray


--> Lexon | Contract
-
function lexon_FindDef somePhrase, dData
   put lexon_GetContractDefArray (dData) into defArray
   put defArray [somePhrase]["rowNum"] into rowNum
   if rowNum is empty then
      return 0
   else
      return rowNum
   end if
end lexon_FindDef

function lexon_FindClause clauseTitle, dData
   put "CLAUSE:" && clauseTitle into findTitle
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum]["@style"] into itemStyle
      if itemStyle = "clause" then
         put dData [rowNum]["title"] into testTitle
         if testTitle = findTitle then
            return rowNum
         end if
      end if
   end repeat
   return 0
end lexon_FindClause
   
function lexon_FindTerm termTitle, dData
   put word 1 to -1 of termTitle && "TERMS." into testTitle
   --
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum]["@style"] into itemStyle
      if itemStyle = "title" then
         put dData [rowNum]["text"] into titleText
         if testTitle = titleText then
            return rowNum
         end if
      end if
   end repeat
   return 0
end lexon_FindTerm

command lexon_AddToTitleArray @titleArray, someTitles, linkType
   repeat for each line someTitle in someTitles
      put the number of words of someTitle into wordNum
      put linkType into titleArray [wordNum][someTitle]["linkType"]
   end repeat
end lexon_AddToTitleArray


--> Private
-
private command _CreateClauseLines @someClause
   -- this should not change the wordNum
   replace "." with CR in someClause
   replace "," with CR in someClause
   replace ";" with CR in someClause
   replace ":" with CR in someClause
end _CreateClauseLines

private function _GetFakeWords sWordNum, eWordNum, someClause
   put token sWordNum to eWordNum of someClause into somePhrase
   repeat the number of  words of somePhrase
      put "•••" & space after fakeWords
   end repeat
   delete char -1 of fakeWords
   return fakeWords
end _GetFakeWords

function _PhraseIsLexon somePhrase
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
      if text_IsUpper (testChar) is false then
         return lineWordNum -1
      end if
   end repeat
   return lineWordNum
end _FindLastLineWord


--> Deps
-
command text_StripQuotedArray @someText
   local offsetArray
   
   sort descending lines of someTitles by the number of words of each
   put 1 into foundNum
   repeat for each line someTitle in someTitles
      repeat 100 -- for safety
         -- can be multiple instances
         put _ConstructQuoteReg() into regExp
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
   end repeat
   --
   return offsetArray
end text_StripQuotedArray

command text_StripTitles @offsetArray, @someText, someTitle, linkType
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

command text_StripPhraseArray @someText, someTitles
   local clauseArray
   
   sort descending lines of someTitles by the number of words of each
   put 1 into foundNum
   repeat for each line someTitle in someTitles
      repeat 100 -- for safety
         text_SetTokenOffsets someTitle, someText, sWordNum, eWordNum
         if the result = 0 then
            exit repeat
         else
            put sWordNum into titleArray [foundNum]["sWordNum"]
            put eWordNum into titleArray [foundNum]["eWordNum"]
            put someTitle into titleArray [foundNum]["text"]
            add 1 to foundNum
            --
            get _GetFakeWords (sWordNum, eWordNum, someText)
            put it into token sWordNum to eWordNum of someText
         end if
      end repeat
   end repeat
   return titleArray
end text_StripPhraseArray

function text_GetPhraseArray clauseText, clauseTitles
   local clauseArray
   
   clause_Deconstruct clauseText, clauseTitle
   sort descending lines of clauseTitles by the number of words of each
   put 1 into foundNum
   repeat for each line clauseTitle in clauseTitles
      repeat 100 -- for safety
         -- text_SetWordOffsets clauseTitle, clauseText, sWordNum, eWordNum, charsToSkip
         text_SetTokenOffsets clauseTitle, clauseText, sWordNum, eWordNum
         put the result into charsToSkip
         --
         if charsToSkip = 0 then
            exit repeat
         else
            get token sWordNum to eWordNum of clauseText
            -- get word sWordNum to eWordNum of clauseText
            text_TrimWordEnd it
            if it is not clauseTitle then breakpoint
            --
            put sWordNum into clauseArray [foundNum]["sWordNum"]
            put eWordNum into clauseArray [foundNum]["eWordNum"]
            put clauseTitle into clauseArray [foundNum]["text"]
            add 1 to foundNum
            --
            get _GetFakeWords (sWordNum, eWordNum, clauseText)
            put it into token sWordNum to eWordNum of clauseText
         end if
      end repeat
   end repeat
   return clauseArray
end text_GetPhraseArray

command text_SetTokenOffsets somePhrase, someText, @sTokenNum, @eTokenNum, pCharsToSkip
   -- wordoffset does not accept multi-word search terms
   
   put regExp_WordPhrase (somePhrase) into regExp
   put char (pCharsToSkip + 1) to -1 of someText into testText
   --
   if matchChunk (testText, regExp, sCharNum, eCharNum) then
      put char sCharNum to eCharNum of testText into testPhrase
      --
      get char 1 to sCharNum of testText
      put the number of tokens of it into sTokenNum
      put sTokenNum + the number of tokens of somePhrase - 1 into eTokenNum
      get token sTokenNum to eTokenNum of someText
      --
      get char 1 to pCharsToSkip of someText
      put the number of tokens of it into offsetNum
      add offsetNum to sTokenNum
      add offsetNum to eTokenNum
      --
      return eCharNum
   else
      return 0
   end if
end text_SetTokenOffsets

function regExp_WordPhrase somePhrase
   regExp_SetAnySpace somePhrase
   put "(?i)\b(" & somePhrase & ")\b" into regExp
   return regExp
end regExp_WordPhrase

command regExp_SetAnySpace @somePhrase
   repeat for each word someWord in somePhrase
      put someWord & "\s" after regExp
   end repeat
   delete char -2 to -1 of regExp
   put regExp into somePhrase
end regExp_SetAnySpace

command text_SetWordOffsets somePhrase, someText, @sWordNum, @eWordNum, pCharsToSkip
   -- wordoffset does not accept multi-word search terms
   -- could improve by using ergular expression
   
   put offset (somePhrase, someText, pCharsToSkip) into rCharNum
   if rCharNum = 0 then return 0
   --
   put rCharNum + pCharsToSkip - 1 into sCharNum
   get char 1 to sCharNum of someText
   put (the number of words of it) + 1 into sWordNum
   put sWordNum + the number of words of somePhrase into eWordNum
   subtract 1 from eWordNum
   --
   put sCharNum + the number of chars of somePhrase - 1 into eCharNum
   return eCharNum
   
   put word sWordNum to eWordNum of someText into checkLine
   text_TrimWordEnd checkLine
   return checkLine
end text_SetWordOffsets

command text_TrimWordEnd @somePhrase
   if char -1 of somePhrase is among the chars of ".,;:" then delete char -1 of somePhrase
end text_TrimWordEnd

function text_IsLower testChar
   --  if text_StartsWithCaps (testChar) then
   put charToNum (testChar) into sCharNum
   put sCharNum >= 97 AND sCharNum <= 122 into isLower
   return isLower
end text_IsLower

function text_IsUpper testChar
   --  if text_StartsWithCaps (testChar) then
   put charToNum (testChar) into sCharNum
   put sCharNum >= 65 AND sCharNum <= 90 into isLower
   return isLower
end text_IsUpper
