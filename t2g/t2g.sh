#!/bin/bash

PNG_FILE="temperature.png"

T_SOURCE=/var/log/temperatures.log

cat $T_SOURCE | grep `date +%Y-%m-%d` | cut -d";" -f 1,4 | cut -c 11- > today.csv
cat $T_SOURCE | grep `date --date="-1 day" +%Y-%m-%d` | cut -d";" -f 1,4 | cut -c 11- > yesterday.csv


/usr/bin/gnuplot <<EOF

# style
#set style fill solid border -1
#set style line 1 lt 2 lw 1

set title "Temperature - Celsius"
set xlabel "Date - Time"
set ylabel "Degree C"

set terminal png size 1024,400
set terminal png
set output "$PNG_FILE"

set xdata time
set timefmt "%H:%M.%S"
#set format x "%d %h\n%H:%M"
set format x "%H:%M"
#set yrange [ 4 : * ]
set grid x y
set datafile separator ";"

#plot "today.csv" using 1:2 title "temp" with lines lc rgb "red"
#plot "today.csv" using 1:2 title "temp" with points
#plot "today.csv" using 1:2 title "temp" with linespoints
#plot "today.csv" using 1:2 title "temp" with filledcurves y1=0

plot "today.csv" using 1:2 title "today" with linespoints lc rgb "red", "today.csv" using 1:2 title "today filled" with filledcurves y1=0 lc rgb "red", "yesterday.csv" using 1:2 title "yestarday" with linespoints lc rgb "blue"
#plot "today.csv" using 1:2 title "today" with filledcurves y1=0, "yesterday.csv" using 1:2 title "yestarday" with linespoints lc rgb "blue"

EOF


