script "Global | Lexon | Association | Create | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Lexon | Association | Create | Menu
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
   -- called once for each menu
   return the display_View of tObject
end menu_Target


--> Global | Lexon | Association | Create | Menu
-
on menu_DisplayWiredElements displayView
   put "http://lexon.wiki/assets/components/shoelace.html" into someURL
   put scaffold_GetTemplate ("Wired HTML") into tHTML
   --
   -- put "Hello World" & CR after someBody
   put "<wired-icon-button><mwc-icon>favorite</mwc-icon></wired-icon-button>" & CR after someBody
   put "<wired-icon-button class='red'><mwc-icon>favorite</mwc-icon></wired-icon-button>" & CR after someBody
   put "<wired-card elevation='5'><h1>wired-elements demo</h1></wired-card>" & CR after someBody
   put "<p><wired-button id='btn1'>Submit</wired-button></p>" & CR after someBody
   --
   replace "'" with quote in someBody
   --
   put merge (tHTML) into someHTML
   --
   display_Browser someURL
   put the result into displayView
   --
   --  put the behavior of displayView into bObject
   -- edit the script of bObject
   --
   set the browser_HtmlText of displayView to someHTML
   display_Text someHTML
end menu_DisplayWiredElements

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_SelectGroupControls displayView
   put displayView
end menu_SelectGroupControls


--> Deps
-
