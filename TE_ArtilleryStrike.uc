class TE_ArtilleryStrike extends TwitchEvent;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local Controller C;

	local KFGameType KFGT;
	local int ZedsKilled;

	for (C = TwitchEventMut.Level.ControllerList; C != None; C = C.NextController)
	{
		if(KFPlayerController(C) != None)
		{
			KFPlayerController(C).ClientShakeView(vect(400, 400, 400), vect(12500, 12500, 12500), 6.f, vect(20, 20, 50), vect(12500, 12500, 12500), 2.f);
		}
	}

	if(TwitchEventMut == None || KFGameType(TwitchEventMut.Level.Game) == None)
	{
		return;
	}

	KFGT = KFGameType(TwitchEventMut.Level.Game);

	if(KFGT.TotalMaxMonsters <= 0)
	{
		Response = Instigator$" called in an airstrike! There were no zeds outside of the combat zone though so none were hit...";
		return;
	}

	ZedsKilled = 20 + Rand(10);
	ZedsKilled = Min(KFGT.TotalMaxMonsters, ZedsKilled);

	Response = Instigator$" called in an airstrike! "$ZedsKilled$" zeds were killed!";
	
	KFGT.TotalMaxMonsters -= ZedsKilled; 
}

defaultproperties
{

}