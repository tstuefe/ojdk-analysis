export ISOLATE_CPUS_COMMAND=" "
export PERF_COMMAND=" "
export JDK_A_NAME=jdk-with-oopmap-lu-table-v2
export JDK_B_NAME=jdk-with-oopmap-lu-table-v2

export USEGC="-XX:+UseParallelGC"

bash ./measure.sh

