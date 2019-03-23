class PE_Punt extends TwitchPlayerEffect;

var Vector PuntVector;

function bool InitEffect(Pawn NewPawn)
{
	return Super.InitEffect(NewPawn);
}

function StartEffect()
{
	local Vector CalcedPunt;

	if(Pawn == None)
	{
		Destroy();
		return;
	}

	CalcedPunt = vect(0, 0, 0);

	CalcedPunt.Z = -1.f * Pawn.Velocity.Z;

	//Randomize PuntVector right before use.
	PuntVector.X = ((FRand() * 2.f) - 1.f) * default.PuntVector.X;
	PuntVector.Y = ((FRand() * 2.f) - 1.f) * default.PuntVector.Y;
	PuntVector.Z = (1.f + ((FRand() * 0.25f) - 0.125f)) * default.PuntVector.z;

	CalcedPunt += PuntVector;

	Pawn.SetPhysics(PHYS_Falling);
	Pawn.Velocity += CalcedPunt;
}

function TickEffect()
{
	if(Pawn == None)
	{
		EffectInterval = 0.f;
		return;
	}

	if(Pawn.Physics == PHYS_Walking)
	{
		EffectInterval = 0.f;
		return;
	}

	EffectInterval = 0.1f;
}

function bool IgnoreFallDamageForPawn(Pawn Victim)
{
	return Pawn == Victim;
}

defaultproperties
{
	EffectInterval = 0.5f
	EffectLifeSpan = 0.f

	PuntVector=(X=50,Y=50,Z=1000)
}