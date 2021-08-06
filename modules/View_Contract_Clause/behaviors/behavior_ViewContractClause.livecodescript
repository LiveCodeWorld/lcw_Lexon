script "behavior_ViewContractClause"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewContractClause
type: behavior
version: 0.1

--> Variables
-
local LocalArray


--> Working on
-
getprop clause_Title [pStripClause]
   put the dvData of me into dData
   put the dvRow of me into rowNum
   put lexon_GetRowTitle (rowNum, dData) into clauseTitle
   if pStripClause is true then
      
   end if
   return clauseTitle
end clause_Title

getprop clause_Data [pClauseText]
   if exists (the dvControl of me) then
      put the dv_RowData of me into rowData
      put rowData ["clauseData"] into clauseData
   else
      put _ConstructClauseData (pClauseText, defLineData) into clauseData
   end if
   return clauseData
end clause_Data

private function _ConstructClauseData utf8Clause
   put empty into defLineData
   put the contract_TitleArray of me into titleArray
   put lexon_ConstructRowClauseData (utf8Clause, titleArray, defLineData) into clauseData
   return clauseData
end _ConstructClauseData

on keyDown theKey
   if theKey = "." then
      put _GetNewClause (theKey) into newClause
      put _ConstructRowData (newClause) into rowData
      --
      FillInData rowData
   else
      LayoutControl
   end if
   pass keyDown
end keyDown

private function _ConstructRowData newClause
   clause_Deconstruct newClause, clauseTitle
   --
   put _ConstructClauseData (newClause) into newClauseData
   -- put _ConstructDefData (newClause) into newDefData
   --
   put clauseTitle into rowData ["title"]
   put newClause into rowData ["text"]
   --
   put newClauseData into rowData ["clauseData"]
   -- put newDefData into rowData ["defData"]
   --
   return rowData
end _ConstructRowData


--> Colours
-
private function _GetMissingColour
   return "red"
end _GetMissingColour

private function _GetClauseColour
   return "orange"
end _GetClauseColour

private function _GetDefWordColour
   return "dark green"
end _GetDefWordColour

private function _GetDefLineColour
   return "purple"
end _GetDefLineColour

private function _GetTermColour
   return "blue"
end _GetTermColour


--> DataView
-
on FillInData rowData, pRow
   -- assumes rowData already formed with clauseData indexed
   -- defData not required at this stage
   
   lock screen
   put rowData ["title"] into clauseTitle
   put rowData ["text"] into utf8Clause
   put rowData ["clauseData"] into clauseData
   --
   set the clause_Data [utf8Clause] of me to clauseData
   _IndentLines utf8Clause
   _FormatClauseTitle clauseTitle
   set the lock_Text of me to true
   --
   LayoutControl
   unlock screen
end FillInData

private command _IndentLines clauseText, pIndentNum
   put _TextFieldID() into fldID
   --
   put 1 into indentNum
   repeat with lineNum = 2 to the number of lines of clauseText
      get char 1 of token 1 of line lineNum of clauseText
      if text_IsUpper (it) is false then
         -- set the firstIndent of line lineNum of fld id fldID to empty
         set the liststyle of line lineNum of fld id fldID to "skip"
         set the listIndent of line lineNum of fld id fldID to 18
         if indentNum = 1 then
            set the spaceabove of line lineNum of fld id fldID to 2
         end if
         add 1 to indentNum
      end if
   end repeat
end _IndentLines


--> Events | Keydown
-
on returnInField
   put _TextFieldID()  into fldID
   put word 2 of the selectedchunk into cNum
   put the text of field id fldID of me into newClause
   put CR before char cNum of newClause
   --
   set the text of field id fldID of me to newClause
   LayoutControl
   select after char cNum of field id fldID of me
end returnInField

private function _GetNewClause theKey
   put word 2 of the selectedchunk into cNum
   put the text of _TextField() into someClause
   put theKey before char cNum of someClause
   return someClause
end _GetNewClause

setprop clause_Data [pClauseText] clauseData
   lock screen
   --
   put _TextField() into textField
   put _GetDefWordColour() into defWordColour
   put _GetDefLineColour() into defLineColour
   put _GetMissingColour() into missingColour
   put _GetClauseColour() into clauseColour
   put _GetTermColour() into termColour
   --
   if pClauseText is not empty then
      set the plain_Text of me to pClauseText
   else
      -- set the plain_Text of me to clauseData ["text"]
   end if
   
   put item 2 of the extents of clauseData into maxNum
   repeat with itemNum = maxNum down to 1 -- go backwards just in case
      put clauseData [itemNum] into phraseArray
      put phraseArray ["sCharNum"] into sCharNum
      put phraseArray ["eCharNum"] into eCharNum
      put phraseArray ["text"] into somePhrase
      put phraseArray ["linkType"] into linkType
      --  lexon_StripPunctuation somePhrase
      --
      set the textstyle of char sCharNum to eCharNum of textField to "link"
      switch linkType
         case "clause"
            set the textcolor of char sCharNum to eCharNum of textField to clauseColour
            break
         case "term"
            set the textcolor of char sCharNum to eCharNum of textField to termColour
            break
         case "def"
            -- definition terms linking to definition sections
            set the textcolor of char sCharNum to eCharNum of textField to defWordColour
            break
         case "unknown"
            set the textcolor of char sCharNum to eCharNum of textField to missingColour
            break
         default
            -- def line
            -- definition sections
            set the textcolor of char sCharNum to eCharNum of textField to defLineColour
      end switch
   end repeat
   unlock screen
end clause_Data


--> Props
-
setprop clause_Text [clauseTitle] clauseText
   put the dv_RowData of me into rowData
   FillInData rowData
end clause_Text

getprop clause_DefData
   put the dv_RowValue ["text"] of me into clauseText
   --
   put lexon_GetDefLineData (clauseText) into defData
   return defData
end clause_DefData

setprop indent_Lines
   -- put the plain_Text of me into clauseText
   put the dv_RowValue ["text"] of me into clauseText
   --
   _IndentLines clauseText, 24
end indent_Lines

getprop plain_Text clauseText
   put the text of _TextField() into clauseText
   return clauseText
end plain_Text

setprop plain_Text clauseText
   lock screen
   set the text of _TextField() to clauseText
   LayoutControl
   unlock screen
end plain_Text

getprop lock_Text
   return the locktext of _TextField() is true
end lock_Text

setprop lock_Text sBoolean
   put _TextField() into textField
   --
   set the locktext of textField to sBoolean is true
   set the autohilite of textField to sBoolean is false
end lock_Text

on EditKey pKey
   -- Call CreateFieldEditorForField and pass in the field to edit in the row control.
   put _TextField() into textField
   CreateFieldEditorForField textField, pKey
end EditKey

on CloseFieldEditor tempField, rowNum, pKey, whichMessage
   put the dvData of me into dData
   put dData [rowNum] into rowData
   --
   put the text of tempField into newClause
   put clause_GetDataFromText (newClause, rowData) into rowData
   --
   -- set the dvData of me to dData
   set the dvRowData [rowNum] of me to rowData
   --
   put rowData ["id"] into pId
   RefreshRowOfId pId
end CloseFieldEditor


--> DataView
-
setProp dvHilite [pHiliteColor] pBoolean
   if pBoolean then
      set the backgroundcolor of graphic "Background" of me to "yellow"
   else
      set the backgroundcolor of graphic "Background" of me to pHiliteColor
   end if
end dvHilite


--> Icon
-
getprop icon_Type
   get the iconPresetName of _ViewIcon() 
   --
   switch it
      case "trello"
         return "clause"
      case "magic"
      case "trophy"
         return "recital"
      case "th list"
         return "definitions"
      case "bug"
         return "bug"
      default
         return it
   end switch
end icon_Type

setprop icon_Type iconType
   put _ViewIcon() into iView
   switch iconType
      case "clause"
         set the iconPresetName of iView to "trello"
         break
      case "recital"
         set the iconPresetName of iView to "magic"
         break
      case "definitions"
         set the iconPresetName of iView to "th list"
         break
      case "bug"
         set the iconPresetName of iView to "bug"
         break
      default
         set the iconPresetName of iView to "trello"
   end switch
   return the iconPresetName of iView
end icon_Type

getprop icon_Types
   put the behavior of me into bObject
   get the hkey_CaseConditions ["S icon_Type"] of bObject
   return it
end icon_Types

getprop icon_isVisible
   put _ViewIcon() into vIcon
   return the visible of vIcon
end icon_isVisible

setprop icon_isVisible isVisible
   put _ViewIcon() into vIcon
   set the visible of vIcon to isVisible
end icon_isVisible

setprop text_Colour someColour
   set the textcolor of word 1 to -1 of _TextField() to someColour
end text_Colour

setprop text_Style styleList
   set the textstyle of word 1 to -1 of _TextField() to styleList
end text_Style


--> Props
-
getprop clause_Titles
   put the dv_RowData of me into clauseData
   --
   put clause_ListUniqueTitles (clauseData) into uniqueTitles
   return uniqueTitles
end clause_Titles

getprop wiki_Text
   put the dv_RowValue ["title"] of me into pClauseTitle
   put the dv_RowValue ["text"] of me into utf8Clause
   --
   put lexon_GetWikiClause (utf8Clause, pClauseTitle) into wikiClause
   --
   return wikiClause
end wiki_Text


--> Events
-
on mouseDown
   put _ViewIcon() into vIcon
   put the short id of vIcon into vID
   if the short id of the target = vID then
      set the highlight of vIcon to true
      --
      menu_PullDown "Global | Contract | Clause | Menu", "", vIcon
      -- set the highlight of vIcon to false
   else
      pass mouseDown
   end if
end mouseDown

on mouseLeave
   set the highlight of _ViewIcon() to false
   pass mouseLeave
end mouseLeave

on mouseUp
   set the highlight of _ViewIcon() to false
   pass mouseUp
end mouseUp

on resizeControl
   LayoutControl
end resizeControl


--> Private
-
private command _FormatClauseTitle pTitle
   switch pTitle
      case empty
      case "_Untitled"
         break
      default
         put _TextFieldID() into fldID
         put pTitle & CR before line 1 of fld id fldID of me
         set the textStyle of line 1 of fld id fldID to "plain,bold"
         set the spacebelow of line 1 of fld id fldID to 2
         set the textcolor of line 1 of fld id fldID to empty
   end switch
end _FormatClauseTitle


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
   return 16
end icon_Height

getprop view_Margin
   return 0,0,0,8
end view_Margin


--> Geometry
-
getprop formatted_Rect
   put the rect of me into myRect
   _SetInnerRect myRect, innerRect, bMargin
   --
   put _TextRect (innerRect, true) into fRect
   put item 4 of fRect + bMargin into item 4 of fRect
   --
   return fRect
end formatted_Rect

private command _SetInnerRect pControlRect, @innerRect, @bMargin
   put pControlRect into innerRect
   put the view_Margin of me into viewMargin
   rect_SubtractMargins innerRect, viewMargin
   put item 4 of the result into bMargin
end _SetInnerRect

on LayoutControl pControlRect
   get the name of me
   if pControlRect is empty then put the rect of me into pControlRect
   put the dv_IconsShowing of me is not false into iconsShowing
   --
   _SetInnerRect pControlRect, innerRect, bMargin
   /*
   put pControlRect into innerRect
   put the view_Margin of me into viewMargin
   rect_SubtractMargins innerRect, viewMargin
   put item 4 of the result into bMargin
   */
   --
   put _TextRect (innerRect, true) into fieldRect
   --
   put pControlRect into graphicRect
   put item 4 of fieldRect + bMargin into item 4 of graphicRect
   --
   put _IconRect (innerRect) into iconRect
   --
   put _ViewIcon() into vIcon
   lock screen
   set the visible of vIcon to iconsShowing
   set the rect of vIcon to iconRect
   set the rect of _GraphicObject() to graphicRect
   set the rect of _TextField() to fieldRect
   --
   set the rect of me to graphicRect
   unlock screen
end LayoutControl


--> Private
-
private function _IconRect innerRect
   put 12 into vMargin
   put the icon_Height of me into iconHeight
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

private function _TextRect innerRect, pUseFormatted
   put _TextField() into fieldObject
   --
   put the view_Margin of me into someMargin
   put the row_LeftMargin of me into labelFieldWidth
   put the icon_Height of me into labelFieldHeight
   --
   put innerRect into tRect
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
getprop icon_View
   return _ViewIcon()
end icon_View

getProp dvRowControl
   return the long id of me
end dvRowControl


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
