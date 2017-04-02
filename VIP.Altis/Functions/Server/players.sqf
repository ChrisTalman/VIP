function_Server_HandlePlayerKilled =
{
	private _playerKilled = _this select 0;
	private _playerKiller = _this select 1;
	private _playerData = [_playerKilled] call functionGetPlayerData;
	_playerData setVariable ['dead', true, true];
	private _aliveTeamPlayers = [];
	{
		private _playerData = [_x] call functionGetPlayerData;
		if (!(_playerData getVariable 'dead'))
		then
		{
			_aliveTeamPlayers pushBack _x;
		};
	} forEach ([objNull, (_playerKilled getVariable 'team')] call functionGetPlayers);
	if ((count _aliveTeamPlayers) == 0)
	then
	{
		private _victorTeam = BLUFOR;
		if ((_playerKilled getVariable 'team') == _victorTeam)
		then
		{
			_victorTeam = OPFOR;
		};
		[_victorTeam] spawn function_Server_HandleRoundEnd;
	}
	else
	{
		if ((count _aliveTeamPlayers) == 1)
		then
		{
			[[], 'function_Client_HandleLastAlive', (_aliveTeamPlayers select 0)] call BIS_fnc_MP;
		};
	};
	if ((objectParent vip) == _playerKilled)
	then
	{
		[_playerKilled] call functionUnitDropBackpack;
	};
};

function_Server_PlayersData_InitialiseRecord =
{
	private ['_playerObject', '_playerData'];
	_playerObject = _this select 0;
	_playerData = [_playerObject] call functionGetPlayerData;
	if (isNull _playerData)
	then
	{
		_playerData = [] call function_PseudoObject_Create;
		diag_log _playerData;
		_playerData setVariable ['uid', getPlayerUID _playerObject, true];
		_playerData setVariable ['name', name _playerObject, true];
		_playerData setVariable ['team', _playerObject getVariable 'team', true];
		_playerData setVariable ['participant', false, true];
		_playerData setVariable ['dead', false, true];
		playersData pushBack _playerData;
		['playersData', playersData] call functionPublicVariableSetValue;
	}
	else
	{
		if (_playerData getVariable 'name' != name _playerObject)
		then
		{
			_playerData setVariable ['name', name _playerObject, true];
		};
	};
};

function_Server_UpdatePlayerData_RoundStart =
{
	{
		_playerData = _x;
		if ((_playerData getVariable 'dead'))
		then
		{
			_playerData setVariable ['dead', false, true];
		};
		{
			scopeName 'loop';
			if ((getPlayerUID _x) == (_playerData getVariable 'uid'))
			then
			{
				_playerData setVariable ['participant', true, true];
				breakOut 'loop';
			};
		} forEach playableUnits;
	} forEach playersData;
};