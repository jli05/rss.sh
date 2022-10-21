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
from sys import stdin, stderr
import xml.etree.ElementTree as ET
tree = ET.fromstring(stdin.read())

from pandas import to_datetime
n = 0
for item in tree.iter('item'):
    print(str(to_datetime(item.find('pubDate').text)), end='\t')
    print(item.find('title').text, end='\t')
    print(item.find('link').text)
    n += 1
if not n:
    print('0 items', file=stderr)
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


IFS=
while read -r line
do
  if [ -z "$line" ]
  then
    continue
  fi
  case "$line" in
    (\#*) continue ;;
  esac
  echo "$line" >&2
  curl -sS "$line"|python3 $SCRIPT
done <$FILE|awk -F '\t' -v date=$DATE '$1 ~ /....-..-../ && $1 >= date'|sort -t '\t' -k 1 -r|uniq|awk -F '\t' 'BEGIN { } { print "<p><b>" $2 "</b><br><a href=\"" $3 "\">" $3 "</a><br>" $1 "</p>" } END { print "</html>" }' >>$OUTPUT
cp $OUTPUT /tmp/rss.html; open /tmp/rss.html
