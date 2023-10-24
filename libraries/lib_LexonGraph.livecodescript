script "lib_LexonGraph"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_LexonGraph
type: library
version: 0.1

/*Some help*/


--> Working on
-

--> Display | Lexon | Graph
-
command display_LexonContractGraph dData, pShortFile, pGraphStyle, pNotTheseDefs
   put "Lexon" into graphName
   put lexon_ConstructFile (pShortFile) into dotFile
   --
   put lexon_GetContractLinkArray (dData, pNotTheseDefs) into linkArray
   delete variable linkArray ["GENERAL: definitions."]
   --
   put lexon_ConstructGroupStyleArray (dData) into dotGroupStyleArray
   put dot_ConstructDefSection (dotGroupStyleArray, linkArray) into defSection
   put empty into defSection
   --
   put false into concentrate
   put "oval" into defaultShape
   --
   put dot_FromLinkArray (linkArray, pGraphStyle, "lightblue",  concentrate, defaultShape, defSection, graphName) into dotText
   --
   display_DotTextSvg dotText, dotFile, pGraphStyle
   put the result into svgView
   --
   set the link_Array of svgView to linkArray
   set the dot_StyleArray of svgView to dotGroupStyleArray
   set the dv_Data of svgView to dData
   --
   return svgFile
end display_LexonContractGraph

function lexon_ConstructGroupStyleArray dData
   local dotGroupStyleArray, nodeUrl
   
   -- put lexon_ListClauseTitles (dData) into clauseTitles
   repeat with rowNum = 1 to item 2 of the extents of dData 
      put dData [rowNum] into itemArray
      if itemArray ["@style"] = "clause" then
         put itemArray ["title"] into utf8Title
         if utf8Title is empty then next repeat
         --
         put lexon_GetRowTitle (rowNum, dData) into longTitle
         put lexon_GetClauseTitle (longTitle) into clauseTitle
         --
         put kwote (clauseTitle) & CR after clauseTitles
      end if
   end repeat
   delete char -1 of clauseTitles
   --
   graph_AddToGroupStyleArray dotGroupStyleArray, "Clause", clauseTitles, "black", "yellow", nodeUrl
   -- graph_SetNodeLabel dotGroupStyleArray, empty, "http://google.com"
   --
   return dotGroupStyleArray
end lexon_ConstructGroupStyleArray


--> Lexon | Graph
-
function lexon_GetContractLinkArray dData, pNotTheseDefs
   local linkArray
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum]["@style"] into itemStyle
      switch itemStyle
         case "title"
            next repeat
         default
            lexon_AddLinkArray linkArray, rowNum, dData, pNotTheseDefs
      end switch
   end repeat
   return linkArray
end lexon_GetContractLinkArray

command lexon_AddLinkArray @linkArray, rowNum, dData, pNotTheseDefs
   put lexon_GetPrettyRowTitle (rowNum, dData) into fromTitle
   --
   put dData [rowNum]["clauseData"] into clauseData
   repeat with itemNum = 1 to item 2 of the extents of clauseData
      put clauseData [itemNum]["text"] into toTitle
      --
      if toTitle = fromTitle then next repeat -- strip self-references
      --
      put clauseData [itemNum]["linkType"] into linkType
      if linkType is among the items of pNotTheseDefs then next repeat
      --
      put linkType into linkArray [fromTitle][toTitle]["linkType"]
   end repeat
end lexon_AddLinkArray

function lexon_GetRowTitle rowNum, dData
   put dData [rowNum]["title"] into rowTitle
   --
   if rowTitle = "_Untitled" then
      put row_GetDataAbove (rowNum, dData, 2) into sectionTitleData
      put row_GetDataAbove (rowNum, dData, 1) into termTitleData
      --
      put sectionTitleData ["text"] into sectionAboveTitle
      if sectionAboveTitle = "RECITAL." then return "RECITAL"
      
      put termTitleData ["text"] into termAboveTitle
      switch
         case sectionAboveTitle = termAboveTitle
            delete word -1 of termAboveTitle
            put "RECITAL:" && tolower (termAboveTitle) into rowTitle
            break
         default
            delete word -1 of termAboveTitle
            if termAboveTitle is empty then return "GENERAL: definitions"
            --
            put termAboveTitle & ":" && tolower (sectionAboveTitle) into rowTitle
      end switch
   end if
   --
   return rowTitle
end lexon_GetRowTitle


--> Lexon | Graph | Utils
-
function lexon_GetPrettyRowTitle rowNum, dData
   put lexon_GetRowTitle (rowNum, dData) into longTitle
   put lexon_GetClauseTitle (longTitle) into fromTitle
   return fromTitle
end lexon_GetPrettyRowTitle

function lexon_GetLinkArray rowNum, dData, pNotTheseDefs
   local linkArray
   lexon_AddLinkArray linkArray, rowNum, dData, pNotTheseDefs
   return linkArray
end lexon_GetLinkArray


--> Experiments
-
-- function lexon_ConstructContractLinkArray dData
repeat for each key rowNum in dData
   put dData [rowNum]["title"] into pTitle
   -- put _GetSlug (pTitle) into pSlug
   put _Quote (pTitle) into pSlug
   --
   put iData [itemNum]["links"] into linksData
   repeat for each key linkNum in linksData
      put linksData [linkNum]["text"] into cTitle
      -- put _GetSlug (cTitle) into cSlug
      put _Quote (cTitle) into cSlug
      --
      put cTitle into linkArray [pSlug][cSlug]
   end repeat
end repeat
return iData
end lexon_ConstructContractLinkArray


--> Private
-
private function _Quote sText
   replace quote with empty in sText
   put word 1 to -1 of sText into sText
   --
   set the itemdelimiter to ":"
   if item 1 of sText = "Clause" then
      delete item 1 of sText
      put word 1 to -1 of sText into sText
   end if
   --
   put kwote (sText) into cSlug
   return cSlug
end _Quote

private function _GetSlug sText
   replace quote with empty in sText
   put word 1 to -1 of sText into sText
   --
   set the itemdelimiter to ":"
   if item 1 of sText = "Clause" then
      delete item 1 of sText
      put word 1 to -1 of sText into sText
   end if
   --
   put fedwiki_ConstructSlug (sText) into cSlug
   return cSlug
end _GetSlug

