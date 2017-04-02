function_Client_EstablishReadyScrollMenu =
{
	_readyId = player addAction ["<t color='#FF8000'>Ready</t>", function_Client_HandlePlayerReady, "", 1000, true, true, "", "alive _target"];
	player setVariable ['actionIdReady', _readyId];
};

function_Client_HandlePlayerReady =
{
	player removeAction (player getVariable 'actionIdReady');
	[[player], 'function_Server_HandlePlayerReady', false] call BIS_fnc_MP;
};