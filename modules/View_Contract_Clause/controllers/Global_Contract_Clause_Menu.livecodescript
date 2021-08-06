script "Global | Contract | Clause | Menu"
--> MetaData
-
copyright: David Bovill
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

getprop checked_Locked [rowView]
   return the lock_Text of rowView is true
end checked_Locked

getprop checked_ShowLinks [rowView]
   put the stack_Name of rowView into stackName
   put the underlinelinks of stack stackName into someBoolean
   return someBoolean
end checked_ShowLinks

getprop checked_ShowIcon [rowView]
   put the icon_isVisible of rowView into isShowing
   return isShowing
end checked_ShowIcon

private command _SetProp rowView, @templateView, @clauseText, @clauseTitle
   put the view_Name of rowView into viewName
   put view_GetTemplateObject (viewName) into templateView
   --
   put the dv_RowData of rowView into rowData
   put rowData ["text"] into clauseText
   put rowData ["title"] into clauseTitle
   --
   if clauseTitle = "_Untitled" then
      put the lexon_RowTitle of rowView into clauseTitle
   end if
   return rowData
end _SetProp

getprop setIcon_Param [rowView]
   put the icon_Type of rowView into iconType
   -- put iconType
   return iconType
end setIcon_Param

getprop setIcon_Params [rowView]
   -- return "amount,number,person,entity,text,boolean,-,properties"
   put the icon_Types of rowView into iconTypes
   return iconTypes & ",-,test,detect,properties"
end setIcon_Params


--> Global | Contract | Clause | Menu
-
on menu_CreateWikiPage rowView
   lexon_CreateWikiPageFromRow rowView
   put the result into wikiURL
   --
   launch url wikiURL
end menu_CreateWikiPage

on menu_DisplayWikiText rowView
   put the wiki_Text of rowView into wikiText
   put wikiText
end menu_DisplayWikiText

on menu_GraphDeps rowView
   put the lexon_RowLinkArray of rowView into linkArray
   display_LinkArrayGraph linkArray
end menu_GraphDeps

on _
end _

on menu_SetIcon rowView, iconType
   switch iconType
      case "detect"
         put the icon_DetectType of rowView into detectedType
         set the icon_Type of rowView to detectedType
         put detectedType
         break
      case "test"
         put the icon_Type of rowView
         break
      case "properties"
         put the icon_View of rowView into iconView
         display_ObjectProperties iconView         
         break
      default
         set the icon_Type of rowView to iconType
   end switch
end menu_SetIcon

on menu_ShowIcon rowView
   put the icon_isVisible of rowView into isShowing
   set the icon_isVisible of rowView to (isShowing is false)
end menu_ShowIcon

on menu_ShowLinks rowView, someBoolean
   put the stack_Name of rowView into stackName
   put the underlinelinks of stack stackName into someBoolean
   set the underlinelinks of stack stackName to someBoolean is false
end menu_ShowLinks

on menu_Locked rowView
   set the lock_Text of rowView to not the lock_Text of rowView
end menu_Locked

on _
end _

on submenu_Test
   return "Test | Menu"
end submenu_Test

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Test | Menu
-
on menu_TestConstructClauseData rowView
   _SetProp rowView, templateView, clauseText, clauseTitle
   put the result into rowData
   --
   put the contract_TitleArray of rowView into titleArray
   put rowData ["defLineData"] into defLineData
   --
   put lexon_ConstructRowClauseData (clauseText, titleArray, defLineData) into clauseData
   --
   set the clause_Data [clauseText] of templateView to clauseData
   object_GoTo templateView
   --
   display_Data clauseData, "lexon_ConstructRowClauseData()", "Clause Data"
end menu_TestConstructClauseData

on menu_TestClauseData rowView
   _SetProp rowView, templateView, clauseText, clauseTitle
   --
   put the clause_Data [clauseText] of rowView into clauseData
   --
   set the clause_Data [clauseText] of templateView to clauseData
   object_GoTo templateView
end menu_TestClauseData

on menu_TestPlainClause rowView
   _SetProp rowView, templateView, clauseText, clauseTitle
   --
   set the plain_Text of templateView to clauseText
   --
   object_GoTo templateView
end menu_TestPlainClause

on _
end _

on menu_DisplayClauseData rowView
   put the clause_Data of rowView into clauseData
   --
   display_Data clauseData, "clauseData"
end menu_DisplayClauseData

on menu_DisplayDeflineData rowView
   put the dv_RowData of rowView into rowData
   put rowData ["defLineData"] into defData
   --
   display_Data defData, "defLineData"
end menu_DisplayDeflineData

on _
end _

on menu_DisplayLinkArray rowView
   _SetProp rowView, templateView, clauseText, clauseTitle
   --
   put the link_Array of rowView into linkArray
   --
   display_Data linkArray, clauseTitle, "Row Link Array"
end menu_DisplayLinkArray

on menu_DisplayCleanRow rowView
   _SetProp rowView, templateView, clauseText, clauseTitle
   put the result into rowData
   put the contract_TitleArray of rowView into titleArray
   --
   put lexon_CleanRow (rowData, titleArray) into dData
   -- display_Data dData, clauseTitle, "lexon_CleanRow (rowData)"
   --
   display_LexonData dData, clauseTitle
   put the result into contractView
   set the dv_IconsShowing of contractView to true
   --
   -- put the formattedHeight of contractView
end menu_DisplayCleanRow

on _
end _

on menu_DisplayClauseElements rowView
   _SetProp rowView, templateView, clauseText, clauseTitle
   --
   put lexon_ConstructClauseSectionData (clauseText, clauseTitle) into dData
   --
   display_Data dData, rowTitle, "Clause Section Data"
   display_LexonData dData
end menu_DisplayClauseElements

on menu_ConstructDefinitions rowView
   put the dv_RowValue ["text"] of rowView into clauseText
   put the dv_RowValue ["title"] of rowView into rowTitle
   --
   put lexon_GetDefLineData (clauseText) into defData
   --
   display_Data defData, rowTitle, "Def Data"
end menu_ConstructDefinitions

on menu_DisplayDefinitions rowView
   put the dv_RowValue ["text"] of rowView into clauseText
   put the dv_RowValue ["title"] of rowView into rowTitle
   --
   put lexon_GetDefLineData (clauseText) into defLineData
   put lexon_GetClauseCapsArray (clauseText) into clauseArray
   --
   display_Data defLineData, rowTitle, "lexon_GetDefLineData"
   display_Data clauseArray, rowTitle, "lexon_GetClauseCapsArray"
end menu_DisplayDefinitions

on _
end _

on menu_Edit rowView
   put "Hello World" into pKey
   put the dvRow of rowView into rowNum
   --
   dispatch "EditKeyOfRow" to rowView with pKey,rowNum
end menu_Edit


--> Dev | Menu
-
on menu_DisplayRowData rowView
   put the dv_RowData of rowView into rowData
   put rowData ["title"] into rowTitle
   if rowTitle is empty then
      put rowData ["id"] into rowTitle
   end if
   display_Data rowData, rowTitle, "Row Data"
end menu_DisplayRowData

on menu_EditRowBehavior rowView
   put the behavior of rowView into bObject
   edit the script of bObject
end menu_EditRowBehavior

on menu_DisplayRowTemplate rowView
   put the view_Name of rowView into viewName
   put view_GetTemplateObject (viewName) into templateView
   --
   object_GoTo templateView
end menu_DisplayRowTemplate

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

on _
end _

getprop addDataViewBehavior_Params
   return dv_ListStackNames()
end addDataViewBehavior_Params

getprop disabled_AddDataViewBehavior [rowView]
   put the dvControl of rowView into dView
   if exists (dView) then
      return true
   else
      return false
   end if
end disabled_AddDataViewBehavior

on menu_AddDataViewBehavior rowView, stackName
   put the long id of control 1 of stack stackName into dView
   put the behavior of dView into dataViewBehavior
   --
   put the behavior_Objects of rowView & CR&CR & the behavior_Objects of dView
   breakpoint
   --
   put the stack_Name of rowView into rowViewStackName
   set the behavior of stack rowViewStackName to dataViewBehavior
   put the behavior_Objects of stack rowViewStackName
end menu_AddDataViewBehavior

on menu_ClearStackBehavior rowView
   put the stack_Name of rowView into rowViewStackName
   set the behavior of stack rowViewStackName to empty
end menu_ClearStackBehavior

on _
end _

on menu_TestClauseText rowView
   breakpoint
   
   -- only works with access to dvData (ie within a dataview)
   _SetProp rowView, templateView, clauseText, clauseTitle
   --
   set the clause_Text [clauseTitle] of templateView to clauseText
   --
   object_GoTo templateView
end menu_TestClauseText
