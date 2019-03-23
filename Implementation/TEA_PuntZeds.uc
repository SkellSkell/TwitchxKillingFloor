class TEA_PuntZeds extends TwitchEventActor;

var int CurrentIndex;
var array<Pawn> PawnList;

function Initialize(TwitchEventMut TwitchEventMut, string Instigator, out string Response)
{
	local Controller C;

	Super.Initialize(TwitchEventMut, Instigator, Response);

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if(MonsterController(C) != None && C.Pawn != None && C.Pawn.Health > 0)
		{
			PawnList[PawnList.Length] = C.Pawn;
		}
	}

	if(PawnList.Length <= 0)
	{
		Response = Instigator$" punted the zeds! There were no zeds to punt though...";
		Destroy();
		return;
	}

	CurrentIndex = 0;
	SetTimer(0.02f, false);
	Response = Instigator$" punted the zeds! "$PawnList.Length$" zeds were punted!";
}

function Timer()
{
	if(CurrentIndex >= PawnList.Length)
	{
		Destroy();
		return;
	}

	if(PawnList[CurrentIndex] != None && PawnList[CurrentIndex].Health > 0)
	{
		PawnList[CurrentIndex].SetPhysics(PHYS_Falling);
		PawnList[CurrentIndex].Velocity = vect(0, 0, 1000);			
	}

	CurrentIndex++;
	SetTimer(0.02f, false);
}