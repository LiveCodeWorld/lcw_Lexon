script "behavior_ViewLexonContract" with behavior "DataView Array Controller Behavior"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewLexonContract
type: behavior
version: 0.1

--> Variables
-
local LocalArray

function CacheKeyForRow pRow
   put the dvData of me into sDataA
   return sDataA [pRow]["id"]
end CacheKeyForRow


--> Working on
-
on linkClicked somePhrase
   lexon_StripPunctuation somePhrase
   put the contract_ClauseTitles of me into clauseTitles
   put the contract_DefTitles of me into defTitles
   put the dv_RowValue ["@style"] of the target into rowStyle
   --
   switch
      case somePhrase is among the lines of clauseTitles
         set the selected_Clause of me to somePhrase
         break
      case somePhrase is among the lines of defTitles
         set the selected_Def of me to somePhrase
         break
      default
         put somePhrase
   end switch
end linkClicked

setprop selected_Def somePhrase
   put the displayed_Data of me into dData
   put lexon_GetContractDefArray (dData) into defData
   --
   put defData [somePhrase] into defArray
   put defArray [1]["dData rowNum"] into rowNum
   set the dvHilitedRows of me to rowNum
   --
   put somePhrase && rowNum
   display_Data defArray, somePhrase, "Lexon Definition"
end selected_Def

setprop selected_Clause clauseTitle
   put the displayed_Data of me into dData
   put lexon_GetContractLinkArray (dData) into cLinkArray
   --
   put cLinkArray ["meta"][clauseTitle]["itemNum"] into rowNum
   --
   if rowNum is not empty then
      set the dvHilitedRows of me to rowNum
      return cLinkArray
   else
      put clauseTitle
      return empty
   end if
end selected_Clause


--> Props
-
getprop auto_Scroll
   put the viewprop ["scroll selections into view"] of me into someBoolean
   return someBoolean
end auto_Scroll

setprop auto_Scroll someBoolean
   set the viewprop ["scroll selections into view"] of me to someBoolean
end auto_Scroll


--> Clause
-
getprop clause_SectionTitle
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then return empty
   --
   put the row_DataAbove of rowView into sectionTitleArray
   put sectionTitleArray ["@style"] into rowTitleAboveStyle
   put sectionTitleArray ["text"] into rowTitleAbove
   --
   return rowTitleAbove
end clause_SectionTitle

getprop clause_TermTitle
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then return empty
   --
   put the row_DataAbove [1] of rowView into termTitleArray
   put sectionTitleArray ["@style"] into termTitleAboveStyle
   put termTitleArray ["text"] into termTitleAbove
   --
   return termTitleAbove
end clause_TermTitle

getprop row_DataAbove [pLevel]
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then return empty
   --
   put the dvRow of rowView into rowNum
   if rowNum is empty then return empty
   
   put the dvData of me into dData
   --
   put dData [rowNum] into startRowData
   if pLevel is empty then
      get startRowData ["level"]
      if it is empty then
         put 2 into levelAbove -- hack
      else
         put it - 1 into levelAbove
      end if
   else
      put pLevel into levelAbove
   end if
   --
   put rowNum - 1 into startRowNum
   repeat with itemNum = startRowNum down to 1
      put dData [itemNum] into rowData
      put rowData ["level"] into sLevel
      --
      if sLevel is empty then put 3 into sLevel -- hack
      --
      if sLevel <= levelAbove then
         return rowData
      end if
   end repeat
   return empty
end row_DataAbove

getprop contract_Terms
   put the dvData of me into dData
   put _GetTermTitleArray (dData) into termTitleArray
   put termTitleArray ["termTitleDictionary"] into termTitleDictionary
   put the keys of termTitleDictionary into termTitles
   return termTitles
end contract_Terms

getprop contract_TermTitles
   put the dvData of me into dData
   put lexon_ListContractTermTitles (dData) into termTitles
   return termTitles
end contract_TermTitles

getprop contract_DefTitles
   put the dvData of me into dData
   put lexon_ListContractDefs (dData) into contractDefTitles
   return contractDefTitles
end contract_DefTitles

getprop contract_ClauseTitles
   put the dvData of me into dData
   put lexon_ListClauseTitles (dData) into clauseTitles
   return clauseTitles
end contract_ClauseTitles

getprop displayed_Data
   put the dvData of me into dData
   return dData
end displayed_Data

setprop displayed_Data dData
   set the dvData of me to dData
   return the result
end displayed_Data

getprop clause_Titles
   put the dvData of the target into dData
   put lexon_ListClauseTitles (dData) into clauseTitles
   return clauseTitles
end clause_Titles

getprop dv_SectionItems [rowNum]
   put the dvData of the target into dData
   if rowNum is empty then
      put the dvRow of the target into rowNum
   end if
   put dData [rowNum]["level"] into sLevel
   --
   put rowNum into hLits
   repeat with itemNum = (rowNum + 1) to item 2 of the extents of dData
      get dData [itemNum]["level"]
      if it = sLevel then
         return hLits
      else
         put comma & itemNum after hLits
      end if
   end repeat
   return hLits
end dv_SectionItems

command dv_ShowHtml itemText
   put mergMarkdownToXHTML (itemText,,true) into someHTML
   dv_TidyHTML someHTML
   put someHTML
end dv_ShowHtml

getprop dv_IconsShowing
   return LocalArray ["iconsShowing"]
end dv_IconsShowing

setprop dv_IconsShowing iconsShowing
   put iconsShowing into LocalArray ["iconsShowing"]
   LayoutControl
end dv_IconsShowing

getprop dv_LeftMargin
   return LocalArray ["leftM"]
end dv_LeftMargin

setprop dv_LeftMargin leftM
   put leftM into LocalArray ["leftM"]
   LayoutControl
end dv_LeftMargin


--> Events
-
on mouseDown pButton
   switch
      case pButton = 3
         menu_PopUp "Global | DataView | Row | Menu"
         break
      case the dv_CanDrag of me is true
         pass mouseDown
      default
         -- put the dvClickRow of the target into clickedRowNum
         put the dvRowControl of the target into rowView
         if exists (rowView) is false then pass mouseDown
         
         put the dvRow of rowView into clickedRowNum
         put the dvHilitedRow of me into selectedRowNum
         --
         if clickedRowNum = selectedRowNum then
            set the dvHilitedRow of me to 0
         else
            pass mouseDown
         end if
   end switch
end mouseDown

on mouseDoubleUp
   if the optionKey is "Down" then breakpoint
   
   put the dvRowControl of the target into rowView
   put the dv_RowData of the target into rowData
   put rowData ["text"] into itemText
   
   put rowData ["@style"] into itemStyle
   switch itemStyle
      case "clause"
         lexon_Transfer rowView, rowData
         break
      case "markdown"
         dv_ShowHtml itemText
         break
      default
         put itemStyle & CR & itemText
   end switch
   --
   if the optionKey is "Down" then
      put the dv_RowBehavior of the target into rowTemplate
      put the behavior of rowTemplate into bObject
      edit the script of bObject
   end if
end mouseDoubleUp

on preOpenControl
   -- to load can just get the name. Hope this makes the behavior work.
   get the name of stack "View|Contract|Title"
   get the name of stack "View|Contract|Clause"
   --
   dispatch "ResetView" to me
   dispatch "RenderView" to me
end preOpenControl


--> Geometry
-
/*
This DataView already has geometry handers triggered by "resizeControl" => "ResizeToFit" in the "DataView Behavior" stack script.
To make it compatible with LCW Layouts we add the follwoing handlers.
*/

on LayoutControl pControlRect
   -- not a good idea as nesting can causee issues. let's dop a check
   if the long id of the target is not the long id of me then pass LayoutControl
   
   ResizeToFit
end LayoutControl


--> DataView | Row | Dragging
-
on ValidateRowDrop pDraggingInfoA, pProposedRow, pProposedDropOperation
   put the dragData ["private"] into startedRow
   --   
   return true
end ValidateRowDrop

on AcceptRowDrop pDraggingInfoA, droppedOnRow, pDropOperation
   put the dragData ["private"] into startedRow
   --
   _MoveRow startedRow, droppedOnRow
   --
end AcceptRowDrop


--> Drop
-
command drop_URL
   put the keys of the dragData into dropKeys
   put the dragData ["text"] into droppedURL
   --
   put the dragData ["html"] into droppedHTML
   put "<p><a href='(.+\.html)'>.+</a></p>" into wikiHtmlURlReg
   replace "'" with quote in wikiHtmlURlReg
   --
   switch
      case matchText (droppedHTML, wikiHtmlURlReg, wikiHtmlURl)
         drop_WikiHtmlUrl wikiHtmlURl
         break
         /*
      case droppedURL begins with "https://www.c-span.org/video/?"
         drop_Youtube droppedURL
         break
      case "Files" is among the lines of dropKeys
         drop_File
         break
      case "image" is among the lines of dropKeys
         put the dragData ["image"] into imageContents
         put "image" & CR & line 1 of imageContents
         break
      case droppedURL begins with "https://www.bbc.co.uk/iplayer/episode/"
      case matchtext (droppedURL, "https://www.bbc.co.uk/iplayer/episode/(.+)")
         drop_BBC droppedURL
         break
      case droppedURL begins with "https://www.youtube.com/watch?v="
      case matchText (droppedURL, "https://www.youtube.com/watch?v=(.+)", tubeID)
         drop_Youtube droppedURL
         break
      case matchText (droppedURL, "https://vimeo.com/(.+)", vimeoID)
      case matchText (droppedURL, "https://vimeo.com/channels/staffpicks/(.+)", vimeoID)
         drop_Vimeo vimeoID
         break
         */
      default
         -- do nothing
         answer warning "I don't recognise this url!"
         put droppedURL
         break
      default
         put dropKeys
   end switch
end drop_URL


--> Drop
-
command drop_WikiHtmlUrl wikiHtmlURl
   put "http://(.+)\/(.+)\.html" into someReg
   if matchText (wikiHtmlURl, someReg, wikiDomain, pageSlug) is true then
      set the dv_Wikidomain [pageSlug] of me to wikiDomain
   else
      return empty
   end if
end drop_WikiHtmlUrl

/*
command drop_Video
   put the keys of the dragData into dropKeys
   put the dragData ["text"] into droppedURL
   --
   put the dragData ["html"] into droppedHTML
   put "<p><a href='(.+\.html)'>.+</a></p>" into wikiHtmlURlReg
   replace "'" with quote in wikiHtmlURlReg
   --
   switch
      case droppedURL begins with "https://www.c-span.org/video/?"
         drop_Youtube droppedURL
         break
      case "Files" is among the lines of dropKeys
         drop_File
         break
      case "image" is among the lines of dropKeys
         put the dragData ["image"] into imageContents
         put "image" & CR & line 1 of imageContents
         break
      case droppedURL begins with "https://www.bbc.co.uk/iplayer/episode/"
      case matchtext (droppedURL, "https://www.bbc.co.uk/iplayer/episode/(.+)")
         drop_BBC droppedURL
         break
      case droppedURL begins with "https://www.youtube.com/watch?v="
      case matchText (droppedURL, "https://www.youtube.com/watch?v=(.+)", tubeID)
         drop_Youtube droppedURL
         break
      case matchText (droppedURL, "https://vimeo.com/(.+)", vimeoID)
      case matchText (droppedURL, "https://vimeo.com/channels/staffpicks/(.+)", vimeoID)
         drop_Vimeo vimeoID
         break
      case matchText (droppedHTML, wikiHtmlURlReg, wikiHtmlURl)
         drop_WikiHtmlUrl wikiHtmlURl
         break
      default
         -- do nothing
         answer warning "I don't recognise this url!"
         put droppedURL
         break
      default
         put dropKeys
   end switch
end drop_Video

command drop_Vimeo vimeoID
   put vimeoID
end drop_Vimeo

command drop_Youtube youTubeURL
   -- https://www.youtube.com/watch?v=BvDpNtbrr5Y
   put youtube_ListFormats (youTubeURL) into availableFormats
   switch
      case availableFormats contains "webm"
         youtube_DownloadVideo youTubeURL, "webm", true
         break
      case availableFormats contains "ogg"
         youtube_DownloadVideo youTubeURL, "ogg", true
         break
      default
         youtube_DownloadVideo youTubeUrl, "mp4", true
   end switch   
   put the result into videoFile
   set the movie_File of me to videoFile
   return videoFile
end drop_Youtube

command drop_BBC droppedURL
   -- Horizon_2020_-_Pluto_Back_From_the_Dead_m000kqm9_original.mp4
   
   iplayer_DownloadVideo droppedURL
   put the result into infoArray
   --
   display_Data infoArray
   --
   -- now add it to player
   --
   put iplayer_GetDownloadFolder() into iplayerFolder
   finder_Reveal iplayerFolder
end drop_BBC

command drop_File
   put line 1 of dragData ["files"] into videoFile
   switch
      case file_IsVideo (videoFile)
         set the movie_File of me to videoFile
         set the movie_Paused of me to false
         break
      case videoFile ends with ".m3u"
         put url ("file:" & videoFile) into m3uPlayList
         set the m3u_Text of me to m3uPlayList
         break
      default
         put "Dropped file:" && videoFile
   end switch
end drop_File
*/

--> Events | Drag
-
on dragStart
   if the dv_CanDrag of me is true then
      put false into IsDeleted
      set the dvDragImageRow of me to item 1 of the dvHilitedRows of me
      set the dvTrackDragReorder[the dvHilitedRows of me] of me to true
      set the dragData ["private"] to the dvHilitedRows of me # dragdata has to be set to something.
   end if
end dragStart

on dragDrop
   -- if the dv_CanDrag of me is false then
   get the dragData ["private"]
   if it is empty then
      drop_URL
   end if
end dragDrop

on dragEnter
   -- if the dv_CanDrag of me is false then
   if the dragData ["private"] is empty then
      set the allowableDragActions to "link"
      set the dragAction to "Link"
   end if
end dragEnter


--> DataView | Drag | Can
-
getprop dv_CanDrag
   get the viewProp ["multiple lines"] of me
   put it is false into someBoolean
   return someBoolean
end dv_CanDrag

setprop dv_CanDrag someBoolean
   set the viewProp ["multiple lines"] of me to someBoolean is false
end dv_CanDrag

setprop dv_MoveRowNum [startedRow] droppedOnRow
   _MoveRow startedRow, droppedOnRow
   put the result into rowNum
   return rowNum
end dv_MoveRowNum


--> Private
-
private command _MoveRow startedRow, droppedOnRow
   put the dvData of me into dData
   indexedArray_Delete dData, startedRow
   put the result into CutRowData
   --
   if droppedOnRow < startedRow then
      put droppedOnRow into rowNum
   else
      put droppedOnRow - 1 into rowNum
   end if
   indexedArray_Add dData, CutRowData, rowNum
   --
   -- lock screen
   set the dvData of me to dData
   set the dvHilitedRow of me to rowNum
   -- unlock screen
   --
   return rowNum
end _MoveRow
