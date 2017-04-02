function_Server_StartRound =
{
	private ['_playersConvoy', '_routePlanner'];
	_playersConvoy = _this select 0;
	_teamCounts = [] call functionGetPlayerCountForTeams;
	if (((_teamCounts select 0) > 0 && (_teamCounts select 1) > 0) || developerMode)
	then
	{
		// Select random route planner
		_routePlanner = selectRandom _playersConvoy;
		diag_log format ['name: %1. _routePlanner: %2.', name _routePlanner, _routePlanner];
		['routePlanner', _routePlanner] call functionPublicVariableSetValue;
		// Notify clients
		[[_routePlanner], 'function_Client_HandleRoundStart', [] call functionGetPlayers] call BIS_fnc_MP;
		// Update player data
		[] call function_Server_UpdatePlayerData_RoundStart;
	}
	else
	{
		[] call function_Server_HandleInsufficientPlayers;
	};
	[] call functionResetRoundTimer;
};

function_Server_HandleInsufficientPlayers =
{
	['matchStarted', false] call functionPublicVariableSetValue;
	[[], 'function_Client_HandleInsufficientPlayers', [] call functionGetPlayers] call BIS_fnc_MP;
};

function_Server_HandleRoutePlan =
{
	_routePoints = _this select 0;
	diag_log 'Server handling route plan.';
	[_routePoints] call function_Server_StartRoundMainPhase;
};

function_Server_StartRoundMainPhase =
{
	_routePoints = _this select 0;
	diag_log 'Server starting round main phase.';
	['routePlanner', objNull] call functionPublicVariableSetValue;
	['routePoints', _routePoints] call functionPublicVariableSetValue;
	[[], 'function_Client_HandleRoundMainPhase', [] call functionGetPlayers] call BIS_fnc_MP;
	[] call function_Server_EstablishVIP;
	[] call function_Server_SpawnStartingVehicles;
	monitorRoundTimeScript = [] spawn function_Server_MonitorRoundTime;
};

function_Server_SpawnStartingVehicles =
{
	{
		_vehicle = 'C_SUV_01_F' createVehicle ([startPositionConvoy, 0, startPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
		['vehiclesConvoy', _vehicle] call functionPublicVariableAppendToArray;
		_vehicle setVariable ['team', sideConvoy, true];
		[_vehicle] call functionEstablishListenDamage;
		_vehicle = 'B_G_Offroad_01_F' createVehicle ([destinationPosition, 0, startPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
		['vehiclesAmbush', _vehicle] call functionPublicVariableAppendToArray;
	} forEach [1, 2, 3, 4];
	_vehicle = 'B_Heli_Light_01_F' createVehicle ([startPositionConvoy, 0, startPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
	['vehiclesConvoy', _vehicle] call functionPublicVariableAppendToArray;
	[_vehicle] call functionEstablishListenDamage;
	_vehicle = 'B_Heli_Light_01_F' createVehicle ([destinationPosition, 0, startPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
	['vehiclesAmbush', _vehicle] call functionPublicVariableAppendToArray;
};

function_Server_HandleAmbush =
{
	private _log = 'Server handling ambush.';
	diag_log _log;
	if (!roundAmbushed)
	then
	{
		['roundAmbushed', true] call functionPublicVariableSetValue;
		private _players = [] call functionGetPlayers;
		private _log = format ['_players: %1.', _players];
		diag_log _log;
		[[], 'function_Client_HandleAmbush', _players] call BIS_fnc_MP;
	};
};

function_Server_MonitorRoundTime =
{
	private _elapsed = 0;
	while {true}
	do
	{
		scopeName 'loop';
		sleep monitorRoundTimeInterval;
		_elapsed = _elapsed + 1;
		diag_log format ['Elapsed: %1.', _elapsed];
		if (_elapsed > roundTime)
		then
		{
			diag_log 'Round time elapsed.';
			// Ambush Victory
			[sideAmbush] spawn function_Server_HandleRoundEnd;
			breakOut 'loop';
		}
		else
		{
			diag_log 'Round time remaining.';
			roundTimer setVariable ['elapsed', _elapsed, true];
		};
	};
};

function_Server_HandleRoundEnd =
{
	_teamVictor = _this select 0;
	terminate monitorRoundTimeScript;
	_victoryCountIdentifier = 'victoriesTeam1';
	if (_teamVictor == OPFOR)
	then
	{
		_victoryCountIdentifier = 'victoriesTeam2';
	};
	[_victoryCountIdentifier] call functionPublicVariableIncrementInteger;
	_victoriesCount = missionNamespace getVariable _victoryCountIdentifier;
	if (_victoriesCount == 2)
	then
	{
		[_teamVictor] call function_Server_EndMatch;
	}
	else
	{
		terminate monitorVipPositionScript;
		[[_teamVictor], 'function_Client_HandleRoundEnd', [] call functionGetPlayers] call BIS_fnc_MP;
		sleep roundGapSeconds;
		[] call function_Server_ClearRound;
		[] call function_Server_SwapTeams;
		[([objNull, sideConvoy] call functionGetPlayers)] call function_Server_StartRound;
	};
};

functionResetRoundTimer =
{
	roundTimer setVariable ['elapsed', 0, true];
};

function_Server_SwapTeams =
{
	private _previousConvoy = sideConvoy;
	private _previousAmbush = sideAmbush;
	['sideConvoy', _previousAmbush] call functionPublicVariableSetValue;
	['sideAmbush', _previousConvoy] call functionPublicVariableSetValue;
};

function_Server_ClearRound =
{
	['routePoints', []] call functionPublicVariableSetValue;
	['roundAmbushed', false] call functionPublicVariableSetValue;
	deleteVehicle vip;
	['vip', objNull] call functionPublicVariableSetValue;
	{
		deleteVehicle _x;
	} forEach (vehiclesConvoy + vehiclesAmbush);
	['vehiclesConvoy', []] call functionPublicVariableSetValue;
	['vehiclesAmbush', []] call functionPublicVariableSetValue;
};

function_Server_EndMatch =
{
	private _teamVictor = _this select 0;
	private _teamLoser = BLUFOR;
	if (_teamVictor == BLUFOR)
	then
	{
		_teamLoser = OPFOR;
	};
	[['MissionAccomplished', true, true], 'BIS_fnc_endMission', _teamVictor] call BIS_fnc_MP;
	[['MissionFailed', false, true], 'BIS_fnc_endMission', _teamLoser] call BIS_fnc_MP;
	call BIS_fnc_endMission;
};