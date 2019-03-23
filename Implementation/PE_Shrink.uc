class PE_Shrink extends TwitchPlayerEffect;

var float HeadSizeModifier;
var float SizeModifier;

function bool InitEffect(Pawn NewPawn)
{
	local PE_Shrink ActiveShrinker;

	if(NewPawn == None)
	{
		return false;
	}

	foreach DynamicActors(class'PE_Shrink', ActiveShrinker)
	{
		if(ActiveShrinker == Self || ActiveShrinker.Pawn != NewPawn)
		{
			continue;
		}

		if(ActiveShrinker.SizeModifier > 0.2f)
		{
			ActiveShrinker.HeadSizeModifier *= HeadSizeModifier;
			ActiveShrinker.SizeModifier *= SizeModifier;
			ActiveShrinker.UpdateScale(ActiveShrinker.HeadSizeModifier, ActiveShrinker.SizeModifier);
		}

		ActiveShrinker.LifeSpan = FMax(ActiveShrinker.LifeSpan + EffectLifeSpan, ActiveShrinker.default.EffectLifeSpan * 1.5f);

		Destroy();

		return false;
	}

	return Super.InitEffect(NewPawn);
}

function StartEffect()
{
	UpdateScale(HeadSizeModifier, SizeModifier);
}

function TickEffect()
{
	if(KFGameType(Level.Game) != None && !KFGameType(Level.Game).bTradingDoorsOpen)
	{
		UpdateScale(HeadSizeModifier, SizeModifier);
	}
}

function EndEffect()
{
	if(Pawn != None)
	{
		UpdateScale(1.f, 1.f);
	}
}

function UpdateScale(float HeadScale, float BodyScale)
{
	local float CachedHeight;
	CachedHeight = Pawn.CollisionHeight;

	Pawn.bBlockActors = true;
	Pawn.headscale = Pawn.default.headscale * HeadScale;
	Pawn.SetDrawScale(Pawn.default.DrawScale * BodyScale * 1.1f);

	if(BodyScale < 1.f)
	{
		Pawn.SetCollisionSize(Pawn.default.CollisionRadius * BodyScale, Pawn.default.CollisionHeight * BodyScale);
		Pawn.CrouchRadius = Pawn.CollisionRadius;
		Pawn.CrouchHeight = Pawn.CollisionHeight * (Pawn.default.CrouchHeight / Pawn.default.CollisionHeight);
	}
	else
	{
		Pawn.SetCollisionSize(Pawn.default.CollisionRadius, Pawn.default.CollisionHeight);
		Pawn.CrouchRadius = Pawn.default.CrouchRadius;
		Pawn.CrouchHeight = Pawn.default.CrouchHeight;
	}

	
	Pawn.BaseEyeHeight = Pawn.default.BaseEyeHeight * BodyScale;
	Pawn.EyeHeight = Pawn.default.EyeHeight * BodyScale;

	if(Pawn.CollisionHeight != CachedHeight)
	{
		if(Pawn.CollisionHeight > CachedHeight)
		{
			Pawn.SetLocation(Pawn.Location + (vect(0,0,1) * Abs(Pawn.CollisionHeight - CachedHeight) * 1.5f));
		}

		Pawn.PlayTeleportEffect(true, true);
	}
}

defaultproperties
{
	EffectLifeSpan = 30.f
	EffectInterval = 0.125f;

	HeadSizeModifier = 1.2f
	SizeModifier = 0.75f
}