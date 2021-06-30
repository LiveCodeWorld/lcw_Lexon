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


--> Global | Contract | Title | Menu
-
on menu_DisplaySection rowView
   put the dv_SectionItems of rowView into rowNums
   --
   put the dvControl of rowView into dView
   put the dvData of dView into dData
   put 1 into itemNum
   repeat for each item rowNum in rowNums
      put dData [rowNum] into newData [itemNum]
      add 1 to itemNum
   end repeat
   --
   display_LexonData newData
end menu_DisplaySection

on menu_ExportWikiText rowView
   put the dv_SectionItems of rowView into rowNums
   put the lexon_WikiText [rowNums] of rowView
end menu_ExportWikiText

on _
end _

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

on _
end _

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
