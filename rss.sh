#!/bin/sh

if [ $# -ne 1 ]
then
  echo "usage: $0 -<val>[ymwdHMS]" >&2
  exit 2
fi

FILE=$(mktemp /tmp/rss.urls.XXXXXX)
SCRIPT=$(mktemp /tmp/rss.py.XXXXXX)
OUTPUT=$(mktemp /tmp/rss.html.XXXXXX)

cat >$FILE <<EOF
# Add your RSS feed URLs here
EOF

cat >$SCRIPT <<EOF
from sys import stdin
import xml.etree.ElementTree as ET
tree = ET.fromstring(''.join(stdin.readlines()))

from pandas import to_datetime
for item in tree.iter('item'):
    print(str(to_datetime(item.find('pubDate').text)), end='\t')
    print(item.find('title').text, end='\t')
    print(item.find('link').text)
EOF

cat >$OUTPUT <<EOF
<!DOCTYPE html>
<html lang="en">
<meta charset="utf-8">
<link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
EOF

if [ $(uname) = "Darwin" ]
then
  DATE=$(date -j -v $1 '+%Y-%m-%d')
else
  DATE=$(date -I -d $1)
fi
cat $FILE|sed '/^#/d'|xargs -n 1 -I {} sh -c "curl -sS \"{}\"|python3 $SCRIPT"|awk -F '\t' -v date=$DATE '$1 ~ /....-..-../ && $1 >= date'|sort -t '\t' -k 1 -r|uniq|awk -F '\t' 'BEGIN { } { print "<p><b>" $2 "</b><br><a href=\"" $3 "\">" $3 "</a><br>" $1 "</p>" } END { print "</html>" }' >>$OUTPUT
cp $OUTPUT /tmp/rss.html; open /tmp/rss.html
