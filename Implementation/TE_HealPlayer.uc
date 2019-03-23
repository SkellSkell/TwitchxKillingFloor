class TE_HealPlayer extends TwitchEvent;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local Pawn Pawn;

	Pawn = GetPlayer(TwitchEventMut, ExtraInfo);

	if(Pawn == None)
	{
		return;
	}

	Pawn.GiveHealth(100, Pawn.HealthMax);

	Response = Instigator$" healed "$Pawn.PlayerReplicationInfo.PlayerName$"!";
}