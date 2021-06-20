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
private function _PhraseIsLexon somePhrase
   put "Monday,Tuesday,Wedensday,Thursday,Friday,Saturday,Sunday," after lexItems
   put "set,on,start,end,declare," after lexItems
   put "if,the," after lexItems
   -- put "cancel," after lexItems
   --
   switch
      case somePhrase is among the items of lexItems
         return true
      default
         return false
   end switch
end _PhraseIsLexon

command lexon_Transfer rowView
   get the markdown_Text of rowView
   put line 1 of it into clauseTitle
   put line 2 to -1 of it into utf8Clause
   put lexon_CleanClause (utf8Clause) into someClause
   --
   put view_GetTemplateObject ("View|Contract|Clause") into templateObject
   set the clause_Text ["red"] of templateObject to someClause
   --
   object_GoTo templateObject
end lexon_Transfer


--> Display
-
on mDoubleUp_LexonTree displayView, someLine
   get the selected_Path of displayView
   if item 2 of it is not "term" then return false
   if item 4 of it is not "section" then return false
   if item -1 of it is "title" then return false
   
   put the selected_Value of displayView into utf8Clause
   put lexon_CleanClause (utf8Clause) into someClause
   put lexon_GetClauseArray (someClause) into clauseArray
   --
   put the parent_Array of displayView into sArray
   put sArray ["title"] into pageTitle
   --
   put someClause
   display_Data clauseArray, pageTitle, "Lexon Clause Array"
   --
   return displayView
end mDoubleUp_LexonTree

command display_LexonContract lexText
   hackmd_Deconstruct lexText, lexTitle, lexBody
   put the result into lexMeta
   --
   put lexon_FetchContractData (lexBody) into pageArray
   --
   put "DAO Contract" into pageTitle
   display_Data pageArray, pageTitle, "Lexon Page Array"
   put the result into displayView
   --
   display_SetInteractions displayView, "Lexon | Tree", "mDoubleUp_LexonTree"
   return displayView
end display_LexonContract


--> Lexon | Clause
-
function lexon_ConstructWikiClause someClause
   put lexon_GetClauseArray (someClause) into clauseArray
   --
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
end lexon_ConstructWikiClause

function lexon_CleanClause utf8Clause
   put utf8_Decode (utf8Clause) into someClause
   text_CleanQuotes someClause
   return someClause
end lexon_CleanClause

command text_CleanQuotes @someText
   replace "“" with quote in someText
   replace "”" with quote in someText
end text_CleanQuotes

command _CreateClauseLines @someClause
   -- this should not change the wordNum
   replace "." with CR in someClause
   replace "," with CR in someClause
   replace ";" with CR in someClause
   replace ":" with CR in someClause
end _CreateClauseLines

function lexon_GetClauseArray someClause
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
         put _PhraseIsLexon (testWord) is false into isNotlexon
         put _IsLower (testChar) is false into isCaps
         --
         if isCaps and isNotlexon then
            put _FindLastLineWord (lineWordNum, clauseLine) into lastLineWordNum
            put word lineWordNum to lastLineWordNum of clauseLine into somePhrase
            --
            _AddToClauseArray clauseArray, somePhrase, lineWordNum, lastLineWordNum, wordsToAdd, someClause, indexNum
            put lastLineWordNum into lineWordNum
            add 1 to indexNum
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
end lexon_GetClauseArray


--> Lexon | Fetch
-
function lexon_FetchDataViewArray hackmdID, pUseCli
   put lexon_FetchContract (hackmdID, pUseCli) into lexBody
   put lexon_FetchContractData (lexBody) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   return dData
end lexon_FetchDataViewArray

function lexon_ConstructDataViewArray termData
   local dData
   --
   repeat with termNum = 1 to item 2 of the extents of termData
      put termData [termNum] into termArray
      --
      _AddTitle dData, termArray, 1
      --
      put termArray ["term"] into sectionData
      _ParseSectionData dData, sectionData
   end repeat
   return dData
end lexon_ConstructDataViewArray

function lexon_FetchContract noteID, pUseCli
   put hackmd_FetchMarkdown (noteID, pUseCli) into lexText
   --
   hackmd_Deconstruct lexText, lexTitle, lexBody
   put the result into lexMeta
   --
   return lexBody
end lexon_FetchContract

function lexon_FetchDataViewArray noteID, pUseCli
   put lexon_FetchContract (noteID, pUseCli) into lexBody
   put lexon_FetchContractData (lexBody) into lexonArray
   --
   return lexonArray
end lexon_FetchDataViewArray


--> Lexon
-
function lexon_FetchContractData lexText
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
end lexon_FetchContractData

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
      put item 1 of someLine into maybeClauseTitle
      put maybeClauseTitle is "CLAUSE" into isClauseTitle
      --
      switch
         case isClauseTitle AND nextClause is empty
            put _GetTitle (someLine) into nextClauseTitle
            break
         case isClauseTitle
            put nextClauseTitle into clauseArray [tClauseNum]["title"]
            put nextClause into clauseArray [tClauseNum]["clause"]
            add 1 to tClauseNum
            --
            put _GetTitle (someLine) into nextClauseTitle
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


--> Private
-
private command _ParseSectionData @dData, sectionData
   repeat with sectionNum = 1 to item 2 of the extents of sectionData
      put sectionData [sectionNum] into sectionArray
      --
      _AddTitle dData, sectionArray, 2
      --
      put sectionArray ["section"] into clauseData
      --
      _ParseClauseData dData, clauseData
   end repeat
end _ParseSectionData

private command _ParseClauseData @dData, clauseData
   repeat with clauseNum = 1 to item 2 of the extents of clauseData
      put clauseData [clauseNum] into clauseArray
      put clauseArray ["clause"] into clauseText
      --
      --  _AddTitle dData, clauseArray, 3
      put clauseArray ["title"] into someTitle
      put text_RepeatString ("#", 3) && someTitle & CR before clauseText
      --
      dv_AddMarkdown dData, clauseText
   end repeat
end _ParseClauseData

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

private command _AddTitle @dData, someArray, pLevel
   put someArray ["title"] into someTitle
   if someTitle = "_Untitled" then return false
   
   _TitleFormat someTitle
   dv_AddMarkdownTitle dData, someTitle, pLevel
   return true
end _AddTitle

private command _TitleFormat @someTitle
   if char -1 of someTitle is not "." then
      put "." after someTitle
   end if
end _TitleFormat

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

private function _IsLower testChar
   --  if text_StartsWithCaps (testChar) then
   put charToNum (testChar) into sCharNum
   put sCharNum >= 97 AND sCharNum <= 122 into isLower
   return isLower
end _IsLower

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

private function _GetTitle someLine
   put someLine into nextClauseTitle
   if char -1 of clauseTitle = "." then delete char -1 of nextClauseTitle
   return nextClauseTitle
end _GetTitle

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
