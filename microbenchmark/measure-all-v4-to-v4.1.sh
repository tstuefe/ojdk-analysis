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

export OPTIONS_A="-XX:+UnlockExperimentalVMOptions -XX:+UseCompactObjectHeaders -XX:+UseKLUT "
export OPTIONS_B=$OPTIONS_A

export JDK_A_NAME="jdk-v4"
export JDK_B_NAME="jdk-v4.1"
export JDK_C_NAME="jdk-v3"

export TESTCLASSES_IN_BOOT_CLASSPATH="0"

for USEGC in "-XX:+UseParallelGC" "-XX:+UseG1GC" ; do
	export USEGC
	for NUM_CLASSES in 16 64 256 1024 4096 16384 ; do
		echo "____${USEGC}___${NUM_CLASSES_classes}____" >> "$BASE_LOG"
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


