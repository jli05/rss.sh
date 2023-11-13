#!/bin/sh

# usage:
#
#   WGET="" SINCE="" rss_items.sh url
#
# download and print RSS items from a single URL

if [ $# -ne 1 ]
then
  echo "usage: $0 url" >&2
  exit 2
fi

if [ -z "$WGET" ]
then
  echo 'WGET undefined' >&2
  exit 2
fi
if [ -z "$SINCE" ]
then
  echo 'SINCE undefined' >&2
  exit 2
fi

PROJDIR="$(dirname $0)"
URL="$1"

$WGET "$URL" | python3 "$PROJDIR"/rss_items.py --since="$SINCE"
