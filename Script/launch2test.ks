//launch2

clearscreen.

// Set up variables.
global Kp is 0.1.
global Ki is 0.0.
global Kd is 0.0.


function pitchover
{
	parameter angle.
	local east is NORTH + r(-90,90,0).
	local vector is east + r(0,angle,0).
	return vector.
}

global mySteering is pitchover(90).
print "mS 90: " + mySteering.