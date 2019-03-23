class PE_SelfDestruct extends TwitchPlayerEffect;

const NUMPIPES = 5;
var bool bDetonationConfirmed; //Confirms we are detonating.
var bool bExploding; //Means we're performing the explosion.

function StartEffect()
{
	local Controller C;

	for (C = TwitchEventMut.Level.ControllerList; C != None; C = C.NextController)
	{
		//We need this loaded soon, let all the clients know.
		if(KFPlayerController(C) != None)
		{
			KFPlayerController(C).ClientWeaponSpawned(Class'KFMod.PipeBombExplosive', None);
		}
	}
	
	TickEffect();
}

function TickEffect()
{
	local PlayerController PC;

	PC = PlayerController(Pawn.Controller);

	if(PC == None || PC.Pawn == None)
	{
		EffectInterval = 0.f;
		return;
	}

	PC.ClientPlaySound(Sound'KF_FoundrySnd.Keypad_beep01', true, (1.f - FClamp(EffectInterval * 2.f, 0.f, 0.5f)), SLOT_Talk);

	EffectInterval *= 0.85f;

	if(EffectInterval < 0.005f)
	{
		bDetonationConfirmed = true;
		EffectInterval = 0.f;
	}
}

function EndEffect()
{
	local array<PipeBombProjectile> PipebombList;
	local TeamInfo CachedTeam;
	local int Index;

	//We need to make sure we've confirmed before attempting detonation. This function is called whenever a PlayerEffect is destroyed so we need this check.
	if(!bDetonationConfirmed || !IsValid())
	{
		return;
	}

	bExploding = true;

	for(Index = 0; Index < NUMPIPES; Index++)
	{
		PipebombList[PipebombList.Length] = Spawn(Class'KFMod.PipeBombProjectile',,, Pawn.Location, Pawn.Rotation);
	}

	//When detonating we are team-less!
	CachedTeam = Pawn.PlayerReplicationInfo.Team;
	Pawn.PlayerReplicationInfo.Team = None;
	
	for(Index = 0; Index < NUMPIPES; Index++)
	{
		if(PipebombList[Index] == None)
		{
			continue;
		}

		//Up to 75% more range on pipebomb explosion radius.
		PipebombList[Index].DamageRadius = PipebombList[Index].default.DamageRadius * ((float(NUMPIPES) / 7.5f) + 1.f);
		PipebombList[Index].Instigator = Pawn;
		PipebombList[Index].PlacedTeam = 255;
		PipebombList[Index].Explode(Pawn.Location - vect(0, 0, 32), vect(0, 0, 1));	
	}

	Pawn.PlayerReplicationInfo.Team = CachedTeam;
	bExploding = false;
}

function bool PreventDeathForPawn(Pawn Victim)
{
	if(bExploding && Victim == Pawn)
	{
		return true;
	}

	return false;
}

defaultproperties
{
	bDetonationConfirmed=false
	bExploding=false

	EffectInterval = 2.f
	EffectLifeSpan = 0.f
}