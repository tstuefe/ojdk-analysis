CSV_FILE=ARG1
TITLE=ARG2
Y_AXIS_LABEL=ARG3
OUTPUT_FILE_PREFIX=ARG4


set encoding utf8

# Colormap similar to Matlab parula, see:
# http://www.mathworks.de/products/matlab/matlab-graphics/#new_look_for_matlab_graphics

# line styles
set style line  1 lt 1 lc rgb '#352a87' # blue
set style line  2 lt 1 lc rgb '#0f5cdd' # blue
set style line  3 lt 1 lc rgb '#1481d6' # blue
set style line  4 lt 1 lc rgb '#06a4ca' # cyan
set style line  5 lt 1 lc rgb '#2eb7a4' # green
set style line  6 lt 1 lc rgb '#87bf77' # green
set style line  7 lt 1 lc rgb '#d1bb59' # orange
set style line  8 lt 1 lc rgb '#fec832' # orange
set style line  9 lt 1 lc rgb '#f9fb0e' # yellow

# New default Matlab line colors, introduced together with parula (2014b)
set style line 11 lt 1 lc rgb '#0072bd' # blue
set style line 12 lt 1 lc rgb '#d95319' # orange
set style line 13 lt 1 lc rgb '#edb120' # yellow
set style line 14 lt 1 lc rgb '#7e2f8e' # purple
set style line 15 lt 1 lc rgb '#77ac30' # green
set style line 16 lt 1 lc rgb '#4dbeee' # light-blue
set style line 17 lt 1 lc rgb '#a2142f' # red

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

set title TITLE
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
  using 0:2:xticlabel(1) with lines lc rgb "black" dt 1 lw 3, \
  '' using 0:3 with lines lc rgb "dark-green" dt 2 lw 3, \
  '' using 0:3:(sprintf("%.1f%%", $4)) with labels offset 0,-1 textcolor rgb "dark-green" notitle, \
  '' using 0:5 with lines lc rgb "blue" dt 3 lw 3


OUTPUTFILE = sprintf("%s.png", OUTPUT_FILE_PREFIX)
set output OUTPUTFILE
set terminal pngcairo size 600,600 font PNGFONT
set termoption dashlength 1.1

# For some reason pngcairo renders with lighter grays
set grid back lc rgb '#808080' lt 0 lw 1

plot CSV_FILE \
  using 0:2:xticlabel(1) with lines lc rgb "black" dt 1 lw 2, \
  '' using 0:3 with lines lc rgb "dark-green" dt 2 lw 2, \
  '' using 0:3:(sprintf("%.1f%%", $4)) with labels offset 0,-1 textcolor rgb "dark-green" notitle, \
  '' using 0:5 with lines lc rgb "blue" dt 3 lw 2

