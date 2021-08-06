script "behavior_ViewTitleSegmented"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTitleSegmented
type: behavior
version: 0.1


--> Geometry
-
on LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   put _SegmentedControl() into sControl
   put _TitleField() into titleField
   --
   put the inner_Rect [pRect] of me into innerRect
   put _SegmentedRect (innerRect, sControl) into segRect
   --
   -- put _SegmentedTopRight (innerRect) into sTopRight
   -- set the topright of sControl to sTopRight
   -- 
   set the rect of sControl to segRect
   set the rect of titleField to innerRect
end LayoutControl

private function _SegmentedRect innerRect, sControl
   put 10 into someMargin
   --
   put item 4 of innerRect - item 2 of innerRect into innerHeight
   put innerHeight - 2 * someMargin into iconHeight
   get the itemNames of sControl
   put the number of items of it into itemNum
   put round (itemNum * 2 * iconHeight) into  segWidth
   --
   put innerRect into segRect
   add someMargin to item 2 of segRect
   subtract someMargin from item 4 of segRect
   --
   put item 3 of segRect into iconRight
   subtract someMargin from iconRight
   put iconRight into item 3 of segRect
   --
   put iconRight - segWidth into item 1 of segRect
   return segRect
end _SegmentedRect

private function _SegmentedTopRight innerRect
   put item 2 of innerRect into iTop
   put item 3 of innerRect into iRight
   return iRight,iTop
end _SegmentedTopRight


--> Events
-
on resizeControl
   LayoutControl the rect of me
end resizeControl


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop title_View
   return the long id of me
end title_View

private function _SegmentedControl
   return the long id of widget 1 of me
end _SegmentedControl

private function _TitleField
   return the long id of fld 1 of me
end _TitleField

