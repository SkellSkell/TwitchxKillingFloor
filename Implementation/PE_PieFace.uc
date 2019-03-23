class PE_PieFace extends TwitchPlayerEffect;

function StartEffect()
{
	TickEffect();
}

function TickEffect()
{
	KFPlayerController(Pawn.Controller).NewClientPlayTakeHit(Pawn.Location, Pawn.Location, 100, class'KFMod.DamTypeVomit');

	EffectInterval *= 2.f;

	if(EffectInterval > 1.f)
	{
		EffectInterval = 0.f;
	}
}

defaultproperties
{
	EffectInterval = 0.125f
	EffectLifeSpan = 1.95f //0.25 + 0.5 + 1.0 with some extra padding.
}