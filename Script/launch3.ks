//launch3

clearscreen.

// Set up variables.
global Kp is 0.1.
global Ki is 0.0.
global Kd is 0.0.

global gravityTurn is list
(
	list(700,	85),
	list(1600,	80),
	list(2400,	75),
	list(3400,	70),
	list(4300,	65),
	list(5100,	60),
	list(5900,	55),
	list(7200,	50),
	list(9500,	45),
	list(13000,	40),
	list(17000,	35),
	list(23000,	30),
	list(31000,	25),
	list(45000,	20)
).

function pitchover
{
	parameter angle.
	local east is NORTH + r(-90,90,0).
	local vector is east + r(0,angle,0).
	return vector.
}

global stagePlease is false.
global mySteering is r(0,0,0).
set mySteering to pitchover(90).
global myThrottle is 1.0.

lock STEERING to mySteering.
lock THROTTLE to myThrottle.

// Stage when all out of fuel on this stage.
when STAGE:LIQUIDFUEL < 0.1 and STAGE:SOLIDFUEL < 0.1 and not stagePlease then
{
	print "Stage " + STAGE:NUMBER + " is empty.".
	set stagePlease to TRUE.
	
	if TRUE	// make this check for future stages
	{
		return TRUE.
	}
}

print "Launch!".
stage.

// Main loop
until SHIP:APOAPSIS > 80000
{
	// Report status.
	print "Steering: " + mySteering at (0,TERMINAL:HEIGHT - 5).
	print "Facing:   " + SHIP:FACING at (0,TERMINAL:HEIGHT - 4).
	print "Pitch:    " + round(mod(90 - ((UP - SHIP:FACING):YAW),360),0) + "°" at (0,TERMINAL:HEIGHT - 3).
	print "Heading:  " + round(mod(90 - ((UP - SHIP:SRFPROGRADE):YAW),360),0) + "°" at (0,TERMINAL:HEIGHT - 2).
	print "Apoapsis: " + round(SHIP:APOAPSIS,0) at (0,TERMINAL:HEIGHT - 1).
	
	// turning
	if SHIP:ALTITUDE > gravityTurn[0][0] and gravityTurn:LENGTH > 0
	{
		print gravityTurn[0][0] + "m - pitching over to " + gravityTurn[0][1] + " degrees.".
		set mySteering to pitchover(gravityTurn[0][1]).
		gravityTurn:REMOVE(0).
	}
	
	// staging
	if stagePlease and STAGE:READY
	{
		print "Staging.".
		stage.
		set stagePlease to FALSE.
		wait 0.
	}
	
	wait 0.1.
}

print "Congrats!".

// Graceful quit.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
SAS ON.
wait 0.
set SASMODE to "PROGRADE".
