script "lib_LexonFilter"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_LexonFilter
type: library
version: 0.1

/*Some help*/


--> Working on
-
function lexon_GetDefTypeData dData, defType
   put 1 into pNewItemNum
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum] into rowData
      if rowData ["@style"] = "definition" AND rowData ["defType"] = defType then
         put rowData into fData [pNewItemNum]
         add 1 to pNewItemNum
      end if
   end repeat
   return fData
end lexon_GetDefTypeData

function lexon_ListDefTypes dData
   put dv_FilterByStyle (dData, "definition") into fData
   repeat with rowNum = 1 to item 2 of the extents of fData
      put fData [rowNum]["defType"] into defType
      put empty into kArray [defType]
   end repeat
   put keys (kArray) into defTypes
   sort defTypes
   return defTypes
end lexon_ListDefTypes

function lexon_FilterDefinitions dData
   local fData
   put dv_FilterByStyle (dData, "definition") into fData
   
   -- dv_AddMarkdownTitle fData, "DEFINITIONS.", 2
   lexon_AddTitle fData, "DEFINITIONS.", 1
   dv_AddFiltered fData, "definition", dData, 2
   --
   return fData
end lexon_FilterDefinitions

command lexon_InsertTitleAtTop @dData, someTitle, pLevel
   put dv_ConstructItem (someTitle, "title") into itemArray
   put pLevel into itemArray ["level"]
   dv_InsertNewRows dData, itemArray
end lexon_InsertTitleAtTop

function lexon_SortDefinitionsByType dData
   local tSortedArray
   local newRowNum
   
   put dv_FilterByStyle (dData, "definition") into fData
   repeat with rowNum = 1 to item 2 of the extents of fData
      put fData [rowNum]["defType"] into pArray [rowNum]
   end repeat
   
   # fetch the keys and sort them using the array entry values
   get the keys of pArray
   sort lines of it by pArray[each]
   split it by CR
   
   # create a new sorted array using the mapped keys
   put 1 into newRowNum
   repeat for each element oldRowNum in it
      put fData [oldRowNum] into tSortedArray [newRowNum]
      add 1 to newRowNum
   end repeat
   --
   return tSortedArray
end lexon_SortDefinitionsByType


--> Lexon | Clean
-
command lexon_CleanAndSplitData dData, @newClauseData, @defData, pTitleArray
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum] into rowData
      --
      put rowData ["@style"] into itemStyle
      switch itemStyle
         case "definition"
            iData_AddIndexArray defData, rowData
            break
         case "clause"
            put empty into defItemData
            lexon_StripDefLines rowData, newClauseText, defItemData, pTitleArray
            --
            if defItemData is an array then iData_AddIndexArray defData, defItemData
            if rowData is an array then iData_Add newClauseData, rowData
            break
         case "title"
            if rowData ["text"] = "DEFINITIONS." then next repeat
            iData_Add newClauseData, rowData
            break
         default
            breakpoint
      end switch
   end repeat
end lexon_CleanAndSplitData

function lexon_CleanData dData
   -- strip out all def lines and add them as distinct definition rows
   put 1 into insertNum
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum] into rowData
      --
      switch rowData ["@style"]
         case "definition"
         case "title"
            get item 2 of the extents of eData
            put it + 1 into nextNum
            put rowData into eData [nextNum]
            break
         case "clause"
            put lexon_CleanRow (rowData) into cData
            --
            iData_AddIndexArray eData, cData
            break
         default
            breakpoint
      end switch
   end repeat
   --
   return eData
end lexon_CleanData

function lexon_DetectDefinitionType defLine
   get word 3 of defLine
   switch
      case token 1 of word 2 of defLine = "means"
         return "text"
      case it = "its"
      case it = "a"
      case it = "an"
      case it = "the"
         put word 4 of defLine into iconType
         return token 1 of iconType
      case it = "no"
      case it = "yes"
      case it = "true"
         return "boolean"
      case it contains "%"
         return "percentage"
      case it = "defined"
      default
         return "text"
   end switch
end lexon_DetectDefinitionType


--> Lexon | Filter
-
function lexon_CleanRow rowData, pTitleArray
   -- create dvData from rowData seperating out def lines
   local dData
   lexon_StripDefLines rowData, newClauseText, defItemData, pTitleArray
   --
   if defItemData is an array then
      -- dv_AddMarkdownTitle dData, "DEFINITIONS.", 2
      --
      if defItemData is an array then
         iData_AddIndexArray dData, defItemData
      end if
   end if
   --
   if rowData is an array then
      -- dv_AddMarkdownTitle dData, "CLAUSE.", 2
      --
      iData_Add dData, rowData
   end if
   --
   return dData
end lexon_CleanRow

command lexon_StripDefLines @rowData, @newClauseText, @defItemData, pTitleArray
   -- clauseData should be recalculated
   put rowData ["text"] into clauseText
   put rowData ["defLineData"] into defLineData
   
   -- let's strip any def lines and construct defItemArray's
   put item 2 of the extents of defLineData into maxNum
   set the itemdelimiter to "."
   repeat with foundNum = maxNum down to 1
      put defLineData [foundNum] into defLineArray
      put defLineArray ["lineNum"] into lineNum
      --
      put lexon_ConstructDefItemArray (defLineArray, pTitleArray) into defItemArray
      put defItemArray into defItemData [foundNum]
      --
      delete line lineNum of clauseText
   end repeat
   put word 1 to -1 of clauseText into newClauseText
   --
   if newClauseText is empty then
      put empty into rowData
      return empty
   else
      put newClauseText into rowData ["text"]
      delete variable rowData ["defLineData"]
      if pTitleArray is an array then
         put lexon_ConstructRowClauseData (newClauseText, pTitleArray) into rowData ["clauseData"]
      else
         lexon_StripDefLinesFromClauseData rowData
      end if
      return newClauseText
   end if
end lexon_StripDefLines

command lexon_StripDefLinesFromClauseData @rowData
   put rowData ["clauseData"] into clauseData
   --
   put 1 into newItemNum
   repeat with itemNum = 1 to item 2 of the extents of clauseData
      get clauseData [itemNum]
      if it ["linktype"] is not "def line" then
         put it into newClauseData [newItemNum]
         add 1 to newItemNum
      end if
   end repeat
   put newClauseData into rowData ["clauseData"]
end lexon_StripDefLinesFromClauseData

function lexon_ConstructDefItemArray defLineArray, pTitleArray
   put defLineArray ["text"] into defLineText
   put defLineArray ["title"] into defLineTitle
   --
   put dv_ConstructItem (defLineText, "definition") into defItemArray
   put defLineTitle into defItemArray ["title"]
   put 3 into defItemArray ["level"]
   --
   put lexon_DetectDefinitionType (defLineText) into defType
   put defType into defItemArray ["defType"]
   --
   put defLineArray ["sLineCharNum"] into defItemArray ["sCharNum"]
   put defLineArray ["eLineCharNum"] into defItemArray ["eCharNum"]
   --
   if pTitleArray is an array then
      put defLineTitle into defLineData [1]["title"]
      --
      put 1 into defLineData [1]["lineNum"]
      put offset (defLineTitle, defLineText) into sLineCharNum
      put sLineCharNum + the number of chars of defLineTitle -1 into eLineCharNum
      --
      put sLineCharNum into defLineData [1]["sLineCharNum"]
      put eLineCharNum into defLineData [1]["eLineCharNum"]
      --
      get lexon_ConstructRowClauseData (defLineText, pTitleArray, defLineData)
      if it is an array then
         put it into defItemArray ["clauseData"]
      end if
   end if
   return defItemArray
end lexon_ConstructDefItemArray
