class TwitchEventWaveActorSpawner extends TwitchEvent;

var class<TwitchEventWaveActor> TwitchEventWaveActorClass;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local TwitchEventWaveActor TwitchEventWaveActor;

	foreach TwitchEventMut.DynamicActors(class'TwitchEventWaveActor', TwitchEventWaveActor)
	{
		if(TwitchEventWaveActor.Class != default.TwitchEventWaveActorClass)
		{
			continue;
		}

		if(TwitchEventWaveActor.bPendingCompletion)
		{
			continue;
		}
		
		TwitchEventWaveActor.ExtendDuration(Instigator, Response);
		return;
	}


	TwitchEventWaveActor = TwitchEventMut.Spawn(default.TwitchEventWaveActorClass);
	TwitchEventWaveActor.Initialize(TwitchEventMut, Instigator, Response);
}

defaultproperties
{

}