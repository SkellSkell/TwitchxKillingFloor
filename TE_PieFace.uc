class TE_PieFace extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" threw a pie at "$Pawn.PlayerReplicationInfo.PlayerName$"'s face!";
}

defaultproperties
{
	PlayerEffectClass = class'PE_PieFace'
}