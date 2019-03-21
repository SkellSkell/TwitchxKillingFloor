class PE_GiveCash extends TwitchPlayerEffect;

var int CashReward;

var Vector CachedTossVelocity;

function StartEffect()
{
	CachedTossVelocity = vect(0,0,1);

	TickEffect();
}

function TickEffect()
{
	local KFPawn KFPawn;

	local int DropAmount;
    local CashPickup CashPickup;
    local Vector TossVel;

    KFPawn = KFPawn(Pawn);

    if(KFPawn == None)
    {
    	return;
    }

    CashPickup = SpawnCash(Pawn);

    if(CashPickup == None)
    {
    	return;
    }

    DropAmount = 50 + Rand(25);
	DropAmount = Min(CashReward, DropAmount);

    TossVel = vect(0,0,1);
    TossVel.X = (FRand() * 0.1f) - 0.05f;
    TossVel.Y = (FRand() * 0.1f) - 0.05f;

    TossVel.X = Lerp(TossVel.X, CachedTossVelocity.X, 0.25f);
    TossVel.Y = Lerp(TossVel.Y, CachedTossVelocity.Y, 0.25f);

    CachedTossVelocity = TossVel;

    TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500);

    CashPickup.CashAmount = DropAmount;
    CashPickup.bDroppedCash = true;
    CashPickup.RespawnTime = 0;
    CashPickup.Velocity = TossVel;
    CashPickup.DroppedBy = Pawn.Controller;
    CashPickup.InitDroppedPickupFor(None);

    if (PlayerController(Pawn.Controller) != None && Level.TimeSeconds - KFPawn.LastDropCashMessageTime > 4.f)
    {
        PlayerController(Pawn.Controller).Speech('AUTO', 4, "");
    }

	CashReward -= DropAmount;

	if(CashReward <= 0)
	{
		EffectInterval = 0.f;
	}
}

static final function CashPickup SpawnCash(Pawn Dropper)
{
	local Vector X, Y, Z;
    Dropper.GetAxes(Dropper.GetViewRotation(), X , Y, Z);
	return Dropper.Spawn(class'CashPickup',,, Dropper.Location + (1.5 * Dropper.CollisionHeight * Z), Rotator(Z));
}

defaultproperties
{
	CashReward = 10000

	EffectInterval = 0.01f
	EffectLifeSpan = 0.f
}