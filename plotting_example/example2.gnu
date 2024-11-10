#!/usr/bin/gnuplot -persist
#
#
#

#!/usr/bin/gnuplot -persist

set title "Location data"
set xlabel "location"
set ylabel "count"
set grid
plot "loc.dat" u (column(0)):2:xtic(1) w l title "","loc.dat" u (column(0)):3:xtic(1) w l title ""
