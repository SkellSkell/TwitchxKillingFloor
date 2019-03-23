class TE_HuskBomb extends TwitchEventSpawner;

static function string GetSpawnerResponse(Pawn Player, string Instigator, int NumSpawned)
{
	return "Look out! "$Instigator$" has called in "$string(NumSpawned)$" Husks!";
}

//We'll reduce the amount of spawns this event can create if we've already spawned too many previously.
static function int SpawnAtVolumeSingle(KFGameType KFGameType, TwitchEventMut TwitchEventMut, array< class<KFMonster> > MonsterList)
{
	local int Count;
	local ZombieHusk ZombieHusk;

	Count = 0;
	foreach KFGameType.DynamicActors(class'ZombieHusk', ZombieHusk, 'Twitch')
	{
		Count++;
	}


	if(Count > 13)
	{
		MonsterList.Length = 2;
	}
	else if(Count > 10)
	{
		MonsterList.Length = 3;
	}
	else if(Count > 5)
	{
		MonsterList.Length = 4;
	}

	return Super.SpawnAtVolumeSingle(KFGameType, TwitchEventMut, MonsterList);
}

defaultproperties
{
	bSurroundPlayer = false

	ZedList[0] = ZT_Husk;
	ZedList[1] = ZT_Husk;
	ZedList[2] = ZT_Husk;
	ZedList[3] = ZT_Husk;
	ZedList[4] = ZT_Husk;
	ZedList[5] = ZT_Husk;
}