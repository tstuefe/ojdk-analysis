
# Env vars:
# JDK_A_NAME .. JDK_D_NAME: name of jdk dir
# OPTIONS_A .. OPTIONS_D: optional options for JVM A..D
# NUM_CLASSES: number of classes (default 8192)
# TESTCLASSES_IN_BOOT_CLASSPATH ("1" or "0")
# NUM_OBJEXTS: how many objects in total, default is 64 mio
# USEGC: which GC to use (literally, the -XX:+UseXX option) (default G1)
# NUM_FULL_GC: How many GCs (default 100)
# PERF_COMMAND: Perf stat line, optional
# ISOLATE_CPUS_COMMAND: cpu isolation. Defaults to isolation on core 8..15

ONLY_POST_PROCESSING=0
if [[ "$#" -eq 1 ]]; then
	if [[ "$1" == "--only-post" ]]; then
		echo "Only post processing..."
		ONLY_POST_PROCESSING=1
	fi
	
fi

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# The "microbenchmark" dir
BASE_DIR=${SCRIPTPATH}

# A +COH
JDK_A_NAME_DEFAULT="jdk-v4.2"
OPTIONS_A_DEFAULT="-XX:+UnlockExperimentalVMOptions -XX:+UseCompactObjectHeaders -XX:-UseKLUT "

# B: +COH +LUT
JDK_B_NAME_DEFAULT=$JDK_A_NAME_DEFAULT
OPTIONS_B_DEFAULT="-XX:+UnlockExperimentalVMOptions -XX:+UseCompactObjectHeaders -XX:+UseKLUT "

# C: Stock (-COH)
JDK_C_NAME_DEFAULT=$JDK_A_NAME_DEFAULT
OPTIONS_C_DEFAULT=" "

JDK_A_NAME=${JDK_A_NAME:-$JDK_A_NAME_DEFAULT}
JDK_B_NAME=${JDK_B_NAME:-$JDK_B_NAME_DEFAULT}
JDK_C_NAME=${JDK_C_NAME:-$JDK_C_NAME_DEFAULT}

OPTIONS_A=${OPTIONS_A:-$OPTIONS_A_DEFAULT}
OPTIONS_B=${OPTIONS_B:-$OPTIONS_B_DEFAULT}
OPTIONS_C=${OPTIONS_C:-$OPTIONS_C_DEFAULT}

JDK_A="${BASE_DIR}/../${JDK_A_NAME}"
JDK_B="${BASE_DIR}/../${JDK_B_NAME}"
JDK_C="${BASE_DIR}/../${JDK_C_NAME}"

# large ccs, to enforce largest possible shift
COMMON_OPTIONS="-XX:+UseLargePages -Xshare:off -Xmx6g -Xms6g -XX:+AlwaysPreTouch -XX:MetaspaceSize=3g -Xlog:gc -Xlog:metaspace* -XX:CompressedClassSpaceSize=3g "

export LC_NUMERIC=en_US.UTF-8
export LANG=en_US.UTF-8

# test options
NUM_CLASSES=${NUM_CLASSES:-"1024"}
NUM_OBJECTS=${NUM_OBJECTS:-"67108864"}
NUM_FULL_GC=${NUM_FULL_GC:-"10"}

CLASSPATH="${BASE_DIR}/the-test/target/repros8-1.0.jar"

# Location of test jar
TESTJAR="${BASE_DIR}/the-test/generated-test-sources/TESTDATA.jar"

# set to "1" to load test data from boot class path, to "0" to load from normal class path
TESTCLASSES_IN_BOOT_CLASSPATH=${TESTCLASSES_IN_BOOT_CLASSPATH:-"1"}
if [ "$TESTCLASSES_IN_BOOT_CLASSPATH" == "1" ]; then
	BOOTCLASSPATH_OPTION="-Xbootclasspath/a:${TESTJAR}"
else
	CLASSPATH="${CLASSPATH}:${TESTJAR}"
fi


TEST_OPTIONS="-C $NUM_CLASSES -n $NUM_OBJECTS --cycles $NUM_FULL_GC -y --nowait ${EXTRA_TEST_OPTIONS}"

# GC
USEGC=${USEGC:-"-XX:+UseParallelGC"}

# isolate to Cpus 8 to 15
ISOLATE_CPUS_COMMAND_DEFAULT="chrt -r 1 taskset 0xFF00 "
ISOLATE_CPUS_COMMAND=${ISOLATE_CPUS_COMMAND:-$ISOLATE_CPUS_COMMAND_DEFAULT}

# Perf command
PERF_COMMAND_DEFAULT=" perf stat  -B -e  L1-dcache-load-misses,L1-dcache-loads,LLC-load-misses,LLC-loads,dTLB-load-misses,dTLB-loads,instructions,branches "
PERF_COMMAND=${PERF_COMMAND:-$PERF_COMMAND_DEFAULT}

PRECOMMAND="$ISOLATE_CPUS_COMMAND $PERF_COMMAND "

# $1 A B or C
# $2 jdk path
# $3 jdk options
function run() {
	local LETTER=$1
	local JDK=$2
	local OPTIONS=$3
	COMMAND="${JDK}/bin/java  ${USEGC} ${COMMON_OPTIONS} ${OPTIONS} ${BOOTCLASSPATH_OPTION} -cp ${CLASSPATH} de.stuefe.repros.metaspace.StressGCWithManyClasses $TEST_OPTIONS"
	echo "Running $PRECOMMAND $COMMAND"
	#/usr/bin/time -f="%e" -a -o times-run${LETTER}.txt $PRECOMMAND  $COMMAND  >> outlog-${LETTER}.txt
	$PRECOMMAND  $COMMAND  >> outlog-${LETTER}.txt 2>>errlog-${LETTER}.txt
}

if [[ $ONLY_POST_PROCESSING -eq 0 ]]; then
	# remove logs from earlier runs
	rm outlog*
	rm errlog*
	rm times-run*
	rm gc-times*

	run C "${JDK_C}" "${OPTIONS_C}"
	run B "${JDK_B}" "${OPTIONS_B}"
	run A "${JDK_A}" "${OPTIONS_A}"
#	run D "${JDK_D}" "${OPTION_D}"

fi


# $1 A B or C
# $2 description
function post_process_gc_times() {

	local LETTER=$1

	echo "${LETTER} ($2) gc times "

	# Filter out warmup phase, we only want to examine the explicitly issued full gcs
	awk "BEGIN {IN=0} /will start GCs\.\.\./ {IN=1} /after GCs\.\.\./ {IN=0} { if (IN==1) print }" < outlog-${LETTER}.txt > outlog-${LETTER}-no-warmup.txt

	# Now scan for GC pauses 
	ack '\[gc.*GC\(.*Pause .*ms$' outlog-${LETTER}-no-warmup.txt | sed 's/.* \([0-9\.,]*\)ms/\1/g' > gc-times-${LETTER}.txt
	datamash --header-out count 1 sum 1 median 1 sstdev 1 < gc-times-${LETTER}.txt 
}

function post_process_gc_times_all() {
	post_process_gc_times A "$JDK_A_NAME"
	post_process_gc_times B "$JDK_B_NAME"
	post_process_gc_times C "$JDK_C_NAME"
#	post_process_gc_times D "$JDK_D_NAME"

	A_sum=`datamash sum 1 < gc-times-A.txt`

	B_sum=`datamash sum 1 < gc-times-B.txt`
	B_TO_A_sum=`echo "scale=2; ($B_sum * 100) / $A_sum" | bc`
	C_sum=`datamash sum 1 < gc-times-C.txt`
	C_TO_A_sum=`echo "scale=2; ($C_sum * 100) / $A_sum" | bc`
#	D_sum=`datamash sum 1 < gc-times-D.txt`
#	D_TO_A_sum=`echo "scale=2; ($D_sum * 100) / $A_sum" | bc`
	echo "GC Times, Sum, B to A: $B_TO_A_sum%"
	echo "GC Times, Sum, C to A: $C_TO_A_sum%"
#	echo "GC Times, Sum, D to A: $D_TO_A_sum%"

	A_median=`datamash median 1 < gc-times-A.txt`
	A_sstdev=`datamash sstdev 1 < gc-times-A.txt`
	A_sstdev_perc=`echo "scale=2; ($A_sstdev * 100) / $A_median" | bc`
	echo "GC Times, Standard Deviation, A: +-$A_sstdev (+-$A_sstdev_perc%)"
}


post_process_gc_times_all

# $1 A B or C
# $2 description
function post_process_perf_L1_hits() {

	local LETTER=$1

	echo "${LETTER} ($2) perf data: "

	# eg
	# 88     11,812,788,352      L1-dcache-load-misses     #    3.60% of all L1-dcache accesses                                                                                                                                                               
    # 89    328,052,346,403      L1-dcache-loads

    # Note that unlike gc pauses, there should be only a single entry, since we explitly delete output-ABC before
    # every run

    local L1_MISSES_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* L1-dcache-load-misses'`
    echo "    $L1_MISSES_LINE"

    local L1_LOADS_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* L1-dcache-loads'`
    echo "    $L1_LOADS_LINE"

	local LLC_MISSES_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* LLC-load-misses'`
    echo "    $LLC_MISSES_LINE"

    local LLC_LOADS_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* LLC-loads'`
    echo "    $LLC_LOADS_LINE"

    local dTLB_MISSES_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* dTLB-load-misses'`
    echo "    $dTLB_MISSES_LINE"

    local dTLB_LOADS_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* dTLB-loads'`
    echo "    $dTLB_LOADS_LINE"

    local INSTRUCTIONS_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* instructions '`
    echo "    $INSTRUCTIONS_LINE"

    local BRANCHES_LINE=`cat "errlog-${LETTER}.txt" | ack ' *[0-9,.]* branches '`
    echo "    $BRANCHES_LINE"

    echo "$L1_MISSES_LINE" | sed 's/ *\([0-9,.]*\) L1-dcache-load-misses.*/\1/g' | sed 's/[.,]//g' > "perf-l1-misses-${LETTER}.txt"
    echo "$L1_LOADS_LINE" | sed 's/ *\([0-9,.]*\) L1-dcache-loads.*/\1/g' | sed 's/[.,]//g' > "perf-l1-loads-${LETTER}.txt"

    echo "$LLC_MISSES_LINE" | sed 's/ *\([0-9,.]*\) LLC-load-misses.*/\1/g' | sed 's/[.,]//g' > "perf-llc-misses-${LETTER}.txt"
    echo "$LLC_LOADS_LINE" | sed 's/ *\([0-9,.]*\) LLC-loads.*/\1/g' | sed 's/[.,]//g' > "perf-llc-loads-${LETTER}.txt"

    echo "$dTLB_MISSES_LINE" | sed 's/ *\([0-9,.]*\) dTLB-load-misses.*/\1/g' | sed 's/[.,]//g' > "perf-dTLB-misses-${LETTER}.txt"
    echo "$dTLB_LOADS_LINE" | sed 's/ *\([0-9,.]*\) dTLB-loads.*/\1/g' | sed 's/[.,]//g' > "perf-dTLB-loads-${LETTER}.txt"

    echo "$INSTRUCTIONS_LINE" | sed 's/ *\([0-9,.]*\) instructions.*/\1/g' | sed 's/[.,]//g' > "perf-instructions-${LETTER}.txt"
    echo "$BRANCHES_LINE" | sed 's/ *\([0-9,.]*\) branches.*/\1/g' | sed 's/[.,]//g' > "perf-branches-${LETTER}.txt"

}

function post_process_perf_times_all() {
	post_process_perf_L1_hits A "$JDK_A_NAME"
	post_process_perf_L1_hits B "$JDK_B_NAME"
	post_process_perf_L1_hits C "$JDK_C_NAME"
#	post_process_perf_L1_hits D "$JDK_D_NAME"

	# make perce
	local A_l1_misses=`cat perf-l1-misses-A.txt`
	if [ -z "$A_l1_misses" ]; then return; fi
 	local B_l1_misses=`cat perf-l1-misses-B.txt`
	local B_TO_A_l1_misses=`echo "scale=2; ($B_l1_misses * 100) / $A_l1_misses" | bc`
	echo "L1 Misses, B to A: $B_TO_A_l1_misses%"
	local C_l1_misses=`cat perf-l1-misses-C.txt`
	local C_TO_A_l1_misses=`echo "scale=2; ($C_l1_misses * 100) / $A_l1_misses" | bc`
	echo "L1 Misses, C to A: $C_TO_A_l1_misses%"

	local A_l1_loads=`cat perf-l1-loads-A.txt`
	if [ -z "$A_l1_loads" ]; then return; fi
 	local B_l1_loads=`cat perf-l1-loads-B.txt`
	local B_TO_A_l1_loads=`echo "scale=2; ($B_l1_loads * 100) / $A_l1_loads" | bc`
	echo "L1 Loads, B to A: $B_TO_A_l1_loads%"
	local C_l1_loads=`cat perf-l1-loads-C.txt`
	local C_TO_A_l1_loads=`echo "scale=2; ($C_l1_loads * 100) / $A_l1_loads" | bc`
	echo "L1 Loads, C to A: $C_TO_A_l1_loads%"

	local A_llc_misses=`cat perf-llc-misses-A.txt`
	if [ -z "$A_llc_misses" ]; then return; fi
 	local B_llc_misses=`cat perf-llc-misses-B.txt`
	local B_TO_A_llc_misses=`echo "scale=2; ($B_llc_misses * 100) / $A_llc_misses" | bc`
	echo "LLC Misses, B to A: $B_TO_A_llc_misses%"
	local C_llc_misses=`cat perf-llc-misses-C.txt`
	local C_TO_A_llc_misses=`echo "scale=2; ($C_llc_misses * 100) / $A_llc_misses" | bc`
	echo "LLC Misses, C to A: $C_TO_A_llc_misses%"

	local A_llc_loads=`cat perf-llc-loads-A.txt`
	if [ -z "$A_llc_loads" ]; then return; fi
 	local B_llc_loads=`cat perf-llc-loads-B.txt`
	local B_TO_A_llc_loads=`echo "scale=2; ($B_llc_loads * 100) / $A_llc_loads" | bc`
	echo "LLC Loads, B to A: $B_TO_A_llc_loads%"
	local C_llc_loads=`cat perf-llc-loads-C.txt`
	local C_TO_A_llc_loads=`echo "scale=2; ($C_llc_loads * 100) / $A_llc_loads" | bc`
	echo "LLC Loads, C to A: $C_TO_A_llc_loads%"

	local A_dTLB_misses=`cat perf-dTLB-misses-A.txt`
	if [ -z "$A_dTLB_misses" ]; then return; fi
 	local B_dTLB_misses=`cat perf-dTLB-misses-B.txt`
	local B_TO_A_dTLB_misses=`echo "scale=2; ($B_dTLB_misses * 100) / $A_dTLB_misses" | bc`
	echo "dTLB Misses, B to A: $B_TO_A_dTLB_misses%"
	local C_dTLB_misses=`cat perf-dTLB-misses-C.txt`
	local C_TO_A_dTLB_misses=`echo "scale=2; ($C_dTLB_misses * 100) / $A_dTLB_misses" | bc`
	echo "dTLB Misses, C to A: $C_TO_A_dTLB_misses%"

	local A_dTLB_loads=`cat perf-dTLB-loads-A.txt`
	if [ -z "$A_dTLB_loads" ]; then return; fi
 	local B_dTLB_loads=`cat perf-dTLB-loads-B.txt`
	local B_TO_A_dTLB_loads=`echo "scale=2; ($B_dTLB_loads * 100) / $A_dTLB_loads" | bc`
	echo "dTLB Loads, B to A: $B_TO_A_dTLB_loads%"
	local C_dTLB_loads=`cat perf-dTLB-loads-C.txt`
	local C_TO_A_dTLB_loads=`echo "scale=2; ($C_dTLB_loads * 100) / $A_dTLB_loads" | bc`
	echo "dTLB Loads, C to A: $C_TO_A_dTLB_loads%"

	local A_instructions=`cat perf-instructions-A.txt`
	local B_instructions=`cat perf-instructions-B.txt`
	local B_TO_A_instructions=`echo "scale=2; ($B_instructions * 100) / $A_instructions" | bc`
	echo "Instructions, B to A: $B_TO_A_instructions%"
	local C_instructions=`cat perf-instructions-C.txt`
	local C_TO_A_instructions=`echo "scale=2; ($C_instructions * 100) / $A_instructions" | bc`
	echo "Instructions, C to A: $C_TO_A_instructions%"

	local A_branches=`cat perf-branches-A.txt`
	local B_branches=`cat perf-branches-B.txt`
	local B_TO_A_branches=`echo "scale=2; ($B_branches * 100) / $A_branches" | bc`
	echo "branches, B to A: $B_TO_A_branches%"
	local C_branches=`cat perf-branches-C.txt`
	local C_TO_A_branches=`echo "scale=2; ($C_branches * 100) / $A_branches" | bc`
	echo "branches, C to A: $C_TO_A_branches%"

}

post_process_perf_times_all

chown -R thomas *

