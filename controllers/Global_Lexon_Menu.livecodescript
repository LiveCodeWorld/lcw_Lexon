script "Global | Lexon | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Lexon | Menu
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
   -- called once for each menu
   return the display_View of tObject
end menu_Target


--> Global | Lexon | Menu
-
on menu_DisplayLexonContract
   display_LexonContract
end menu_DisplayLexonContract

on menu_DisplayLexonTools
   display_LexonTools
end menu_DisplayLexonTools

on _
end _

on submenu_Display
   return "Display | Menu"
end submenu_Display

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_LexonDataViewArray
   put hackMD_FetchLexonData ("HyQ8s2di_") into dData
   --
   display_Data dData, hackmdID, "Lexon Contract"
end menu_LexonDataViewArray

on menu_LexonContractData
   put hackMD_FetchLexonContract ("HyQ8s2di_", false) into lexBody
   --
   display_LexonContract lexBody
end menu_LexonContractData
