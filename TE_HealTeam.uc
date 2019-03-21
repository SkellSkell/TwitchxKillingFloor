class TE_HealTeam extends TwitchEvent;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local int Index;
	local array<Pawn> PawnList;

	PawnList = GetPlayerList(TwitchEventMut);

	for(Index = 0; Index < PawnList.Length; Index++)
	{
		PawnList[Index].GiveHealth(100, PawnList[Index].HealthMax);
	}

	Response = Instigator$" healed the whole squad!";
}