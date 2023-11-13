#!/bin/sh

DATE=$(python3 -c "from pandas import Timestamp, Timedelta; print((Timestamp.now() - Timedelta('2D')).strftime('%Y-%m-%dT%H:%M:%S'))")

#S3_URI=""
#SNS_TOPIC=""

PROJDIR="$(dirname $0)"
cat "$PROJDIR"/urls.txt | NPROC=$(nproc) WGET="wget -q -O -" SINCE="$DATE" S3_URI="$S3_URI" SNS_TOPIC="$SNS_TOPIC" "$PROJDIR"/rss.sh
doas poweroff
