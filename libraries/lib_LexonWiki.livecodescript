script "lib_LexonWiki"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_LexonWiki
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Lexon | Wiki
-
command lexon_CreateWikiPageFromRow rowView
   put the wiki_Text of rowView into wikiText
   put the dv_RowStyle of rowView into rowStyle
   switch rowStyle
      case "clause"
         put the clause_Title of rowView into pageTitle
         lexon_CreateWikiPage pageTitle, wikiText, "clause"
         break
      case "definition"
         put the definition_Phrase of rowView into pageTitle
         lexon_CreateWikiPage pageTitle, wikiText, "definition"
         break
   end switch
   put the result into wikiURL
   return wikiURL
end lexon_CreateWikiPageFromRow

command lexon_CreateWikiPage someTitle, wikiText, pWhichTemplate
   switch pWhichTemplate
      case "definition"
         put someTitle into pageTitle
         put pageArray_FetchTemplate ("dao.lexon.wiki", "definition-template", pageTitle, "lexon.wiki, liquidlaw.org") into pageArray
         --
         put "# Lexon Definition" & CR&CR into someMarkDown
         put ">" && wikiText after someMarkDown
         break
      default
         put lexon_ShortClauseTitle (someTitle) into pageTitle
         put pageArray_FetchTemplate ("dao.lexon.wiki", "clause-template", pageTitle, "lexon.wiki, liquidlaw.org") into pageArray
         --
         put "# Lexon Clause" & CR&CR into someMarkDown
         delete line 1 of wikiText -- the title
         put ">" && wikiText after someMarkDown
   end switch
   
   -- pageArray_ReplaceSection pageArray, "Lexon Clause", someMarkDown
   pageArray_SetItemText pageArray, "a8a976df-7930-4cc6-a87b-d9c46b5335aa", someMarkDown
   --
   put fedwiki_ConstructSlug (pageTitle) into pSlug
   pageArray_Store "dao.lexon.wiki", pSlug, pageArray
   put the result into wikiURL
   --
   return wikiURL
end lexon_CreateWikiPage

function lexon_ShortClauseTitle clauseTitle
   set the itemDelimiter to ":"
   if item 1 of clauseTitle = "CLAUSE" then
      delete word 1 of clauseTitle
   end if
   return word 1 to -1 of clauseTitle
end lexon_ShortClauseTitle



--> Deps
-
