class TEA_LowGravity extends TwitchEventActor;

enum EGravityStage
{
	GS_Start, //Awaiting low gravity.
	GS_LowGravity, //Awaiting gravity reset.
	GS_PostReset, //Awaiting delay to allow clients to receive net updates.
	GS_Complete //Awaiting cleanup.
};

struct PhysicsVolumeData
{
	var PhysicsVolume Volume;
	var float CachedGravityZ;
	var bool bCachedAlwaysRelevant;
	var ENetRole CachedRemoteRole;
};

var EGravityStage GravityStage;
var array<PhysicsVolumeData> PhysicsVolumeList;

var float Duration;
var float GravityModifier;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Disable('Tick');
}

function Initialize(TwitchEventMut TwitchEventMut, string Instigator, out string Response)
{
	local TEA_LowGravity ActiveLowGravityActor;

	Super.Initialize(TwitchEventMut, Instigator, Response);

	Response = Instigator$" has broken the laws of physics! Gravity has been reduced for "$int(Duration)$" seconds!";

	//Destroy any active low gravity actors
	foreach DynamicActors(class'TEA_LowGravity', ActiveLowGravityActor)
	{
		if(ActiveLowGravityActor == Self)
		{
			continue;
		}

		switch(ActiveLowGravityActor.GravityStage)
		{
			//The other actor is about to start up, we can just let it run and destroy this actor.
			case GS_Start:
				Destroy();
				return;
			//Reset the timer for the previous actor.
			case GS_LowGravity:
				ActiveLowGravityActor.SetTimer(ActiveLowGravityActor.Duration, false);
				Destroy();
				return;
			//Perform immediate cleanup of completed actor.
			case GS_PostReset:
				ActiveLowGravityActor.CleanUpVolumes();
				ActiveLowGravityActor.GravityStage = GS_Complete;
				ActiveLowGravityActor.Destroy();
				break;
		}
	}

	GravityStage = GS_LowGravity;
	SetLowGravity();
	SetTimer(Duration, false);
}

function Timer()
{
	switch(GravityStage)
	{
		case GS_LowGravity:
			ResetGravity();
			BroadcastMessage("Gravity has been reset to normal!", 'Twitch');
			GravityStage = GS_PostReset;
			SetTimer(5.f, false); //5 seconds is probably enough time for all clients to receive the net updates.
			break;
		case GS_PostReset:
			CleanUpVolumes();
			GravityStage = GS_Complete;
			SetTimer(5.f, false); //Defer destroy - not necessary but whatever.
			break;
		case GS_Complete:
			Destroy();
			break;
	}
}

//Modify gravity of all physics volumes and net update them.
function SetLowGravity()
{
	local PhysicsVolume	PV;
	local vector XYDir;
	local float ZDiff, Time, GravityZ;
	local JumpPad J;
	local NavigationPoint N;

	foreach AllActors(class'PhysicsVolume', PV)
	{
		PhysicsVolumeList[PhysicsVolumeList.Length] = GetPhysicsVolumeData(PV);
		GravityZ = PV.Gravity.Z * GravityModifier;

		PV.Gravity.Z = GravityZ;
		PV.NetUpdateTime = Level.TimeSeconds - 1;
		PV.bAlwaysRelevant = true;
		PV.RemoteRole = ROLE_DumbProxy;

		if ( PV.IsA('DefaultPhysicsVolume') )
			Level.DefaultGravity = PV.Gravity.Z; 

		for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
		{
			if(!N.IsA('JumpPad') || !PV.Encompasses(N))
			{
				continue;
			}

			J = JumpPad(N);

			if (J == None)
			{
				continue;
			}

			XYDir = J.JumpTarget.Location - J.Location;
			ZDiff = XYDir.Z;
			Time = 2.5f * J.JumpZModifier * Sqrt(Abs(ZDiff/GravityZ));
			J.JumpVelocity = XYDir/Time; 
			J.JumpVelocity.Z = ZDiff/Time - 0.5f * GravityZ * Time;
		}
	}
}

//Reset gravity of all physics volumes and net update them.
function ResetGravity()
{
	local int Index;
	local PhysicsVolume	PV;
	local vector XYDir;
	local float ZDiff, Time, GravityZ;
	local JumpPad J;
	local NavigationPoint N;

	for(Index = 0; Index < PhysicsVolumeList.Length; Index++)
	{
		PV = PhysicsVolumeList[Index].Volume;
		GravityZ = PhysicsVolumeList[Index].CachedGravityZ;

		PV.Gravity.Z = GravityZ;
		PV.NetUpdateTime = Level.TimeSeconds - 1;
		PV.bAlwaysRelevant = true;
		PV.RemoteRole = ROLE_DumbProxy;

		if ( PV.IsA('DefaultPhysicsVolume') )
			Level.DefaultGravity = PV.Gravity.Z; 

		for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
		{
			if(!N.IsA('JumpPad') || !PV.Encompasses(N))
			{
				continue;
			}

			J = JumpPad(N);

			if (J == None)
			{
				continue;
			}

			XYDir = J.JumpTarget.Location - J.Location;
			ZDiff = XYDir.Z;
			Time = 2.5f * J.JumpZModifier * Sqrt(Abs(ZDiff/GravityZ));
			J.JumpVelocity = XYDir/Time; 
			J.JumpVelocity.Z = ZDiff/Time - 0.5f * GravityZ * Time;
		}
	}
}

//Return volumes to original replication state that we found them in - unless they've been modified externally.
function CleanUpVolumes()
{
	local int Index;
	local PhysicsVolume	PV;

	for(Index = 0; Index < PhysicsVolumeList.Length; Index++)
	{
		PV = PhysicsVolumeList[Index].Volume;

		//Other code has potentially modified this actor, we'll leave it alone.
		if(PV.RemoteRole != ROLE_DumbProxy)
		{
			continue;
		}

		PV.bAlwaysRelevant = PhysicsVolumeList[Index].bCachedAlwaysRelevant;
		PV.RemoteRole = PhysicsVolumeList[Index].CachedRemoteRole;
	}
}

function BroadcastMessage(coerce string Msg, optional name Type )
{
	Level.Game.Broadcast(None, Msg, Type);
}

static final function PhysicsVolumeData GetPhysicsVolumeData(PhysicsVolume PV)
{
	local PhysicsVolumeData PVD;
	PVD.Volume = PV;
	PVD.CachedGravityZ = PV.Gravity.Z;
	PVD.bCachedAlwaysRelevant = PV.bAlwaysRelevant;
	PVD.CachedRemoteRole = PV.RemoteRole;
	return PVD;
}

defaultproperties
{
	GravityStage = GS_Start
	Duration = 30.f
	GravityModifier = 0.25f
}