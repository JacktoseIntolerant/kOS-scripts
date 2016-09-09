//launch6

////////////  Variable setup  ////////////

global Kp is 0.15.
global Ki is 0.0.
global Kd is 0.0.
global twrTarget is 2.1.

//global gravityTurnMode is "sas".
global gravityTurnMode is "steering".


////////////  Function declarations  ////////////

function checkFlameouts {
// counts flamed-out engines
	parameter engList.
	
	set flameouts to 0.
	for eng in engList {
		if eng:FLAMEOUT { set flameouts to flameouts + 1. }
	}
	return flameouts.
}

function listFlameouts {
// returns list flamed-out engines' titles
	parameter engList.
	
	set flameoutNames to list().
	for eng in engList {
		if eng:FLAMEOUT { flameoutNames:ADD(eng:TITLE). }
	}
	return flameoutNames.
}

function checkInactives {
// counts inactive engines
	parameter engList.
	
	set inactives to 0.
	for eng in engList {
		if not eng:IGNITION { set inactives to inactives + 1. }	// "inactive" in game
	}
	return inactives.
}

function doStage {
// stages, with a little safety margin
	print "Staging.".
	wait 0.5.	// give half a sec for all engines to flame out
	wait until STAGE:READY.	// KSP needs a sec between stagings
	stage.
}

function printStatus {
	set statusLines to list(
		//"Mass:     " + round(mass,1),
		//"Gravity:  " + round(g,2),
		//"Weight:   " + round(w,1),
		//"myThrott: " + round(myThrottle,2),
		//"Throttle: " + round(THROTTLE,2),
		//"Avail th: " + round(SHIP:AVAILABLETHRUST,1),
		//"Throt * thrust: " + round(THROTTLE,2) + " * " + round(SHIP:AVAILABLETHRUST,1),
		//"Thrust:   " + round(thrust,1),
		//"T / W:    " + round(thrust,1) + " / " + round(w,1),
		"TWR:      " + round(twr,2),
		"Set TWR:  " + round(twrPid:SETPOINT,2),
		"PID out:  " + round(twrPid:OUTPUT,2),
		"",
		"Steering: " + mySteering,
		"Facing:   " + SHIP:FACING,
		"Pitch:    " + round(mod(90 - ((UP - SHIP:FACING):YAW),360),0) + " deg",
		"Heading:  " + round(mod(90 - ((UP - SHIP:SRFPROGRADE):YAW),360),0) + " deg",
		"Apoapsis: " + round(SHIP:APOAPSIS,0)
	).
	
	set bottomLine to TERMINAL:HEIGHT - 1.
	set topLine to bottomLine - statusLines:LENGTH.
	for line in range(topLine, bottomLine) {
		set statusLine to line - topLine.
		print statusLines[statusLine] at (0, line).
	}
}


////////////  Main program  ////////////

////////////  Preparations  ////////////

clearscreen.

set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
SAS OFF.
RCS OFF.

set mySteering to heading(90,90) + r(0,0,-90).
lock STEERING to mySteering.

set myThrottle to 1.0.
lock THROTTLE to min(1, max(0, myThrottle)).

lock m to SHIP:MASS.
lock g to SHIP:BODY:MU / SHIP:BODY:POSITION:MAG ^ 2.
lock w to m * g.
lock thrust to THROTTLE * SHIP:AVAILABLETHRUST.
lock twr to thrust / w.

global twrPid is pidloop(Kp, Ki, Kd, -1, 1).
set twrPid:SETPOINT to twrTarget.


////////////  Gravity turn setup  ////////////

when SHIP:VELOCITY:SURFACE:MAG > 60 then {
	print "Pitching over 5 degrees.".
	set mySteering to heading(90,85) + r(0,0,-90).
	set timestamp to TIME:SECONDS.
		
when TIME:SECONDS > timestamp + 7 then {	// these are nested, but the indents started looking ugly
	if gravityTurnMode = "sas" {
		print "SAS to prograde.".
		unlock STEERING.
		SAS ON.
		wait 0.1.
		set SASMODE to "prograde".
	} else {	// mode is "steering" or I messed up
		print "Steering prograde.".
		lock mySteering to SRFPROGRADE + r(0,0,-90).
	}
	
when SHIP:ALTITUDE > 35000 then {
	print "Pitching to 15 degrees.".
	set mySteering to heading(90,15) + r(0,0,-90).
	if gravityTurnMode = "sas" {
		SAS OFF.
		wait 0.1.
		lock STEERING to mySteering.
	}
	
when SHIP:ALTITUDE > 40000 then {
	print "Pitching to 10 degrees.".
	set mySteering to heading(90,10) + r(0,0,-90).
}
}
}
}

////////////  Main loop  ////////////

until APOAPSIS > 80000 {
	
	printStatus().	// Continuous readout, mostly for debugging

	//////  Throttling  //////
	
	// throttling
	if SHIP:ALTITUDE < 30000 {
		set myThrottle to min(1, max(0,
			myThrottle + twrPid:UPDATE(TIME:SECONDS, twr)
		)).
	} else {
		set myThrottle to 1.
	}
	
	
	//////  Staging  //////
	
	list ENGINES in engs.	// update every time
	set flameouts to checkFlameouts(engs).	// number of engines flamed out (on the whole ship)
	set inactives to checkInactives(engs).	// number of engines not ignited (on the whole ship)
	
	if flameouts {
		print "Engines flamed out:".
		for engName in listFlameouts(engs) { print engName. }.
		if inactives or MAXTHRUST > 0.1 {	// condition alpha, beta, gamma
			doStage().
		} else {	// done staging.
			print "No more engines to stage to.".
			break.
		}
	} else if inactives and MAXTHRUST < 0.1 {	// no flameouts, but need to stage (condition delta)
		print "No thrust and more engines waiting.".
		doStage().
	}
	
	wait 0.1.
}


////////////  Graceful quit  ////////////

set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
SAS ON.
wait 0.1.
set SASMODE to "PROGRADE".
print "The helm is yours, pilot.".
