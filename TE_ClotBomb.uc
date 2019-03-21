class TE_ClotBomb extends TwitchEventSpawner;

static function string GetSpawnerResponse(Pawn Player, string Instigator, int NumSpawned)
{
	return "Look out! "$Instigator$" has called in "$string(NumSpawned)$" Clots surrounding "$Player.PlayerReplicationInfo.PlayerName$"!";
}

defaultproperties
{
	bSurroundPlayer = true

	ZedList[0] = ZT_Clot;
	ZedList[1] = ZT_Clot;
	ZedList[2] = ZT_Clot;
	ZedList[3] = ZT_Clot;
	ZedList[4] = ZT_Clot;
}