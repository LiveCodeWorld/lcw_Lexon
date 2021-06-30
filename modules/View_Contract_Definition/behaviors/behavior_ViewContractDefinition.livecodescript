script "behavior_ViewContractDefinition"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewContractDefinition
type: behavior
version: 0.1


--> DataView
-
setProp dvHilite [pHiliteColor] pBoolean
   if pBoolean then
      set the backgroundcolor of graphic "Background" of me to "light green"
   else
      set the backgroundcolor of graphic "Background" of me to pHiliteColor
   end if
end dvHilite


--> Working on
-
setprop clause_Colour [clauseText] defColour
   -- a slow ugly hack
   put _TextField() into textField
   put _GetDefColour() into defColour
   put _GetMissingColour() into missingColour
   put _GetClauseColour() into clauseColour
   put _GetTermColour() into termColour
   -- 
   if clauseText is empty then put the clause_Text of me into clauseText
   --
   put the contract_ClauseTitles of me into clauseTitles
   put the contract_DefTitles of me into defTitles
   put the contract_TermTitles of me into termTitles
   put lexon_GetClauseCapsArray (clauseText) into clauseArray
   --
   put item 2 of the extents of clauseArray into maxNumm
   repeat with itemNum = maxNumm down to 1
      put clauseArray [itemNum] into phraseArray
      put phraseArray ["sWordNum"] into sWordNum
      put phraseArray ["eWordNum"] into eWordNum
      --
      put phraseArray ["text"] into somePhrase
      lexon_StripPunctuation somePhrase
      --
      set the textstyle of word sWordNum to eWordNum of textField to "link"
      switch
         case somePhrase is among the lines of clauseTitles
            set the textcolor of word sWordNum to eWordNum of textField to clauseColour
            break
         case somePhrase is among the lines of termTitles
            set the textcolor of word sWordNum to eWordNum of textField to termColour
            break
         case somePhrase is among the lines of defTitles
            set the textcolor of word sWordNum to eWordNum of textField to defColour
            break
         default
            set the textcolor of word sWordNum to eWordNum of textField to missingColour
      end switch
   end repeat
   --
   return clauseArray
end clause_Colour

setprop clause_CapsColour [clauseText] capsColour
   put _TextField() into textField
   --
   if capsColour is not a color then return empty
   if clauseText is empty then put the clause_Text of me into clauseText
   --
   put lexon_GetClauseCapsArray (clauseText) into clauseArray
   --
   put item 2 of the extents of clauseArray into maxNumm
   repeat with itemNum = maxNumm down to 1
      put clauseArray [itemNum] into phraseArray
      put phraseArray ["sWordNum"] into sWordNum
      put phraseArray ["eWordNum"] into eWordNum
      put phraseArray ["text"] into somePhrase
      --
      -- set the textcolor of word sWordNum to eWordNum of textField to capsColour
      set the textstyle of word sWordNum to eWordNum of textField to "link"
   end repeat
   --
   return clauseArray
end clause_CapsColour

on FillInData pDataA, pRow
   put pDataA ["title"] into clauseTitle
   put pDataA ["text"] into utf8Clause
   --
   set the view_Text [clauseTitle] of me to utf8Clause
end FillInData

setprop view_Text [clauseTitle] utf8Clause
   lock screen
   put lexon_CleanClause (utf8Clause) into clauseText
   put _GetClauseColour() into capsColour
   put _GetDefColour() into defColour
   --
   set the text of _TextField() to clauseText
   set the clause_Colour [clauseText] of me to defColour
   _IndentLines clauseText
   _FormatClauseTitle clauseTitle
   --
   LayoutControl
   unlock screen
end view_Text

private function _GetMissingColour
   return "red"
end _GetMissingColour

private function _GetClauseColour
   return "blue"
end _GetClauseColour

private function _GetDefColour
   return "dark green"
end _GetDefColour

private function _GetTermColour
   return "brown"
end _GetTermColour

setprop text_Colour someColour
   set the textcolor of word 1 to -1 of _TextField() to someColour
end text_Colour

setprop text_Style styleList
   set the textstyle of word 1 to -1 of _TextField() to styleList
end text_Style

getprop clause_Text
   if the dvControl of me is empty then
      put the text of _TextField() into clauseText
   else
      put the dv_RowValue ["title"] of me into clauseTitle
      put the dv_RowValue ["text"] of me into utf8Clause
      --
      if clauseTitle is not empty then
         put word 1 to -1 of clauseTitle & CR before utf8Clause
      end if
      --
      put lexon_CleanClause (utf8Clause) into clauseText
   end if
   --
   set the itemdelimiter to ":"
   if item 1 of clauseText = "CLAUSE" then
      delete line 1 of clauseText
   end if
   --
   return clauseText
end clause_Text

setprop clause_Text [sColour] clauseText
   put the dvControl of me into dView
   if dView is empty then
      set the view_Text [sColour] of me to clauseText
   else
      set the dv_RowValue ["text"] of me to clauseText
      put the result into dData
      return dData
   end if
end clause_Text


--> Props
-
getprop clause_Structure
   put the clause_Text of the target into clauseText
   --
   put lexon_GetDefData (clauseText) into defData
   put the result into fLine
   put defData into sData ["def"]
   --
   put lexon_GetClauseCapsArray (clauseText) into clauseArray
   put clauseArray into sData ["caps"]
   --
   return sData
end clause_Structure

getprop clause_DefData
   put the clause_Text of the target into clauseText
   put lexon_GetDefData (clauseText) into defData
   return defData
end clause_DefData


--> Props | Colour
-
setprop clause_DefColour [capsColour] defColour   
   put _TextField() into textField
   put the clause_Text of me into clauseText
   put lexon_GetDefData (clauseText) into defData
   --
   lock screen
   --
   set the textstyle of word 1 to -1 of textField to "plain"
   --
   if defColour is a color then
      put item 2 of the extents of defData into maxNum
      repeat with itemNum = maxNum down to 1
         put defData [itemNum]["lineNum"] into lineNum
         put defData [itemNum]["text"] into defLine
         --
         lexon_SetDefWordOffsets defLine, clauseText, sWordNum, eWordNum
         put the result into fLine
         --
         if fLine = defLine then
            -- set the textcolor of word sWordNum to eWordNum of textField to defColour
            set the textcolor of word sWordNum of textField to defColour
         else
            throw "Error, defLine should match the phrase in utf8Clause"
         end if
      end repeat
   end if
   --
   if capsColour is a color then
      set the clause_Colour [clauseText] of textField to capsColour
   end if
   --
   unlock screen
end clause_DefColour

setprop phrase_DefColour [capsColour] defColour
   put _TextField() into textField
   put the clause_Text of me into clauseText
   put lexon_GetDefData (clauseText) into defData
   --
   lock screen
   --
   set the textstyle of word 1 to -1 of textField to "plain"
   --
   if defColour is a color then
      put item 2 of the extents of defData into maxNum
      repeat with itemNum = maxNum down to 1
         put defData [itemNum]["lineNum"] into lineNum
         put defData [itemNum]["text"] into defLine
         --
         lexon_SetDefWordOffsets defLine, clauseText, sWordNum, eWordNum
         put the result into fLine
         --
         if fLine = defLine then
            set the textcolor of word sWordNum to eWordNum of textField to defColour
         else
            throw "Error, defLine should match the phrase in utf8Clause"
         end if
      end repeat
   end if
   --
   if capsColour is a color then
      set the clause_CapsColour [clauseText] of textField to capsColour
   end if
   --
   unlock screen
end phrase_DefColour


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

setprop indent_Lines
   put the clause_Text of me into clauseText
   _IndentLines clauseText, 24
end indent_Lines


--> Private
-


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
   put _TextFieldID() into fldID
   --
   if pTitle is not empty then
      put pTitle & CR before line 1 of fld id fldID of me
      set the textStyle of line 1 of fld id fldID to "bold"
      set the spacebelow of line 1 of fld id fldID to 2
      set the textcolor of line 1 of fld id fldID to empty
   end if
end _FormatClauseTitle

private command _IndentLines clauseText, pIndentNum
   -- a bit ugly as if line wraps the wrapped part is not indented
   -- possibly use listIndent
   put _TextFieldID() into fldID
   --
   put 1 into indentNum
   repeat with lineNum = 1 to the number of lines of clauseText
      get char 1 of line lineNum of clauseText
      if _IsLower (it) then
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

private function _IsLower testChar
   --  if text_StartsWithCaps (testChar) then
   put charToNum (testChar) into sCharNum
   put sCharNum >= 97 AND sCharNum <= 122 into isLower
   return isLower
end _IsLower


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


