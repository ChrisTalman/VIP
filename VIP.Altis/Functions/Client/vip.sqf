function_Client_MonitorVipPosition =
{
	private _outsideRoute = false;
	private _timeSinceChange = 0;
	while {true}
	do
	{
		sleep vipClientMonitorPositionIntervalSeconds;
		_timeSinceChange = _timeSinceChange + vipClientMonitorPositionIntervalSeconds;
		if ([] call functionIsVipOutsideRoute)
		then
		{
			if (!_outsideRoute)
			then
			{
				_outsideRoute = true;
				_timeSinceChange = 0;
			};
			if ((vip getVariable 'team') == sideConvoy && (player getVariable 'team') == sideConvoy && ((objectParent vip) == player || ((objectParent (objectParent vip)) == (objectParent player))) && !roundAmbushed)
			then
			{
				if (_timeSinceChange < vipOutsideTunnelConvoyGracePeriod)
				then
				{
					[_timeSinceChange] call functionHudSetOutsideRouteAlert;
				}
				else
				{
					[] call functionHudClearAlert;
				};
			}
			else
			{
				if ((vip getVariable 'team') == sideAmbush && (player getVariable 'team') == sideAmbush)
				then
				{
					if (_timeSinceChange < vipOutsideTunnelAmbushHoldPeriod)
					then
					{
						[_timeSinceChange] call functionHudSetHoldAlert;
					}
					else
					{
						[] call functionHudClearAlert;
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
				[] call functionHudClearAlert;
			};
		};
	};
};