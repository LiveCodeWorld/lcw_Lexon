script "behavior_ViewContentsLeft"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewContentsLeft
type: behavior
version: 0.1


private function _TitleBarHeight
   put the titleBar_Height of me into tBarHeight
   if tBarHeight is a number then
      return tBarHeight
   else
      return 50
   end if
end _TitleBarHeight
   
private function _BodyMargin
   put the body_Margin of me into bodyMargin
   if bodyMargin is a number then
      return bodyMargin
   else
      return 20
   end if
end _BodyMargin

private function _TitleRect leftRect
   put leftRect into titleBarRect
   put _TitleBarHeight() into tBarHeight
   --
   put item 2 of leftRect + tBarHeight into item 4 of titleBarRect
   return titleBarRect
end _TitleRect

function _IndexRect leftRect 
   put leftRect into indexRect
   put _BodyMargin() into bodyMargin
   
   put _titleRect (leftRect) into titleBarRect
   put item 4 of titleBarRect + bodyMargin into item 2 of indexRect
   return indexRect
end _IndexRect

on resizeControl
   LayoutControl
end resizeControl

command LayoutControl pLeftRect
   if pLeftRect is empty then put the rect of me into pLeftRect
   --
   put _titleRect (pLeftRect) into titleRect
   put _indexRect (pLeftRect) into indexRect
   --
   lock screen
   set the rect of _TitleField() to titleRect
   set the rect of _IndexField() to indexRect
   unlock screen
end LayoutControl

private function _TitleField
   return the long id of fld "Project Title" of me
end _TitleField

private function _IndexField
   return the long id of fld "Left Index" of me
end _IndexField
