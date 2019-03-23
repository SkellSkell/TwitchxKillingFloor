class TE_GiveCash extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return "Grab it while it's hot! "$Instigator$" turned "$Pawn.PlayerReplicationInfo.PlayerName$" into a dosh fountain!";
}

defaultproperties
{
	PlayerEffectClass = class'PE_GiveCash'
}