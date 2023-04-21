#!/bin/sh

# usage:
#   rss.sh [-<nnn>d]

#S3_URI="<uri>"
#SNS_TOPIC="<topic_arn>"

FILE=$(mktemp /tmp/rss.urls.XXXXXX)
OUTPUT=$(mktemp /tmp/rss.txt.XXXXXX)
ERROR=$(mktemp /tmp/rss.err.XXXXXX)
OUTPUT_DIR=$(mktemp -d /tmp/rss.XXXXXX)

cat >$FILE <<EOF
# Add your RSS feed URLs here
EOF

if [ $# -eq 1 ]
then
  if [ $(uname) = "Darwin" ]
  then
    DATE=$(date -j -v $1 '+%Y-%m-%d')
  else
    OFFS=$(echo $1|sed 's/d$/ days/')
    DATE=$(date -I -d "$OFFS")
  fi
  DATE_FLAG=--since=$DATE
fi

cat $FILE|python3 rss.py $DATE_FLAG 2>>$ERROR >>$OUTPUT

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
