function pitchover
{
	parameter angle.
	//local east is NORTH + r(-90,90,0).
	local east is UP + r(0,-90,180).
	local vector is east + r(0,angle,0).
	return vector.
}