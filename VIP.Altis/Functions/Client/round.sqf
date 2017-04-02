function_Client_HandleRoundStart =
{
	_routePlanner = _this select 0;
	player removeAction (player getVariable 'actionIdReady');
	[] call functionHandleAliveMode;
	if (_routePlanner == player)
	then
	{
		['NotificationPositive', ['Prepare', 'Prepare for round. You are route planner.']] call bis_fnc_showNotification;
		[] call function_Client_EstablishPlanRouteMenu;
	}
	else
	{
		_message = format ['Prepare for round. Awaiting route plan from %1.', name _routePlanner];
		['NotificationPositive', ['Prepare', _message]] call bis_fnc_showNotification;
	};
};

function_Client_EstablishPlanRouteMenu =
{
	_planRouteId = player addAction ["<t color='#0099FF'>Plan Route</t>", functionPlanRoute, "", 1000, true, true, "", "alive _target"];
	player setVariable ['actionIdPlanRoute', _planRouteId];
};

function_Client_HandleRoundMainPhase =
{
	_title = 'undefined';
	_message = 'undefined';
	if ((player getVariable 'team') == sideConvoy)
	then
	{
		_title = 'Escort';
		_message = 'Convoy route decided. Escort VIP to destination.';
	}
	else
	{
		_title = 'Ambush';
		_message = 'Convoy route revealed. Capture VIP.';
	};
	['NotificationPositive', [_title, _message]] call bis_fnc_showNotification;
	{
		[_x] call functionEstablishListenDamage;
	} forEach (missionNamespace getVariable (format ['vehicles%1', [(player getVariable 'team')] call functionGetTeamLiteral]));
	monitorVipPositionScript = [] spawn function_Client_MonitorVipPosition;
};

function_Client_NotifyVipOutsideTunnelIllegal =
{
	//['NotificationNegative', ['Warning', format ['Return to route or lose in %1 seconds.', vipOutsideTunnelConvoyGracePeriod], 10]] call bis_fnc_showNotification;
};

function_Client_HandleAmbush =
{
	private _log = 'Client handling ambush.';
	systemChat _log;
	diag_log _log;
	['Notification', ['Ambush', 'Convoy ambushed. Route deviation authorised.']] call bis_fnc_showNotification;
};

function_Client_HandleVipTeam =
{
	_type = 'undefined';
	_title = 'undefined';
	_message = 'undefined';
	if ((vip getVariable 'team') == (player getVariable 'team'))
	then
	{
		if ((player getVariable 'team') == sideConvoy)
		then
		{
			_type = 'NotificationPositive';
			_title = 'Escort';
			_message = 'VIP secured. Escort to destination.';
		}
		else
		{
			_type = 'NotificationPositive';
			_title = 'Hold';
			_message = format ['VIP captured. Hold for %1 seconds away from route.', vipOutsideTunnelAmbushHoldPeriod];
		};
	}
	else
	{
		if ((player getVariable 'team') == sideConvoy)
		then
		{
			_type = 'NotificationNegative';
			_title = 'Secure';
			_message = 'VIP lost. Secure from ambush team.';
		}
		else
		{
			_type = 'NotificationNegative';
			_title = 'Capture';
			_message = 'VIP lost. Secure from convoy team.';
		};
	};
	[_type, [_title, _message]] call bis_fnc_showNotification;
};

function_Client_HandleLastAlive =
{
	['NotificationNegative', ['Last Standing', 'You are the last standing. The rest of your team has died.']] call bis_fnc_showNotification;
};

function_Client_HandleRoundEnd =
{
	_teamVictor = _this select 0;
	if ((player getVariable 'team') == _teamVictor)
	then
	{
		['NotificationPositive', ['Victory', 'Your team won the round.']] call bis_fnc_showNotification;
	}
	else
	{
		['NotificationNegative', ['Defeat', 'Your team lost the round.']] call bis_fnc_showNotification;
	};
	terminate monitorRoundTimeScript;
	terminate monitorVipPositionScript;
};

function_Client_HandleInsufficientPlayers =
{
	['NotificationNegative', ['Insufficient', 'Insufficient players to proceed. Please ready up.']] call bis_fnc_showNotification;
	[] call function_Client_EstablishReadyScrollMenu;
};