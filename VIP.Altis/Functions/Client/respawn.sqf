function_Client_DispatchClientReady =
{
	[[player], 'function_Server_HandleClientReady', false] call BIS_fnc_MP;
};

function_Client_HandleClientReady =
{
	[] call functionHandleUnitNowControlledByPlayer;
};

functionEstablishRespawnSystem =
{
	player addEventHandler ['Respawn', functionHandlePlayerRespawnEvent];
	player addEventHandler ['Killed', functionHandlePlayerKilledEvent];
	[player] call functionUnitAddDamagePrevention;
};

functionHandleUnitNowControlledByPlayer =
{
	_playerData = [player] call functionGetPlayerData;
	diag_log format ['dead: %1.', _playerData getVariable 'dead'];
	if ((player getVariable 'team') != (_playerData getVariable 'team'))
	then
	{
		systemChat 'You cannot join this team.';
		[] call functionHandleWrongTeamMode;
	}
	else
	{
		if ((_playerData getVariable 'dead'))
		then
		{
			systemChat "You're dead.";
			[] call functionHandleDeathMode;
		}
		else
		{
			if (!matchStarted || (matchStarted && (_playerData getVariable 'participant')))
			then
			{
				systemChat "You're alive.";
				[] call functionHandleAliveMode;
			}
			else
			{
				systemChat "You're observing.";
				[] call functionHandleDeathMode;
			};
		};
	};
};

functionSpawnPlayer =
{
	player setVariable ['respawning', false, true];
	[player] call functionUnitRemoveDamagePrevention;
	private _log = 'Setting spawn position.';
	systemChat _log;
	diag_log _log;
	player setPos ([[] call functionGetPlayerStartPosition, 0, startPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos);
	private _log = 'Set spawn position.';
	systemChat _log;
	diag_log _log;
	_playerLoadout = missionNamespace getVariable (format ['playerLoadout%1', [(player getVariable 'team')] call functionGetTeamLiteral]);
	if ((typeName _playerLoadout) == 'ARRAY')
	then
	{
		[player, _playerLoadout] call functionUnitSetLoadout;
	}
	else
	{
		_defaultLoadout = missionNamespace getVariable (format ['defaultLoadout%1', [(player getVariable 'team')] call functionGetTeamLiteral]);
		[player, _defaultLoadout] call functionUnitSetLoadout;
	};
	[] call function_Client_EnablePlayer;
};

functionGetPlayerStartPosition =
{
	private _object = [player] call functionGetPlayerData;
	if ((isNull _object))
	then
	{
		_object = player;
	}; 
	private _startPosition = startPositionConvoy;
	if ((_object getVariable 'team') == sideAmbush)
	then
	{
		_startPosition = destinationPosition;
	};
	_startPosition;
};

functionHandlePlayerRespawnEvent =
{
	_playerObject = _this select 0;
	_playerCorpseObject = _this select 1;
	_playerObject setVariable ['team', (_playerCorpseObject getVariable 'team'), true];
	_playerObject setVariable ['uid', getPlayerUID player, true];
	[player] call functionUnitAddDamagePrevention;
	[] call functionEstablishBasicItems;
	[] call functionEstablishPlayerScrollMenu;
	[] call function_Client_DisablePlayer;
};

function_Client_DisablePlayer =
{
	player enableSimulation false;
};

function_Client_EnablePlayer =
{
	player enableSimulation true;
};

functionHandleAliveMode =
{
	[] call functionSpawnPlayer;
	[] call functionDeathSpectateEnd;
	[] call functionEstablishRouteHud;
	cutText ['', 'BLACK IN', 1, false];
};

functionHandlePlayerKilledEvent =
{
	_playerKilled = _this select 0;
	_playerKiller = _this select 1;
	[[_playerKilled, _playerKiller], 'function_Server_HandlePlayerKilled', false] call BIS_fnc_MP;
	if (_playerKilled == player)
	then
	{
		playerKilledCorpseObject = _playerKilled;
		call functionHandleDeathMode;
		player setVariable ['respawning', true, true];
	};
};

functionHandleDeathMode =
{
	//cutText ['', 'BLACK FADED', 604800, false];
	[] call functionDeathSpectateStart;
	[] call functionDisestablishRouteHud;
};

functionDeathSpectateStart =
{
	private _playerObject = player;
	private _viewTeams = [(player getVariable 'team')];
	private _viewAi = true;
	private _viewFreeCamera = false;
	private _viewThirdPerson = true;
	['Initialize', [_playerObject, _viewTeams, _viewAi, _viewFreeCamera, _viewThirdPerson]] call BIS_fnc_EGSpectator;
};

functionDeathSpectateEnd =
{
	['Terminate'] call BIS_fnc_EGSpectator;
};

functionPreventCloseDeathMenu =
{
	_codeOfKeyPressed = _this select 0;
	_preventDefaultKeyBehaviour = false;
	if (_codeOfKeyPressed == 1)
	then
	{
		_preventDefaultKeyBehaviour = true;
	}
	else
	{
		_preventDefaultKeyBehaviour = false;
	};
	_preventDefaultKeyBehaviour;
};

functionHandleWrongTeamMode =
{
	cutText ['', 'BLACK FADED', 604800, false];
};

functionEstablishPlayerScrollMenu =
{
	// Actions
	player addAction ['<t color="#0099FF">Equipment</t>', functionOpenEquipmentInterface, '', 1000, false, true, '', 'alive _target'];
	if (!matchStarted)
	then
	{
		[] call function_Client_EstablishReadyScrollMenu;
	};
	if (player == routePlanner)
	then
	{
		[] call function_Client_EstablishPlanRouteMenu;
	};
};