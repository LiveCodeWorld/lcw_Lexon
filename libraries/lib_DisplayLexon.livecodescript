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
command display_LexonDefinitions dData, pCloneName
   if pCloneName is empty then put "Lexon Contract Definitions" into pCloneName
   --
   breakpoint
   put lexon_FilterDefinitions (dData) into fData -- broken???
   --
   display_LexonData fData, pCloneName
   put the result into contractView
   set the dv_IconsShowing of contractView to true
   --
   return contractView
end display_LexonDefinitions

command display_LexonTools
   display_StackTools "Lexon Hub"
end display_LexonTools


--> Display | Lexon
-
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


--> Display | Lexon
-
command display_LexonContract pHackmdID, pCloneName, pStackRect
   if pCloneName is empty then put "Lexon Contract" into pCloneName
   if pHackmdID is empty then
      -- put "HyQ8s2di_" into pHackmdID
      put lexon_ConstructFile ("oversimplicated.txt") into lexFile
      put lexon_GetContractData (lexFile) into dData
   else
      put hackMD_FetchLexonContract (pHackmdID, false) into lexBody
      put lexon_DataFromContract (lexBody) into dData
   end if
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
   put hackMD_FetchLexonContract (hackmdID, false) into lexBody
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
