//==================
//Twitch x Killing Floor
//By: Skell (Jean-David Veilleux-Foppiano)
//
// Twitch x Killing Floor is a user interaction mod that allows for players watching via
// the Twitch viewer (through Streamlabs) to interact with Killing Floor in realtime.
//==================
class TwitchEventMut extends Mutator;

var TwitchBroadcastHandler TwitchBroadcastHandler;
var TwitchRule TwitchRule;


/* Any data we want to store in a global context for communication between Twitch actors. */
var private array<Pawn> PreventDeathList;
var private array<Pawn> IgnoreFallDamageList;

var private array<TwitchEventActor> TwitchEventActorList;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetupBroadcaster();
	SetupGameRule();
}

function SetupBroadcaster()
{
	local BroadcastHandler BroadcastHandler;
	BroadcastHandler = Level.Game.BroadcastHandler;

	TwitchBroadcastHandler = Spawn(class'TwitchBroadcastHandler');
	TwitchBroadcastHandler.TwitchEventMut = Self;
	Level.Game.BroadcastHandler = TwitchBroadcastHandler;

	if(Level.Game.BroadcastHandler != None)
	{
		Level.Game.BroadcastHandler.NextBroadcastHandler = BroadcastHandler;
	}
	else
	{
		Level.Game.BroadcastHandler = BroadcastHandler;
	}
}

function SetupGameRule()
{
	TwitchRule = Spawn(class'TwitchRule');
	TwitchRule.TwitchEventMut = Self;
	Level.Game.AddGameModifier(TwitchRule);
}

function AddTwitchEventActor(TwitchEventActor TwitchEventActor)
{
	if(TwitchEventActor == None)
	{
		return;
	}

	TwitchEventActorList[TwitchEventActorList.Length] = TwitchEventActor;
}

function RemoveTwitchEventActor(TwitchEventActor TwitchEventActor)
{
	local int Index;

	if(TwitchEventActorList.Length == 0)
	{
		return;
	}

	for(Index = TwitchEventActorList.Length - 1; Index > -1; Index--)
	{
		if(TwitchEventActorList[Index] == TwitchEventActor)
		{
			TwitchEventActorList.Remove(Index, 1);
			break;
		}
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int Index;

	for(Index = TwitchEventActorList.Length - 1; Index > -1; Index--)
	{
		if(TwitchEventActorList[Index] != None && !TwitchEventActorList[Index].CheckReplacement(Other, bSuperRelevant))
		{
			return false;
		}
	}

	return true;
}

function bool ShouldPreventDeath(Pawn Pawn)
{
	local int Index;

	for(Index = TwitchEventActorList.Length - 1; Index > -1; Index--)
	{
		if(TwitchEventActorList[Index] != None && TwitchEventActorList[Index].PreventDeathForPawn(Pawn))
		{
			return true;
		}
	}

	return false;	
}

function bool ShouldIgnoreFallDamage(Pawn Pawn)
{
	local int Index;

	for(Index = TwitchEventActorList.Length - 1; Index > -1; Index--)
	{
		if(TwitchEventActorList[Index] != None && TwitchEventActorList[Index].IgnoreFallDamageForPawn(Pawn))
		{
			return true;
		}
	}

	return false;	
}

function ScoreKill(Controller Killer, Pawn Killed)
{
	local int Index;

	for(Index = TwitchEventActorList.Length - 1; Index > -1; Index--)
	{
		if(TwitchEventActorList[Index] != None)
		{
			TwitchEventActorList[Index].ProcessKill(Killer, Killed);
		}
	}
}

function NetDamage(out int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType )
{
	local int Index;

	if(IsFallDamage(DamageType) && ShouldIgnoreFallDamage(Injured))
	{
		Damage = 0;
		return;
	}

	//Allow all twitch event actors to modify incomming damage.
	for(Index = TwitchEventActorList.Length - 1; Index > -1; Index--)
	{
		if(TwitchEventActorList[Index] != None)
		{
			TwitchEventActorList[Index].ProcessDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
		}
	}
}

static final function bool IsFallDamage(class<DamageType> DamageType)
{
	return DamageType == Class'Fell';
}

defaultproperties
{
	bAddToServerPackages=False
	GroupName="KF-TwitchEventMut"
	FriendlyName="Twitch Event Mut"
	Description="A means with which to run Twitch events."
}