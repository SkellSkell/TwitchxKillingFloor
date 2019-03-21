class TwitchRule extends GameRules;

var TwitchEventMut TwitchEventMut;

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
	if(TwitchEventMut.ShouldPreventDeath(Killed))
	{
		return true;
	}

	return Super.PreventDeath(Killed, Killer, DamageType, HitLocation);
}

function bool PreventSever(Pawn Killed, Name boneName, int Damage, class<DamageType> DamageType)
{
	return Super.PreventSever(Killed, boneName, Damage, DamageType);

	//We can enable this later if we want to remove decapitation from Self-Destruct and other "non-lethal" damages.
	if(TwitchEventMut.ShouldPreventDeath(Killed))
	{
		return true;
	}

	return Super.PreventSever(Killed, boneName, Damage, DamageType);
}

function ScoreKill(Controller Killer, Controller Killed)
{
	Super.ScoreKill(Killer, Killed);

	TwitchEventMut.ScoreKill(Killer, Killed.Pawn);
}


function int NetDamage( int OriginalDamage, int Damage, pawn Injured, pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	TwitchEventMut.NetDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);

	return Super.NetDamage(OriginalDamage, Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
}
