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
command clause_Deconstruct @someClause, @clauseTitle
   -- put lexon_CleanClause (someClause) into someClause
   if lexon_IsClauseTitle (line 1 of someClause) then
      put word 1 to -1 of line 1 of someClause into clauseTitle
      delete line 1 of someClause
   else
      put "_Untitled" into clauseTitle
   end if
end clause_Deconstruct


--> Lexon | Local | Model
-
function lexon_GetContractData lexFile
   put url ("file:" & lexFile) into lexBody
   put lexon_DataFromContract (lexBody) into dData
   return dData
end lexon_GetContractData


--> Lexon | Files
-
function lexon_ConstructFile pShortFile
   put lexon_GetContractFolder() into lexFolder
   if pShortFile is empty then
      answer file "Select a Lexon contract..." with lexFolder
      if it is empty then exit to top
      put it into lexFile
   else
      put lexFolder & pShortFile into lexFile
   end if
   return lexFile
end lexon_ConstructFile

function lexon_GetContractFolder
   put the project_AssetFolder of stack "lcw_Lexon" into contractFolder
   return contractFolder
end lexon_GetContractFolder


--> Lexon | List
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

function lexon_ListContractTermTitles dData
   -- easier to take from termData
   put lexon_GetTermTitleArray (dData) into termTitleArray
   put termTitleArray ["orderedTitles"] into orderedTitles
   return orderedTitles
end lexon_ListContractTermTitles

function lexon_ListContractTerms dData
   put lexon_GetTermTitleArray (dData) into termTitleArray
   put termTitleArray ["termTitleDictionary"] into termTitleDictionary
   put the keys of termTitleDictionary into termTitles
   return termTitles
end lexon_ListContractTerms

function lexon_GetTermTitleArray dData
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
end lexon_GetTermTitleArray


--> Lexon | ClauseTitle
-
function lexon_GetClauseTitle utf8Title
   put lexon_GetTitle (utf8Title) into clauseTitle
   set the itemdelimiter to ":"
   if item 1 of clauseTitle = "CLAUSE" then
      delete item 1 of clauseTitle
      put word 1 to -1 of clauseTitle into clauseTitle
      return clauseTitle
   else
      return utf8Title
   end if
end lexon_GetClauseTitle

function lexon_IsClauseTitle sTitle
   set the itemdelimiter to ":"
   put word 1 to -1 of item 1 of sTitle into maybeClauseTitle
   put maybeClauseTitle = "CLAUSE" into isClauseTitle
   return isClauseTitle
end lexon_IsClauseTitle

function lexon_GetTitle sTitle
   if char -1 of sTitle = "." then delete char -1 of sTitle
   return sTitle
end lexon_GetTitle


--> Lexon | Contract | TermData
-
function lexon_DataFromContract lexBody
   put lexon_ConstructTermIndexData (lexBody) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   return dData
end lexon_DataFromContract

function lexon_ConstructTermIndexData lexText
   -- construct a structured array from the contract text
   -- split the array into sections based on  TERM SECTIONS.
   
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
            put pageTitle into termIndexData [tSectionNum]["title"]
            put sectionArray into termIndexData [tSectionNum]["term"]
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
         put pageTitle into termIndexData [tSectionNum]["title"]
         put sectionArray into termIndexData [tSectionNum]["term"]
      end if
   end if
   --
   return termIndexData
end lexon_ConstructTermIndexData

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
      put lexon_IsClauseTitle (someLine) into isClauseTitle
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


--> Private
-
private function _EndsWithTerms someLine   
   switch word -1 of someLine
      case "TERMS."
      case "TERMS"
         return true
      default
         return false
   end switch
end _EndsWithTerms

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

private function text_IsCaps someText
   put "^[^a-z]*$" into someReg
   get matchtext (word 1 to -1 of someText, someReg)
   return it 
end text_IsCaps
