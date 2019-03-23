//TwitchEvent that spawns a TwitchPlayerEffect on a specified player pawn.
class TwitchEventPlayerEffect extends TwitchEvent;

var class<TwitchPlayerEffect> PlayerEffectClass;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local Pawn Pawn;
	local TwitchPlayerEffect PlayerEffect;

	Pawn = GetPlayer(TwitchEventMut, ExtraInfo);

	if(Pawn == None)
	{
		return;
	}

	PlayerEffect = TwitchEventMut.Spawn(default.PlayerEffectClass);
	PlayerEffect.Initialize(TwitchEventMut, Instigator, Response);
	PlayerEffect.InitEffect(Pawn);

	Response = GetPlayerEffectResponse(Pawn, Instigator);
}

static function string GetPlayerEffectResponse(Pawn Pawn, string Instigator)
{
	return "";
}

defaultproperties
{

}