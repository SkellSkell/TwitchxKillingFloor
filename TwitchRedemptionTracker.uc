class TwitchRedemptionTracker extends Object
	config(TwitchTracker);

struct RedemptionData
{
	var String Name;
	var int Count;
};

var config array<RedemptionData> RedemptionDataList;

function IncrementRedemptionCount(string RedemptionName)
{
	local int Index;
	local bool bFoundRedemption;
	bFoundRedemption = false;
	
	for(Index = 0; Index < RedemptionDataList.Length; Index++)
	{
		if(RedemptionDataList[Index].Name != RedemptionName)
		{
			continue;
		}

		RedemptionDataList[Index].Count++;
		bFoundRedemption = true;
		break;
	}

	if(!bFoundRedemption)
	{
		RedemptionDataList[RedemptionDataList.Length] = GetRedemptionData(RedemptionName);
	}

	SaveConfig();
}

static final function RedemptionData GetRedemptionData(string RedemptionName)
{
	local RedemptionData RedemptionData;
	RedemptionData.Name = RedemptionName;
	RedemptionData.Count = 1;
	return RedemptionData;
}

defaultproperties
{

}