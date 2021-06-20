script "behavior_ViewContractClause"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: behavior_ViewContractClause
type: behavior
version: 0.1

--> Variables
-
local LocalArray


--> Events
-
on mouseDown
   put _ViewIcon() into vIcon
   put the short id of vIcon into vID
   if the short id of the target = vID then
      menu_PullDown "Global | Contract | Clause | Menu", "", vIcon
   end if
end mouseDown


--> DataView
-
setProp dvHilite [pHiliteColor] pBoolean
   if pBoolean then
      set the backgroundcolor of graphic "Background" of me to "orange"
   else
      set the backgroundcolor of graphic "Background" of me to pHiliteColor
   end if
end dvHilite


--> Geometry | Props
-
getprop _IconHeight
   return 21
end _IconHeight

getprop label_Width
   return 45
end label_Width

getprop view_Margin
   return 0,0,0,8
end view_Margin


--> Events
-
on resizeControl
   LayoutControl
end resizeControl


--> Props
-
setprop text_Colour someColour
   set the textcolor of word 1 to -1 of _TextField() to someColour
end text_Colour

setprop clause_Colour someColour
   put LocalArray ["someClause"] into someClause
   put lexon_GetClauseArray (someClause) into clauseArray
   --
   put item 2 of the extents of clauseArray into maxNumm
   repeat with itemNum = maxNumm down to 1
      put clauseArray [itemNum] into phraseArray
      put phraseArray ["sWordNum"] into sWordNum
      put phraseArray ["eWordNum"] into eWordNum
      put phraseArray ["text"] into somePhrase
      --
      set the textcolor of word sWordNum to eWordNum of _TextField() to someColour
      -- put somePhrase into word sWordNum to eWordNum of wikiClause
   end repeat
end clause_Colour

getprop clause_Text
   if the dvControl of me is empty then
      put LocalArray ["someClause"] into someClause
      -- put the text of _TextField() into someClause
   else
      put the row_Value ["text"] of me into someClause
   end if
   return someClause
end clause_Text

setprop clause_Text [sColour] someClause
   if the dvControl of me is empty then
      put someClause into LocalArray ["someClause"]
      --
      lock screen
      _SetClause someClause, sColour
      LayoutControl
      unlock screen
   else
      set the row_Value ["text"] of me to someClause
      put the result into dData
      return dData
   end if
end clause_Text


--> Form
-
on FillInData pDataA, pRow
   _SetClause pDataA ["text"]
end FillInData

private command _SetClause someClause, pColour
   lock screen
   set the text of _TextField() to word 1 to -1 of someClause
   set the clause_Colour of me to pColour
   unlock screen
end _SetClause


--> Geometry
-
on LayoutControl pControlRect
   local tRect
   if pControlRect is empty then put the rect of me into pControlRect
   --
   put pControlRect into innerRect
   put the view_Margin of me into viewMargin
   rect_SubtractMargins innerRect, viewMargin
   put item 4 of the result into bMargin
   --
   _SetTextRect innerRect
   put item 4 of the result + bMargin into item 4 of pControlRect
   --
   _SetGraphicRect pControlRect
   --
   put _IconRect (innerRect) into iconRect
   set the rect of _ViewIcon() to iconRect
   --
   set the rect of me to pControlRect
end LayoutControl

command _SetTextRect pControlRect   
   put _TextRect (pControlRect, true) into tRect
   set the rect of _TextField() to tRect
   return tRect
end _SetTextRect

command _SetGraphicRect pControlRect
   set the rect of _GraphicObject() to pControlRect
end _SetGraphicRect


--> Private
-
private function _IconRect innerRect
   put 12 into vMargin
   put the _IconHeight of me into iconHeight
   --
   put item 1 of innerRect + iconHeight into item 3 of innerRect
   put item 2 of innerRect + iconHeight into item 4 of innerRect
   --
   add vMargin to item 1 of innerRect
   add vMargin to item 2 of innerRect
   add vMargin to item 3 of innerRect
   add vMargin to item 4 of innerRect
   --
   return innerRect
end _IconRect

private function _TextRect pControlRect, pUseFormatted
   put _TextField() into fieldObject
   --
   put the view_Margin of me into someMargin
   put the label_Width of me into labelFieldWidth
   put the _IconHeight of me into labelFieldHeight
   --
   put pControlRect into tRect
   --
   put item 1 of tRect + labelFieldWidth into tLeft
   put tLeft into item 1 of tRect
   --
   put item 2 of tRect into fTop
   if pUseFormatted is true then
      put the formattedheight of fieldObject into fHeight
      -- add 4 to fHeight
   else
      put item 4 of tRect - fTop into fHeight
   end if
   --
   put max (labelFieldHeight,fHeight) into fHeight
   put fTop + fHeight into labelBottom
   --
   put labelBottom into item 4 of tRect
   --
   return tRect
end _TextRect


--> Objects
-
getProp dvRowControl
   return the long id of me
end dvRowControl


--> Objects | Private
-
private function _TextField
   return the long id of field "Label" of me
end _TextField

private function _ViewIcon
   return the long id of widget 1 of me
end _ViewIcon

private function _GraphicObject
   return the long id of graphic "Background" of me
end _GraphicObject
