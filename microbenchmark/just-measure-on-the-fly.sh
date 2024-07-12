export ISOLATE_CPUS_COMMAND=" "
export PERF_COMMAND=" perf stat  -B -e  L1-dcache-load-misses,L1-dcache-loads,LLC-load-misses,LLC-loads,dTLB-load-misses,dTLB-loads,instructions,branches "
#export PERF_COMMAND=" "
export JDK_A_NAME=jdk-v3
export JDK_B_NAME=jdk-v3
export JDK_C_NAME=jdk-v3

export OPTIONS_A="-XX:+UnlockExperimentalVMOptions -XX:+UseCompactObjectHeaders -XX:-UseKLUT"
export OPTIONS_B="-XX:+UnlockExperimentalVMOptions -XX:+UseCompactObjectHeaders -XX:+UseKLUT"
export OPTIONS_C=" "



export USEGC="-XX:+UseParallelGC"

export NUM_CLASSES=1024
export NUM_FULL_GC=10

bash ./measure.sh

