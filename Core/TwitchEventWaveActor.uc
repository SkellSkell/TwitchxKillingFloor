//A TwitchEventActor that lasts for a wave (or multiple waves depending on implementation). Has appropriate events for wave start, wave end, and duration extension.
class TwitchEventWaveActor extends TwitchEventActor;

//Has this actor been initialized yet?
var bool bInitialized;

//Is this actor pending completion? (actor has cleaned up and is awaiting destroy)
var bool bPendingCompletion;

//Is this actor initialized and waiting to execute it's first wave function.
var bool bWaitingForFirstWave;

//The wave this actor has started at.
var private int StartWave;
//The number of waves this effect will last.
var private int WaveDuration;
//The wave we last ran wave events for.
var private int CurrentWave;

//Sound that will be played when this event is redeemed. (if multiple specified, it will play a randomly selected one)
var array<Sound> EventStartSounds;
//Sound that will be played when the first wave this event is relevant for has begun. (if multiple specified, it will play a randomly selected one)
var array<Sound> FirstWaveStartSounds;
//Sound that will be played when a wave (not including the first) this event is relevant for has begun. (if multiple specified, it will play a randomly selected one)
var array<Sound> WaveStartSounds;
//Sound that will be played when a wave this event is relevant for has completed. (if multiple specified, it will play a randomly selected one)
var array<Sound> WaveCompleteSounds;

var float EventStartSoundVolume;
var float FirstWaveStartSoundVolume;
var float WaveStartSoundVolume;
var float WaveCompleteSoundVolume;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Enable('Tick');
}

function Initialize(TwitchEventMut TwitchEventMutNew, string Instigator, out string Response)
{
	Super.Initialize(TwitchEventMutNew, Instigator, Response);

	if(EventStartSounds.Length > 0)
	{
		PlaySoundForPlayers(EventStartSounds[Rand(EventStartSounds.Length)], 1.f);
	}
}

function ExtendDuration(string Instigator, out string Response)
{
	WaveDuration++;
}

event Tick( float DeltaTime )
{
	Super.Tick(DeltaTime);

	if(!bInitialized && !KFGameType(Level.Game).bWaveInProgress)
	{
		InitializeWaveActor();
		return;
	}

	if(bInitialized)
	{
		if(CurrentWave != KFGameType(Level.Game).WaveNum && !KFGameType(Level.Game).bWaveInProgress)
		{
			CurrentWave = KFGameType(Level.Game).WaveNum;

			OnWaveComplete();

			if(CurrentWave > StartWave + WaveDuration)
			{
				OnEventEnded();
				return;
			}
		}
		else if(CurrentWave == KFGameType(Level.Game).WaveNum && KFGameType(Level.Game).bWaveInProgress)
		{
			OnWaveStart();
			CurrentWave = -1;
		}
	}
}

function InitializeWaveActor()
{
	if(bInitialized)
	{
		return;
	}

	log("initialized "$self);
	bInitialized = true;

	StartWave = KFGameType(Level.Game).WaveNum;

	//If we're still waiting on a wave to complete
	if(KFGameType(Level.Game).bWaveInProgress)
	{
		StartWave++;
	}
}

function OnWaveStart()
{
	if(bWaitingForFirstWave)
	{
		OnFirstWaveStart();
	}
	else
	{
		if(WaveStartSounds.Length > 0)
		{
			PlaySoundForPlayers(WaveStartSounds[Rand(WaveStartSounds.Length)], 1.f);
		}
	}
}

function OnFirstWaveStart()
{
	if(FirstWaveStartSounds.Length > 0)
	{
		PlaySoundForPlayers(FirstWaveStartSounds[Rand(FirstWaveStartSounds.Length)], 1.f);
	}

	bWaitingForFirstWave = false;
}

function OnWaveComplete()
{
	if(bWaitingForFirstWave)
	{
		return;
	}

	if(WaveCompleteSounds.Length > 0)
	{
		PlaySoundForPlayers(WaveCompleteSounds[Rand(WaveCompleteSounds.Length)], 1.f);
	}
}

function OnEventEnded()
{
	bPendingCompletion = true;
	Destroy();
}

function PlaySoundForPlayers(Sound Sound, float SoundVolume)
{
	local Controller C;
	local PlayerController P;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		P = PlayerController(C);

		if (P != None)
		{
			P.ClientPlaySound(Sound, true, SoundVolume, SLOT_None);
		}
	}
}

defaultproperties
{
	bInitialized = false
	bPendingCompletion = false
	bWaitingForFirstWave = true

	EventStartSoundVolume = 1.f
	FirstWaveStartSoundVolume = 1.f
	WaveStartSoundVolume = 1.f
	WaveCompleteSoundVolume = 1.f

	StartWave = -1
	CurrentWave = -1
	WaveDuration = 0
}