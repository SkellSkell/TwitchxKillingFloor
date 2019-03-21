class PE_Randomizer extends TwitchPlayerEffect;

var KFGameType KFGT;

enum ERandomizerStage
{
	RS_Perk, //Awaiting perk randomization.
	RS_Weapon, //Awaiting weapon randomization.
	RS_Ammo, //Awaiting ammo refill.
	RS_Locked, //Awaiting inventory unlock.
	RS_Complete //Awaiting cleanup.
};

var ERandomizerStage RandomizerStage;

struct WeaponSet
{
	var class<KFVeterancyTypes> Perk;
	var array<string> WeaponList;
};

var array< WeaponSet > RandomizerList;

var KFPlayerController KFPC;

var int RandomIndex;

function bool InitEffect(Pawn NewPawn)
{
	local PE_Randomizer ActiveRandomizer;

	if(NewPawn == None)
	{
		return false;
	}

	//Find and remove all randomizers active on this pawn.
	foreach DynamicActors(class'PE_Randomizer', ActiveRandomizer)
	{
		if(ActiveRandomizer == Self || ActiveRandomizer.Pawn != NewPawn)
		{
			continue;
		}

		ActiveRandomizer.UnlockWeapons();
		ActiveRandomizer.RandomizerStage = RS_Complete;
		ActiveRandomizer.Destroy();
	}

	if(NewPawn != None)
	{
		KFPC = KFPlayerController(NewPawn.Controller);
		RandomIndex = Rand(RandomizerList.Length);
	}

	return Super.InitEffect(NewPawn);
}

function TickEffect()
{
	if(KFPC == None || KFPC.Pawn == None)
	{
		RandomizerStage = RS_Complete;
	}

	switch(RandomizerStage)
	{
		case RS_Perk:
			RandomizePerk();
			return;
		case RS_Weapon:
			RandomizeWeapons();
			return;
		case RS_Ammo:
			FillUpAmmo();
			return;
		case RS_Locked:
			EffectInterval = 60.f;
			RandomizerStage = RS_Complete;
			return;
		case RS_Complete:
			UnlockWeapons();
			EffectInterval = 0.f;
			return;
	}
}

function RandomizePerk()
{
	local class<KFVeterancyTypes> NewPerk;

	NewPerk = RandomizerList[RandomIndex].Perk;

	if(NewPerk == None)
	{
		return;
	}

	KFPC.SelectedVeterancy = NewPerk;

	KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ClientVeteranSkill = NewPerk;
	KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).ClientVeteranSkillLevel = 6;

	KFPC.bChangedVeterancyThisWave = true;

    KFHumanPawn(KFPC.Pawn).VeterancyChanged();

    //If this perk gives an armor bonus, then they're probably a medic.
	if(NewPerk.static.GetBodyArmorDamageModifier(KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo)) < 1.f)
	{
    	KFHumanPawn(KFPC.Pawn).ShieldStrength = 100;
	}

	ResetInventory();

    RandomizerStage = RS_Weapon;
}

function RandomizeWeapons()
{
	local Inventory Inv;
	local KFWeapon KFW;

	SpawnWeapons();

	for(Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
	{
		if(KFWeapon(Inv) != None)
		{
			KFW = KFWeapon(Inv);
		}
		else
		{
			continue;
		}

		KFW.bKFNeverThrow = true;
		KFW.bCanThrow = false;
	}

	//Force the player to switch to a new weapon.
	KFPC.ClientSwitchToBestWeapon();

    RandomizerStage = RS_Ammo;
}

function SpawnWeapons()
{
	local int Index;
	local Inventory Inv;
	local class<Weapon> WeaponClass;
	local Controller C;

	for(Index = 0; Index < RandomizerList[RandomIndex].WeaponList.Length; Index++)
	{
		WeaponClass = class<Weapon>(DynamicLoadObject(RandomizerList[RandomIndex].WeaponList[Index], class'Class'));

		if(WeaponClass == None)
		{
			continue;
		}

		Inv = Spawn(WeaponClass);

		if(Inv == None)
		{
			continue;
		}

		Inv.GiveTo(Pawn);
	
		if (Inv != None)
		{
			Inv.PickupFunction(Pawn);
		}

		//We need to notify people this gun has been spawned to load assets.
		for (C = Level.ControllerList; C != None; C = C.nextController)
	    {
	        if (KFPlayerController(C) != None)
	        {
	            KFPlayerController(C).ClientWeaponSpawned(WeaponClass, None);
	        }
	    }
	}
}

function ResetInventory()
{
	if(Pawn.Inventory == None)
	{
		return;
	}

	if(KFWeapon(Pawn.Weapon) != None && KFWeapon(Pawn.Weapon).bIsReloading) 
	{
		KFWeapon(Pawn.Weapon).bCanThrow = true;
		KFWeapon(Pawn.Weapon).ActuallyFinishReloading();
	}

	DestroyInventory(Pawn);

	GiveDefaultInventory(Pawn);
}

static final function DestroyInventory(Pawn Pawn)
{
    Pawn.Weapon = None;
    Pawn.SelectedItem = None;
    
    while (Pawn.Inventory != None)
    {
        Pawn.Inventory.Destroy();
    }
}

static final function GiveDefaultInventory(Pawn Pawn)
{
	local KFHumanPawn KFHumanPawn;
	local Inventory Inv;

	local int Index;

	KFHumanPawn = KFHumanPawn(Pawn);

	if(KFHumanPawn == None)
	{
		return;
	}

	for(Index = 0; Index < 16; Index++)
	{
		if(KFHumanPawn.RequiredEquipment[Index] == "")
		{
			continue;
		}

		KFHumanPawn.CreateInventory(KFHumanPawn.RequiredEquipment[Index]);
	}

	Index = 0;

	if(KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo) == None)
	{
		return;
	}

	for ( Inv = Pawn.Inventory; Inv != None && Index < 20; Inv = Inv.Inventory )
	{
		if(Frag(Inv) != None)
		{
			FillUpGrenades(Frag(Inv), KFPlayerReplicationInfo(Pawn.PlayerReplicationInfo));
			break;
		}

		Index++;
	}
}

static function FillUpGrenades(Frag Frag, KFPlayerReplicationInfo KFPRI)
{
	Frag.AddAmmo(5.f * KFPRI.ClientVeteranSkill.Static.AddExtraAmmoFor(KFPRI, Frag.FireModeClass[0].default.AmmoClass), 0);
}

function FillUpAmmo()
{
	local Inventory Inv;
	local KFWeapon KFW;
	local int MaxAmmo, CurAmmo;

	for(Inv = Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
	{
		if(KFWeapon(Inv) != None)
			KFW = KFWeapon(Inv);
		else
			continue;

		GetAmmoCount(KFW, MaxAmmo, CurAmmo);
		KFW.AddAmmo(MaxAmmo - CurAmmo, 0);

		if(KFW.bHasSecondaryAmmo)
		{
			MaxAmmo = KFW.MaxAmmo(1);
			CurAmmo = KFW.AmmoAmount(1);
			KFW.AddAmmo(MaxAmmo - CurAmmo, 1);
		}
	}

    RandomizerStage = RS_Locked;
}

static final function GetAmmoCount(KFWeapon KFW, out int MaxAmmo, out int CurAmmo)
{
	local float retMax, retCur;
	
	KFW.GetAmmoCount(retMax, retCur);

	MaxAmmo = int(retMax);
	CurAmmo = int(retCur);
}

function UnlockWeapons()
{
	local Inventory Inv;
	local KFWeapon KFW;

	for(Inv = Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if(KFWeapon(Inv) != None)
		{
			KFW = KFWeapon(Inv);
		}
		else
		{
			continue;
		}

		if(IsDefaultEquipment(Pawn, Inv))
		{
			continue;
		}

		KFW.bKFNeverThrow = false;
		KFW.bCanThrow = true;
	}
}

static final function bool IsDefaultEquipment(Pawn Pawn, Inventory Inventory)
{
	local UnrealPawn UnrealPawn;
	local int Index;

	UnrealPawn = UnrealPawn(Pawn);

	if(UnrealPawn == None)
	{
		return false;
	}

	for(Index = 0; Index < 16; Index++)
	{
		if(UnrealPawn.RequiredEquipment[Index] != "" && UnrealPawn.RequiredEquipment[Index] ~= string(Inventory.Class))
		{
			return true;
		}
	}

	return false;
}

defaultproperties
{
	EffectInterval = 0.1f
	EffectLifeSpan = 0.f

	RandomizerStage=RS_Perk

	RandomizerList(0)=(Perk=Class'KFMod.KFVetFieldMedic',WeaponList=("KFMod.MP5MMedicGun","KFMod.KrissMMedicGun","KFMod.M32GrenadeLauncher","KFMod.Machete"))
	RandomizerList(1)=(Perk=Class'KFMod.KFVetFieldMedic',WeaponList=("KFMod.MP5MMedicGun","KFMod.MP7MMedicGun","KFMod.KrissMMedicGun","KFMod.Katana","KFMod.MK23Pistol"))
	RandomizerList(2)=(Perk=Class'KFMod.KFVetFieldMedic',WeaponList=("KFMod.MP5MMedicGun","KFMod.MP7MMedicGun","KFMod.M14EBRBattleRifle"))

	RandomizerList(3)=(Perk=Class'KFMod.KFVetSupportSpec',WeaponList=("KFMod.BoomStick","KFMod.AA12AutoShotgun","KFMod.Katana"))
	RandomizerList(4)=(Perk=Class'KFMod.KFVetSupportSpec',WeaponList=("KFMod.BoomStick","KFMod.KSGShotgun","KFMod.Axe","KFMod.MK23Pistol"))
	RandomizerList(5)=(Perk=Class'KFMod.KFVetSupportSpec',WeaponList=("KFMod.BoomStick","KFMod.BenelliShotgun","KFMod.Katana","KFMod.MK23Pistol"))

	RandomizerList(6)=(Perk=Class'KFMod.KFVetSharpshooter',WeaponList=("KFMod.M14EBRBattleRifle","KFMod.Winchester"))
	RandomizerList(7)=(Perk=Class'KFMod.KFVetSharpshooter',WeaponList=("KFMod.Winchester","KFMod.SPSniperRifle","KFMod.Magnum44Pistol"))
	RandomizerList(8)=(Perk=Class'KFMod.KFVetSharpshooter',WeaponList=("KFMod.M14EBRBattleRifle","KFMod.Deagle","KFMod.DualMK23Pistol"))

	RandomizerList(9)=(Perk=Class'KFMod.KFVetCommando',WeaponList=("KFMod.SCARMK17AssaultRifle","KFMod.AK47AssaultRifle","KFMod.Katana"))
	RandomizerList(10)=(Perk=Class'KFMod.KFVetCommando',WeaponList=("KFMod.FNFAL_ACOG_AssaultRifle","KFMod.SCARMK17AssaultRifle","KFMod.Machete","KFMod.MK23Pistol"))
	RandomizerList(11)=(Perk=Class'KFMod.KFVetCommando',WeaponList=("KFMod.SCARMK17AssaultRifle","KFMod.M32GrenadeLauncher","KFMod.MK23Pistol"))

	RandomizerList(12)=(Perk=Class'KFMod.KFVetFirebug',WeaponList=("KFMod.HuskGun","KFMod.DualFlareRevolver","KFMod.MK23Pistol"))
	RandomizerList(13)=(Perk=Class'KFMod.KFVetFirebug',WeaponList=("KFMod.Trenchgun","KFMod.DualFlareRevolver","KFMod.Deagle"))
	RandomizerList(14)=(Perk=Class'KFMod.KFVetFirebug',WeaponList=("KFMod.FlameThrower","KFMod.DualFlareRevolver"))

	RandomizerList(15)=(Perk=Class'KFMod.KFVetDemolitions',WeaponList=("KFMod.M32GrenadeLauncher","KFMod.M79GrenadeLauncher","KFMod.MK23Pistol","KFMod.PipeBombExplosive"))
	RandomizerList(16)=(Perk=Class'KFMod.KFVetDemolitions',WeaponList=("KFMod.M32GrenadeLauncher","KFMod.M4203AssaultRifle","KFMod.PipeBombExplosive"))
	RandomizerList(17)=(Perk=Class'KFMod.KFVetDemolitions',WeaponList=("KFMod.M32GrenadeLauncher","KFMod.SPGrenadeLauncher","KFMod.Deagle","KFMod.PipeBombExplosive"))

	//RandomizerList(12)=(Perk=Class'KFMod.KFVetBerserker',WeaponList=("KFMod.Axe","KFMod.Machete","KFMod.SPSniperRifle","KFMod.FlareRevolver"))
	//RandomizerList(13)=(Perk=Class'KFMod.KFVetBerserker',WeaponList=("KFMod.Axe","KFMod.Katana","KFMod.Winchester"))
	//RandomizerList(14)=(Perk=Class'KFMod.KFVetBerserker',WeaponList=("KFMod.ClaymoreSword","KFMod.Katana","KFMod.FlareRevolver","KFMod.MP5MMedicGun"))
}