#!/bin/sh

DATE=$(python3 -c "from pandas import Timestamp, Timedelta; print((Timestamp.now() - Timedelta('2D')).strftime('%Y-%m-%dT%H:%M:%S'))")

PROJDIR="$(dirname $0)"
cat "$PROJDIR"/urls.txt | NPROC=2 WGET="wget -q -O -" SINCE="$DATE" "$PROJDIR"/rss.sh
doas poweroff
