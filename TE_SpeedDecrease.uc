class TE_SpeedDecrease extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" broke "$Pawn.PlayerReplicationInfo.PlayerName$"'s legs! Poor guy...";
}

defaultproperties
{
	PlayerEffectClass = class'PE_SpeedDecrease'
}