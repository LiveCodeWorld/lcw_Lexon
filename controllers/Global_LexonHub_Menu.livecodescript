script "Global | LexonHub | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | LexonHub | Menu
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
   if exists (tObject) is false then return empty
   put the displayed_Object of tObject into stackObject
   return stackObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | LexonHub | Menu
-
on menu_OpenHub
   go to stack "Lexon Hub"
end menu_OpenHub

on menu_FetchContract stackObject
   put "HyQ8s2di_" into hackmdID
   put lexon_FetchContract (hackmdID, false) into lexBody
   -- put textDecode (lexBody, "utf8") into lexBody
   put lexon_ConstructTermIndexData (lexBody) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   --
   put the contract_Field of stackObject into contractField
   put the contract_View of stackObject into contractView
   --
   put textDecode (lexBody, "utf8") into lexBody
   set the text of contractField to lexBody
   set the dvData of contractView to dData
end menu_FetchContract

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
on menu_OpenContractViewer
   go to stack "Lexon Contract Viewer"
end menu_OpenContractViewer

