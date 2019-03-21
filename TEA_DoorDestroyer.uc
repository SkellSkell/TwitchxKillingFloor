class TEA_DoorDestroyer extends TwitchEventWaveActor;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Initialize(TwitchEventMut TwitchEventMutNew, string Instigator, out string Response)
{				
	Super.Initialize(TwitchEventMutNew, Instigator, Response);
	Response = Instigator$" has planted a bomb on every door on the map. They're set to blow at the start of next wave!";
}

function ExtendDuration(string Instigator, out string Response)
{
	Super.ExtendDuration(Instigator, Response);
	Response = Instigator$" brought another set of door bombs - looks like another wave without doors...";
}

function OnWaveStart()
{
	Super.OnWaveStart();

	DestroyDoors();
}

function DestroyDoors()
{
	local KFDoorMover Door;
	local array<Pawn> PawnList;

	PawnList = class'TwitchEvent'.static.GetPlayerList(self);

	if(PawnList.Length == 0)
	{
		return;
	}

	foreach DynamicActors(class'KFDoorMover', Door)
	{
		if(Door.bStartSealed)
		{
			continue;
		}

		Door.TakeDamage(1000000.f, PawnList[0], Door.Location, Vector(Door.Rotation), class'DamTypeFrag');
	}
}

defaultproperties
{

}