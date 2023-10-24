script "Global | Contract | Title | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Contract | Title | Dev | Menu
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


--> Global | Contract | Title | Dev | Menu
-
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

on menu_Refresh rowView
   put the dvControl of rowView into dView
   --
   send "ResetView" to dView in 2 ticks
   send "RenderView" to dView in 4 ticks
end menu_Refresh

private on _
end _

on menu_ExportWikiText rowView
   put the dv_SectionItems of rowView into rowNums
   put the lexon_WikiText [rowNums] of rowView
end menu_ExportWikiText

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

private on __
end __

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

private on ___
end ___

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
