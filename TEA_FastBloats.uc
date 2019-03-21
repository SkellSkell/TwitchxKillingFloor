class TEA_FastBloats extends TwitchEventWaveActor;

var array<ZombieBloatBase> BloatList;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Initialize(TwitchEventMut TwitchEventMutNew, string Instigator, out string Response)
{				
	Super.Initialize(TwitchEventMutNew, Instigator, Response);
	Response = Instigator$" injected next wave's Bloats with something - they are very fast!";
}

function ExtendDuration(string Instigator, out string Response)
{
	Super.ExtendDuration(Instigator, Response);
	Response = Instigator$" has injected even more Bloats with something - another wave of speedy Bloats!";
}

event Tick(float DeltaTime)
{
	local int Index;

	Super.Tick(DeltaTime);

	for(Index = BloatList.Length - 1; Index > -1; Index--)
	{
		if(BloatList[Index] == None)
		{
			continue;
		}

		BloatList[Index].OriginalGroundSpeed *= 6.f;
	}

	BloatList.Length = 0;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(!bInitialized)
	{
		return true;
	}

	//Append this bloat the processing list. We have to wait for PostBeginPlay() to be called so this deferring is intentional.
	if(ZombieBloatBase(Other) != None)
	{
		BloatList[BloatList.Length] = ZombieBloatBase(Other);
	}

	return true;
}

defaultproperties
{

}