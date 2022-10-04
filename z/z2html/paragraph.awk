# paragraph.awk
#
# Enclose nonblank, nontagged paragraphs in <p class="informal"> ... </p>
# Only process paragraphs in the <body> of the HTML page, not the <head>
#  to avoid messing up any embedded styles or other header information
# Add blank <p class="space"></p> between consecutive zed or mixed paragraphs
#
# 17-Jan-2000  J. Jacky  Add space paragraph between consecutive formal paras.

BEGIN {
  blank = 0; tagged = 1; informal = 2; formal = 3; # mnemonics
  curr = blank;
  para = informal;
  body = 0;
    }
{
  prev = curr;
  prev_para = para;

  if (!body && ($0 ~ /^[ 	]*<body>/)) body = 1; # entered page body

  curr = informal;
  if ($0 ~ /^[ 	]*$/) curr = blank;  # empty lines, also spaces and tabs
  if ($0 ~ /^[ 	]*</) curr = tagged; # allow leading spaces and tabs

  # Allow in-line text formatting tags at start of line in informal paragraphs
  if ($0 ~ /^[ 	]*<b>/) curr = informal;
  if ($0 ~ /^[ 	]*<em>/) curr = informal; 
  if ($0 ~ /^[ 	]*<tt>/) curr = informal;
  if ($0 ~ /^[ 	]*<var/) curr = informal;
  if ($0 ~ /^[ 	]*<font/) curr = informal;

  if (prev != informal && curr == informal && body) print "<p class=\"informal\">";
  if (prev == informal && curr != informal && body) print "</p>";

  # Assign para just to determine when we need spacer between formal paras.
  if (informal == curr) para = informal;
  if ($0 ~ /^[ 	]*<h/) para = tagged; # header tag like <h3> etc.
  # Do not assign para at blank line - retain previous para through blank lines

  # New formal paragraph  
  if (($0 ~ /<div class="zed">/) || ($0 ~ /<div class="mixed">/)) {
    para = formal;
    if (prev_para == formal) print "<p class=\"space\"></p>\n";
  }

  print $0;
}
END {
  if (curr == informal) print "</p>";  # informal last line, no blank after
}

