class TwitchPlayerEffectSpeed extends TwitchPlayerEffect;

var KF_StoryInventoryItem SpeedItem;
var class<KF_StoryInventoryItem> InventoryClass;
var float MovementSpeedModifier;

function StartEffect()
{
	SpeedItem = Pawn.Spawn(InventoryClass, Pawn,,,rot(0,0,0));

	if(SpeedItem == None)
	{
		Destroy();
	}

	SpeedItem.PickupClass = None;   
	SpeedItem.MovementSpeedmodifier = MovementSpeedModifier;
	SpeedItem.GiveTo(Pawn);
	Pawn.ModifyVelocity(0.f, Pawn.Velocity);
}

function EndEffect()
{
	if(SpeedItem != None)
	{
		Pawn.DeleteInventory(SpeedItem);
		Pawn.ModifyVelocity(0.f, Pawn.Velocity);
		SpeedItem.Destroy();
	}
}

defaultproperties
{
	EffectLifeSpan = 15.f

	InventoryClass = class'Inv_GasCan'
	MovementSpeedModifier = 1.f
}