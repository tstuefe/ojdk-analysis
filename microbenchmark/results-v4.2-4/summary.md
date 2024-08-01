# KlassLookupTable patch

- **A** Lilliput HEAD
- **B** Lilliput HEAD + KLUT patch
- **C** Mainline OpenJDK

Various metrics by number of classes

## Selected

### ParallelGC
![ParallelGC](./auswertung/ParallelGC-gc-pauses.svg) ![ParallelGC](./auswertung/ParallelGC-l1-misses.svg) ![ParallelGC](./auswertung/ParallelGC-tlb-misses.svg) ![ParallelGC](./auswertung/ParallelGC-tlb-loads.svg)

----------------

### G1GC
![G1GC](./auswertung/G1GC-gc-pauses.svg) ![G1GC](./auswertung/G1GC-l1-misses.svg)

![G1GC](./auswertung/G1GC-tlb-misses.svg) ![G1GC](./auswertung/G1GC-tlb-loads.svg)

----------------

### SerialGC
![SerialGC](./auswertung/SerialGC-gc-pauses.svg) ![SerialGC](./auswertung/SerialGC-l1-misses.svg)

![SerialGC](./auswertung/SerialGC-tlb-misses.svg) ![SerialGC](./auswertung/SerialGC-tlb-loads.svg)

----------------

## All

### ParallelGC
![ParallelGC](./auswertung/ParallelGC-gc-pauses.svg) 

![ParallelGC](./auswertung/ParallelGC-l1-misses.svg) ![ParallelGC](./auswertung/ParallelGC-l1-loads.svg) 

![ParallelGC](./auswertung/ParallelGC-tlb-misses.svg) ![ParallelGC](./auswertung/ParallelGC-tlb-loads.svg)

![ParallelGC](./auswertung/ParallelGC-instructions.svg) ![ParallelGC](./auswertung/ParallelGC-branches.svg)

### G1GC
![G1GC](./auswertung/G1GC-gc-pauses.svg)

![G1GC](./auswertung/G1GC-l1-misses.svg) ![G1GC](./auswertung/G1GC-l1-loads.svg)

![G1GC](./auswertung/G1GC-tlb-misses.svg) ![G1GC](./auswertung/G1GC-tlb-loads.svg)

![G1GC](./auswertung/G1GC-instructions.svg) ![G1GC](./auswertung/G1GC-branches.svg)

### SerialGC
![SerialGC](./auswertung/SerialGC-gc-pauses.svg)

![SerialGC](./auswertung/SerialGC-l1-misses.svg) ![SerialGC](./auswertung/SerialGC-l1-loads.svg)

![SerialGC](./auswertung/SerialGC-tlb-misses.svg) ![SerialGC](./auswertung/SerialGC-tlb-loads.svg)

![SerialGC](./auswertung/SerialGC-instructions.svg) ![SerialGC](./auswertung/SerialGC-branches.svg)


## Low pause collectors

### ShenandoahGC
![ShenandoahGC](./auswertung/ShenandoahGC-l1-misses.svg) ![ShenandoahGC](./auswertung/ShenandoahGC-l1-loads.svg)

![ShenandoahGC](./auswertung/ShenandoahGC-tlb-misses.svg) ![ShenandoahGC](./auswertung/ShenandoahGC-tlb-loads.svg)

![ShenandoahGC](./auswertung/ShenandoahGC-instructions.svg) ![ShenandoahGC](./auswertung/ShenandoahGC-branches.svg)

### ZGC
![ZGC](./auswertung/ZGC-l1-misses.svg) ![ZGC](./auswertung/ZGC-l1-loads.svg)

![ZGC](./auswertung/ZGC-tlb-misses.svg) ![ZGC](./auswertung/ZGC-tlb-loads.svg)

![ZGC](./auswertung/ZGC-instructions.svg) ![ZGC](./auswertung/ZGC-branches.svg)

