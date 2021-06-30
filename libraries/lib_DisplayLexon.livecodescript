script "lib_DisplayLexon"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DisplayLexon
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Display | Lexon
-
command display_LexonData dData, pCloneName, pStackRect
   display_Clone "View|Lexon|Contract", pCloneName, dData, "", pStackRect
   put the result into dView
   --
   -- set the displayed_Data of dView to dData
   set the dv_IconsShowing of dView to isHowing is false
   set the dv_CanDrag of dView to false
   set the displayed_Data of dView to dData
   set the auto_Scroll of dView to true
   --
   put the stack_Name of dView into stackName
   set the underlinelinks of stack stackName to false
   --
   return displayView
end display_LexonData

command display_LexonContract hackmdID, pCloneName, pStackRect
   if hackmdID is empty then put "HyQ8s2di_" into hackmdID
   if pCloneName is empty then put "Lexon Contract" into pCloneName
   --
   put lexon_FetchContract (hackmdID, false) into lexBody
   put lexon_GetTermData (lexBody) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   --
   display_LexonData dData, pCloneName, pStackRect
   put the result into displayView
   --
   return displayView
end display_LexonContract

command display_LexonTermData hackmdID, pCloneName, pStackRect
   if hackmdID is empty then put "HyQ8s2di_" into hackmdID
   if pCloneName is empty then put "Lexon Contract" into pCloneName
   --
   put lexon_FetchContract (hackmdID, false) into lexBody
   put lexon_GetTermData (lexBody) into termData
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


--> Lexon | Contract | Fetch
-
function lexon_FetchDataFromHackMD hackmdID
   put lexon_FetchTermData (hackmdID, false) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   return dData
end lexon_FetchDataFromHackMD

function lexon_FetchTermData hackmdID, pUseCli
   put lexon_FetchContract (hackmdID, pUseCli) into lexBody
   put lexon_GetTermData (lexBody) into termData
   return termData
end lexon_FetchTermData

function lexon_FetchContract noteID, pUseCli
   put hackmd_FetchMarkdown (noteID, pUseCli) into lexText
   hackmd_Deconstruct lexText, lexTitle, lexBody
   put the result into lexMeta
   --
   return lexBody
end lexon_FetchContract


--> Deps
-
