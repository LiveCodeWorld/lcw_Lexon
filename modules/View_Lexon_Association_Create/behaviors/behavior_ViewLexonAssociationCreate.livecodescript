script "behavior_ViewLexonAssociationCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewLexonAssociationCreate
type: behavior
version: 0.1


--> Props
-
getprop form_Data
   put the long id of group "Form Fields" of me into fieldGroup
   put the number of groups of fieldGroup into gMax
   --
   repeat with gNum = 1 to gMax
      put the short name of group gnum of fieldGroup into gName
      put the field_Data of group gnum of fieldGroup into gData
      put gData into formData [gName]
   end repeat
   return formData
end form_Data

getprop field_Data
   switch
      case word 1 of the target = "group"
         put the long id of the target into formControl
         break
      default
         if the owner of the target = "group" then
            put the long id of the owner of the target into formControl
         else
            return empty
         end if
   end switch
   if exists (fld 1 of formControl) is false then return empty
   --
   put the short id of fld 1 of formControl into fldID
   put the text of fld id fldID into someText
   return someText
end field_Data
