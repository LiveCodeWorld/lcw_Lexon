script "Global | Lexon | Contract | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Lexon | Contract | Menu
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
   put tObject into LocalArray ["tObject"]
end menu_Init

getprop menu_Target [tObject]   
   -- put the dv_LinkedDataView of tObject into dView
   put the dvControl of tObject into dView
   if exists (dView) is true then return dView
   
   put the displayed_Object of tObject into dObject
   if exists (dObject) is false then return empty
   
   put the dvControl of dObject into dView
   if exists (dView) is true then return dView
   
   put the contract_View of dObject into dView
   return dView
end menu_Target

getprop checked_CanDrag [dView]
   put the dv_CanDrag of dView into canDrag
   return canDrag
end checked_CanDrag

getprop checked_ShowLinks [rowView]
   put the stack_Name of rowView into stackName
   put the underlinelinks of stack stackName into someBoolean
   return someBoolean
end checked_ShowLinks

getprop checked_ShowIcons [dView]
   put the dv_IconsShowing of dView into isShowing
   return isShowing
end checked_ShowIcons

getprop checked_ScrollToSelection [dView]
   put the viewProp ["scroll selections into view"] of dView into doesScroll
   return doesScroll
end checked_ScrollToSelection

on mDoubleUp_DisplayClauses displayView, clauseTitle
   put the displayed_Object of displayView into dView
   set the selected_Clause of dView to clauseTitle
end mDoubleUp_DisplayClauses

on mDoubleUp_DisplayDef displayView, sDef
   put the displayed_Object of displayView into dView
   set the selected_Def of dView to sDef
end mDoubleUp_DisplayDef

on mDoubleUp_DisplayContractTerm
   put the params
   breakpoint
end mDoubleUp_DisplayContractTerm

on mDoubleUp_DisplayTermTitle displayView, termTitle
   put the displayed_Object of displayView into dView
   --
   put the dvData of dView into dData
   put _GetTermTitleArray (dData) into termTitleArray
   put termTitleArray ["termTitleDictionary"] into termTitleDictionary
   --
   put termTitle into termWord
   delete word -1 of termTitle
   --
   put termTitleDictionary [termTitle] into termTitleArray
   put termTitleArray ["rowNum"] into rowNum
   --
   set the dvHilitedRows of dView to rowNum
end mDoubleUp_DisplayTermTitle

getprop hiliteClause_Params [dView]
   put the contract_ClauseTitles of dView into clauseTitles
   return clauseTitles
end hiliteClause_Params


--> Global | Lexon | Contract | Menu
-
on menu_FetchLexonContract dView
   /*
   put lexon_FetchTermData ("HyQ8s2di_") into termData
   put lexon_ConstructDataViewArray (termData) into dData
   --
   set the displayed_Data of dView to dData
   set the lexon_TermData of dView to termData
   dispatch "ResizeToFit" to dView
   */
   --
   display_LexonContract "HyQ8s2di_", "Lexon Contract"
end menu_FetchLexonContract

on menu_ReFetchContract dView
   put lexon_FetchTermData ("HyQ8s2di_") into termData
   put lexon_ConstructDataViewArray (termData) into dData
   --
   set the displayed_Data of dView to dData
   -- set the lexon_TermData of dView to termData
   dispatch "ResizeToFit" to dView
end menu_ReFetchContract

on menu_DisplayBrowser
   display_Browser someURL, sRect
end menu_DisplayBrowser

on _
end _

on menu_CleanContract dView
   put the displayed_Data of dView into dData
   --
   put lexon_CleanData (dData) into eData
   --
   display_LexonData eData
end menu_CleanContract

on menu_DisplayDefinitions contractView
   put the displayed_Data of contractView into dData
   --
   --
   display_LexonDefinitions dData
end menu_DisplayDefinitions

on _
end _

on menu_GraphContract dView
   put the dvData of dView into dData
   --
   -- put lexon_ConstructContractLinkArray (dData) into linkArray
   put lexon_GetContractLinkArray (dData, "def") into linkArray
   --
   display_LinkArrayGraph linkArray
   display_Data linkArray, "Contract Graph", "Lexon"
end menu_GraphContract

on menu_DisplayContractLinkArray dView
   put the displayed_Data of dView into iData
   put lexon_GetContractLinkArray (iData) into cLinkArray
   --
   display_Data cLinkArray, "Clause LinkArray", "Lexon Contract"
end menu_DisplayContractLinkArray

on _
end _

on menu_RenameUntitled dView
   set the selected_Clause of dView to clauseTitle
end menu_RenameUntitled

on _
end _

on menu_HiliteClause dView, clauseTitle
   set the selected_Clause of dView to clauseTitle
end menu_HiliteClause

on submenu_ImportData
   return "Global | Wiki | Data | Menu"
end submenu_ImportData

on submenu_Templates
   return "Global | DataView | Template | Menu"
end submenu_Templates

on submenu_Behaviors
   return "Global | DataView | Behaviors | Menu"
end submenu_Behaviors

on _
end _

on menu_ShowLinks rowView, someBoolean
   put the stack_Name of rowView into stackName
   put the underlinelinks of stack stackName into someBoolean
   set the underlinelinks of stack stackName to someBoolean is false
end menu_ShowLinks

on menu_ShowIcons dView
   put the dv_IconsShowing of dView into isHowing
   set the dv_IconsShowing of dView to isHowing is false
end menu_ShowIcons

on menu_ScrollToSelection dView
   put the viewProp ["scroll selections into view"] of dView into doesScroll
   set the viewProp ["scroll selections into view"] of dView to (doesScroll is false)
end menu_ScrollToSelection

on menu_CanDrag dView
   put the dv_CanDrag of dView is false into cantDrag
   set the dv_CanDrag of dView to cantDrag
end menu_CanDrag

on _
end _

on menu_RefreshDataView dView
   send "ResetView" to dView in 2 ticks
   send "RenderView" to dView in 4 ticks
end menu_RefreshDataView

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_FetchTermData
   put lexon_FetchTermData ("HyQ8s2di_") into termData
   --
   display_Data termData, "Term Data", "Lexon"
end menu_FetchTermData

on _
end _

on menu_AddDefArray dView
   put the displayed_Data of dView into dData
   --
   lexon_AddDefAndClauseData dData
   --
   display_Data dData, "dData"
end menu_AddDefArray

on menu_DisplayTitleArray dView
   put the contract_TitleArray of dView into titleArray
   --
   display_Data titleArray, "titleArray"
end menu_DisplayTitleArray

on _
end _

on menu_DisplayTermTitles dView
   put the contract_TermTitles of dView into termTitles
   --
   display_Data termTitles, "Term Titles", "Lexon Contract"
   put the result into displayView
   set the mouse_DoubleUp ["me"] of displayView to "mDoubleUp_DisplayTermTitle"
   set the displayed_Object of displayView to dView
end menu_DisplayTermTitles

on menu_DisplayTerms dView
   put the contract_Terms of dView into contractTerms
   --
   display_Data contractTerms, "Contract Terms", "Lexon Contract"
   put the result into displayView
   set the mouse_DoubleUp ["me"] of displayView to "mDoubleUp_DisplayContractTerm"
   set the displayed_Object of displayView to dView
end menu_DisplayTerms

on menu_DisplayClauseTitles dView
   put the contract_ClauseTitles of dView into clauseTitles
   --
   display_Data clauseTitles, "Clause Titles", "Lexon Contract"
   put the result into displayView
   set the mouse_DoubleUp ["me"] of displayView to "mDoubleUp_DisplayClauses"
   set the displayed_Object of displayView to dView
end menu_DisplayClauseTitles

on menu_DisplayDefTitles dView
   put the contract_DefTitles of dView into defTitles
   --
   display_Data defTitles, "Def Titles", "Lexon Contract"
   put the result into displayView
   set the mouse_DoubleUp ["me"] of displayView to "mDoubleUp_DisplayDef"
   set the displayed_Object of displayView to dView
end menu_DisplayDefTitles

on _
end _

on menu_DisplayContractTermData
   put lexon_FetchContract ("HyQ8s2di_") into lexBody
   put lexon_GetTermPageArray (lexBody) into termData
   --
   display_Data termData, "Term Data", "Lexon Contract"
end menu_DisplayContractTermData

on menu_DisplayDataviewArray
   put lexon_FetchDataViewArray ("HyQ8s2di_") into dData
   --
   display_Data dData, "DataView Array", "Lexon Contract"
end menu_DisplayDataviewArray

on _
end _

on menu_SetLinkedDataView dView
   select dView
   -- select group id dvID of stack stackName
   
   lcw_Answer "Do you want to set the linked dataview of this menu to the selectedobj?"
   --
   set the dv_LinkedDataView of dView to dView
   --
   put the card_Object of dView into cObject
   set the dv_LinkedDataView of cObject to dView
   
   -- in case it is called from an indexView
   put LocalArray ["displayView"] into displayView
   if exists (displayView) is true then
      set the dv_LinkedDataView of displayView to dView
   end if
end menu_SetLinkedDataView

on menu_Deselect
   select empty
end menu_Deselect
