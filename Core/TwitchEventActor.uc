//Actor spawned by a TwitchEvent class. Adds itself to the Twitch Event Mutator when initialized, removes itself when destroyed.
class TwitchEventActor extends Actor;

var TwitchEventMut TwitchEventMut;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Disable('Tick');
}

function Initialize(TwitchEventMut NewTwitchEventMut, string Instigator, out string Response)
{
	if(NewTwitchEventMut == None)
	{
		return;
	}
	
	TwitchEventMut = NewTwitchEventMut;
	TwitchEventMut.AddTwitchEventActor(self);
}

event Destroyed()
{
	if(TwitchEventMut != None)
	{
		TwitchEventMut.RemoveTwitchEventActor(self);
	}

	Super.Destroyed();
}

//All twitch event actors that are spawned are added to a list in the mutator. The following functions are used by that API.
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	return true;
}

function bool PreventDeathForPawn(Pawn Victim)
{
	return false;
}

function bool IgnoreFallDamageForPawn(Pawn Victim)
{
	return false;
}

function ProcessKill(Controller Killer, Pawn Killed)
{
	//override this function for custom behaviour.
}

function ProcessDamage(out int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType )
{
	//override this function for custom behaviour.
}