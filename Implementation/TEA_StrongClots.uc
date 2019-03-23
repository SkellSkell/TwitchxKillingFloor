class TEA_StrongClots extends TwitchEventWaveActor;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Initialize(TwitchEventMut TwitchEventMutNew, string Instigator, out string Response)
{				
	Super.Initialize(TwitchEventMutNew, Instigator, Response);
	Response = Instigator$" injected next wave's Clots with something - they do a lot more damage now!";
}

function ExtendDuration(string Instigator, out string Response)
{
	Super.ExtendDuration(Instigator, Response);
	Response = Instigator$" has injected even more Clots with something - another wave of scary Clots!";
}

function ProcessDamage(out int Damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType )
{
	if(!bInitialized)
	{
		return;
	}

	if(ZombieClotBase(InstigatedBy) != None)
	{
		Damage *= 3;
		Momentum *= 3.f;
	}

	Super.ProcessDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{

}