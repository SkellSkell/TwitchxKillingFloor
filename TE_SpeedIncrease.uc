class TE_SpeedIncrease extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" gave "$Pawn.PlayerReplicationInfo.PlayerName$" super speed!";
}

defaultproperties
{
	PlayerEffectClass = class'PE_SpeedIncrease'
}