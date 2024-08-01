# KlassLookupTable patch

JDKs and Configs compared:
- **A** Lilliput HEAD
- **B** Lilliput HEAD + KLUT patch
- **C** Mainline OpenJDK

TOC

- [ParallelGC](#ParallelGC)
- [G1GC](#g1gc)
- [SerialGC](#SerialGC)
- [ShenandoahGC](#ShenandoahGC)
- [ZGC](#ZGC)

-----------------------

## ParallelGC

![](./auswertung/ParallelGC-gc-pauses.svg) 

![](./auswertung/ParallelGC-l1-misses.svg) ![](./auswertung/ParallelGC-l1-loads.svg) 

![](./auswertung/ParallelGC-llc-misses.svg) ![](./auswertung/ParallelGC-llc-loads.svg) 

![](./auswertung/ParallelGC-tlb-misses.svg) ![](./auswertung/ParallelGC-tlb-loads.svg)

![](./auswertung/ParallelGC-instructions.svg) ![](./auswertung/ParallelGC-branches.svg)


-----------------------

## G1GC

![](./auswertung/G1GC-gc-pauses.svg)

![](./auswertung/G1GC-l1-misses.svg) ![](./auswertung/G1GC-l1-loads.svg)

![](./auswertung/G1GC-llc-misses.svg) ![](./auswertung/G1GC-llc-loads.svg)

![](./auswertung/G1GC-tlb-misses.svg) ![](./auswertung/G1GC-tlb-loads.svg)

![](./auswertung/G1GC-instructions.svg) ![](./auswertung/G1GC-branches.svg)

-----------------------

## SerialGC

![](./auswertung/SerialGC-gc-pauses.svg)

![](./auswertung/SerialGC-l1-misses.svg) ![](./auswertung/SerialGC-l1-loads.svg)

![](./auswertung/SerialGC-llc-misses.svg) ![](./auswertung/SerialGC-llc-loads.svg)

![](./auswertung/SerialGC-tlb-misses.svg) ![](./auswertung/SerialGC-tlb-loads.svg)

![](./auswertung/SerialGC-instructions.svg) ![](./auswertung/SerialGC-branches.svg)

-----------------------

## ShenandoahGC

![](./auswertung/ShenandoahGC-l1-misses.svg) ![](./auswertung/ShenandoahGC-l1-loads.svg)

![](./auswertung/ShenandoahGC-llc-misses.svg) ![](./auswertung/ShenandoahGC-llc-loads.svg)

![](./auswertung/ShenandoahGC-tlb-misses.svg) ![](./auswertung/ShenandoahGC-tlb-loads.svg)

![](./auswertung/ShenandoahGC-instructions.svg) ![](./auswertung/ShenandoahGC-branches.svg)


-----------------------

## ZGC

![](./auswertung/ZGC-l1-misses.svg) ![](./auswertung/ZGC-l1-loads.svg)

![](./auswertung/ZGC-llc-misses.svg) ![](./auswertung/ZGC-llc-loads.svg)

![](./auswertung/ZGC-tlb-misses.svg) ![](./auswertung/ZGC-tlb-loads.svg)

![](./auswertung/ZGC-instructions.svg) ![](./auswertung/ZGC-branches.svg)

