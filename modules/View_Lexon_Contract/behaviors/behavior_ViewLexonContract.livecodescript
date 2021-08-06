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

function CacheKeyForRow rowNum
   put the dvData of me into dData
   put dData [rowNum] into rowData
   put rowData ["id"] into rowID
   return rowID
end CacheKeyForRow


--> Working on
-
on mouseDoubleUp
   put the dvRowControl of the target into rowView
   put the dvRow of rowView into rowNum
   --
   put the dv_RowData of rowView into rowData
   put rowData ["@style"] into itemStyle
   --
   dispatch "EditKeyOfRow" to rowView with itemStyle,rowNum
   
   /*
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
   */
end mouseDoubleUp

on linkClicked somePhrase
   put the dvRowControl of the target into rowView
   --
   lexon_StripPunctuation somePhrase
   put the contract_ClauseTitles of me into clauseTitles
   put the contract_DefTitles of me into defTitles
   put the contract_Terms of me into contractTerms
   --
   put the dv_RowData of the target into rowData
   --
   switch
      case somePhrase is among the lines of clauseTitles
         set the selected_Clause of me to somePhrase
         break
      case somePhrase is among the lines of defTitles
         set the selected_Def of me to somePhrase
         break
      case somePhrase is among the lines of contractTerms
         set the selected_Term of me to somePhrase
         break
      default
         put somePhrase
   end switch
end linkClicked

getprop link_Array
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then return empty
   --
   put the dvData of rowView into dData
   put the dvRow of rowView into rowNum
   -- put the dv_RowData of rowView into rowData
   -- put the lexon_RowTitle of rowView into fromTitle
   --
   put lexon_GetLinkArray (rowNum, dData) into linkArray
   --
   return linkArray
end link_Array

getprop lexon_RowTitle
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then return empty
   --   
   put lexon_GetRowTitle (rowNum, dData) into rowTitle
   return rowTitle
end lexon_RowTitle

getprop row_DataAbove [pLevel]
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then return empty
   put the dvRow of rowView into rowNum
   if rowNum is empty then return empty
   
   put the dvData of me into dData
   put row_GetDataAbove (rowNum, dData, pLevel) into rowDataAbove
   --
   return rowDataAbove
end row_DataAbove

setprop selected_Term somePhrase
   put the displayed_Data of me into dData
   put lexon_FindTerm (somePhrase, dData) into rowNum
   --
   if rowNum is a number then
      set the dvHilitedRows of me to rowNum
   end if
end selected_Term

setprop selected_Def somePhrase
   put the displayed_Data of me into dData
   put lexon_FindDef (somePhrase, dData) into rowNum
   --
   if rowNum is a number then
      set the dvHilitedRows of me to rowNum
   end if
end selected_Def

setprop selected_Clause clauseTitle
   put the displayed_Data of me into dData
   put lexon_FindClause (clauseTitle, dData) into rowNum
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
getprop lexon_RowLinkArray
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then return empty
   --
   put the dv_RowData of rowView into rowData
   --
   put rowData ["title"] into clauseTitle
   put lexon_GetClauseTitle (clauseTitle) into clauseTitle
   --
   put rowData ["links"] into linkData
   repeat for each key itemNum in linkData
      put linkData [itemNum]["text"] into linkPhrase
      _CleanLink linkPhrase
      put linkPhrase & comma after linkItems
      put empty into linkArray [clauseTitle][linkPhrase]
   end repeat
   return linkArray
end lexon_RowLinkArray

private command _CleanLink @linkPhrase
   -- issues with utf8???
   
   replace "’" with "'" in linkPhrase
   put utf8_Encode (linkPhrase) into linkPhrase
   -- put utf8_Decode (linkPhrase) into linkPhrase
   -- replace "'" with empty in linkPhrase
   -- replace "‚Äô" with "'" in linkPhrase
end _CleanLink

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


--> Props | Contract
-
getprop contract_TitleArray
   put the dvData of me into dData
   put lexon_GetContractTitleArray (dData) into titleArray
   --
   return titleArray
end contract_TitleArray

getprop contract_Terms
   put the dvData of me into dData
   put lexon_ListContractTerms (dData) into contractTerms
   return contractTerms
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

getprop lexon_SectionData [rowNum]
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then
      get the name of the target
      breakpoint
      return empty
   end if
   
   put the dv_SectionItems [rowNum] of rowView into rowNums
   --
   put the dvData of me into dData
   put 1 into itemNum
   repeat for each item rowNum in rowNums
      put dData [rowNum] into newData [itemNum]
      add 1 to itemNum
   end repeat
   return newData
end lexon_SectionData

getprop dv_SectionItems [rowNum]
   put the dvData of the target into dData
   put the dvRowControl of the target into rowView
   if exists (rowView) is false then
      get the name of the target
      breakpoint
      return empty
   end if
   -- 
   if rowNum is empty then
      put the dvRow of rowView into rowNum
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

on preOpenControl
   -- to load can just get the name. Hope this makes the behavior work.
   get the name of stack "View|Contract|Title"
   get the name of stack "View|Contract|Clause"
   get the name of stack "View|Contract|Definition"
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
