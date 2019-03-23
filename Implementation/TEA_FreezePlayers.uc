class TEA_FreezePlayers extends TwitchEventWaveActor;

struct FreezeData
{
	var Pawn Pawn;
	var float UnFreezeDuration;
	var bool bFrozen;
	var Inventory Freezer;
};

var array<FreezeData> FreezeDataList;

var float UnFreezeDuration;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Enable('Tick');
}

function Initialize(TwitchEventMut TwitchEventMutNew, string Instigator, out string Response)
{				
	Super.Initialize(TwitchEventMutNew, Instigator, Response);
	Response = Instigator$" has started freeze tag next wave - players can only move briefly after killing zeds!";
}

function ExtendDuration(string Instigator, out string Response)
{
	Super.ExtendDuration(Instigator, Response);
	Response = Instigator$" has increased the duration of freeze tag!";
}

event Tick( float DeltaTime )
{
	local int Index;

	Super.Tick(DeltaTime);

	for(Index = FreezeDataList.Length - 1; Index > -1; Index--)
	{
		TickFreezeData(DeltaTime, FreezeDataList[Index]);
	}
}

function OnWaveStart()
{
	local int Index;
	local array<Pawn> PawnList;
	Super.OnWaveStart();

	PawnList = class'TwitchEvent'.static.GetPlayerList(self);

	for(Index = PawnList.Length - 1; Index > -1; Index--)
	{
		if(PawnList[Index] == None)
		{
			continue;
		}

		FreezeDataList[FreezeDataList.Length] = CreateFreezeEntryFor(PawnList[Index]);
	}
}

function OnWaveComplete()
{
	local int Index;

	Super.OnWaveComplete();

	for(Index = FreezeDataList.Length - 1; Index > -1; Index--)
	{
		UnFreezePlayer(FreezeDataList[Index]);
	}

	FreezeDataList.Length = 0;
}

function ProcessKill(Controller Killer, Pawn Killed)
{
	local int Index;

	if(!bInitialized)
	{
		return;
	}	

	if(Killer == None || Killer.Pawn == None || KFMonster(Killed) == None)
	{
		return;
	}

	for(Index = FreezeDataList.Length - 1; Index > -1; Index--)
	{
		if(Killer.Pawn == FreezeDataList[Index].Pawn)
		{
			UnFreezePlayer(FreezeDataList[Index]);
		}
	}
}

function TickFreezeData(float DeltaTime, out FreezeData FreezeData)
{
	if(FreezeData.bFrozen || FreezeData.Pawn == None)
	{
		return;
	}

	FreezeData.UnFreezeDuration -= DeltaTime;

	if(FreezeData.UnFreezeDuration <= 0.f)
	{
		FreezePlayer(FreezeData);
	}
}

function FreezePlayer(out FreezeData FreezeData)
{
	if(FreezeData.Pawn == None)
	{
		return;
	}

	FreezeData.Freezer = Spawn(class'Inv_GasCan', FreezeData.Pawn,,,rot(0,0,0));

	if(FreezeData.Freezer == None)
	{
		return;
	}

	FreezeData.Freezer.PickupClass = None;   
	Inv_GasCan(FreezeData.Freezer).MovementSpeedmodifier = 0.00001f;
	FreezeData.Freezer.GiveTo(FreezeData.Pawn);
	//FreezeData.Pawn.ModifyVelocity(0.f, FreezeData.Pawn.Velocity);
	FreezeData.bFrozen = true;
}

function UnFreezePlayer(out FreezeData FreezeData)
{
	if(FreezeData.Pawn == None)
	{
		return;
	}

	if(FreezeData.Freezer != None)
	{
		FreezeData.Pawn.DeleteInventory(FreezeData.Freezer);
		FreezeData.Freezer.Destroy();
	}

	//FreezeData.Pawn.ModifyVelocity(0.f, FreezeData.Pawn.Velocity);
	FreezeData.UnFreezeDuration = default.UnFreezeDuration;
	FreezeData.bFrozen = false;
}

function FreezeData CreateFreezeEntryFor(Pawn Pawn)
{
	local FreezeData FreezeData;
	FreezeData.Pawn = Pawn;
	FreezeData.UnFreezeDuration = default.UnFreezeDuration;
	FreezeData.bFrozen = false;
	return FreezeData;
}

defaultproperties
{
	UnFreezeDuration = 5.f;
}