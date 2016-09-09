//stagetest

////////////  Declarations  ////////////

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


////////////  Main program  ////////////

clearscreen.

until STAGE:NUMBER = 0 {
	
	list ENGINES in engs.	// check every time
	set flameouts to checkFlameouts(engs).
	set inactives to checkInactives(engs).
	
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

print "Done!".