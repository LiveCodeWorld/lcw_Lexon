script "Global | Contract | Clause | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Contract | Clause | Menu
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

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

getprop test_Param [mTarget]
  return "b"
end test_Param

getprop test_Params [mTarget]
   return "a,b,c"
end test_Params

getprop checked_TestChecked
   return true
end checked_TestChecked

getprop disabled_Test
  return false -- true, "delete"
end disabled_Test

function _GetRandomClause
   put lexon_FetchDataViewArray ("HyQ8s2di_") into dData
   put any item "8,11,13,15,17" into itemNum
   --
   put dData [itemNum]["text"] into clauseText
   subtract 1 from itemNum
   put dData [itemNum]["text"] into clauseTitle
   --
   return clauseText
end _GetRandomClause


--> Global | Contract | Clause | Menu
-
on menu_ColourClause rowView
   set the colour_Me of rowView to "red"
end menu_ColourClause

on menu_ClearColour rowView
   set the text_Colour of rowView to ""
end menu_ClearColour

on _
end _
   
on menu_ResetTextLocal rowView
   put the clause_Text of rowView into someClause
   set the clause_Text of rowView to someClause
end menu_ResetTextLocal

on menu_DisplayWikiText rowView
   put the clause_Text of rowView into someClause
   --
   put lexon_ConstructWikiClause (someClause) into wikiClause
   --
   set the clause_Text of rowView to wikiClause
end menu_DisplayWikiText

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
