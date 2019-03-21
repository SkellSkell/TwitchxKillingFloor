class TE_Punt extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" punted "$Pawn.PlayerReplicationInfo.PlayerName$"!";
}

defaultproperties
{
	PlayerEffectClass=class'PE_Punt'
}