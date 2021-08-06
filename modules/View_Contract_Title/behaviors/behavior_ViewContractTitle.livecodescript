script "behavior_ViewContractTitle"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewContractTitle
type: behavior
version: 0.1


--> Working on
-
-- getProp dvCanSelect
return false
end dvCanSelect

-- function CacheKeyForRow pRow
put the dvData of me into sDataA
return sDataA [pRow]["id"]
end CacheKeyForRow

private command _SetTitleLevel tLevel, textField
   switch tLevel
      case 1
         set the textsize of textField to 24
         set the visible of _ViewIcon() to true
         break
      case 2
         set the textsize of textField to 18
         set the visible of _ViewIcon() to false
         break
      default
         -- small and not used
         set the textsize of textField to 14
         set the visible of _ViewIcon() to false
   end switch
end _SetTitleLevel


--> Edit
-
on EditKey pKey
   -- Call CreateFieldEditorForField and pass in the field to edit in the row control.
   put _TextField() into pField
   CreateFieldEditorForField pField, pKey
end EditKey


--> Icon
-
getprop icon_isVisible
   put _ViewIcon() into vIcon
   return the visible of vIcon
end icon_isVisible

setprop icon_isVisible isVisible
   put _ViewIcon() into vIcon
   set the visible of vIcon to isVisible
end icon_isVisible


--> Geometry | Props
-
getprop row_LeftMargin
   put the dv_LeftMargin of me into leftM
   if leftM is empty then
      return 45
   else
      return leftM
   end if
end row_LeftMargin

getprop icon_Height
   return 18
end icon_Height

getprop icon_TopMargin
   return 15
end icon_TopMargin

getprop icon_LeftMargin
   return 12 
end icon_LeftMargin

getprop min_Height
   return 21
end min_Height

getprop view_Margin
   return 0,0,0,8
end view_Margin


--> Hilite
-
getprop row_TitleLevel
   -- put the dv_RowValue ["level"] of me into tLevel
   
   put the textsize of _TextField() into tSize
   switch tSize
      case 28
         return 1
      case 18
         return 2
      default
         return 3
   end switch
   return tLevel
end row_TitleLevel

setprop row_TitleLevel tLevel
   put _TextField() into textField
   --
   lock screen
   _SetTitleLevel tLevel, textField
   LayoutControl
   unlock screen
end row_TitleLevel

setProp dvHilite [pHiliteColor] pBoolean
   if pBoolean then
      set the backgroundcolor of graphic "Background" of me to "green"
   else
      set the backgroundcolor of graphic "Background" of me to pHiliteColor
   end if
end dvHilite


--> Events
-
on mouseDown
   put _ViewIcon() into vIcon
   put the short id of vIcon into vID
   --
   if the short id of the target = vID then
      set the highlight of vIcon to true
      menu_PullDown "Global | Contract | Title | Menu", "", vIcon
      set the highlight of vIcon to false
   else
      pass mouseDown
   end if
end mouseDown

on mouseLeave
   put _ViewIcon() into vIcon
   if the short id of the target = the short id of vIcon then
      set the highlight of vIcon to false
   else
      pass mouseLeave
   end if
end mouseLeave

on mouseUp
   put _ViewIcon() into vIcon
   if the short id of the target = the short id of vIcon then
      set the highlight of vIcon to false
   else
      pass mouseUp
   end if
end mouseUp

on resizeControl
   if the long id of the target = the long id of me then
      LayoutControl
   else
      pass resizeControl
   end if
end resizeControl


--> Props
-
getprop title_Text
   put the dv_RowValue ["text"] of me into titleText
   return titleText
end title_Text

setprop title_Text [pLevel] titleText
   if the dvControl of me is empty then
      lock screen
      _SetTitle titleText, pLevel
      LayoutControl
      unlock screen
   else
      set the dv_RowValue ["text"] of me to titleText
      put the result into dData
      return dData
   end if
end title_Text


--> Form
-
on FillInData pDataA, pRow
   --  put pDataA ["@style"] into sStyle -- = "title"
   put pDataA ["text"] into sTitle
   put pDataA ["level"] into tLevel
   _SetTitle sTitle, tLevel
   --
   put pDataA into LocalArray ["rowData"]
end FillInData

private command _SetTitle sTitle, tLevel
   put _TextField() into textField
   --
   put word 1 to -1 of sTitle into sTitle
   set the text of textField to sTitle
   --
   _SetTitleLevel tLevel, textField
end _SetTitle


--> Geometry
-
on LayoutControl pControlRect
   local tRect
   if pControlRect is empty then put the rect of me into pControlRect
   put the dv_IconsShowing of me is not false into iconsShowing
   --
   put pControlRect into innerRect
   put the view_Margin of me into viewMargin
   rect_SubtractMargins innerRect, viewMargin
   put item 4 of the result into bMargin
   --
   put _TextRect (innerRect, true) into fieldRect
   --
   put pControlRect into graphicRect
   put item 4 of fieldRect + bMargin into item 4 of graphicRect
   --
   put _IconRect (innerRect) into iconRect
   --
   put _ViewIcon() into vIcon
   -- set the visible of vIcon to iconsShowing
   set the rect of vIcon to iconRect
   set the rect of _GraphicObject() to graphicRect
   set the rect of _TextField() to fieldRect
   --
   set the rect of me to graphicRect
end LayoutControl


--> Private
-
private function _IconRect innerRect
   put the icon_Height of me into iconHeight
   put the icon_TopMargin of me into mTop
   put the icon_LeftMargin of me into mLeft
   --
   put item 1 of innerRect + iconHeight into item 3 of innerRect
   put item 2 of innerRect + iconHeight into item 4 of innerRect
   --
   add mLeft to item 1 of innerRect
   add mLeft to item 3 of innerRect
   
   add mTop to item 2 of innerRect
   add mTop to item 4 of innerRect
   --
   return innerRect
end _IconRect

private function _TextRect pControlRect, pUseFormatted
   put _TextField() into fieldObject
   --
   put the view_Margin of me into someMargin
   put the row_LeftMargin of me into labelFieldWidth
   put the min_Height of me into minHeight
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
   put max (minHeight,fHeight) into fHeight
   put fTop + fHeight into labelBottom
   --
   put labelBottom into item 4 of tRect
   --
   return tRect
end _TextRect


--> Objects | Private
-
private function _TextFieldID
   return the short id of field "Label" of me
end _TextFieldID

private function _TextField
   return the long id of field "Label" of me
end _TextField

private function _ViewIcon
   return the long id of widget 1 of me
end _ViewIcon

private function _GraphicObject
   return the long id of graphic "Background" of me
end _GraphicObject


--> Objects
-
getProp dvRowControl
   return the long id of me
end dvRowControl
