#!/usr/bin/gnuplot -c
#
#
# plotting the example1.gnu with the data.txt
#
#

set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 600, 400
set output 'output.png'
set style data  histogram
set style fill solid border -1
plot  for [i=2:3] '/dev/stdin' using i:xtic(1) title col
