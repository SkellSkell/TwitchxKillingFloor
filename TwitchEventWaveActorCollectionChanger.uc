class TwitchEventWaveActorCollectionChanger extends TwitchEventWaveActor;

var class<KFMonstersCollection> CollectionOverride;

var private class<KFMonstersCollection> CachedMonsterCollection;
var private array<KFMonstersCollection.MClassTypes> CachedMonsterClasses;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Enable('Tick');
}

function Initialize(TwitchEventMut TwitchEventMutNew, string Instigator, out string Response)
{
	Super.Initialize(TwitchEventMutNew, Instigator, Response);
	Response = "A strange thing will occur to the next wave because of "$Instigator$"!";
}

function ExtendDuration(string Instigator, out string Response)
{
	Super.ExtendDuration(Instigator, Response);
	Response = Instigator$" has extended the nightmare...";
}

function OnWaveComplete()
{
	Super.OnWaveComplete();

	if(!bWaitingForFirstWave)
	{
		return;
	}

	CachedMonsterCollection = KFGameType(Level.Game).MonsterCollection;
	CachedMonsterClasses = static.ConvertMonsterListToMC(KFGameType(Level.Game).MonsterClasses);

	UpdateMonsterCollection(KFGameType(Level.Game), CollectionOverride, CollectionOverride.default.MonsterClasses);
}

function OnEventEnded()
{
	UpdateMonsterCollection(KFGameType(Level.Game), CachedMonsterCollection, CachedMonsterClasses);
	Super.OnEventEnded();
}

function UpdateMonsterCollection(KFGameType GameType, class<KFMonstersCollection> Collection, array<KFMonstersCollection.MClassTypes> MonsterClasses)
{
	GameType.MonsterCollection = Collection;
	GameType.MonsterClasses = static.ConvertMonsterListToGT(MonsterClasses);

	GameType.InitSquads.Length = 0;

	GameType.LoadUpMonsterList();
	GameType.SetupWave();

	DebugSquads();
}

static function array<KFMonstersCollection.MClassTypes> ConvertMonsterListToMC(array<KFGameType.MClassTypes> GTMonsterList)
{
	local int i;
	local array<KFMonstersCollection.MClassTypes> MCMonsterList;

	MCMonsterList.Length = GTMonsterList.Length;
	for ( i=0; i<MCMonsterList.Length; i++ )
	{
		MCMonsterList[i].MClassName = GTMonsterList[i].MClassName;
		MCMonsterList[i].MID = GTMonsterList[i].MID;
	}

	return MCMonsterList;
}

static function array<KFGameType.MClassTypes> ConvertMonsterListToGT(array<KFMonstersCollection.MClassTypes> MCMonsterList)
{
	local int i;
	local array<KFGameType.MClassTypes> GTMonsterList;

	GTMonsterList.Length = MCMonsterList.Length;
	for ( i=0; i<GTMonsterList.Length; i++ )
	{
		GTMonsterList[i].MClassName = MCMonsterList[i].MClassName;
		GTMonsterList[i].MID = MCMonsterList[i].MID;
	}

	return GTMonsterList;
}

function DebugSquads()
{
	local array<KFGameType.MSquadsList> Squads;
	local string SquadString;
	local int i, j;
	Squads = KFGameType(Level.Game).InitSquads;

	log("Listing out all squads...");
	for ( i=0; i<Squads.Length; i++ )
	{
		SquadString = "";

		for ( j=0; j<Squads[i].MSquad.Length; j++ )
		{
			SquadString $= " | ";
			SquadString $= Squads[i].MSquad[j].default.MenuName;
		}

		log(SquadString);
	}
}

defaultproperties
{
	//CollectionOverride = class'PuppetCollection'
}