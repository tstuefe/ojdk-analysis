set -e


# This script overrides
# - BASE_DIR
# - USEGC
# - NUM_CLASSES
# it leaves all other variables alone

BASE_DIR=$PWD
export BASE_DIR

TIMESTAMP=`date | tr ':_ ' '-' `
RESULTS_ROOT="results-$TIMESTAMP"
mkdir -p $RESULTS_ROOT
pushd $RESULTS_ROOT

BASE_LOG="$PWD/all.log"
touch "$BASE_LOG"

export TESTCLASSES_IN_BOOT_CLASSPATH="0"

export NUM_FULL_GC=50

for USEGC in "-XX:+UseSerialGC" "-XX:+UseParallelGC" "-XX:+UseG1GC" "-XX:+UseShenandoahGC" "-XX:+UseZGC"; do
#for USEGC in "-XX:+UseSerialGC"  ; do
	export USEGC
	for NUM_CLASSES in 16 64 256 1024 4096 16384 ; do
		echo "**** $USEGC and $NUM_CLASSES classes ****" >> "$BASE_LOG"
		export NUM_CLASSES

		GC_NAME=${USEGC:8}
		SUBDIR="$GC_NAME-$NUM_CLASSES"
		mkdir $SUBDIR
		pushd $SUBDIR
		
		bash "${BASE_DIR}/measure.sh" >> "$BASE_LOG"
		
		popd
	done

done

popd

chown -R thomas .


