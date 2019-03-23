class TEA_SpawnRateIncrease extends TwitchEventActor;

var KFLevelRules KFLR;  

var float Duration;
var float RateMultiplier;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Disable('Tick');
}

function Initialize(TwitchEventMut TwitchEventMut, string Instigator, out string Response)
{
	Super.Initialize(TwitchEventMut, Instigator, Response);

	foreach DynamicActors(class'KFLevelRules', KFLR) 
	{
		break;
	}

	if(KFLR == None)
	{
		Response = "TEA_SpawnRateIncrease Tried to speed up spawn rates but couldn't find a KFLevelRules to speed up (something is very wrong with the level)! Aborting spawn rate increase subsystem.";
		Destroy();
		return;
	}

	KFLR.WaveSpawnPeriod *= RateMultiplier;

	Response = Instigator$" sped up zed spawn rate for "$int(Duration)$" seconds!";

	SetTimer(Duration, false);
}

function Timer()
{
	KFLR.WaveSpawnPeriod /= RateMultiplier;
	Destroy();
}

defaultproperties
{
	Duration = 120.f
	RateMultiplier = 0.8f
}