script "model_LexonHackMD"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_LexonHackMD
type: model
version: 0.1


--> Lexon | HackMD | Fetch
-
function hackMD_FetchLexonData hackmdID
   put hackMD_FetchLexonTermData (hackmdID, false) into termData
   put lexon_ConstructDataViewArray (termData) into dData
   return dData
end hackMD_FetchLexonData

function hackMD_FetchLexonTermData hackmdID, pUseCli
   put hackMD_FetchLexonContract (hackmdID, pUseCli) into lexBody
   put lexon_ConstructTermIndexData (lexBody) into termData
   return termData
end hackMD_FetchLexonTermData

function hackMD_FetchLexonContract noteID, pUseCli
   put hackmd_FetchMarkdown (noteID, pUseCli) into lexText
   hackmd_Deconstruct lexText, lexTitle, lexBody
   put the result into lexMeta
   --
   return lexBody
end hackMD_FetchLexonContract
