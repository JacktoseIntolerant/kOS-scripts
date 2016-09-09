//launch3

clearscreen.

global gravityTurn is list
(
	list(700,	85),
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
).

function pitchover
{
	parameter angle.
	local east is NORTH + r(-90,90,0).
	local vector is east + r(0,angle,0).
	return vector.
}

global mySteering is r(0,0,0).
set mySteering to pitchover(90).

from {local h is 0.} until h > 50000 step {set h to h + 100.} do
{
	print h at (0,TERMINAL:HEIGHT - 1).
	if h > gravityTurn[0][0]
	{
		set mySteering to pitchover(gravityTurn[0][1]).
		print gravityTurn[0][1] + " " + mySteering.
		gravityTurn:REMOVE(0).
		if gravityTurn:LENGTH < 1 { BREAK. }
	}
	
	wait 0.01.
}
