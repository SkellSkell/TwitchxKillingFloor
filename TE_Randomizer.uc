class TE_Randomizer extends TwitchEventPlayerEffect;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" randomized "$Pawn.PlayerReplicationInfo.PlayerName$"'s perk and weapons!";
}

defaultproperties
{
	PlayerEffectClass = class'PE_Randomizer'
}