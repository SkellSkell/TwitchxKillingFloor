//Spawns a specified TwitchEventActor.
class TwitchEventActorSpawner extends TwitchEvent;

var class<TwitchEventActor> TwitchEventActorClass;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local TwitchEventActor TwitchEventActor;
	TwitchEventActor = TwitchEventMut.Spawn(default.TwitchEventActorClass);
	TwitchEventActor.Initialize(TwitchEventMut, Instigator, Response);
}