#!/bin/bash

set -e

ALL_LOG="all.log"

if [ ! -f $ALL_LOG ]; then
	echo "$ALL_LOG not found"
	exit -1
fi

AUSWERTUNG_DIR="./auswertung"

if [ ! -d "$AUSWERTUNG_DIR" ]; then
	mkdir "$AUSWERTUNG_DIR"
fi

SCRIPT_DIR=$(dirname "$0")

gawk -f "${SCRIPT_DIR}/post-process-build-csv-tables.awk" < "$ALL_LOG"


for GC in SerialGC ParallelGC G1GC ShenandoahGC ZGC; do

	for what in gc-pauses l1-misses l1-loads tlb-misses tlb-loads instructions branches; do
		CSV_FILE="$AUSWERTUNG_DIR/${GC}-${what}.csv"

		if [ ! -f "$CSV_FILE" ]; then
			echo "$CSV_FILE not found, skipping..."
		else 

			case $what in
				"gc-pauses")
					what_nice="GC pauses, Sum, ms"
					;;
				"l1-misses") 
					what_nice="L1 Misses"
					;;
				"l1-loads")
					what_nice="L1 Loads"
					;;
				"tlb-misses") 
					what_nice="TLB Misses"
					;;
				"tlb-loads")
					what_nice="TLB Loads"
					;;
				"instructions")
					what_nice="Instructions"
					;;
				"branches") 
					what_nice="Branches"
					;;
			esac

			TITLE="$GC: $what_nice"
			Y_AXIS_LABEL="$what_nice"
			OUTPUT_FILE_PREFIX="${CSV_FILE%.*}"

			if [ "$GC" == "ZGC" -a "$what" == "gc-pauses" ]; then
				echo "skipping plot generation for ZGC GC pause"
			else
				gnuplot -c "${SCRIPT_DIR}/post-process-generate-charts.gnuplot" "$CSV_FILE" "$TITLE" "$Y_AXIS_LABEL" "$OUTPUT_FILE_PREFIX"  
			fi
		fi
	done

done

cp "${SCRIPT_DIR}/post-process-summary-template.md" "summary.md"

