class TwitchEventSpawner extends TwitchEvent;

enum EZedType
{
	ZT_Clot,
	ZT_Crawler,
	ZT_Gorefast,
	ZT_Stalker,
	ZT_Scrake,
	ZT_Fleshpound,
	ZT_Bloat,
	ZT_Siren,
	ZT_Husk
};

//Should we spawn zeds directly around a player?
var bool bSurroundPlayer;

//Number of times we will retry to find a new volume to spawn zeds at.
const VOLUME_RETRY_LIMIT = 5;

//Can we accomplish this spawn over multiple spawn volumes?
var bool bUseMultipleVolumes;

//Should the new spawns be counted as part of the wave (will count towards maximum spawns on the map at one time).
var bool bAddToMaxMonster;

//Zeds to spawn with this event.
var array<EZedType> ZedList;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local Pawn Pawn;
	local int NumSpawned;

	Pawn = GetPlayer(TwitchEventMut, ExtraInfo);

	if(Pawn == None)
	{
		return;
	}

	if(default.bSurroundPlayer)
	{
		NumSpawned = SpawnAtPlayer(Pawn, TwitchEventMut);
	}
	else
	{
		NumSpawned = SpawnAtVolume(Pawn, TwitchEventMut);
	}

	Response = GetSpawnerResponse(Pawn, Instigator, NumSpawned);
}

//Default response system. This should be overwritten by child classes.
static function string GetSpawnerResponse(Pawn Player, string Instigator, int NumSpawned)
{
	local string Response;
	Response = "Look out! "$string(NumSpawned)$" zeds have been called in by "$Instigator;

	if(default.bSurroundPlayer)
	{
		Response = Response$" surrounding "$Player.PlayerReplicationInfo.PlayerName$"!";
	}
	else
	{
		Response = Response$"!";
	}

	return Response;
}

static function class<KFMonster> GetZedClassFromEnum(KFGameType KFGameType, EZedType ZedType)
{
	local class<KFMonstersCollection> MonsterCollection;
	local int Index;

	if(KFGameType == None || KFGameType.MonsterCollection == None)
	{
		return None;
	}

	MonsterCollection = KFGameType.MonsterCollection;

	Index = int(ZedType);

	if(MonsterCollection.default.MonsterClasses.Length <= Index)
	{
		return None;
	}

	return Class<KFMonster>(DynamicLoadObject(MonsterCollection.default.MonsterClasses[Index].MClassName, Class'Class'));
}

static final function int SpawnAtPlayer(Pawn Player, TwitchEventMut TwitchEventMut)
{
	local int NumZeds;
	local int Index;
	local class<KFMonster> MonsterClass;
	local Vector RandomOffset;
	local int DeltaTheta;
	local int Theta;
	local Rotator SpawnDirection;
	local int NumSpawned;

	local KFMonster SpawnedZed;

	if(Player == None)
	{
		return 0;
	}

	NumSpawned = 0;

	NumZeds = default.ZedList.Length;
	DeltaTheta = int(float(65536)/float(NumZeds));
	Theta = 0;
	SpawnDirection = rot(0, 0, 0);

	for(Index = 0; Index < NumZeds; Index++)
	{
		MonsterClass = GetZedClassFromEnum(KFGameType(Player.Level.Game), default.ZedList[Index]);

		if(MonsterClass == None)
		{
			continue;
		}

		SpawnDirection.Yaw = Theta;

		RandomOffset = Vector(SpawnDirection) * (72.f + (FRand() * 8.f)); 
		RandomOffset += Player.Location;

		if(!IsValidSpawnLocation(Player, Player.Location, RandomOffset, RandomOffset))
		{
			Theta += DeltaTheta;
			continue;
		}

		SpawnedZed = Player.Spawn(MonsterClass,, 'Twitch', RandomOffset, Rotator(-Vector(SpawnDirection)));

		ProcessSpawnedZed(SpawnedZed, TwitchEventMut);

		if(SpawnedZed != None)
		{
			NumSpawned++;
		}

		Theta += DeltaTheta;
	}

	return NumSpawned;
}

static final function bool IsValidSpawnLocation(Pawn Player, Vector Start, Vector End, out Vector AdjustedLocation)
{
	local Vector HitLocation, HitNormal;
	AdjustedLocation = End;

	
	if(Player.Trace(HitLocation, HitNormal, End, Start, false, vect(12.f, 12.f, 12.f)) != None)
	{
		AdjustedLocation = HitLocation;
	}

	//Return true if the adjusted distance is closer than 32uu.
	return VSize(Start - AdjustedLocation) > 32.f;
}

static final function int SpawnAtVolume(Actor Actor, TwitchEventMut TwitchEventMut)
{
	local KFGameType KFGameType;

	local int Index;

	local class<KFMonster> MonsterClass;
	local array< class<KFMonster> > CachedNextSpawnSquad; //NOTE: THIS IS THE KFGT's CURRENT SPAWN SQUAD - ALWAYS RESET TO THIS BEFORE EXITING.
	local array< class<KFMonster> > MonsterList;

	local int NumSpawned;

	if(Actor == None)
	{
		return 0;
	}

	KFGameType = KFGameType(Actor.Level.Game);

	if(KFGameType == None)
	{
		return 0;
	}

	//Create class list.
	for(Index = 0; Index < default.ZedList.Length; Index++)
	{
		MonsterClass = GetZedClassFromEnum(KFGameType, default.ZedList[Index]);

		if(MonsterClass == None)
		{
			continue;
		}

		MonsterList[MonsterList.Length] = MonsterClass;
	}

	//Ignore if we failed to find any classes.
	if(MonsterList.Length <= 0)
	{
		return 0;
	}
	
	NumSpawned = 0;

	//Cache the KFGT's current squad it wants to spawn and then set the current one to ours.
	CachedNextSpawnSquad = KFGameType.NextSpawnSquad;
	KFGameType.NextSpawnSquad = MonsterList;

	if(default.bUseMultipleVolumes)
	{
		NumSpawned = SpawnAtVolumeMultiple(KFGameType, TwitchEventMut, MonsterList);
	}
	else
	{
		NumSpawned = SpawnAtVolumeSingle(KFGameType, TwitchEventMut, MonsterList);
	}
	
	//Reset the squad back to the cached version once done.
	KFGameType(Actor.Level.Game).NextSpawnSquad = CachedNextSpawnSquad;

	return NumSpawned;
}

//Find current best volume to use and spawn there.
static function int SpawnAtVolumeSingle(KFGameType KFGameType, TwitchEventMut TwitchEventMut, array< class<KFMonster> > MonsterList)
{
	local int NumSpawned;
	
	NumSpawned = MonsterList.Length;
	SpawnZedsInVolume(KFGameType.FindSpawningVolume(true), MonsterList, TwitchEventMut);
	NumSpawned -= MonsterList.Length;

	return NumSpawned;
}

//Defer spawning of this squad over multiple volumes.
static function int SpawnAtVolumeMultiple(KFGameType KFGameType, TwitchEventMut TwitchEventMut, array< class<KFMonster> > MonsterList)
{
	local array<ZombieVolume> CachedZedSpawnList; //NOTE: THIS IS THE KFGT's CURRENT SPAWN VOLUMES - ALWAYS RESET TO THIS BEFORE EXITING.
	local int Index;
	local int SpawnerIndex;
	local int NumSpawned;
	local ZombieVolume SpawnVolume;

	CachedZedSpawnList = KFGameType.ZedSpawnList;

	NumSpawned = MonsterList.Length;

	for(Index = 0; Index < VOLUME_RETRY_LIMIT; Index++)
	{
		//This request should behave like a normal spawn volume.
		SpawnVolume = KFGameType.FindSpawningVolume(false);

		if(SpawnVolume == None)
		{
			continue;
		}

		SpawnZedsInVolume(SpawnVolume, MonsterList, TwitchEventMut);

		if(MonsterList.Length <= 0)
		{
			break;
		}

		//Remove this spawner from the possible list of spawners.
		for(SpawnerIndex = 0; SpawnerIndex < KFGameType.ZedSpawnList.Length; SpawnerIndex++)
		{
			if(KFGameType.ZedSpawnList[SpawnerIndex] == None)
			{
				continue;
			}

			if(SpawnVolume != KFGameType.ZedSpawnList[SpawnerIndex])
			{
				continue;
			}

			KFGameType.ZedSpawnList.Remove(SpawnerIndex, 1);
			break;
		}
	}	

	NumSpawned -= MonsterList.Length;	

	//Reset the spawner list back the cached version once done.
	KFGameType.ZedSpawnList = CachedZedSpawnList;

	return NumSpawned;
}

static final function SpawnZedsInVolume(ZombieVolume SpawnVolume, out array< class<KFMonster> > MonsterList, TwitchEventMut TwitchEventMut)
{
	local KFGameType KFGT;

	local int Index;

	local Vector SpawnPosition;
	local Rotator SpawnRotation;

	local KFMonster SpawnedZed;

	if(SpawnVolume == None)
	{
		return;
	}

	KFGT = KFGameType(SpawnVolume.Level.Game);

	SpawnRotation = rot(0, 0, 0);

	for(Index = 0; Index < SpawnVolume.SpawnPos.Length; Index++)
	{
		if(MonsterList.Length <= 0)
		{
			break;
		}

		SpawnPosition = SpawnVolume.SpawnPos[Index];
		SpawnRotation.Yaw = Rand(65536);

		SpawnedZed = SpawnVolume.Spawn(MonsterList[0],, 'Twitch', SpawnPosition, SpawnRotation);

		if(SpawnedZed == None)
		{
			continue;
		}

		ProcessSpawnedZed(SpawnedZed, TwitchEventMut);
		
		if(default.bAddToMaxMonster)
		{
			KFGT.NumMonsters++;
		}

		KFGT.WaveMonsters++;
		MonsterList.Remove(0, 1);
	}
}

static function ProcessSpawnedZed(KFMonster SpawnedZed, TwitchEventMut TwitchEventMut)
{

}

defaultproperties
{
	bSurroundPlayer = false
	bUseMultipleVolumes = false
	bAddToMaxMonster = true
}