script "Global | Lexon | Contract | Graph | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Lexon | Contract | Graph | Menu
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop graphContractClauses_Params
   return dot_ListGraphStyles()
end graphContractClauses_Params

getprop graphContract_Params
   return dot_ListGraphStyles()
end graphContract_Params


--> Global | Lexon | Contract | Graph | Menu
-
on menu_GraphContract rowView, graphStyle
   put the dvData of rowView into dData
   --
   put lexon_GetContractLinkArray (dData) into linkArray
   display_LinkArray linkArray, "All", "lexon_GetContractLinkArray()"
   --
   display_LexonContractGraph dData, "full_contract.dot", graphStyle
end menu_GraphContract

on menu_GraphContractClauses rowView, graphStyle
   put the dvData of rowView into dData
   --
   display_LexonContractGraph dData, "contract.dot", graphStyle, "def"
end menu_GraphContractClauses

on menu_GraphLinkedClauses rowView
   put the dvData of rowView into dData
   put lexon_GetContractLinkArray (dData, "def") into linkArray
   --
   put the project_AssetFolder of stack "lcw_Lexon" into projectAssetFolder
   put projectAssetFolder & "linked_clauses.dot" into dotFile
   --
   put true into concentrate
   put empty into defSection
   --
   display_LinkArrayGraph linkArray, "hierarchical", dotFile, "lightblue", "Linked Clauses", defSection, concentrate, "rectangle"
end menu_GraphLinkedClauses

private on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | Lexon | Contract | Graph | Menu")
end submenu_Dev
