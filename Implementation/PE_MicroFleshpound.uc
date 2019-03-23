class PE_MicroFleshpound extends TwitchPlayerEffect;

var KFMonster Monster;

var float HeadSizeModifier;
var float SizeModifier;

var float MaxHealth;
var float MaxHeadHealth;

var float SpeedModifier;

function bool InitEffect(Pawn NewPawn)
{
	Monster = KFMonster(NewPawn);

	return Super.InitEffect(NewPawn);
}

function StartEffect()
{
	UpdateScale();
	InitMonster();
}

function TickEffect()
{
	UpdateScale();
	UpdateMonster();
}

function UpdateScale()
{
	local float CachedHeight;
	CachedHeight = Pawn.CollisionHeight;

	Pawn.bBlockActors = true;
	Pawn.headscale = Pawn.default.headscale * HeadSizeModifier;
	Pawn.SetDrawScale(Pawn.default.DrawScale * SizeModifier * 1.15f);

	Pawn.SetCollisionSize(Pawn.default.CollisionRadius * SizeModifier, Pawn.default.CollisionHeight * SizeModifier);
	
	Pawn.BaseEyeHeight = Pawn.default.BaseEyeHeight * SizeModifier;
	Pawn.EyeHeight = Pawn.default.EyeHeight * SizeModifier;

	if(Pawn.CollisionHeight != CachedHeight)
	{
		if(Pawn.CollisionHeight > CachedHeight)
		{
			
			Pawn.SetLocation(Pawn.Location + (vect(0.f, 0.f, 1.f) * Abs(Pawn.CollisionHeight - CachedHeight) * 1.5f));
		}

		Pawn.PlayTeleportEffect(true, true);
	}
}

function InitMonster()
{
	Monster.OnlineHeadshotOffset = Monster.default.OnlineHeadshotOffset * default.SizeModifier;
	Monster.OriginalGroundSpeed = Monster.default.GroundSpeed * default.SpeedModifier;

	Monster.HealthMax = default.MaxHealth;
	Monster.Health = default.MaxHealth;
	Monster.HeadHealth = default.MaxHeadHealth;
	
	Monster.MeleeDamage = 5.f;
}

function UpdateMonster()
{
	Monster.OnlineHeadshotOffset = Monster.default.OnlineHeadshotOffset * SizeModifier;
	Monster.OriginalGroundSpeed = Monster.default.GroundSpeed * default.SpeedModifier;

	Monster.MeleeDamage = 5.f;
}

defaultproperties
{
	EffectLifeSpan = 0.f
	EffectInterval = 0.5f;

	HeadSizeModifier = 1.75f
	SizeModifier = 0.5f

	MaxHealth = 900.f
	MaxHeadHealth = 400.f

	SpeedModifier = 3.f
}