//launch4

clearscreen.

set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
unlock THROTTLE.

	lock m to SHIP:MASS.
	lock g to SHIP:SENSORS:GRAV:MAG.
	lock w to m * g.
	lock p to SHIP:SENSORS:PRES / 100.
	lock maxThrust to SHIP:MAXTHRUSTAT(p).
	lock throt to THROTTLE.
	lock thrust to throt * maxThrust.
	lock twr to thrust / w.
	
global count is 0.
until SHIP:ALTITUDE > 70000
{
	if count > 9
	{
		clearscreen.
		set count to 0.
	} else
	{
		set count to count + 1.
	}
	
	print "m: " + round(m,1) at (0,0).
	print "g: " + round(g,2) at (0,1).
	print "w: " + round(w,0) at (0,2).
	print "p: " + round(p,2) at (0,3).
	print "maxThrust: " + round(maxThrust,0) at (0,4).
	print "throt:     " + round(throt,2) at (0,5).
	print "thrust:    " + round(thrust,0) at (0,6).
	print "twr:       " + round(twr,2) at (0,7).
	wait 0.1.
}
