script "behavior_ViewRecordFolder"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: behavior_ViewRecordFolder
type: behavior
version: 0.1

/*
Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.
*/


--> Work in Progress
-
local LocalArray

getprop field_Data
   put the text of _FieldObject() into someFolder
   return someFolder
end field_Data

setprop field_Data someFolder
   put _FieldObject() into fldObject
   set the text of fldObject to someFolder
   return fldObject
end field_Data


--> Events
-
on mouseUp
   answer folder "Where is the folder?"
   set the text of _fieldObject() to it
end mouseUp

on resizeControl
   LayoutControl
end resizeControl


--> Geometry
-
on LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   
   -- rect_CreateMask pRect, "Outer"
   
   put the margins of me into myMargins
   rect_SubtractMargins pRect, myMargins
   
   -- rect_CreateMask pRect, "Inner"
   
   put _fieldObject() into fieldObject
   
   put pRect into fieldRect
   put the effective textHeight of me into myTextHeight 
   add myTextHeight to item 2 of fieldRect
   
   put the effective textHeight of fieldObject into fieldHeight
   put the margins of fieldObject into fMargins
   margin_Normalize fMargins, leftM, topM, rightM, bottomM
   add topM to fieldHeight
   -- add bottomM to fieldHeight
   
   add leftM to item 1 of fieldRect
   subtract rightM from item 3 of fieldRect
   
   -- hack
   add -2 to item 1 of fieldRect
   add 2 to item 3 of fieldRect
   
   put item 2 of fieldRect + fieldHeight into item 4 of fieldRect
   
   set the rect of fieldObject to fieldRect
end LayoutControl


--> Objects
-
function _fieldObject
   return the long id of fld 1 of me
end _fieldObject


