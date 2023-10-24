script "Global | Lexon | Contract | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Lexon | Contract | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray
local HackMdID = "HyQ8s2di_"

--> Menu | Props
-
getprop menu_Target [tObject]   
   put tObject into LocalArray ["tObject"]
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
   display_LexonContract HackMdID, "Lexon Contract"
end menu_FetchLexonContract

on menu_ReFetchContract dView
   put hackMD_FetchLexonTermData (HackMdID) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   --
   set the displayed_Data of dView to dData
   /*
   put lexon_FetchDataViewArray ("HyQ8s2di_") into dData
   set the dvData of dView to dData
   -- 
   set the lexon_TermData of dView to termData
   dispatch "ResizeToFit" to dView
   */
end menu_ReFetchContract

private on _
end _

on menu_LoadLexonContract dView
   put lexon_ConstructFile() into lexFile
   put lexon_GetContractData (lexFile) into dData
   set the displayed_Data of dView to dData
end menu_LoadLexonContract

on menu_DownloadLexonContract
   put hackMD_FetchLexonContract (HackMdID) into lexBody
   --
   put lcw_Ask ("Give the contract a short file name...", "oversimplicated.txt") into shortFile
   put lexon_GetContractFolder() into lexFolder
   put lexFolder & shortFile into lexFile
   --
   put lexBody into url ("file:" & lexFile)
end menu_DownloadLexonContract

on menu_RevealContractFolder
   put lexon_GetContractFolder() into lexFolder
   finder_Reveal lexFolder
end menu_RevealContractFolder

private on __
end __

-- on menu_GraphContract dView
   put the dvData of dView into dData
   --
   -- put lexon_ConstructContractLinkArray (dData) into linkArray
   put lexon_GetContractLinkArray (dData, "def") into linkArray
   --
   display_LinkArrayGraph linkArray
   display_Data linkArray, "Contract Graph", "Lexon"
end menu_GraphContract

on submenu_GraphContract
   return "Global | Lexon | Contract | Graph | Menu"
end submenu_GraphContract

private on ___
end ___

on menu_RenameUntitled dView
   set the selected_Clause of dView to clauseTitle
end menu_RenameUntitled

private on ___
end ___

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

private on ____
end ____

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

private on _____
end _____

on submenu_Dev
   return menu_DevTitle ("Global | Lexon | Contract | Menu")
end submenu_Dev
