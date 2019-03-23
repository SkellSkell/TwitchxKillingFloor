class TE_CrawlerBomb extends TwitchEventSpawner;

static function string GetSpawnerResponse(Pawn Player, string Instigator, int NumSpawned)
{
	return "Look out! "$Instigator$" called in "$string(NumSpawned)$" Crawlers!";
}

//We'll reduce the amount of spawns this event can create if we've already spawned too many previously.
static function int SpawnAtVolumeMultiple(KFGameType KFGameType, TwitchEventMut TwitchEventMut, array< class<KFMonster> > MonsterList)
{
	local int Count;
	local ZombieCrawler ZombieCrawler;

	Count = 0;
	foreach KFGameType.DynamicActors(class'ZombieCrawler', ZombieCrawler, 'Twitch')
	{
		Count++;
	}

	if(Count > 23)
	{
		MonsterList.Length = 3;
	}
	else if(Count > 18)
	{
		MonsterList.Length = 6;
	}
	else if(Count > 10)
	{
		MonsterList.Length = 9;
	}

	return Super.SpawnAtVolumeMultiple(KFGameType, TwitchEventMut, MonsterList);
}

defaultproperties
{
	bSurroundPlayer = false
	bUseMultipleVolumes = true
	bAddToMaxMonster = false

	ZedList[0] = ZT_Crawler;
	ZedList[1] = ZT_Crawler;
	ZedList[2] = ZT_Crawler;
	ZedList[3] = ZT_Crawler;
	ZedList[4] = ZT_Crawler;
	ZedList[5] = ZT_Crawler;
	ZedList[6] = ZT_Crawler;
	ZedList[7] = ZT_Crawler;
	ZedList[8] = ZT_Crawler;
	ZedList[9] = ZT_Crawler;
	ZedList[10] = ZT_Crawler;
	ZedList[11] = ZT_Crawler;
	ZedList[12] = ZT_Crawler;
}