class TE_MicroSCBomb extends TwitchEventSpawner;

static function string GetSpawnerResponse(Pawn Player, string Instigator, int NumSpawned)
{
	return "Look out! "$Instigator$" has called in "$string(NumSpawned)$" Micro Scrakes!";
}

static function int SpawnAtVolumeSingle(KFGameType KFGameType, TwitchEventMut TwitchEventMut, array< class<KFMonster> > MonsterList)
{
	local int Count;
	local ZombieScrake ZombieScrake;

	Count = 0;
	foreach KFGameType.DynamicActors(class'ZombieScrake', ZombieScrake, 'Twitch')
	{
		Count++;
	}

	if(Count > 20)
	{
		MonsterList.Length = 1;
	}
	if(Count > 15)
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

static function ProcessSpawnedZed(KFMonster SpawnedZed, TwitchEventMut TwitchEventMut)
{
	local TwitchPlayerEffect PlayerEffect;
	local string DummyString;

	if(SpawnedZed == None)
	{
		return;
	}

	PlayerEffect = TwitchEventMut.Spawn(class'PE_MicroScrake');
	PlayerEffect.Initialize(TwitchEventMut, DummyString, DummyString);
	PlayerEffect.InitEffect(SpawnedZed);
}

defaultproperties
{
	bSurroundPlayer = false

	ZedList[0] = ZT_Scrake;
	ZedList[1] = ZT_Scrake;
	ZedList[2] = ZT_Scrake;
	ZedList[3] = ZT_Scrake;
}