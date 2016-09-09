//launch5

clearscreen.

// Set up variables.
global Kp is 0.1.
global Ki is 0.0.
global Kd is 0.0.
global twrTarget is 2.0.

//global gravityTurn is list
//(
//	list(700,	85),
//	list(1700,	80),
//	list(2700,	75),
//	list(3500,	70),
//	list(4400,	65),
//	list(5300,	60),
//	list(5900,	55),
//	list(7000,	50),
//	list(9500,	45),
//	list(13000,	40),
//	list(17000,	35),
//	list(23000,	30),
//	list(31000,	25),
//	list(45000,	20)
//).

set mySteering to heading(90,90).
lock STEERING to mySteering.

set myThrottle to 1.0.
lock THROTTLE to myThrottle.

lock m to SHIP:MASS.
lock g to SHIP:BODY:MU / SHIP:BODY:POSITION:MAG ^ 2.
lock w to m * g.
lock thrust to THROTTLE * SHIP:AVAILABLETHRUST.
lock twr to thrust / w.

global twrPid is pidloop(Kp, Ki, Kd, -1, 1).
set twrPid:SETPOINT to twrTarget.

// Stage when all out of fuel on this stage.
global stagePlease is false.
when STAGE:LIQUIDFUEL < 0.1 and STAGE:SOLIDFUEL < 0.1 and not stagePlease then
{
	print "Stage " + STAGE:NUMBER + " is empty.".
	set stagePlease to TRUE.
	
	if TRUE	// make this check for future stages
	{
		return TRUE.
	}
}

// turning
when SHIP:VELOCITY:SURFACE:MAG > 60 then
	{
		set mySteering to heading(90,85).
		set timestamp to TIME:SECONDS.
		
	when TIME:SECONDS > timestamp + 6 then
	{
		unlock STEERING.
		SAS ON.
		wait 0.1.
		set SASMODE to "prograde".
		
	when SHIP:ALTITUDE > 35000 then
	{
		SAS OFF.
		wait 0.1.
		set mySteering to heading(90,15).
		lock STEERING to mySteering.
		
	when SHIP:ALTITUDE > 40000 then
	{
		SAS OFF.
		wait 0.1.
		set mySteering to heading(90,10).
		lock STEERING to mySteering.
	}
	}
	}
	}


print "Launch!".
//stage.

// Main loop
until SHIP:APOAPSIS > 80000
{
	// Report status.
	print "TWR:      " + round(twr,2) at (0,TERMINAL:HEIGHT - 9).
	print "Set TWR:  " + round(twrPid:SETPOINT,2) at (0,TERMINAL:HEIGHT - 8).
	print "PID out:  " + round(twrPid:OUTPUT,2) at (0,TERMINAL:HEIGHT - 7).
	print "Steering: " + mySteering at (0,TERMINAL:HEIGHT - 5).
	print "Facing:   " + SHIP:FACING at (0,TERMINAL:HEIGHT - 4).
	print "Pitch:    " + round(mod(90 - ((UP - SHIP:FACING):YAW),360),0) + "°" at (0,TERMINAL:HEIGHT - 3).
	print "Heading:  " + round(mod(90 - ((UP - SHIP:SRFPROGRADE):YAW),360),0) + "°" at (0,TERMINAL:HEIGHT - 2).
	print "Apoapsis: " + round(SHIP:APOAPSIS,0) at (0,TERMINAL:HEIGHT - 1).
	
	// throttling
	if SHIP:ALTITUDE < 30000
	{
		set myThrottle to myThrottle + twrPid:UPDATE(TIME:SECONDS, twr).
	}
	else
	{
		set myThrottle to 1.
	}
		
	// turning
	//if SHIP:ALTITUDE > gravityTurn[0][0] and gravityTurn:LENGTH > 0
	//{
	//	print gravityTurn[0][0] + "m - pitching over to " + gravityTurn[0][1] + " degrees.".
	//	set mySteering to pitchover(gravityTurn[0][1]).
	//	gravityTurn:REMOVE(0).
	//}
	
	// staging
	if stagePlease and STAGE:READY
	{
		print "Staging.".
		stage.
		set stagePlease to FALSE.
	}
	
	wait 0.1.
}

print "Congrats!".

// Graceful quit.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
SAS ON.
wait 0.1.
set SASMODE to "PROGRADE".
