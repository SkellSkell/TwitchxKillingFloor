//Base class for all TwitchEvent. Is never instantiated.
class TwitchEvent extends Object;

//TwitchEventMut TwitchEventMut - TwitchEventMut that triggered this event.
//string Instigator - Name (twitch name) of the user that triggered this event.
//array<String> ExtraInfo - Any custom info the event needs.
//out string Response - If this string is not null the "Twitch" PRI will use the say command with Response as the message.
static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	//override this for custom behaviour
}

//--------
//Helper functions for any event.
//--------

//Master player grabber. If extra info is passed it will try to get a player by name.
static final function Pawn GetPlayer(Actor Actor, optional array<string> ExtraInfo)
{
	local Pawn Pawn;

	if(ExtraInfo.Length > 0 && ExtraInfo[0] != "")
	{
		Pawn = GetPlayerByName(Actor, ExtraInfo[0]);
	}

	if(Pawn == None)
	{
		Pawn = GetRandomPlayer(Actor);
	}

	return Pawn;
}

static final function Pawn GetPlayerByName(Actor Actor, string PlayerName)
{
	local Controller C;
	local int TargetNameSize;

	TargetNameSize = Len(PlayerName);

	for (C = Actor.Level.ControllerList; C != None; C = C.NextController)
	{
		//We only want player pawns here.
		if(KFHumanPawn(C.Pawn) == None || C.Pawn.Health <= 0)
		{
			continue;
		}

		if(InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(PlayerName)) >= 0)
		{
			return C.Pawn;
		}

		/*
		if(Len(C.PlayerReplicationInfo.PlayerName) < TargetNameSize)
		{
			continue;
		}

		if(Left(C.PlayerReplicationInfo.PlayerName, TargetNameSize) ~= PlayerName)
		{
			return C.Pawn;
		}
		*/
	}

	return None;
}

static final function Pawn GetRandomPlayer(Actor Actor)
{
	local array<Pawn> PawnList;

	PawnList = GetPlayerList(Actor);

	if(PawnList.Length == 0)
	{
		return None;
	}

	return PawnList[Rand(PawnList.Length)];
}

static final function array<Pawn> GetPlayerList(Actor Actor)
{
	local Controller C;
	local array<Pawn> PawnList;

	for (C = Actor.Level.ControllerList; C != None; C = C.NextController)
	{
		if(KFHumanPawn(C.Pawn) != None && C.Pawn.Health > 0)
		{
			PawnList[PawnList.Length] = C.Pawn;
		}
	}

	return PawnList;
}

defaultproperties
{
	
}