script "lib_LexonGraph"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_LexonGraph
type: library
version: 0.1

/*Some help*/


--> Working on
-
function lexon_GetClauseLinkArray iData
   
end lexon_GetClauseLinkArray


--> Graph
-
command graph_SimpleLinkArray linkArray, pGraphName, pFile
   -- put dot_FromLinkArray (linkArray) into dotText
   put linkArray_DotNodeLinks (linkArray, empty) into nodeSection
   put dot_Construct (nodeSection, pGraphName) into dotText
   --
   display_Text dotText
   dot_CreateGraph dotText, pFile
   put the result into svgFile
   --
   display_SVG svgFile
end graph_SimpleLinkArray


--> Lexon | Graph
-
function lexon_ConstructContractLinkArray iData
   repeat for each key itemNum in iData
      put iData [itemNum]["title"] into pTitle
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

function lexon_GetContractLinkArray dData
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum] into clauseData
      --
      put clauseData ["title"] into utf8Title
      put lexon_GetClauseTitle (utf8Title) into cTitle
      --
      if cTitle is not empty then
         put clause_GetUniqueTitleData (clauseData) into titleData
         put titleData into cLinkArray ["linkArray"][cTitle]
         put itemNum into cLinkArray ["meta"][cTitle]["itemNum"]
         put titleData into cLinkArray ["meta"][cTitle]["children"]
      end if
   end repeat
   return cLinkArray
end lexon_GetContractLinkArray


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
