functionGetPlayerData =
{
	// Arguments: player object
	// Returns: player data object
	private _player = _this select 0;
	private _playerData = [playersData, 'uid', getPlayerUID _player] call functionGetArrayObjectWithVariableValue;
	_playerData;
};

functionGetAlivePlayers =
{
	// Arguments: side
	// Returns: array of player objects
	private _side = _this select 0;
	private _players = [];
	{
		if (isPlayer _x)
		then
		{
			private _playerData = [_x] call functionGetPlayerData;
			if (!(isNull _playerData))
			then
			{
				if ((_playerData getVariable 'team' == _side) && (_playerData getVariable 'participant') && !(_playerData getVariable 'dead'))
				then
				{
					_players pushBack _x;
				};
			};
		};
	} forEach playableUnits;
	_players;
};