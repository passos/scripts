" Vim syntax file
" Language:		Mail file
" Previous Maintainer:	Felix von Leitner <leitner@math.fu-berlin.de>
" Maintainer:		Gautam Iyer <gautam@math.uchicago.edu>
" Last Change:		Wed 01 Jun 2005 02:11:07 PM CDT

scriptencoding utf-8

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" The mail header is recognized starting with a "keyword:" line and ending
" with an empty line or other line that can't be in the header. All lines of
" the header are highlighted. Headers of quoted messages (quoted with [>:]) are
" also highlighted.

" Syntax clusters
syn cluster mailLinks		contains=mailURL,mailEmail
syn cluster mailQuoteExps	contains=mailQuoteExp1,mailQuoteExp2,mailQuoteExp3,mailQuoteExp4,mailQuoteExp5,mailQuoteExp6

syn case match
" For "From " matching case is required. The "From " is not matched in quoted
" emails
" According to RFC 2822 any printable ASCII character can appear in a field
" name, except ':'.

syn case ignore
" Nothing else depends on case. Headers in properly quoted (with "[>:] " or "[>:]")
" emails are matched

" Mail Signatures. (Begin with "-- ", end with change in quote level)
syn region	mailSignature	keepend contains=@mailLinks,@mailQuoteExps start="^--\s$" end="^$" end="^\([>:] \)\+"me=s-1
syn region	mailSignature	keepend contains=@mailLinks,@mailQuoteExps,@NoSpell start="^\z(\([>:] \)\+\)--\s$" end="^\z1$" end="^\z1\@!"me=s-1 end="^\z1\([>:] \)\+"me=s-1

" URLs start with a known protocol or www,web,w3.
syn match mailURL contains=@NoSpell `\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^' 	<>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^' 	<>"]+)[a-z0-9/]`
syn match mailEmail contains=@NoSpell "\v[_=a-z\./+0-9-]+\@[a-z0-9._-]+\a{2}"

" Make sure quote markers in regions (header / signature) have correct color
syn match mailQuoteExp1	contained "\v^([>:] )"
syn match mailQuoteExp2	contained "\v^([>:] ){2}"
syn match mailQuoteExp3	contained "\v^([>:] ){3}"
syn match mailQuoteExp4	contained "\v^([>:] ){4}"
syn match mailQuoteExp5	contained "\v^([>:] ){5}"
syn match mailQuoteExp6	contained "\v^([>:] ){6}"

syn match bbsAuthorExpr contained "^【.*】$"

" Even and odd quoted lines. order is imporant here!
syn match mailQuoted1	contains=mailHeader,@mailLinks,mailSignature,@NoSpell "^\([>:] \).*$"
syn match mailQuoted2	contains=mailHeader,@mailLinks,mailSignature,@NoSpell "^\([>:] \)\{2}.*$"
syn match mailQuoted3	contains=mailHeader,@mailLinks,mailSignature,@NoSpell "^\([>:] \)\{3}.*$"
syn match mailQuoted4	contains=mailHeader,@mailLinks,mailSignature,@NoSpell "^\([>:] \)\{4}.*$"
syn match mailQuoted5	contains=mailHeader,@mailLinks,mailSignature,@NoSpell "^\([>:] \)\{5}.*$"
syn match mailQuoted6	contains=mailHeader,@mailLinks,mailSignature,@NoSpell "^\([>:] \)\{6}.*$"

syn match bbsAuthor	    contains=bbsAuthorExpr,@NoSpell "^【.*】$"

" Need to sync on the header. Assume we can do that within 100 lines
if exists("mail_minlines")
    exec "syn sync minlines=" . mail_minlines
else
    syn sync minlines=100
endif

" Define the default highlighting.
hi def link mailSignature	PreProc
hi def link mailEmail		Special
hi def link mailURL		String
hi def link mailQuoted1		Comment
hi def link mailQuoted3		mailQuoted1
hi def link mailQuoted5		mailQuoted1
hi def link mailQuoted2		Identifier
hi def link mailQuoted4		mailQuoted2
hi def link mailQuoted6		mailQuoted2
hi def link mailQuoteExp1	mailQuoted1
hi def link mailQuoteExp2	mailQuoted2
hi def link mailQuoteExp3	mailQuoted3
hi def link mailQuoteExp4	mailQuoted4
hi def link mailQuoteExp5	mailQuoted5
hi def link mailQuoteExp6	mailQuoted6
hi def link bbsAuthor       Statement
hi def link bbsAuthorExpr   Statement

let b:current_syntax = "bbs"
