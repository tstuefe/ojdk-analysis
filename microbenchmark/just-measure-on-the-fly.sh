export ISOLATE_CPUS_COMMAND="chrt -r 1 taskset 0xFF00  "
#xport ISOLATE_CPUS_COMMAND=" "
export PERF_COMMAND=" perf stat  -B -e  L1-dcache-load-misses,L1-dcache-loads,LLC-load-misses,LLC-loads,dTLB-load-misses,dTLB-loads,instructions,branches "
#export PERF_COMMAND=" "

export JDK_A_NAME="jdk-v4-1"
export JDK_B_NAME=$JDK_A_NAME
export JDK_C_NAME=$JDK_A_NAME


export OPTIONS_A="-XX:+UnlockExperimentalVMOptions -XX:+UseCompactObjectHeaders -XX:-UseKLUT"
export OPTIONS_B="-XX:+UnlockExperimentalVMOptions -XX:+UseCompactObjectHeaders -XX:+UseKLUT"
export OPTIONS_C=" "

export TESTCLASSES_IN_BOOT_CLASSPATH="0"

export USEGC="-XX:+UseParallelGC"
#export USEGC="-XX:+UseG1GC"

#export NUM_CLASSES=1024
export NUM_CLASSES=1024
export NUM_FULL_GC=10

#export EXTRA_TEST_OPTIONS=" --wire-up"

bash ./measure.sh

