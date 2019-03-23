//TwitchEventActor that is tied to a specific player pawn.
class TwitchPlayerEffect extends TwitchEventActor;

var Pawn Pawn;

var float EffectInterval;
var float EffectLifeSpan;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Disable('Tick');
}

//Returns true if this actor successfully initlialized.
function bool InitEffect(Pawn NewPawn)
{
	Pawn = NewPawn;

	if(IsValid())
	{
		StartEffect();

		//If effect interval is equal to or less than 0 then we don't want to tick this.
		if(EffectInterval > 0.f)
		{
			SetTimer(EffectInterval, false);
		}

		//If the lifespan is equal to or less than 0 then the effect will manage itself.
		if(EffectLifeSpan > 0.f)
		{
			LifeSpan = EffectLifeSpan;
		}

		return true;
	}

	Destroy();
	return false;
}

function bool IsValid()
{
	if(Pawn == None)
	{
		return false;
	}

	if(Pawn.Health <= 0)
	{
		return false;
	}

	if(TwitchEventMut == None)
	{
		return false;
	}

	return true;
}

function Timer()
{
	if(!IsValid())
	{
		Destroy();
		return;
	}

	TickEffect();

	if(EffectInterval > 0.f)
	{
		SetTimer(EffectInterval, false);
	}
	else
	{
		Destroy();	
	}
}

event Destroyed()
{
	EndEffect();

	Super.Destroyed();
}

function StartEffect()
{
	//override this function for custom behaviour.
}

function TickEffect()
{
	//override this function for custom behaviour.
}

function EndEffect()
{
	//override this function for custom behaviour.
}

defaultproperties
{
	EffectInterval = 0.25f
	EffectLifeSpan = 0.6f
}