#!/bin/sh

# usage:
#
#   cat urls.txt | WGET="" SINCE="" S3_URI="" SNS_TOPIC="" rss.sh
#
# batch download and print RSS items

if [ -n "$NPROC" ]
then
  JOBS_FLAG="-P $NPROC"
fi

PROJDIR="$(dirname $0)"
OUTPUT=$(mktemp /tmp/rss.txt.XXXXXX)
ERROR=$(mktemp /tmp/rss.err.XXXXXX)

cat - | sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' | WGET="$WGET" SINCE="$SINCE" xargs -n 1 $JOBS_FLAG "$PROJDIR"/rss_items.sh 2>>$ERROR >>$OUTPUT

if [ -z "$S3_URI" -a -z "$SNS_TOPIC" ]
then
  cat $OUTPUT
  cat $ERROR >&2
else
  if [ -n "$S3_URI" ]
  then
    OUTPUT_DIR=$(mktemp -d /tmp/rss.XXXXXX)
    cp $OUTPUT $ERROR $OUTPUT_DIR
    aws s3 sync $OUTPUT_DIR $S3_URI
  fi
  if [ -n "$SNS_TOPIC" ]
  then
    cat $ERROR >>$OUTPUT
    aws sns publish --topic-arn $SNS_TOPIC --subject "rss" --message file://$OUTPUT
  fi
fi
