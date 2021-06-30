script "Global | Contract | Clause | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Contract | Clause | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
on menu_Init tObject
   -- called only once for top menu
   pass menu_Init
end menu_Init

getprop menu_Target [tObject]
   put the dvRowControl of tObject into rowView
   return rowView
end menu_Target

getprop menu_CheckTarget [rowView]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

function _GetRandomClause
   put lexon_FetchDataViewArray ("HyQ8s2di_") into dData
   put any item "8,11,13,15,17" into itemNum
   --
   put dData [itemNum]["text"] into clauseText
   subtract 1 from itemNum
   put dData [itemNum]["text"] into clauseTitle
   --
   return clauseText
end _GetRandomClause


--> Global | Contract | Clause | Menu
-
on menu_DisplayClauseElements rowView
   put the dv_RowValue ["text"] of rowView into clauseText
   put the dv_RowValue ["title"] of rowView into rowTitle
   --
   put lexon_ConstructClauseSectionData (clauseText, rowTitle) into dData
   --
   display_Data dData, rowTitle, "Clause Section Data"
   display_LexonData dData
end menu_DisplayClauseElements

on menu_ConstructDefinitions rowView
   put the dv_RowValue ["text"] of rowView into clauseText
   put the dv_RowValue ["title"] of rowView into rowTitle
   --
   put lexon_GetDefData (clauseText) into defData
   --
   display_Data defData, rowTitle, "Def Data"
end menu_ConstructDefinitions

on menu_DisplayDefinitions rowView
   put the dv_RowValue ["text"] of rowView into clauseText
   put the dv_RowValue ["title"] of rowView into rowTitle
   --
   -- put the dv_RowData of rowView into rowData
   -- put rowData ["defData"] into defData
   -- put rowData ["title"] into rowTitle
   --
   put lexon_GetDefData (clauseText) into defData
   put lexon_GetClauseCapsArray (clauseText) into clauseArray
   --
   display_Data defData, rowTitle, "lexon_GetDefData"
   display_Data clauseArray, rowTitle, "lexon_GetClauseCapsArray"
end menu_DisplayDefinitions

on menu_ClauseTitle rowView
   put the dv_RowData of rowView into rowData
   -- put the dvData of rowView into dData
   -- put the dvRow of rowView into rowNum
   --
   -- put rowData ["text"] into rowText
   -- put rowData ["id"] into rowID
   -- put rowData ["level"] into rowLevel
   
   put rowData ["title"] into rowTitle
   if rowTitle is empty then
      put the clause_SectionTitle of rowView
   else
      put rowTitle
   end if
end menu_ClauseTitle

on _
end _

on menu_LinkClauses rowView
   set the clause_DefColour ["blue"] of rowView to "red"
end menu_LinkClauses

on menu_ColourClause rowView
   set the phrase_DefColour ["blue"] of rowView to "dark green"
end menu_ColourClause

on menu_ClearFormatting rowView
   lock screen
   set the text_Colour of rowView to empty
   set the text_Style of rowView to empty
   unlock screen
end menu_ClearFormatting

on _
end _

on menu_ResetTextLocal rowView
   put the clause_Text of rowView into clauseText
   --
   set the itemdelimiter to ":"
   if item 1 of clauseText = "CLAUSE" then
      put line 1 of clauseText into clauseTitle
      delete line 1 of clauseText
   else
      put empty into clauseTitle
   end if
   --
   set the view_Text [clauseTitle] of rowView to clauseText
end menu_ResetTextLocal

on menu_ShowLinks rowView, someBoolean
   put the stack_Name of rowView into stackName
   put the underlinelinks of stack stackName into someBoolean
   set the underlinelinks of stack stackName to someBoolean is false
end menu_ShowLinks

getprop checked_ShowLinks [rowView]
   put the stack_Name of rowView into stackName
   put the underlinelinks of stack stackName into someBoolean
   return someBoolean
end checked_ShowLinks

on _
end _

on menu_UniqueClauseTitles rowView
   put the clause_Titles of rowView
end menu_UniqueClauseTitles

on menu_DisplayStructure rowView
   put the clause_Structure of rowView into cStructureData
   --
   display_Data cStructureData, cTitle, "Clause Structure"
end menu_DisplayStructure

on _
end _

on menu_DisplayRowData rowView
   put the dv_RowData of rowView into rowData
   put rowData ["title"] into rowTitle
   if rowTitle is empty then
      put rowData ["id"] into rowTitle
   end if
   display_Data rowData, rowTitle, "Row Data"
end menu_DisplayRowData

on menu_CapitalisePhrases rowView
   put the dv_RowData of rowView into rowData
   put rowData ["text"] into utf8Clause
   --
   put the contract_ClauseTitles of rowView into clauseTitles
   repeat for each line clauseTitle in clauseTitles
      put text_InitialCaps (clauseTitle) into clauseTitle
      put clauseTitle into someReg
      replace space with "\s" in someReg
      --
      text_StripReg utf8Clause, someReg, "•••"
      put the result into stripResultArray
   end repeat
   put utf8Clause
end menu_CapitalisePhrases

on _
end _

on menu_DisplayRowTemplate rowView
   put the view_Name of rowView into viewName
   put view_GetTemplateObject (viewName) into templateView
   --
   object_GoTo templateView
end menu_DisplayRowTemplate

on _
end _

on menu_DisplayWikiText rowView
   put the wiki_Text of rowView into wikiText
   put wikiText
end menu_DisplayWikiText

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_TestCap rowView
   put the dv_RowData of rowView into rowData
   put rowData ["text"] into utf8Clause
   --
   put "Election Is In Progress" into someReg
   replace space with "\s" in someReg
   --
   text_StripReg utf8Clause, someReg, "•••"
   put the result into stripResultArray
   --
   put utf8Clause
end menu_TestCap

on menu_TestIndent rowView
   set the indent_Lines of rowView to true
end menu_TestIndent

on menu_TestClause rowView
   get the clause_Text of rowView
   put line 1 of it into pTitle
   put line 2 to -1 of it into someClause
   --
   set the test_Clause [pTitle] of rowView to someClause
end menu_TestClause

on _
end _

on menu_EditRowBehavior rowView
   put the behavior of rowView into bObject
   edit the script of bObject
end menu_EditRowBehavior
