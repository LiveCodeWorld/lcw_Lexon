script "Global | Contract | Title | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Contract | Title | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the dvRowControl of tObject into rowView
   return rowView
end menu_Target

getprop level_Param [rowView]
   put the row_TitleLevel of rowView into sLevel
   return sLevel
end level_Param

getprop level_Params [rowView]
   return "1,2,3"
end level_Params

getprop checked_TestChecked
   return true
end checked_TestChecked

getprop disabled_Test
   return false -- true, "delete"
end disabled_Test

getprop graphContractClauses_Params
   return dot_ListGraphStyles()
end graphContractClauses_Params

getprop graphContract_Params
   return dot_ListGraphStyles()
end graphContract_Params


--> Global | Contract | Title | Menu
-
on menu_GraphContract rowView, graphStyle
   put the dvData of rowView into dData
   --
   put lexon_GetContractLinkArray (dData) into linkArray
   display_LinkArray linkArray, "All", "lexon_GetContractLinkArray()"
   --
   display_LexonContractGraph dData, "full_contract.dot", graphStyle
end menu_GraphContract

on menu_GraphContractClauses rowView, graphStyle
   put the dvData of rowView into dData
   --
   display_LexonContractGraph dData, "contract.dot", graphStyle, "def"
end menu_GraphContractClauses

on menu_GraphLinkedClauses rowView
   put the dvData of rowView into dData
   put lexon_GetContractLinkArray (dData, "def") into linkArray
   --
   put the project_AssetFolder of stack "lcw_Lexon" into projectAssetFolder
   put projectAssetFolder & "linked_clauses.dot" into dotFile
   --
   put true into concentrate
   put empty into defSection
   --
   display_LinkArrayGraph linkArray, "hierarchical", dotFile, "lightblue", "Linked Clauses", defSection, concentrate, "rectangle"
end menu_GraphLinkedClauses

on _
end _

on menu_RevealAssetFolder rowView
   put the project_AssetFolder of stack "lcw_Lexon" into projectAssetFolder
   --
   finder_Reveal projectAssetFolder
end menu_RevealAssetFolder

on menu_DisplayContractLinkArray rowView
   put the dvData of rowView into dData
   put lexon_GetContractLinkArray (dData, "def") into linkArray
   --
   display_Data linkArray, "Not Defs", "lexon_GetContractLinkArray()"
end menu_DisplayContractLinkArray

on _
end _

on menu_SplitContract rowView
   local newClauseData, defData
   --
   put the dvData of rowView into dData
   put the contract_TitleArray of rowView into titleArray
   --
   lexon_CleanAndSplitData dData, newClauseData, defData, titleArray
   --
   display_LexonData newClauseData, "Clean Contract"
   --
   lexon_InsertTitleAtTop defData, "DEFINITIONS.", 1
   display_LexonData defData, "Split Definitions", true
end menu_SplitContract

on menu_CleanContract rowView
   put the dvData of rowView into dData
   --
   put lexon_CleanData (dData) into eData
   --
   display_LexonData eData, "Clean Contract"
end menu_CleanContract

on menu_CleanSection rowView
   put the lexon_SectionData of rowView into sData
   --
   put lexon_CleanData (sData) into eData
   --
   display_LexonData eData, "Clean Section"
end menu_CleanSection

on _
end _

on menu_DisplayDefinitions rowView
   put the dvData of rowView into dData
   --
   display_LexonDefinitions dData
end menu_DisplayDefinitions

on menu_SortDefinitions rowView
   put the dvData of rowView into dData
   --
   put lexon_SortDefinitionsByType (dData) into sData
   lexon_InsertTitleAtTop sData, "DEFINITIONS.", 1
   --
   display_LexonData sData, "Sorted Definitions"
   put the result into contractView
   set the dv_IconsShowing of contractView to true
end menu_SortDefinitions

getprop displayType_Params [rowView]
   put the dvData of rowView into dData
   put lexon_ListDefTypes (dData) into defTypes
   return defTypes
end displayType_Params

on menu_DisplayType rowView, defType
   put the dvData of rowView into dData
   --
   put lexon_GetDefTypeData (dData, defType) into fData
   put "DEFINITIONS of" && defType & ". "into sTilte
   lexon_InsertTitleAtTop fData, sTilte, 1
   --
   display_LexonData fData, sTilte
   put the result into contractView
   set the dv_IconsShowing of contractView to true
end menu_DisplayType

on _
end _

on menu_CreateWiki rowView
   put the dvControl of rowView into dView
   put the dvData of dView into dData
   put item 2 of the extents of dData into maxRowNum
   --
   repeat with rowNum = 1 to maxRowNum  
      set the cursor to busy    
      put the dvControlOfRow [rowNum] of dView into rowView
      if exists (rowView) is false then next repeat -- not cached or created yet
      --
      lexon_CreateWikiPageFromRow rowView
   end repeat
end menu_CreateWiki

on _
end _

on menu_DetectIcons rowView
   put the dvControl of rowView into dView
   put the dvData of dView into dData
   put item 2 of the extents of dData into maxRowNum
   --
   repeat with rowNum = 1 to maxRowNum  
      set the cursor to busy    
      put the dvControlOfRow [rowNum] of dView into rowView
      if exists (rowView) is false then
         -- not cached or created yet
         next repeat
      end if
      --
      switch the dv_RowStyle of rowView
         case "definition"
            put the icon_DetectType of rowView into iconType
            set the icon_Type of rowView to iconType
            break
         case "title"
         default
            next repeat
      end switch 
   end repeat
end menu_DetectIcons

on _
end _

on menu_DisplaySection rowView
   put the lexon_SectionData of rowView into newData
   --
   display_LexonData newData
end menu_DisplaySection

on _
end _

on menu_ReIndex rowView
   put the dvControl of rowView into dView
   put the dvData of dView into dData
   --
   lexon_AddDefAndClauseData dData
   --
   set the dvData of dView to dData
   -- display_Data dData, "dData"
   send "ResetView" to dView in 2 ticks
   send "RenderView" to dView in 4 ticks
end menu_ReIndex

on menu_ExportWikiText rowView
   put the dv_SectionItems of rowView into rowNums
   put the lexon_WikiText [rowNums] of rowView
end menu_ExportWikiText

on _
end _

on submenu_Lexon
   return "Global | Lexon | Contract | Menu"
end submenu_Lexon

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Refresh rowView
   put the dvControl of rowView into dView
   --
   send "ResetView" to dView in 2 ticks
   send "RenderView" to dView in 4 ticks
end menu_Refresh

on _
end _

on menu_RowBehavior rowView
   put the behavior of rowView into bObject
   edit the script of bObject
end menu_RowBehavior

on menu_DataViewBehavior rowView
   put the dvControl of rowView into dView
   --
   put the behavior of dView into bObject
   edit the script of bObject
end menu_DataViewBehavior

on menu_DisplayData rowView
   put the dvData of rowView into dData
   --
   display_Data dData, "the dvData"
end menu_DisplayData

on _
end _

on menu_TestGraph rowView
   put the dvControl of rowView into dView
   put the svg_View of dView into svgView
   --
   put the handler_Key ["M menu_ImportContract"] of me into hkey
   --
   graph_Hkey hkey, "fast undirected spring"
   put the result into svgFile
   --
   set the svg_File [true] of svgView to svgFile
end menu_TestGraph

on menu_GraphBehavior rowView
   put the dvControl of rowView into dView
   --
   put the svg_View of dView into svgView
   --
   put the behavior of svgView into bObject
   edit the script of bObject
end menu_GraphBehavior

on _
end _

on menu_HiliteSection rowView
   put the dv_SectionItems of rowView into hLits
   set the dvHilitedRows of rowView to hLits
end menu_HiliteSection

on menu_Level rowView, sLevel
   set the row_TitleLevel of rowView to sLevel
end menu_Level

on menu_ImportContract rowView
   put the dvControl of rowView into dView
   --
   put lexon_FetchDataViewArray ("HyQ8s2di_") into dData
   set the dvData of dView to dData
end menu_ImportContract

on menu_Clear rowView
   put the dvControl of rowView into dView
   --
   send dv_ClearData to dView in 2 ticks
end menu_Clear

