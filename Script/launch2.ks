//launch2

clearscreen.

// Set up variables.
global Kp is 0.1.
global Ki is 0.0.
global Kd is 0.0.

global gravityTurn is list
(
	list(0,		90),
	list(0700,	85),
	list(1300,	80),
	list(2000,	75),
	list(3500,	65),
	list(6000,	55),
	list(10000,	45),
	list(12500,	40),
	list(15500,	35),
	list(20000,	30),
	list(27000,	25),
	list(42000,	20)
)

function pitchover
{
	parameter angle.
	local east is NORTH + r(-90,90,0).
	local vector is east + r(0,angle,0).
	return vector.
}

global mySteering is r(0,0,0).
set mySteering to pitchover(90).
print "mS 90: " + mySteering.
global myThrottle is 1.0.

lock STEERING to mySteering.
lock THROTTLE to myThrottle.

// Stage when all out of fuel on this stage.
when STAGE:LIQUIDFUEL < 0.1 and STAGE:SOLIDFUEL < 0.1 then
{
	wait 0.1.
	print "Staging.".
	stage.
	if true	// make this check for future stages
	{
		return true.
	}
}

// Launching process.
when SHIP:VERTICALSPEED > 60 then
{
	set mySteering to pitchover(85).
	
	when SHIP:ALTITUDE > 1500 then
	{
		set mySteering to pitchover(80).
		
	when SHIP:ALTITUDE > 4000 then
	{
		set mySteering to pitchover(75).
		
	when SHIP:ALTITUDE > 6000 then
	{
		set mySteering to pitchover(65).
		
	when SHIP:ALTITUDE > 8000 then
	{
		set mySteering to pitchover(55).
		
	when SHIP:ALTITUDE > 10000 then
	{
		set mySteering to pitchover(45).
		
		print "Altitude 10km.".
		print "Pitch should be 60-45°.".
		print "Pitch is        " + round(90 - ((UP - SHIP:FACING):YAW)) + "°.".
		
	when SHIP:ALTITUDE > 15000 then
	{
		set mySteering to pitchover(40).
		
	when SHIP:ALTITUDE > 20000 then
	{
		set mySteering to pitchover(30).
		
	when SHIP:ALTITUDE > 30000 then
	{
		set mySteering to pitchover(25).
	}
	}
	}
	}
	}
	}
	}
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
	
	wait 0.1.
}

print "Congrats!".

// Graceful quit.
set PILOTMAINTHROTTLE to 0.
SAS ON.
wait 0.
set SASMODE to "PROGRADE".
