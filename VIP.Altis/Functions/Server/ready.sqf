function_Server_HandlePlayerReady =
{
	_player = _this select 0;
	playersReady pushBack _player;
	call function_Server_CheckAllPlayersReady;
};

function_Server_CheckAllPlayersReady =
{
	_allReady = true;
	_playersConvoy = [];
	_playersAmbush = [];
	{
		scopeName 'loop';
		if ((_x getVariable 'team') == sideConvoy)
		then
		{
			_playersConvoy pushBack _x;
		};
		if ((_x getVariable 'team') == sideAmbush)
		then
		{
			_playersAmbush pushBack _x;
		};
		if ((playersReady find _x) == -1)
		then
		{
			_allReady = false;
			breakOut 'loop';
		};
	} forEach ([] call functionGetPlayers);
	if ((_allReady && count _playersConvoy > 0 && count _playersAmbush > 0) || developerMode)
	then
	{
		[_playersConvoy, _playersAmbush] call function_Server_HandleAllPlayersReady;
	};
};

function_Server_HandleAllPlayersReady =
{
	_playersConvoy = _this select 0;
	_playersAmbush = _this select 1;
	// Declare all ready
	['matchStarted', true] call functionPublicVariableSetValue;
	// Update player records for participant status
	{
		_playerData = [_x] call functionGetPlayerData;
		_playerData setVariable ['participant', true, true];
	} forEach (_playersConvoy + _playersAmbush);
	// Start round
	[_playersConvoy] call function_Server_StartRound;
};