// Imports
call compile preprocessFileLineNumbers 'Functions\Client\respawn.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\routePlan.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\intelligence.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\ready.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\round.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\hud.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\equipment.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\utilities.sqf';
call compile preprocessFileLineNumbers 'Functions\Client\vip.sqf';
call compile preprocessFileLineNumbers 'Functions\Server\respawn.sqf';
call compile preprocessFileLineNumbers 'Functions\Server\ready.sqf';
call compile preprocessFileLineNumbers 'Functions\Server\vip.sqf';
call compile preprocessFileLineNumbers 'Functions\Server\players.sqf';
call compile preprocessFileLineNumbers 'Functions\Server\utilities.sqf';
call compile preprocessFileLineNumbers 'Functions\Server\round.sqf';
call compile preprocessFileLineNumbers 'Functions\Common\utilities.sqf';
call compile preprocessFileLineNumbers 'Functions\Common\object.sqf';
call compile preprocessFileLineNumbers 'Functions\Common\loadout.sqf';
call compile preprocessFileLineNumbers 'Functions\Common\vip.sqf';
call compile preprocessFileLineNumbers 'Functions\Common\players.sqf';
call compile preprocessFileLineNumbers 'constants.sqf';

// Common
monitorVipPositionScript = scriptNull;
monitorRoundTimeScript = scriptNull;
developerMode = false;

// Serverside
if (isServer or isDedicated)
then
{
	diag_log 'Serverside scripting may be assessed from this point on.';
	['playersData', []] call functionPublicVariableSetValue;
	['routePlanner', objNull] call functionPublicVariableSetValue;
	['matchStarted', false] call functionPublicVariableSetValue;
	['routePoints', []] call functionPublicVariableSetValue;
	['roundAmbushed', false] call functionPublicVariableSetValue;
	['vip', objNull] call functionPublicVariableSetValue;
	['sideConvoy', objNull] call functionPublicVariableSetValue;
	['sideAmbush', objNull] call functionPublicVariableSetValue;
	['vehiclesConvoy', []] call functionPublicVariableSetValue;
	['vehiclesAmbush', []] call functionPublicVariableSetValue;
	['victoriesTeam1', 0] call functionPublicVariableSetValue;
	['victoriesTeam2', 0] call functionPublicVariableSetValue;
	['roundTimer', ([] call function_PseudoObject_Create)] call functionPublicVariableSetValue;
	[] call functionResetRoundTimer;
	playersReady = [];
	[] call functionEstablishPositions;
	[] call functionEstablishTeams;
	[] call functionEstablishServerPlayableUnits;
	[] call function_Server_ListenEntityKilled;
};

// Clientside
if (!isServer or !isDedicated)
then
{
	waitUntil {!(isNull player) and hasInterface and !(isNull (findDisplay screenDisplayID))};
	diag_log 'Clientside scripting may be assessed from this point on.';
	[] call function_Client_DispatchClientReady;
	playerLoadoutConvoy = false;
	playerLoadoutAmbush = false;
	routePlanNamespace = objNull;
	player setVariable ['team', side player, true];
	[] call functionEstablishRespawnSystem;
	[player] call functionEstablishPlayerScrollMenu;
	[] call functionEstablishMapGraphics;
	[] call functionEstablishScreenKeyActions;
	[] spawn functionHandleVirtualArsenalOpenClose;
	[player] call functionEstablishListenDamage;
	[] call functionEstablishPlayerHud;
	[] call functionToggleOperationalHUD;
};