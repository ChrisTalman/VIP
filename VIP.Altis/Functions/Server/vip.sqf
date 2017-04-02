function_Server_EstablishVIP =
{
	[] call functionCreateVip;
	vip setVariable ['team', sideConvoy, true];
	[] spawn function_Server_MonitorVipTeam;
	monitorVipPositionScript = [] spawn function_Server_MonitorVipPosition;
};

function_Server_MonitorVipTeam =
{
	while {true}
	do
	{
		waitUntil {(vip getVariable 'team') != (objectParent vip) getVariable ['team', (vip getVariable 'team')]};
		[] call function_Server_HandleVipTeam;
	};
};

function_Server_HandleVipTeam =
{
	vip setVariable ['team', (objectParent vip) getVariable 'team', true];
	[[], 'function_Client_HandleVipTeam', [] call functionGetPlayers] call BIS_fnc_MP;
};

function_Server_MonitorVipPosition =
{
	_outsideRoute = false;
	_timeSinceChange = 0;
	while {true}
	do
	{
		scopeName 'loop';
		sleep vipServerMonitorPositionIntervalSeconds;
		_timeSinceChange = _timeSinceChange + vipServerMonitorPositionIntervalSeconds;
		if ((objectParent vip) distance destinationPosition <= vipDestinationRadius)
		then
		{
			// Convoy Victory
			[sideConvoy] spawn function_Server_HandleRoundEnd;
		};
		if ([] call functionIsVipOutsideRoute)
		then
		{
			if (!_outsideRoute)
			then
			{
				_outsideRoute = true;
				_timeSinceChange = 0;
			};
			if ((vip getVariable 'team') == sideConvoy && !roundAmbushed)
			then
			{
				if (_timeSinceChange > vipOutsideTunnelConvoyGracePeriod)
				then
				{
					diag_log 'VIP outside tunnel beyond grace period.';
					// Ambush Victory
					[sideAmbush] spawn function_Server_HandleRoundEnd;
					breakOut 'loop';
				};
				if (_timeSinceChange == 0)
				then
				{
					diag_log 'VIP outside tunnel.';
					[[], 'function_Client_NotifyVipOutsideTunnelIllegal', [objNull, sideConvoy] call functionGetPlayers] call BIS_fnc_MP;
				};
			}
			else
			{
				if ((vip getVariable 'team') == sideAmbush)
				then
				{
					diag_log ['Hold period: %1.', _timeSinceChange];
					if (_timeSinceChange > vipOutsideTunnelAmbushHoldPeriod)
					then
					{
						diag_log 'VIP outside tunnel beyond hold period.';
						// Ambush Victory
						[sideAmbush] spawn function_Server_HandleRoundEnd;
						breakOut 'loop';
					};
				};
			};
		}
		else
		{
			if (_outsideRoute)
			then
			{
				_outsideRoute = false;
				_timeSinceChange = 0;
			};
		};
	};
};

function_Server_HandleVipKilled =
{
	private ['_killerTeam'];
	_killed = _this select 0;
	_killer = _this select 1;
	if ((_killed isKindOf 'Land' || _killed isKindOf 'Air') && ((objectParent (objectParent vip)) == _killed || (objectParent vip) == _killed))
	then
	{
		if (_killed isKindOf 'Land')
		then
		{
			diag_log format ['VIP was destroyed in vehicle death. Killer: %1. Team: %2.', name _killer, _killer getVariable 'team'];
			_killerTeam = _killer getVariable 'team';
			if (_killerTeam == sideConvoy)
			then
			{
				// Ambush Victory
				[sideAmbush] spawn function_Server_HandleRoundEnd;
			}
			else
			{
				// Convoy Victory
				[sideConvoy] spawn function_Server_HandleRoundEnd;
			};
		}
		else
		{
			if (_killed isKindOf 'Air')
			then
			{
				diag_log 'VIP was dropped from destroyed air vehicle.';
				moveOut vip;
				if ((objectParent vip) isKindOf 'Man')
				then
				{
					[objectParent vip] call functionUnitDropBackpack;
				};
			}
			else
			{
				diag_log 'VIP was in unhandled destroyed vehicle.';
			};
		};
	};
};