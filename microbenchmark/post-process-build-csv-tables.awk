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
            print_outfile(GC_SUM_PAUSES, GC, "gc-pauses")
            delete GC_SUM_PAUSES
            print_outfile(L1_MISSES, GC, "l1-misses")
            delete L1_MISSES
            print_outfile(L1_LOADS, GC, "l1-loads")
            delete L1_LOADS
            print_outfile(TLB_MISSES, GC, "tlb-misses")
            delete TLB_MISSES
            print_outfile(TLB_LOADS, GC, "tlb-loads")
            delete TLB_LOADS
            print_outfile(INSTRUCTIONS, GC, "instructions")
            delete INSTRUCTIONS
            print_outfile(BRANCHES, GC, "branches")
            delete BRANCHES
}

# Arguments:
# array_            : array to print (multidim by num classes and variant (ABC))
# gc_               : GC name
# what_             : short name of what we measured, eg "l1-misses"
# colname_prefix_   : Column name prefix of what we measured, eg "L1 Misses "
function print_outfile(array_, gc_, what_) {
    FILENAME="auswertung/" gc_ "-" what_ ".csv"
    print "Writing " FILENAME
    print "num_classes,A,B,B-to-A,C,C-to-A"\
           > FILENAME
    for (num_classes in array_) {
        VALA=array_[num_classes]["A"]
        VALB=array_[num_classes]["B"]
        VALC=array_[num_classes]["C"]
        VALB_TO_A = VALA > 0 ? (VALB * 100.0) / VALA : 0
        VALC_TO_A = VALC > 0 ? (VALC * 100.0) / VALA : 0
        printf "%d, %d, %d, %.2f, %d, %.2f,\n", num_classes, VALA, VALB, VALB_TO_A, VALC, VALC_TO_A > FILENAME
    }
}

# scrape scrape scrape

/^[ABC] \(.*\) perf data:/ {
    ABC=$1
}

/[\t ]*[0-9]+[\t ]+L1-dcache-load-misses/ {
    gsub(",", "") #replace thousand separator from perf output
    L1_MISSES[NUM_CLASSES][ABC]=$1
}

/[\t ]*[0-9]+[\t ]+L1-dcache-loads/ {
    gsub(",", "") #replace thousand separator from perf output
    L1_LOADS[NUM_CLASSES][ABC]=$1
}

/[\t ]*[0-9]+[\t ]+dTLB-load-misses/ {
    gsub(",", "") #replace thousand separator from perf output
    TLB_MISSES[NUM_CLASSES][ABC]=$1
}

/[\t ]*[0-9]+[\t ]+dTLB-loads/ {
    gsub(",", "") #replace thousand separator from perf output
    TLB_LOADS[NUM_CLASSES][ABC]=$1
}

/[\t ]*[0-9]+[\t ]+instructions/ {
    gsub(",", "") #replace thousand separator from perf output
    INSTRUCTIONS[NUM_CLASSES][ABC]=$1
}

/[\t ]*[0-9]+[\t ]+branches/ {
    gsub(",", "") #replace thousand separator from perf output
    BRANCHES[NUM_CLASSES][ABC]=$1
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