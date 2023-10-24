script "Global | Lexon | Contract | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Lexon | Contract | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Lexon | Contract | Dev | Menu
-
on menu_DisplayLinkTypeArray rowView
   put the dv_RowData of rowView into rowData
   put the dvData of rowView into cTitleArray
   --
   put lexon_GetLinkTypeArray (rowData, cTitleArray, dTitleArray) into linkTypeArray
   --
   put rowData ["title"] into sTitle
   display_Array linkTypeArray, sTitle, "LinkTypeArray"
end menu_DisplayLinkTypeArray

-- function lexon_GetLinkTypeArray rowData, dData
-- this is broken due to smaller phrases over-riding long ones
put rowData ["links"] into clauseArray
--
put lexon_GetTermTitleArray (dData) into termTitleData
-- display_Data termTitleData, "termTitleData"
put termTitleData ["termTitleDictionary"] into termTitleDictionary
--
put lexon_GetContractDefArray (dData) into contractDefArray
-- display_Data contractDefArray, "contractDefArray"
--
put lexon_GetClauseTitleArray (dData) into cTitleArray
-- display_Data cTitleArray, "lexon_GetClauseTitleArray"
--
repeat with itemNum = 1 to item 2 of the extents of clauseArray
   put clauseArray [itemNum] into phraseArray
   put phraseArray ["text"] into somePhrase
   lexon_StripPunctuation somePhrase
   switch
      case somePhrase is among the keys of contractDefArray
         put phraseArray into linkTypeArray ["def"][somePhrase]
         break
      case somePhrase is among the keys of termTitleDictionary
         put phraseArray into linkTypeArray ["term"][somePhrase]
         break
      case somePhrase is among the keys of cTitleArray
         put phraseArray into linkTypeArray ["clause"][somePhrase]
         break
      default
         put phraseArray into linkTypeArray ["unknown"][somePhrase]
   end switch
end repeat
return linkTypeArray
end lexon_GetLinkTypeArray

on menu_FetchTermData
   put lexon_FetchTermData ("HyQ8s2di_") into termData
   --
   display_Data termData, "Term Data", "Lexon"
end menu_FetchTermData

private on _
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

private on __
end __

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

private on ___
end ___

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

private on ____
end ____

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

private on _____
end _____

on menu_DisplayBrowser
   hackmd_Launch HackMdID
   -- display_Browser someURL, sRect
end menu_DisplayBrowser

on menu_HackMdCommandLine
   launch_HackmdHelp
end menu_HackMdCommandLine

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
   display_LexonDefinitions dData
end menu_DisplayDefinitions

on menu_DisplayContractLinkArray dView
   put the displayed_Data of dView into iData
   put lexon_GetContractLinkArray (iData) into cLinkArray
   --
   display_Data cLinkArray, "Clause LinkArray", "Lexon Contract"
end menu_DisplayContractLinkArray

on menu_RefreshDataView dView
   send "ResetView" to dView in 2 ticks
   send "RenderView" to dView in 4 ticks
end menu_RefreshDataView
