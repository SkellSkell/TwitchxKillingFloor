class TE_TeamAmmo extends TwitchEvent;

var float RefillPercent;

static function TriggerEvent(TwitchEventMut TwitchEventMut, string Instigator, array<string> ExtraInfo, out string Response)
{
	local int Index;
	local array<Pawn> PawnList;

	PawnList = GetPlayerList(TwitchEventMut);

	for(Index = 0; Index < PawnList.Length; Index++)
	{
		FillPlayerAmmo(PawnList[Index]);
	}

	Response = Instigator$" gave the team ammo!";
}

static final function FillPlayerAmmo(Pawn Pawn)
{
	local Inventory Inv;
	local KFWeapon KFW;

	local int MaxAmmo, CurAmmo;

	for(Inv = Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
	{
		KFW = KFWeapon(Inv);
		
		if(KFW == None)
		{
			continue;
		}

		GetAmmoCount(KFW, MaxAmmo, CurAmmo);
		KFW.AddAmmo(GetAmmoIncrease(MaxAmmo, CurAmmo), 0);

		if(KFW.bHasSecondaryAmmo)
		{
			MaxAmmo = KFW.MaxAmmo(1);
			CurAmmo = KFW.AmmoAmount(1);
			KFW.AddAmmo(GetAmmoIncrease(MaxAmmo, CurAmmo), 1);
		}
	}
}

static final function GetAmmoCount(KFWeapon KFW, out int MaxAmmo, out int CurAmmo)
{
	local float retMax, retCur;
	
	KFW.GetAmmoCount(retMax, retCur);

	MaxAmmo = int(retMax);
	CurAmmo = int(retCur);
}

static final function float GetAmmoIncrease(int MaxAmmo, int CurAmmo)
{
	return Min(MaxAmmo - CurAmmo, int(float(MaxAmmo) * default.RefillPercent));
}

defaultproperties
{
	RefillPercent=0.5f
}