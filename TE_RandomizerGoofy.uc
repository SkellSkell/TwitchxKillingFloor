class TE_RandomizerGoofy extends TE_Randomizer;

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return Instigator$" randomized "$Pawn.PlayerReplicationInfo.PlayerName$"'s perk and weapons... in a weird way.";
}

defaultproperties
{
	PlayerEffectClass = class'PE_RandomizerGoofy'
}