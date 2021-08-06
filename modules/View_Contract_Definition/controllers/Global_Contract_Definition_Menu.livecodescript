script "Global | Contract | Definition | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Contract | Definition | Menu
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


--> Global | Contract | Definition | Menu
-
on menu_ColourDefinition rowView
   set the clause_Colour of rowView to "Purple"
end menu_ColourDefinition

on menu_GraphDeps rowView
   put the lexon_RowLinkArray of rowView into linkArray
   display_LinkArrayGraph linkArray
end menu_GraphDeps

on _
end _

getprop checked_ShowIcon [rowView]
   put the icon_isVisible of rowView into isShowing
   return isShowing
end checked_ShowIcon
   
on menu_ShowIcon rowView
   put the icon_isVisible of rowView into isShowing
   set the icon_isVisible of rowView to (isShowing is false)
end menu_ShowIcon

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditRowBehavior rowView
   put the behavior of rowView into bObject
   edit the script of bObject
end menu_EditRowBehavior


--> Deps
-
