script "Global | Lexon | Menu"
--> MetaData
-
copyright: Anonymous
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
on menu_TestLexonContract
   put "HyQ8s2di_" into hackmdID
   
   put lexon_FetchContract (hackmdID, false) into lexBody
   put lexon_FetchContractData (lexBody) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   --
   display_Data dData, hackmdID, "Lexon Contract"
end menu_TestLexonContract

on menu_DisplayContractData
   -- put url "https://hackmd.io/@lexon/HyQ8s2di_/download" into lexText
   put lexon_FetchContract ("HyQ8s2di_", false) into lexBody
   --
   display_LexonContract lexBody
end menu_DisplayContractData

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
