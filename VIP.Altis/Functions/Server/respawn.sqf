function_Server_HandleClientReady =
{
	private ['_playerObject'];
	_playerObject = _this select 0;
	_playerObject hideObjectGlobal false;
	[_playerObject] call function_Server_PlayersData_InitialiseRecord;
	[[], 'function_Client_HandleClientReady', _playerObject] call BIS_fnc_MP;
};

functionHandlePlayableUnitLocalityChange =
{
	{
		if ((owner _x) == serverOwnershipID)
		then
		{
			[_x] call function_Server_UnitDisableHandleVip;
			[_x] spawn functionDelayedIslandRepositioning;
			[_x] call functionDisablePlayableUnit;
			[_x] call functionDisablePlayableUnitAI;
			[_x] call functionUnitAddDamagePrevention;
		}
		else
		{
			[_x] call functionUnitRemoveDamagePrevention;
		};
	} forEach playableUnits;
};

function_Server_UnitDisableHandleVip =
{
	_unit = _this select 0;
	[_unit] call functionUnitDropBackpack;
};

functionDelayedIslandRepositioning =
{
	_unitObject = _this select 0;
	sleep 1;
	_unitObject setPos respawnIslandPosition;
};

functionEstablishServerPlayableUnits =
{
	{
		_x addEventHandler ['Local', {[_this select 0, _this select 1] spawn functionHandlePlayableUnitLocalityChange}];
		[_x] call functionDisablePlayableUnit;
		_x setVariable ['team', side _x, true];
		_x setVariable ['respawning', true, true];
	} forEach playableUnits;
};

functionDisablePlayableUnit =
{
	private ['_playableUnitObject'];
	_playableUnitObject = _this select 0;
	_playableUnitObject disableAI 'ANIM';
	_playableUnitObject setDamage 0;
	_playableUnitObject hideObjectGlobal true;
};

functionDisablePlayableUnitAI =
{
	_unit = _this select 0;
	_groupMembers = units (group _unit);
	{
		if (_x != _unit)
		then
		{
			_x setDamage 1;
		};
	} forEach _groupMembers;
};

functionEstablishPositions =
{
	['startPositionConvoy', (selectRandom startPositions) select 0] call functionPublicVariableSetValue;
	['destinationPosition', (selectRandom startPositions) select 1] call functionPublicVariableSetValue;
	diag_log format ['startPositionConvoy: %1. destinationPosition: %2.', startPositionConvoy, destinationPosition];
};

functionEstablishTeams =
{
	_teamBluforRandom = round (random 1);
	_sideConvoy = BLUFOR;
	_sideAmbush = OPFOR;
	if (_teamBluforRandom == 1 && !developerMode)
	then
	{
		_sideConvoy = OPFOR;
		_sideAmbush = BLUFOR;
	};
	['sideConvoy', _sideConvoy] call functionPublicVariableSetValue;
	['sideAmbush', _sideAmbush] call functionPublicVariableSetValue;
};