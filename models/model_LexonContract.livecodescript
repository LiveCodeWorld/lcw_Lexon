script "model_LexonContract"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_LexonContract
type: model
version: 0.1


--> Variables
-
local LocalArray


--> Working on
-
command clause_Deconstruct @someClause, @clauseTitle
   -- put lexon_CleanClause (someClause) into someClause
   if lexon_IsClauseTitle (line 1 of someClause) then
      put word 1 to -1 of line 1 of someClause into clauseTitle
      delete line 1 of someClause
   else
      put "_Untitled" into clauseTitle
   end if
end clause_Deconstruct


--> Lexon | List
-
function lexon_ListClauseTitles dData
   repeat with itemNum = 1 to item 2 of the extents of dData
      put dData [itemNum] into itemArray
      if itemArray ["@style"] = "clause" then
         put itemArray ["title"] into utf8Title
         if utf8Title is empty then next repeat
         --
         put lexon_GetClauseTitle (utf8Title) into clauseTitle
         put clauseTitle & CR after clauseTitles
      end if
   end repeat
   delete char -1 of clauseTitles
   sort lines of clauseTitles
   return word 1 to -1 of clauseTitles
end lexon_ListClauseTitles

command _CreateClauseLines @someClause
   -- this should not change the wordNum
   replace "." with CR in someClause
   replace "," with CR in someClause
   replace ";" with CR in someClause
   replace ":" with CR in someClause
end _CreateClauseLines

function lexon_ListContractTermTitles dData
   -- easier to take from termData
   put lexon_GetTermTitleArray (dData) into termTitleArray
   put termTitleArray ["orderedTitles"] into orderedTitles
   return orderedTitles
end lexon_ListContractTermTitles

function lexon_ListContractTerms dData
   put lexon_GetTermTitleArray (dData) into termTitleArray
   put termTitleArray ["termTitleDictionary"] into termTitleDictionary
   put the keys of termTitleDictionary into termTitles
   return termTitles
end lexon_ListContractTerms

function lexon_GetTermTitleArray dData
   repeat with rowNum = 1 to item 2 of the extents of dData
      put dData [rowNum] into clauseData
      put clauseData ["@style"] into sStyle
      put clauseData ["text"] into utf8Title
      put clauseData ["level"] into titleLevel
      --
      if sStyle = "title" and titleLevel = 1 then
         put utf8Title into termPhrase
         if word -1 of termPhrase = "TERMS." then delete word -1 of termPhrase
         --
         -- if termPhrase is not among the items of "GENERAL" then
         put rowNum into termTitleDictionary [termPhrase]["rowNum"]
         put utf8Title into termTitleDictionary [termPhrase]["title"]
         -- end if
         --
         put utf8Title & CR after orderedTitles
      end if
   end repeat
   delete char -1 of orderedTitles
   --
   put orderedTitles into termTitleArray ["orderedTitles"]
   put termTitleDictionary into termTitleArray ["termTitleDictionary"]
   --
   return termTitleArray
end lexon_GetTermTitleArray


--> Lexon | ClauseTitle
-
function lexon_GetClauseTitle utf8Title
   put lexon_GetTitle (utf8Title) into clauseTitle
   set the itemdelimiter to ":"
   if item 1 of clauseTitle = "CLAUSE" then
      delete item 1 of clauseTitle
      put word 1 to -1 of clauseTitle into clauseTitle
      return clauseTitle
   else
      return utf8Title
   end if
end lexon_GetClauseTitle

function lexon_IsClauseTitle sTitle
   set the itemdelimiter to ":"
   put word 1 to -1 of item 1 of sTitle into maybeClauseTitle
   put maybeClauseTitle = "CLAUSE" into isClauseTitle
   return isClauseTitle
end lexon_IsClauseTitle

function lexon_GetTitle sTitle
   if char -1 of sTitle = "." then delete char -1 of sTitle
   return sTitle
end lexon_GetTitle


--> Private
-
private function text_IsCaps someText
   put "^[^a-z]*$" into someReg
   get matchtext (word 1 to -1 of someText, someReg)
   return it 
end text_IsCaps
