# toc.sed - make table of contents from HTML output of z2html.sed

s/<h2><a name="\([^"]*\)">\([^<]*\)<\/a><\/h2>/<a href="#\1">\2<\/a><br>/p
s/<h3><a name="\([^"]*\)">\([^<]*\)<\/a><\/h3>/\&nbsp;\&nbsp;\&nbsp;\&nbsp;<a href="#\1">\2<\/a><br>/p
s/<h4><a name="\([^"]*\)">\([^<]*\)<\/a><\/h4>/\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;<a href="#\1">\2<\/a><br>/p
