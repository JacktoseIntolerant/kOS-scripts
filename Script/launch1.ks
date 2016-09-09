//hellolaunch



lock STEERING to mySteering.
lock THROTTLE to myThrottle.

//Set controls.
clearscreen.
print "Steering up.".
set mySteering to heading (90,90).
print "Throttle to max.".
set myThrottle to 1.

print "and ...".
print "GO!".

when SHIP:MAXTHRUST = 0 then
{
	wait 0.1.
	print "Staging.".
	stage.
	return true.
}

until SHIP:APOAPSIS > 100000
{
	if SHIP:VERTICALSPEED < 60
	{
		set mySteering to heading(90,90).
	}
	else if SHIP:VELOCITY:SURFACE:MAG >= 60 and SHIP:VELOCITY:SURFACE:MAG < 200
	{
		set mySteering to heading (90,80).
	}
	else if
	
	print "Steering: " + mySteering at (0,34).
	print "Apoapsis: " + round(SHIP:APOAPSIS,0) at (0,35).
	
	wait 0.
}