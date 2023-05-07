#!/bin/sh

PROJDIR=$(dirname $0)
$PROJDIR/rss.sh -2d
sudo shutdown +0
