script "lib_DisplayLexon"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayLexon
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_LexonTools
   display_StackTools "Lexon Hub"
end display_LexonTools

command display_LexonData dData, pCloneName, pShowIcons, pStackRect
   lock screen
   if exists (stack pCloneName) then
      put the long id of control 1 of stack pCloneName into contractView
      put the dvControl of contractView into contractView
      if exists (contractView) is false then 
         return "Error, cannot locate dvControl of stack:" && pCloneName
      else
         set the displayed_Data of contractView to dData
      end if
   else
      display_Clone "View|Lexon|Contract", pCloneName, dData, "", pStackRect
      put the result into contractView
   end if
   -- should be "invisible first"
   --
   set the dv_IconsShowing of contractView to isHowing is false
   set the dv_CanDrag of contractView to false
   set the displayed_Data of contractView to dData
   set the auto_Scroll of contractView to true
   --
   put the stack_Name of contractView into stackName
   set the underlinelinks of stack stackName to false
   set the dv_IconsShowing of contractView to pShowIcons is true
   --
   unlock screen
   --
   dispatch "ResizeToFit" to contractView
   --
   return contractView
end display_LexonData

command display_LexonDefinitions dData, pCloneName
   if pCloneName is empty then put "Lexon Contract Definitions" into pCloneName
   --
   put lexon_FilterDefinitions (dData) into fData
   --
   display_LexonData fData, pCloneName
   put the result into contractView
   set the dv_IconsShowing of contractView to true
   --
   return contractView
end display_LexonDefinitions


--> Display | Lexon
-
command display_LexonContract hackmdID, pCloneName, pStackRect
   if hackmdID is empty then put "HyQ8s2di_" into hackmdID
   if pCloneName is empty then put "Lexon Contract" into pCloneName
   --
   put lexon_FetchContract (hackmdID, false) into lexBody
   put lexon_ConstructTermIndexData (lexBody) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   --
   display_LexonData dData, pCloneName, pStackRect
   put the result into contractView
   --
   return contractView
end display_LexonContract

command display_LexonTermData hackmdID, pCloneName, pStackRect
   if hackmdID is empty then put "HyQ8s2di_" into hackmdID
   if pCloneName is empty then put "Lexon Contract" into pCloneName
   --
   put lexon_FetchContract (hackmdID, false) into lexBody
   put lexon_ConstructTermIndexData (lexBody) into termData
   --
   put "DAO Contract" into pageTitle
   display_Data termData, pageTitle, "Lexon Page Array"
   put the result into displayView
   --
   display_SetInteractions displayView, "Lexon | Tree", "mDoubleUp_LexonTree"
   return displayView
end display_LexonTermData

on mDoubleUp_LexonTree displayView, someLine
   get the selected_Path of displayView
   if item 2 of it is not "term" then return false
   if item 4 of it is not "section" then return false
   if item -1 of it is "title" then return false
   
   put the selected_Value of displayView into utf8Clause
   put lexon_CleanClause (utf8Clause) into someClause
   put lexon_GetClauseCapsArray (someClause) into clauseArray
   --
   put the parent_Array of displayView into sArray
   put sArray ["title"] into pageTitle
   --
   put someClause
   display_Data clauseArray, pageTitle, "Lexon Clause Array"
   --
   return displayView
end mDoubleUp_LexonTree


--> Lexon | Contract | TermData
-
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


--> Lexon | Contract | Fetch
-
function lexon_FetchDataFromHackMD hackmdID
   put lexon_FetchTermData (hackmdID, false) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   return dData
end lexon_FetchDataFromHackMD

function lexon_FetchTermData hackmdID, pUseCli
   put lexon_FetchContract (hackmdID, pUseCli) into lexBody
   put lexon_ConstructTermIndexData (lexBody) into termData
   return termData
end lexon_FetchTermData

function lexon_FetchContract noteID, pUseCli
   put hackmd_FetchMarkdown (noteID, pUseCli) into lexText
   hackmd_Deconstruct lexText, lexTitle, lexBody
   put the result into lexMeta
   --
   return lexBody
end lexon_FetchContract


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
