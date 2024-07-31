#!/bin/awk

BEGIN {

}

/^\*\*\*\* .XX..Use[0-9a-zA-Z]+ and [0-9]+ classes/ {
    THIS_GC=substr($2, 9) # cut leading "-XX:+Use"
    if (THIS_GC != GC) {
        # First line for this gc
        # close off old results
        if (GC != "") {
            write_all_files(GC)
        }
        GC=THIS_GC
    }
    NUM_CLASSES=$4
}

function write_all_files(gc_) {
            print_outfile(GC_SUM_PAUSES, GC, "gc_times")
            delete GC_SUM_PAUSES
            print_outfile(L1_MISSES, GC, "l1_misses")
            delete L1_MISSES
            print_outfile(L1_LOADS, GC, "l1_loads")
            delete L1_LOADS
}

function print_outfile(array_, gc_, what_) {
    FILENAME="auswertung/" gc_ "_" what_ ".csv"
    print "Writing " FILENAME
    print "num_classes,A,B,C" > FILENAME
    for (num_classes in array_) {
        print num_classes", "\
        array_[num_classes]["A"]", "\
        array_[num_classes]["B"]", "\
        array_[num_classes]["C"] > FILENAME
    }
}

# scrape L1 misses

/^[ABC] \(.*\) perf data:/ {
    ABC=$1
}

/[\t ]*[0-9]+[\t ]+L1-dcache-load-misses/ {
    L1_MISSES[NUM_CLASSES][ABC]=$1
}

/[\t ]*[0-9]+[\t ]+L1-dcache-loads/ {
    L1_LOADS[NUM_CLASSES][ABC]=$1
}


# scrape GC times

# Format 
# A (jdk-v4.2) gc times 
# count(field-1)  sum(field-1)    median(field-1) sstdev(field-1)
# 50      235005.19       4621.2835       393.55190145444
# B (jdk-v4.2) gc times 
# count(field-1)  sum(field-1)    median(field-1) sstdev(field-1)
# 50      195957.321      3831.8575       318.72206161399
# C (jdk-v4.2) gc times 
# count(field-1)  sum(field-1)    median(field-1) sstdev(field-1)
# 50      209236.976      4110.626        242.36299983022

/^[0-9]+/ {
    if (NR == GRAB_GC_TIMES_AT) {
        GRAB_GC_TIMES_AT=-1
        GC_SUM_PAUSES[NUM_CLASSES][ABC]=$2
    }
}

/^[ABC] \(.*\) gc times/ {
    ABC=$1
    GRAB_GC_TIMES_AT=NR+2
}

END {
    if (GC != "") {
        write_all_files(GC)
    }
}