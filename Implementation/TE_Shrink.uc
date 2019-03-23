class TE_Shrink extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" shrank "$Pawn.PlayerReplicationInfo.PlayerName$"!";
}

defaultproperties
{
	PlayerEffectClass = class'PE_Shrink'
}