script "Global | Contract | Title | Dev | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Contract | Title | Dev | Dev | Menu
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


--> Global | Contract | Title | Dev | Dev | Menu
-

