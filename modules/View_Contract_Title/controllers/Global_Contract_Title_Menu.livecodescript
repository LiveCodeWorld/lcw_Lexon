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

getprop displayType_Params [rowView]
   put the dvData of rowView into dData
   put lexon_ListDefTypes (dData) into defTypes
   return defTypes
end displayType_Params


--> Global | Contract | Title | Menu
-
on submenu_GraphContract
   return "Global | Lexon | Contract | Graph | Menu"
end submenu_GraphContract

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

private on __
end __

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

private on ___
end ___

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

private on ____
end ____

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

private on _____
end _____

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

private on ______
end ______

on menu_DisplaySection rowView
   put the lexon_SectionData of rowView into newData
   --
   display_LexonData newData
end menu_DisplaySection

on submenu_Lexon
   return "Global | Lexon | Contract | Menu"
end submenu_Lexon

on submenu_Dev
   return menu_DevTitle ("Global | Contract | Title | Menu")
end submenu_Dev
