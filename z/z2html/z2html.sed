# z2html.sed - Z2HTML: simple Fuzz/LaTeX to HTML translator for Z notation
#
# Use GIFs (not symbol font) for Z symbols, HTML tables for Z boxes
# Use *-m.gif, looks best with medium text size
# Set each Z paragraph inside <div class="zed"> ... </div> for stylesheet
# Set in-line Z text (LaTeX $...$) inside <var class="zed"> ... </var> ditto
#
# 11-Jul-1999  J. Jacky  First attempts, used symbol font for most Z characters
#  9-Oct-1999  J. Jacky  Replace all font face=symbol... with GIF's
# 23-Nov-1999  J. Jacky  Begin stylesheet version
#  7-Jan-2000  J. Jacky  Replace <p ...> around tables with <div ...>
# 13-Jan-2000  J. Jacky  Rename zgif directory to zimg (maybe use .png later)
# 15-Jan-2000  J. Jacky  Add closing </tr> in tabular, zed paragraphs
#                        Don't put &nbsp before <em> etc. in informal paragrphs

# Header

1i\
<html>\
\
<head>\
<link rel="stylesheet" href="zed.css" type="text/css">\
<title>Z notation<\/title>\
<\/head>\
\
<body>\

# Footer

$a\
\
<\/body>\
<\/html>

# Get rid of Fuzz comment lines, otherwise Z behind them will appear in HTML

/^%%/d

# Get rid of % LaTeX comments but not \% legitimate LaTeX percent
/^%.*$/d
s/ %.*$//g
s/	%.*$//g
s/\\%/%/g

# Must convert these before writing out *any* HTML tags!
# But can't use any & before handling LaTeX tabular and argue

s/\\>/\\latex-tab/g
s/</\\html-amp-lt;/g
s/>/\\html-amp-gt;/g

# LaTex tabbing - must convert before inserting any other tags
#
# tabbing, tabular, argue environments are class="mixed"
# because they can contain both Z and informal text

/\\begin{tabbing}/,/\\end{tabbing}/ {
	s/\\begin{tabbing}/<div class="mixed">\
<table border=0 cellpadding=0 cellspacing=0>/g
	s/\\end{tabbing}/<\/table>\
<\/div>\
/g
	/^[ 	]*</!s/.*/<tr> <td>&<\/td><\/tr>/
	s/\\=/<\/td> <td>/g
	s/\\latex-tab/<\/td> <td>/g
}

# LaTex tabular 

/\\begin{tabular}/,/\\end{tabular}/ {
	s/\\begin{tabular}.*$/<div class="mixed">\
<table border=0 cellpadding=0 cellspacing=0>/g
	s/\\end{tabular}/<\/table>\
<\/div>\
/g
	/^[ 	]*</!s/.*/<tr> <td>&<\/td><\/tr>/
	s/\&/<\/td> <td>/g
}

# LaTeX argue environment (proofs etc.)

/\\begin{argue}/,/\\end{argue}/ {
	s/\\begin{argue}/<div class="mixed">\
<table border=0 cellpadding=0 cellspacing=0>/g
	s/\\end{argue}/<\/table>\
<\/div>\
/g
	/^[ 	]*</!s/^\([^&]*\)\&\(.*\)$/<tr> <td>\$\1\$<\/td><td align=right>\2<\/td><\/tr>/g
}

# Now we've translated all the LaTeX & so...

s/\\html-amp-/\&/g

# In-line Z text

s/\$\([^$]*\)\$/<var class="zed">\1<\/var>/g

# Single line math paragraph

s/\\\[\(.*\)\\\]/<div class="zed">\
<table border=0 cellpadding=0 cellspacing=0>\
<tr> <td class="zed">\1<\/td><\/tr>\
<\/table>\
<\/div>\
/g

# Single line zed paragraph

s/\\begin{zed}\(.*\)\\end{zed}/<div class="zed">\
<table border=0 cellpadding=0 cellspacing=0>\
<tr> <td class="zed">\1<\/td><\/tr>\
<\/table>\
<\/div>\
/g

# Multiline zed paragraph

/\\begin{zed}/,/\\end{zed}/ {
	s/\\begin{zed}/<div class="zed">\
<table border=0 cellpadding=0 cellspacing=0>/g
	s/\\end{zed}/<\/table>\
<\/div>\
/g
	/^[ 	]*</!s/.*/<tr> <td class="zed">&<\/td><\/tr>/
	s/\\also/<img width=1 height=10 align=bottom alt=" " src="zimg\/clear.gif">/
}


# Single line axdef box

# We use ! not LaTeX \ inside alt="..." to avoid confusion

s/\\begin{axdef}\(.*\)\\end{axdef}/<div class="zed">\
<table border=0 cellpadding=0 cellspacing=0>\
<tr> <td width=1 rowspan=99 bgcolor=black><img width=1 height=1 alt="!begin{axdef}" src="zimg\/clear.gif"><br><\/td><\/tr>\
<tr> <td width=10><\/td><td class="zed">\1<\/td><\/tr>\
<tr><td><img width=1 height=1 alt="!end{axdef}" src="zimg\/clear.gif"><\/td><\/tr>\
<\/table>\
<\/div>\
/g

# Axiomatic definition box

/\\begin{axdef}/,/\\end{axdef}/ {
	s/\\begin{axdef}/<div class="zed">\
<table border=0 cellpadding=0 cellspacing=0>\
<tr> <td width=1 rowspan=99 bgcolor=black><img width=1 height=1 alt="!begin{axdef}" src="zimg\/clear.gif"><br><\/td><\/tr>/g
	s/\\where/<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td height=1 bgcolor=black><img width=10 height=1 alt="!where" src="zimg\/black-10.gif"><\/td>\
      <td height=1 bgcolor=black><img width=15 height=1 alt=" " src="zimg\/black-15.gif"><\/td>\
      <td height=1><img width=75 height=1 alt=" " src="zimg\/black-75.gif"><\/td><\/tr>\
<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>/g
	s/\\end{axdef}/<tr><td width=10 height=1><img width=10 height=1 alt="!end{axdef}" src="zimg\/clear.gif"><\/td><\/tr>\
<\/table>\
<\/div>\
/g
	/^[ 	]*</!s/.*/<tr> <td><\/td><td class="zed" colspan=2>&<\/td><\/tr>/
	s/\\also/<img width=1 height=10 align=bottom alt=" " src="zimg\/clear.gif">/
}

# Schema box
#
# Box is three columns
# First column is space after left edge
# Second column is schema name at the top of the box
# Third column is box top border after schema name
# Schema name sits by itelf on a row above the box top borders
# Text inside box (both decl. and pred.) is colspan=2 in columns two and three
# Box borders are <td ... bgcolor=black>, shows up when print under MS Windows
# Box borders also <img ... src="black.gif">, shows up in Linux .ps out and print
# Box top border is columns one and three, column 2 left blank
# Line between decl. and pred. in cols 1, 2 is bgcolor=black and src="black.gif"
#  "     "       "  col 3 is no bgcolor but <img width=75 ... src="black.gif">
# Box bottom border is colspan=3 in all three columns

/\\begin{schema}{.*}/,/\\end{schema}/ {
	s/\\begin{schema}{\(.*\)}/<div class="zed">\
<table border=0 cellpadding=0 cellspacing=0>\
<tr> <td><img alt="!begin{schema}{" src="zimg\/clear.gif"><\/td>\
     <td><\/td><td class="zed">\1<\/td>\
     <td><img alt="}" src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td width=1 rowspan=99 bgcolor=black><br><\/td><\/tr>\
<tr> <td width=10  height=1 bgcolor=black><img width=10 height=1 alt=" " src="zimg\/black-10.gif"><\/td>\
     <td height=1><img alt=" " src="zimg\/clear.gif"><\/td>\
     <td width=200 height=1 bgcolor=black><img width=200 height=1 alt=" " src="zimg\/black-200.gif"><\/td><\/tr>\
<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>/g
	s/\\where/<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td height=1 bgcolor=black><img width=10 height=1 alt="!where" src="zimg\/black-10.gif"><\/td>\
      <td height=1 bgcolor=black><img width=15 height=1 alt=" " src="zimg\/black-15.gif"><\/td>\
      <td height=1><img width=75 height=1 alt=" " src="zimg\/black-75.gif"><\/td><\/tr>\
<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>/g
	s/\\end{schema}/<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td colspan=3 bgcolor=black><img width=300 height=1 alt="!end{schema}" src="zimg\/black-300.gif"><\/td><\/tr>\
<\/table>\
<\/div>\
/g
	/^[ 	]*</!s/.*/<tr> <td><\/td><td class="zed" colspan=2>&<\/td><\/tr>/
	s/\\also/<img width=1 height=10 align=bottom alt=" " src="zimg\/clear.gif">/
}

# Generic definition box

/\\begin{gendef}\[.*\]/,/\\end{gendef}/ {
	s/\\begin{gendef}\[\(.*\)\]/<div class="zed">\
<table border=0 cellpadding=0 cellspacing=0>\
<tr> <td><img alt="!begin{gendef}" src="zimg\/clear.gif"><\/td>\
     <td><\/td><td class="zed">\[\1\]<\/td>\
     <td><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td width=1 rowspan=99 bgcolor=black><br><\/td><\/tr>\
<tr> <td width=10 height=1 bgcolor=black><img width=10 height=1 alt=" " src="zimg\/black-10.gif"><\/td>\
     <td height=1><img alt=" " src="zimg\/clear.gif"><\/td>\
     <td width=200 height=1 bgcolor=black><img width=200 height=1 alt=" " src="zimg\/black-200.gif"><\/td><\/tr>\
<tr> <td height=3><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td width=10 height=1 bgcolor=black><img width=10 height=1 alt=" " src="zimg\/black-10.gif"><\/td>\
     <td height=1><img alt=" " src="zimg\/clear.gif"><\/td>\
     <td width=200 height=1 bgcolor=black><img width=200 height=1 alt=" " src="zimg\/black-200.gif"><\/td><\/tr>\
<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>/g
	s/\\where/<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td height=1 bgcolor=black><img width=10 height=1 alt="!where" src="zimg\/black-10.gif"><\/td>\
      <td height=1 bgcolor=black><img width=15 height=1 alt=" " src="zimg\/black-15.gif"><\/td>\
      <td height=1><img width=75 height=1 alt=" " src="zimg\/black-75.gif"><\/td><\/tr>\
<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>/g
	s/\\end{gendef}/<tr> <td height=10><img alt=" " src="zimg\/clear.gif"><\/td><\/tr>\
<tr> <td colspan=3 bgcolor=black><img width=300 height=1 alt="!end{gendef}" src="zimg\/black-300.gif"><\/td><\/tr>\
<\/table>\
<\/div>\
/g
	/^[ 	]*</!s/.*/<tr> <td><\/td><td class="zed"  colspan=2>&<\/td><\/tr>/
	s/\\also/<img width=1 height=10 align=bottom alt=" " src="zimg\/clear.gif">/
}

# White space: line break, tab, space, indents

s/\\\\//g
s/	//g
s/~/\&nbsp;/g
s/\\t\([1-9]\)/<img width=\10 height=1 align=bottom alt="    " src="zimg\/clear.gif">/


# Logic

# We use ! not LaTeX \ inside alt="..." to avoid confusion
# between LaTeX commands we want to replace and literal text we want in alt=
# Replace all ! with \ at end of the script, after all LaTeX cmds processed

s/\\lnot/<img width=7 height=7 alt="!lnot" src="zimg\/lnot-m.gif">/g
s/\\land/<img width=8 height=7 alt="!land" src="zimg\/land-m.gif">/g
s/\\lor/<img width=8 height=7 alt="!lor" src="zimg\/lor-m.gif">/g
s/\\implies/<img width=13 height=7 alt="!implies" src="zimg\/implies-m.gif">/g
s/\\iff/<img width=13 height=7 alt="!iff" src="zimg\/iff-m.gif">/g
s/\\forall/<img width=9 height=10 alt="!forall" src="zimg\/forall-m.gif">/g
s/@/<img width=7 height=7 alt="@" src="zimg\/spot-m.gif">/g
s/\\exists/<img width=6 height=10 alt="!exists" src="zimg\/exists-m.gif">/g
s/\\vdash/<img width=8 height=11 alt="!vdash" src="zimg\/vdash-m.gif">/g
s/\\models/<img width=8 height=11 alt="!models" src="zimg\/models-m.gif">/g
s/\\LET/<b>let<\/b>/g

# LaTeX commands that begin with \in... must precede \in itself, ditto \cap

s/\\inrel{\([^}]*\)}/<u>\1<\/u>/g
s/\\inseq/<b>in<\/b>/g
s/\\inj/<img  width=14 height=8 alt="!inj" src="zimg\/inj-m.gif">/g
s/\\inv/<sup>~<\/sup>/g 
s/\\input/input/g
s/\\inbag/<img width=7 height=7 alt="!inbag" src="zimg\/inbag-m.gif">/g

s/\\caption/caption/g

# Sets and expressions

s/\\neq/<img width=7 height=7 alt="!neq" src="zimg\/neq-m.gif">/g
s/\\in/<img width=7 height=7 alt="!in" src="zimg\/in-m.gif">/g
s/\\notin/<img width=7 height=11 align=absbottom alt="!notin" src="zimg\/notin-m.gif">/g
s/\\emptyset/<img width=11 height=11 alt="!emptyset" src="zimg\/emptyset-m.gif">/g
s/\\subseteq/<img width=9 height=10 align=absbottom alt="!subseteq" src="zimg\/subseteq-m.gif">/g
s/\\subset/<img width=9 height=7 alt="!subset" src="zimg\/subset-m.gif">/g
s/\\{/{/g
s/\\}/}/g
s/\\lambda/<img width=8 height=10 alt="!lambda" src="zimg\/lambda-m.gif">/g
s/\\mu/<img width=7 height=10 alt="!mu" align=absbottom src="zimg\/mu-m.gif">/g
s/\\IF/<b>if<\/b>/g
s/\\THEN/<b>then<\/b>/g
s/\\ELSE/<b>else<\/b>/g
s/\\cross/<img width=7 height=7 alt="!cross" src="zimg\/cross-m.gif">/g
s/\\power/<img height=11 width=9 alt="!power" src="zimg\/power-m.gif">/g
s/\\finset/<img height=11 width=8 alt="!finset" src="zimg\/finset-m.gif">/g
s/\\cap/<img width=10 height=7 alt="!cap" src="zimg\/cap-m.gif">/g
s/\\cup/<img width=10 height=7 alt="!cup" src="zimg\/cup-m.gif">/g
s/\\bigcap/<img width=11 height=14 alt="!bigcap" align="absbottom" src="zimg\/bigcap-m.gif">/g
s/\\bigcup/<img width=11 height=14 alt="!bigcup" align="absbottom" src="zimg\/bigcup-m.gif">/g
s/\\setminus/\\/g

# Free types

s/\\ldata/<img width=8 height=14 align=absbottom alt="!ldata" src="zimg\/ldata-m.gif">/g
s/\\rdata/<img width=8 height=14 align=absbottom alt="!rdata" src="zimg\/rdata-m.gif">/g

# LaTeX commands that begin with \ran... must precede \ran itself

s/\\rangle/<img width=5 height=14 align=absbottom alt="!rangle" src="zimg\/rangle-m.gif">/g

# Relations, except \inrel and \inv must precede \in above

s/\\rel/<img width=13 height=8 alt="!rel" src="zimg\/rel-m.gif">/g
s/\\mapsto/<img height=9 width=10 alt="!mapsto" src="zimg\/mapsto-m.gif">/g
s/\\dom/<b>dom<\/b>/g
s/\\ran/<b>ran<\/b>/g
s/\\id/<b>id<\/b>/g
s/\\comp/<img width=6 height=12 alt="!comp" src="zimg\/comp-m.gif" align=absbottom>/g
s/\\circ/<img width=7 height=7 alt="!circ" src="zimg\/circ-m.gif">/g
s/\\dres/<img height=11 width=10 alt="!dres" src="zimg\/dres-m.gif">/g
s/\\ndres/<img height=11 width=10  alt="!ndres" src="zimg\/ndres-m.gif">/g
s/\\rres/<img height=11 width=10 alt="!rres" src="zimg\/rres-m.gif">/g
s/\\nrres/<img height=11 width=10 alt="!nrres" src="zimg\/nrres-m.gif">/g
s/\\limg/<img height=14 width=7 alt="!limg" src="zimg\/limg-m.gif" align=absbottom>/g
s/\\rimg/<img height=14 width=7 alt="!rimg" src="zimg\/rimg-m.gif" align=absbottom>/g
s/\\plus/<sup>+<\/sup>/g
s/\\star/<sup>*<\/sup>/g
s/\\oplus/<img width=9 height=9 alt="!oplus" src="zimg\/oplus-m.gif">/g

# Functions, except \inj must precede \in above

s/\\pfun/<img width=14 height=8 alt="!pfun" src="zimg\/pfun-m.gif">/g
s/\\fun/<img width=14 height=8 alt="!fun" src="zimg\/fun-m.gif">/g
s/\\pinj/<img width=14 height=8 alt="!pinj" src="zimg\/pinj-m.gif">/g
s/\\bij/<img width=14 height=8 alt="!bij" src="zimg\/bij-m.gif">/g
s/\\psurj/<img width=14 height=8 alt="!psurj" src="zimg\/psurj-m.gif">/g
s/\\surj/<img width=14 height=8 alt="!surj" src="zimg\/surj-m.gif">/g
s/\\ffun/<img width=14 height=8 alt="!ffun" src="zimg\/ffun-m.gif">/g
s/\\finj/<img width=14 height=8 alt="!finj" src="zimg\/finj-m.gif">/g

# Numbers and arithmetic

s/\\#/#/g
s/_1/<sub><font size=-3>1<\/font><\/sub>/g
s/_2/<sub><font size=-3>2<\/font><\/sub>/g
s/_3/<sub><font size=-3>3<\/font><\/sub>/g
s/\\num/<img height=11 width=10 alt="!num" src="zimg\/num-m.gif">/g
s/\\nat/<img height=11 width=10 alt="!nat" src="zimg\/nat-m.gif">/g
s/\\div/<b>div<\/b>/g
s/\\mod/<b>mod<\/b>/g
s/\\leq/<img width=7 height=9 alt="!leq" src="zimg\/leq-m.gif">/g
s/\\geq/<img width=7 height=9 alt="!geq" src="zimg\/geq-m.gif">/g
s/\\upto/\.\./g

# Sequences, except \inseq must precede \in above, \rangle preced \ran

s/\\seq/seq/g
s/\\iseq/iseq/g
s/\\langle/<img width=5 height=14 align=absbottom alt="!langle" src="zimg\/langle-m.gif">/g
s/\\cat/<img width=12 height=11 alt="!cat" src="zimg\/cat-m.gif">/g
s/\\dcat/<img width=17 height=14 align=absbottom alt="!dcat" src="zimg\/dcat-m.gif">/g
s/\\prefix/<b>prefix<\/b>/g
s/\\suffix/<b>suffix<\/b>/g
s/\\partition/<b>partition<\/b>/g
s/\\disjoint/<b>disjoint<\/b>/g
s/\\extract/<img width=5 height=14 align=absbottom alt="!extract" src="zimg\/extract-m.gif">/g
s/\\filter/<img width=5 height=14 align=absbottom alt="!filter" src="zimg\/filter-m.gif">/g

# Bags - except \inbag must precede \in, above

s/\\bag/bag/g
s/\\lbag/<img width=7 height=14 align=absbottom alt="!lbag" src="zimg\/lbag-m.gif">/g
s/\\rbag/<img width=7 height=14 align=absbottom alt="!rbag" src="zimg\/rbag-m.gif">/g
s/\\bcount/<img width=5 height=14 align=absbottom alt="!bcount" src="zimg\/bcount-m.gif">/g
s/\\otimes/<img width=9 height=9 alt="!otimes" src="zimg\/otimes-m.gif">/g
s/\\subbageq/<img width=9 height=10 align=absbottom alt="!subbageq" src="zimg\/subbageq-m.gif">/g
s/\\uplus/<img width=11 height=7 alt="!uplus" src="zimg\/uplus-m.gif">/g
s/\\uminus/<img width=11 height=7 alt="!uminus" src="zimg\/uminus-m.gif">/g

# Schema calculus

s/\\defs/<img height=11 width=11 alt="!defs" src="zimg\/defs-m.gif">/g
s/\\theta/<img width=5 height=10 alt="!theta" src="zimg\/theta-m.gif">/g
s/\\semi/<img width=6 height=12 alt="!semi" align=absbottom src="zimg\/comp-m.gif">/g
s/\\project/<img width=5 height=14 align=absbottom alt="!project" src="zimg\/filter-m.gif">/g
s/\\pipe/\&gt;\&gt;/g
s/\\hide/\\/g
s/\\pre/<b>pre<\/b>/g
s/\\lblot/<img width=5 height=14 align=absbottom alt="!lblot" src="zimg\/lblot-m.gif">/g
s/\\rblot/<img width=5 height=14 align=absbottom alt="!rblot" src="zimg\/rblot-m.gif">/g

# Conventions

s/\\Delta/<img width=7 height=10 alt="!Delta" src="zimg\/Delta-m.gif">/g
s/\\Xi/<img width=9 height=10 alt="!Xi" src="zimg\/Xi-m.gif">/g

# LaTeX stuff

# Translate these first because they can occur inside section headings etc.

s/{\\em \([^}]*\)}/<em>\1<\/em>/g
s/{\\bf \([^}]*\)}/<b>\1<\/b>/g
s/{\\tt \([^}]*\)}/<tt>\1<\/tt>/g
s/\\mbox{\([^}]*\)}/\1/g

# Citations
s/\\cite{\([^}]*\)}/\[\1\]/g

# Labels often occur on same line as section headings so translate them first
#s/\\label{\(.*\)}/<a name="\1">\1<\/a>/g

# For now just get rid of labels
s/\\label{[^}]*}//g

# For now just show refs in [...].  Possibly support cross-ref links later.
#s/\\ref{\(.*\)}/<a href=\#"\1">\1<\/a>/g
s/\\ref{\([^}]*\)}/[\1]/g

s/\\chapter{\([^}]*\)}/<h1>\1<\/h1>/g
s/\\section{\([^}]*\)}/<h2><a name="\1">\1<\/a><\/h2>/g
s/\\section\*{\([^}]*\)}/<h2><a name="\1">\1<\/a><\/h2>/g
s/\\subsection{\([^}]*\)}/<h3><a name="\1">\1<\/a><\/h3>/g
s/\\subsection\*{\([^}]*\)}/<h3><a name="\1">\1<\/a><\/h3>/g
s/\\subsubsection{\([^}]*\)}/<h4><a name="\1">\1<\/a><\/h4>/g
s/\\subsubsection\*{\([^}]*\)}/<h4><a name="\1">\1<\/a><\/h4>/g
s/\\footnote{\([^}]*\)}/ (\1)/g

# Put paragraph headings on a line by themselves so text is clearly informal
s/\\paragraph{\([^}]*\)}/<h4>\1<\/h4>\
\
/g

s/\\begin{quote}/<blockquote>/g
s/\\end{quote}/<\/blockquote>/g

# Just get rid of untranslated LaTeX environment directives for now
/^\\[^ 	]*{[^}]*}$/d
s/\\[^ 	]*{[^}]*}//g

s/\\footnote{\([^}]*\)$/ (\1/g
s/^\([^{}]*\)}/\1)/g

# s/\\.*{.*}//g -- This test is too weak, deletes legitimate Fuzz/LaTeX also

# Misc. LaTeX commands 
# Commands not explicitly handled in this script will appear verbatim in HTML

s/\\dots/.../g
s/\\ldots/.../g
s/\\_/_/g

# Get rid of \kill in \tabbing but keep the \kill lines
s/\\kill//g

# Get rid of these
/\\newpage/d

# Finally, replace ! with LaTeX prefix char \ inside alt="..."
s/alt="!/alt="\\/g

# Have a nice day.
