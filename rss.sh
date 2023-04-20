#!/bin/sh

if [ $# -ne 1 ]
then
  echo "usage: $0 -<val>[ymwdHMS]" >&2
  exit 2
fi

#S3_URI="<uri>"
#SNS_TOPIC="<topic_arn>"

FILE=$(mktemp /tmp/rss.urls.XXXXXX)
SCRIPT=$(mktemp /tmp/rss.py.XXXXXX)
OUTPUT=$(mktemp /tmp/rss.txt.XXXXXX)
ERROR=$(mktemp /tmp/rss.err.XXXXXX)
OUTPUT_DIR=$(mktemp -d /tmp/rss.XXXXXX)

cat >$FILE <<EOF
# Add your RSS feed URLs here
EOF

cat >$SCRIPT <<EOF
from sys import stdin, stderr
import xml.etree.ElementTree as ET
tree = ET.fromstring(stdin.read())

NS = {'atom': 'http://www.w3.org/2005/Atom'}
from pandas import to_datetime
n = 0
if tree.tag.endswith('rss'):
    for item in tree.iter('item'):
        print(str(to_datetime(item.find('pubDate').text)), end='\t')
        print(item.find('title').text, end='\t')
        print(item.find('link').text)
        n += 1
elif tree.tag.endswith('feed'):
    for item in tree.iterfind('atom:entry', NS):
        print(str(to_datetime(item.find('atom:updated', NS).text)), end='\t')
        print(item.find('atom:title', NS).text, end='\t')
        print(item.find('atom:link', NS).attrib['href'])
        n += 1
else:
    raise NotImplementedError(tree.tag)
if not n:
    print('warning: 0 items', file=stderr)
EOF


if [ $(uname) = "Darwin" ]
then
  DATE=$(date -j -v $1 '+%Y-%m-%d')
else
  OFFS=$(echo $1|sed 's/d$/ days/')
  DATE=$(date -I -d "$OFFS")
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
  curl -sSL "$line"|python3 $SCRIPT
done <$FILE 2>>$ERROR|awk -F '\t' -v date=$DATE '$1 >= date'|sort -t '\t' -k 1 -r|uniq|awk -F '\t' '{ print $2; print $3; print $1; print " " }' >>$OUTPUT

cat $ERROR >>$OUTPUT
cp $OUTPUT $OUTPUT_DIR/rss.txt
if [ -n "$S3_URI" ]
then
  aws s3 sync $OUTPUT_DIR $S3_URI
fi
if [ -n "$SNS_TOPIC" ]
then
  aws sns publish --topic-arn $SNS_TOPIC --subject "rss" --message file://$OUTPUT
fi
