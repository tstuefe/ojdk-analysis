#!/bin/bash

set -e

BASE_DIR=$PWD
export BASE_DIR

if [ $# -ne 1 ]; then
	echo "Usage $0 <result dir to post-process>"
	exit -1
fi

pushd "$1"

BASE_LOG="${PWD}/all.log"
touch "$BASE_LOG"
if [ -f "$BASE_LOG" ]; then
	mv "$BASE_LOG" "${BASE_LOG}.old"
fi

DIRS=`ls -d *GC*`

for a in $DIRS; do
	echo "Post-processing $a..."
	USEGC=`echo "$a" | sed 's/\([A-Za-z0-9]*GC\)-[0-9]*/\1/g'`
	NUM_CLASSES=`echo "$a" | sed 's/[A-Za-z0-9]*GC-\([0-9]*\)/\1/g'`
	echo "**** -XX:+Use${USEGC} and $NUM_CLASSES classes ****" >> "$BASE_LOG"
	pushd $a

	bash "${BASE_DIR}/measure.sh" "--only-post" >> "$BASE_LOG"

	popd
	
	
done

popd


