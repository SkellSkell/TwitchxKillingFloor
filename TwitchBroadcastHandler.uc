class TwitchBroadcastHandler extends BroadcastHandler;

var TwitchEventMut TwitchEventMut;

var TwitchRedemptionTracker TwitchRedemptionTracker;

//The string we're listening to for events.
const EVENT_PREFIX = "!TWITCH";

//The index where the event prefix is stored.
const PREFIX_INDEX = 0;
//The index where the name of the instigator of this command (their Twitch username) is stored.
const INSTIGATOR_INDEX = 1;
//The index where the name of the event of this command is stored.
const EVENT_INDEX = 2;
//The index where extra info is stored in the parsed command. Used by GetExtraInfo.
const EXTRAINFO_INDEX = 3;

struct EventInfo
{
	var string EventName;
	var class<TwitchEvent> EventClass;
};

var array<EventInfo> EventList;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if(Role != ROLE_Authority)
	{
		return;
	}

	TwitchRedemptionTracker = New(Self) class'TwitchRedemptionTracker';
}

function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	if(UTServerAdminSpectator(Sender) != None && TwitchEvent(Msg))
	{
		return;
	}

	Super.Broadcast(Sender, Msg, Type);
}

function bool TwitchEvent(string Command)
{
	local string Username;
	local string EventName;
	local array<string> ParsedCommand;

	local class<TwitchEvent> TwitchEvent;
	local string Response;

	ParsedCommand = ParseCommand(Command);

	switch(ParsedCommand.Length)
	{
	//Twitch commands must have at least 2 entries to be valid (eg: "!Twitch CLOTBOMB")
	case 0:
	case 1:
		return false;
		break;
	default:
		if(ParsedCommand[PREFIX_INDEX] != EVENT_PREFIX) {
			return false;
		}
		Username = ParsedCommand[INSTIGATOR_INDEX];
		EventName = ParsedCommand[EVENT_INDEX];
		break;
	}

	TwitchEvent = GetTwitchEvent(EventName);

	if(TwitchEvent != None)
	{
		log("Triggering event "$EventName$".", 'TWITCH');

		TwitchEvent.static.TriggerEvent(TwitchEventMut, Username, GetExtraInfo(ParsedCommand), Response);

		if(Response != "")
		{
			TwitchBroadcast("TWITCH: "$Response, 'Twitch');
		}

		if(TwitchRedemptionTracker != None)
		{
			TwitchRedemptionTracker.IncrementRedemptionCount(EventName);
		}
	}

	return true;
}

function class<TwitchEvent> GetTwitchEvent(string EventName)
{
	local int Index;
	
	for(Index = 0; Index < EventList.Length; Index++)
	{
		if(EventList[Index].EventName != EventName)
		{
			continue;
		}

		return EventList[Index].EventClass;
	}

	return None;
}

function AddEvents(array<EventInfo> NewEventList)
{
	local int Index;

	for(Index = 0; Index < NewEventList.Length; Index++)
	{
		log("Added event "$NewEventList[Index].EventName$".", 'TWITCH');
		EventList[EventList.Length] = NewEventList[Index];
	}
}

function TwitchBroadcast(coerce string Msg, optional name Type )
{
	local Controller C;
	local PlayerController P;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		P = PlayerController(C);

		if (P != None)
		{
			BroadcastText(None, P, Msg, Type);
		}
	}
}

static final function array<string> ParseCommand(string ExtraInfo)
{
	local int Index;
	local array<string> ParsedInfo;
	Split(ExtraInfo, " ", ParsedInfo);

	for(Index = 0; Index < ParsedInfo.Length; Index++)
	{
		//Do not sanitize the username.
		if(Index == INSTIGATOR_INDEX)
		{
			continue;
		}

		ParsedInfo[Index] = Caps(ParsedInfo[Index]);
	}

	return ParsedInfo;
}

static final function array<string> GetExtraInfo(array<string> ParsedCommand)
{
	local int Index;
	local array<string> NewExtraInfo;

	ParsedCommand.Remove(0, EXTRAINFO_INDEX);

	for(Index = 0; Index < ParsedCommand.Length; Index++)
	{
		NewExtraInfo[Index] = ParsedCommand[Index];
	}

	return NewExtraInfo;
}

defaultproperties
{
	EventList(0)=(EventName="CLOTBOMB",EventClass=class'TE_ClotBomb')
	EventList(1)=(EventName="SIRENBOMB",EventClass=class'TE_SirenBomb')
	EventList(2)=(EventName="HUSKBOMB",EventClass=class'TE_HuskBomb')
	EventList(3)=(EventName="CRAWLERBOMB",EventClass=class'TE_CrawlerBomb')
	EventList(4)=(EventName="FPBOMB",EventClass=class'TE_MicroFPBomb')
	EventList(5)=(EventName="SCBOMB",EventClass=class'TE_MicroSCBomb')

	EventList(6)=(EventName="VOMIT",EventClass=class'TE_PieFace')
	EventList(7)=(EventName="PUNT",EventClass=class'TE_Punt')
	EventList(8)=(EventName="SPEEDUP",EventClass=class'TE_SpeedIncrease')
	EventList(9)=(EventName="SPEEDDOWN",EventClass=class'TE_SpeedDecrease')
	EventList(10)=(EventName="GIVEMONEY",EventClass=class'TE_GiveCash')
	EventList(11)=(EventName="RANDPERK",EventClass=class'TE_Randomizer')
	EventList(12)=(EventName="SELFDESTRUCT",EventClass=class'TE_SelfDestruct')
	EventList(13)=(EventName="LOWGRAV",EventClass=class'TE_LowGravity')
	EventList(14)=(EventName="SHRINK",EventClass=class'TE_Shrink')

	EventList(15)=(EventName="HEALTEAM",EventClass=class'TE_HealTeam')
	EventList(16)=(EventName="AMMOTEAM",EventClass=class'TE_TeamAmmo')

	EventList(17)=(EventName="SPAWNRATE",EventClass=class'TE_SpawnRateIncrease')
	EventList(18)=(EventName="PUNTZEDS",EventClass=class'TE_PuntZeds')

	EventList(19)=(EventName="FREEZEPLAYERS",EventClass=class'TE_FreezePlayers')
	EventList(20)=(EventName="DOORDESTROYER",EventClass=class'TE_DoorDestroyer')
	EventList(21)=(EventName="STRONGCLOTS",EventClass=class'TE_StrongClots')
	EventList(22)=(EventName="FASTBLOATS",EventClass=class'TE_FastBloats')
}