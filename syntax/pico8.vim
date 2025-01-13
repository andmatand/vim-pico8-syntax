" Copied from vim's default syntax/lua.vim file and modified a bit

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists("lua_version")
  " Default is lua 5.3
  let lua_version = 5
  let lua_subversion = 3
elseif !exists("lua_subversion")
  " lua_version exists, but lua_subversion doesn't. In this case set it to 0
  let lua_subversion = 0
endif

syn case match

" syncing method
syn sync minlines=1000

if lua_version >= 5
  syn keyword luaMetaMethod __add __sub __mul __div __pow __unm __concat
  syn keyword luaMetaMethod __eq __lt __le
  syn keyword luaMetaMethod __index __newindex __call
  syn keyword luaMetaMethod __metatable __mode __gc __tostring
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  syn keyword luaMetaMethod __mod __len
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 2)
  syn keyword luaMetaMethod __pairs
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 3)
  syn keyword luaMetaMethod __idiv __name
  syn keyword luaMetaMethod __band __bor __bxor __bnot __shl __shr
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 4)
  syn keyword luaMetaMethod __close
endif

" catch errors caused by wrong parenthesis and wrong curly brackets or
" keywords placed outside their respective blocks

syn region luaParen transparent start='(' end=')' contains=TOP,luaParenError
syn match  luaParenError ")"
syn match  luaError "}"
syn match  luaError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"

" Function declaration
syn region luaFunctionBlock transparent matchgroup=luaFunction start="\<function\>" end="\<end\>" contains=TOP

" else
syn keyword luaCondElse matchgroup=luaCond contained containedin=luaCondEnd else

" then ... end
syn region luaCondEnd contained transparent matchgroup=luaCond start="\<then\>" end="\<end\>" contains=TOP

" elseif ... then
syn region luaCondElseif contained containedin=luaCondEnd transparent matchgroup=luaCond start="\<elseif\>" end="\<then\>" contains=TOP

" if ... then
syn region luaCondStart transparent matchgroup=luaCond start="\<if\>" end="\<then\>"me=e-4 contains=TOP nextgroup=luaCondEnd skipwhite skipempty

" do ... end
syn region luaBlock transparent matchgroup=luaStatement start="\<do\>" end="\<end\>" contains=TOP
" repeat ... until
syn region luaRepeatBlock transparent matchgroup=luaRepeat start="\<repeat\>" end="\<until\>" contains=TOP

" while ... do
syn region luaWhile transparent matchgroup=luaRepeat start="\<while\>" end="\<do\>"me=e-2 contains=TOP nextgroup=luaBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region luaFor transparent matchgroup=luaRepeat start="\<for\>" end="\<do\>"me=e-2 contains=TOP nextgroup=luaBlock skipwhite skipempty

syn keyword luaFor contained containedin=luaFor in

" other keywords
syn keyword luaStatement return local break
if lua_version > 5 || (lua_version == 5 && lua_subversion >= 2)
  syn keyword luaStatement goto
  syn match luaLabel "::\I\i*::"
endif

" operators
syn keyword luaOperator and or not

if (lua_version == 5 && lua_subversion >= 3) || lua_version > 5
  syn match luaSymbolOperator "[#<>=~^&|*/%+-]\|\.\{2,3}"
elseif lua_version == 5 && (lua_subversion == 1 || lua_subversion == 2)
  syn match luaSymbolOperator "[#<>=~^*/%+-]\|\.\{2,3}"
else
  syn match luaSymbolOperator "[<>=~^*/+-]\|\.\{2,3}"
endif

" comments
syn keyword luaTodo            contained TODO FIXME XXX
syn match   luaComment         "--.*$" contains=luaTodo,@Spell
if lua_version == 5 && lua_subversion == 0
  syn region luaComment        matchgroup=luaCommentDelimiter start="--\[\[" end="\]\]" contains=luaTodo,luaInnerComment,@Spell
  syn region luaInnerComment   contained transparent start="\[\[" end="\]\]"
elseif lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  " Comments in Lua 5.1: --[[ ... ]], [=[ ... ]=], [===[ ... ]===], etc.
  syn region luaComment        matchgroup=luaCommentDelimiter start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell
endif

" first line may start with #!
syn match luaComment "\%^#!.*"

syn keyword luaConstant nil
if lua_version > 4
  syn keyword luaConstant true false
endif

" strings
syn match  luaSpecial contained #\\[\\abfnrtv'"[\]]\|\\[[:digit:]]\{,3}#
if lua_version == 5
  if lua_subversion == 0
    syn region luaString2 matchgroup=luaStringDelimiter start=+\[\[+ end=+\]\]+ contains=luaString2,@Spell
  else
    if lua_subversion >= 2
      syn match  luaSpecial contained #\\z\|\\x[[:xdigit:]]\{2}#
    endif
    if lua_subversion >= 3
      syn match  luaSpecial contained #\\u{[[:xdigit:]]\+}#
    endif
    syn region luaString2 matchgroup=luaStringDelimiter start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
  endif
endif
syn region luaString matchgroup=luaStringDelimiter start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,@Spell
syn region luaString matchgroup=luaStringDelimiter start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell

" integer number
syn match luaNumber "\<\d\+\>"
" floating point number, with dot, optional exponent
syn match luaNumber  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\="
" floating point number, starting with a dot, optional exponent
syn match luaNumber  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" floating point number, without dot, with exponent
syn match luaNumber  "\<\d\+[eE][-+]\=\d\+\>"

" hex numbers
if lua_version >= 5
  if lua_subversion == 1
    syn match luaNumber "\<0[xX]\x\+\>"
  elseif lua_subversion >= 2
    syn match luaNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"
  endif
endif

" tables
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=TOP,luaStatement

" methods
syntax match luaFunc ":\@<=\k\+"

" PICO-8 API functions
syn keyword p8api abs
                \ add
                \ all
                \ assert
                \ atan2
                \ band
                \ bnot
                \ bor
                \ btn
                \ btnp
                \ bxor
                \ camera
                \ cartdata
                \ ceil
                \ chr
                \ circ
                \ circfill
                \ clip
                \ cls
                \ cocreate
                \ color
                \ coresume
                \ cos
                \ costatus
                \ cstore
                \ cursor
                \ del
                \ deli
                \ dget
                \ dir
                \ dset
                \ extcmd
                \ fget
                \ fillp
                \ flip
                \ flr
                \ foreach
                \ fset
                \ getmetatable
                \ ipairs
                \ line
                \ load
                \ lshr
                \ map
                \ max
                \ memcpy
                \ memset
                \ menuitem
                \ mget
                \ mid
                \ min
                \ mset
                \ music
                \ ord
                \ oval
                \ ovalfill
                \ pack
                \ pairs
                \ pal
                \ palt
                \ peek
                \ peek2
                \ peek4
                \ pget
                \ poke
                \ poke2
                \ poke4
                \ print
                \ printh
                \ pset
                \ rawequal
                \ rawget
                \ rawlen
                \ rawset
                \ rect
                \ rectfill
                \ reload
                \ rnd
                \ rotl
                \ rotr
                \ run
                \ serial
                \ setmetatable
                \ sfx
                \ sget
                \ sgn
                \ shl
                \ shr
                \ sin
                \ split
                \ spr
                \ sqrt
                \ srand
                \ sset
                \ sspr
                \ stat
                \ stop
                \ sub
                \ time
                \ tline
                \ tonum
                \ tostr
                \ type
                \ unpack
                \ yield

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

hi def link luaStatement        Statement
hi def link luaRepeat           Repeat
hi def link luaFor              Repeat
hi def link luaString           String
hi def link luaString2          String
hi def link luaStringDelimiter  luaString
hi def link luaNumber           Number
hi def link luaOperator         Operator
hi def link luaSymbolOperator   luaOperator
hi def link luaConstant         Constant
hi def link luaCond             Conditional
hi def link luaCondElse         Conditional
hi def link luaFunction         Function
hi def link luaMetaMethod       Function
hi def link luaComment          Comment
hi def link luaCommentDelimiter luaComment
hi def link luaTodo             Todo
hi def link luaTable            Structure
hi def link luaError            Error
hi def link luaParenError       Error
hi def link luaSpecial          SpecialChar
hi def link luaLabel            Label
hi def link luaFunc             Identifier
hi def link p8api               Special


let b:current_syntax = "lua"

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: et ts=8 sw=2
