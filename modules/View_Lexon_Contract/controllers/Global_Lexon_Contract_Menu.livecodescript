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

getprop menu_Target [dView]
   pass menu_Target
   
   put the dv_LinkedDataView of tObject into dView
   put dView into LocalArray ["dView"]
   return dView
end menu_Target

-- getprop menu_CheckTarget [dView]
return exists (dView)
end menu_CheckTarget


--> Global | Lexon | Contract | Menu
-
on menu_Test displayView
   --  set the dv_LinkedDataView of displayView to displayView
   put hackmd_FetchMarkdown ("THH_aKkQTeyakl6QO1cF8g")
end menu_Test

on menu_DataViewDisplay dView
   display_DataView dView, "click"
end menu_DataViewDisplay

on _
end _

-- getprop disabled_SetLinkedDataView [dView]
get the dvControl of dView
if exists (it) then
   return false
else
   return true
end if
end disabled_SetLinkedDataView

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

on submenu_Behaviors
   return "Global | DataView | Behaviors | Menu"
end submenu_Behaviors

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
