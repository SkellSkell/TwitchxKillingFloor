class TE_SelfDestruct extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" stuck a bomb to "$Pawn.PlayerReplicationInfo.PlayerName$"! Get away from them!";
}

defaultproperties
{
	PlayerEffectClass = class'PE_SelfDestruct'
}