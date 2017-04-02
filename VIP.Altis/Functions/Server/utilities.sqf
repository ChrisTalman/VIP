function_Server_ListenEntityKilled =
{
	addMissionEventHandler ['EntityKilled', function_Server_HandleEntityKilled];
};

function_Server_HandleEntityKilled =
{
	_killed = _this select 0;
	_killer = _this select 1;
	diag_log format ['Killed: %1. Killer: %2.', name _killed, name _killer];
	[_killed, _killer] call function_Server_HandleVipKilled;
};