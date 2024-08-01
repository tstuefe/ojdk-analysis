CSV_FILE=ARG1
TITLE=ARG2
Y_AXIS_LABEL=ARG3
OUTPUT_FILE_PREFIX=ARG4


set encoding utf8

# line styles

#A
set style line  1 lt 1 lw 3 dt 1 lc rgb "black"

#B
set style line  2 lt 1 lw 3 dt 4 lc rgb '#ff6600' # darkish orange

#C
set style line  3 lt 1 lw 3 dt 3 lc rgb '#9966ff' # purple


# palette
set palette defined (\
0 '#352a87',\
1 '#0363e1',\
2 '#1485d4',\
3 '#06a7c6',\
4 '#38b99e',\
5 '#92bf73',\
6 '#d9ba56',\
7 '#fcce2e',\
8 '#f9fb0e')


# Standard border
set border 3 back lc rgb '#606060' lt 1 lw 1
set tics out nomirror

# Standard grid
set grid back lc rgb '#c0c0c0' lt 0 lw 1
#unset grid

PNGFONT="FreeSerif, 12"
SVGFONT="FreeSerif, 14"

########################################

set datafile separator ','

set key autotitle columnhead outside opaque # use the first line as title

set ylabel Y_AXIS_LABEL # label for the Y axis
set xlabel 'Number of Classes' # label for the X axis


# First generate plot with absolute numbers

set title "{/*1.5".TITLE."}"
OUTPUTFILE = sprintf("%s.svg", OUTPUT_FILE_PREFIX)
set output OUTPUTFILE

# Note:
# 0 is the record number
# 1 is the number of classes (x axis)
# 2 is A
# 3 is B
# 4 is B to A
# 5 is C
# 6 is C to A

set yrange [0:*]
set terminal svg enhanced size 600,600 font SVGFONT background rgb 'white'

plot CSV_FILE \
  using 0:2:xticlabel(1) with lines ls 1, \
  '' using 0:3 with lines ls 2, \
  '' using 0:3:(sprintf("%.1f%%", $4)) with labels offset 0,-1 textcolor ls 2 notitle, \
  '' using 0:5 with lines ls 3


OUTPUTFILE = sprintf("%s.png", OUTPUT_FILE_PREFIX)
set output OUTPUTFILE
set terminal pngcairo size 600,600 font PNGFONT
set termoption dashlength 1.1

# For some reason pngcairo renders with lighter grays
set grid back lc rgb '#808080' lt 0 lw 1

plot CSV_FILE \
  using 0:2:xticlabel(1) with lines ls 1, \
  '' using 0:3 with lines ls 2, \
  '' using 0:3:(sprintf("%.1f%%", $4)) with labels offset 0,-1 textcolor ls 2 notitle, \
  '' using 0:5 with lines ls 3

