functionOpenEquipmentInterface =
{
	if ((position player) distance ([] call functionGetPlayerStartPosition) <= startPositionSpawnRadius)
	then
	{
		['Open', true] spawn BIS_fnc_arsenal;
	}
	else
	{
		_message = 'You must be within radius of start position to select equipment.';
		_rich = format ['<t color="#D00000">%1</t>', _message];
		systemChat _message;
		hint parseText _rich;
	};
};

functionHandleVirtualArsenalOpenClose =
{
	while {true}
	do
	{
		private _vipEquipped = false;
		private _vipVariables = [];
		waitUntil {!(isNull (uiNamespace getVariable 'RscDisplayArsenal'))};
		if (!(isNull vip) && (unitBackpack player) == vip)
		then
		{
			_vipEquipped = true;
			{
				_vipVariables pushBack [_x, (vip getVariable _x)];
			} forEach (allVariables vip);
		};
		waitUntil {isNull (uiNamespace getVariable 'RscDisplayArsenal')};
		if (_vipEquipped && (isNull vip))
		then
		{
			[] call functionCreateVip;
			{
				private _variableName = _x select 0;
				private _variableValue = _x select 1;
				vip setVariable [_variableName, _variableValue, true];
			} forEach _vipVariables;
		};
		// playerLoadout array format: uniform, vest, backpack, headgear, goggles, weapon items, assigned items, uniform items, vest items, backpack items
		missionNamespace setVariable [(format ['playerLoadout%1', [player getVariable 'team'] call functionGetTeamLiteral]), [uniform player] + [vest player] + [backpack player] + [headgear player] + [goggles player] + [weaponsItems player] + [assignedItems player] + [uniformItems player] + [vestItems player] + [backpackItems player]];
	};
};