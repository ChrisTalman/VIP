functionEstablishPlayerHud =
{
	(uiName_customPlayerHud call BIS_fnc_rscLayer) cutRsc [uiName_customPlayerHud, 'PLAIN', 0, false];
	call functionHandleHealth;
	player addEventHandler ['HandleDamage', {call functionHandleHealth}];
	player addEventHandler ['HandleHeal', {call functionHandleHealth}];
	[] spawn functionUpdatePanelHUDByInterval;
	//[] spawn functionUpdateTeamsInformationHUDByInterval;
	[] spawn functionHandlePlayerGetInVehicle;
	[] spawn functionHudUpdateTeamsByInterval;
};

functionUpdatePanelHUDByInterval =
{
	_vehicle = _this select 0;
	while {true}
	do
	{
		call functionUpdatePanelHUD;
		_currentServerTime = serverTime;
		waitUntil {serverTime >= (_currentServerTime + panelHUDUpdateIntervalInSeconds)};
	};
};

functionHandleHealth = 
{
	call functionUpdatePanelHUD;
};

functionUpdatePanelHUD =
{
	_vipStatus = [] call functionGetVipStatus;
	_playerHealth = round (100 - ((damage player) * 100));
	_text = 'VIP: %1';
	if (alive player)
	then
	{
		_text = _text + ' | Health: %2';
	};
	_text = '<t size="2.5" shadow="2">' + _text + '</t>';
	((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudPanel) ctrlSetStructuredText (parseText format [_text, _vipStatus, _playerHealth]);
};

functionGetVipStatus =
{
	_status = 'undefined';
	if (!(isNull vip))
	then
	{
		if ((vip getVariable 'team') == (player getVariable 'team'))
		then
		{
			if ((player getVariable 'team') == sideConvoy)
			then
			{
				_status = '<t color="#3FB421">Escort</t>';
			}
			else
			{
				_status = '<t color="#3FB421">Hold</t>';
			};
		}
		else
		{
			if ((player getVariable 'team') == sideConvoy)
			then
			{
				_status = '<t color="#D00000">Resecure</t>';
			}
			else
			{
				_status = '<t color="#D00000">Capture</t>';
			};
		};
	}
	else
	{
		_status = 'Wait';
	};
	_status;
};

functionUpdateVehicleOccupancyHUD =
{
	_vehicle = _this select 0;
	_hudText = '<t size="2" shadow="2">';
	_vehicleName = _vehicle getVariable ['vehicleName', (getText (configFile >> 'CfgVehicles' >> (typeOf _vehicle) >> 'displayName'))];
	_hudText = _hudText + format ['%1<br/>', _vehicleName];
	{
		if (_x == (driver _vehicle))
		then
		{
			_hudText = _hudText + format ['%1 <img image="A3\ui_f\data\igui\cfg\commandbar\imageDriver_ca.paa"/><br/>', name _x];
		}
		else
		{
			if (_x == (gunner _vehicle))
			then
			{
				_hudText = _hudText + format ['%1 <img image="A3\ui_f\data\igui\cfg\commandbar\imageGunner_ca.paa"/><br/>', name _x];
			}
			else
			{
				if (_x == (commander _vehicle))
				then
				{
					_hudText = _hudText + format ['%1 <img image="A3\ui_f\data\igui\cfg\commandbar\imageCommander_ca.paa"/><br/>', name _x];
				}
				else
				{
					_hudText = _hudText + format ['%1<br/>', name _x];
				};
			};
		};
	} forEach (crew _vehicle);
	_hudText = _hudText + '</t>';
	((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudVehicleOccupancy) ctrlSetStructuredText (parseText _hudText);
};

functionUpdateVehicleOccupancyHUDByInterval =
{
	_vehicle = _this select 0;
	while {(vehicle player) == _vehicle}
	do
	{
		[_vehicle] call functionUpdateVehicleOccupancyHUD;
		_currentServerTime = serverTime;
		waitUntil {serverTime >= (_currentServerTime + vehicleOccupancyHUDUpdateIntervalInSeconds)};
	};
};

functionClearVehicleOccupancyHUD =
{
	((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudVehicleOccupancy) ctrlSetStructuredText (parseText '');
};

functionHandlePlayerGetInVehicle =
{
	while {true}
	do
	{
		waitUntil {vehicle player != player};
		_currentVehicle = (vehicle player);
		[_currentVehicle] spawn functionUpdateVehicleOccupancyHUDByInterval;
		_getInEventID = _currentVehicle addEventHandler ['GetIn', {[_this select 0] call functionUpdateVehicleOccupancyHUD}];
		_getOutEventID = _currentVehicle addEventHandler ['GetOut', {[_this select 0] call functionUpdateVehicleOccupancyHUD}];
		waitUntil {vehicle player == player};
		_currentVehicle removeEventHandler ['GetIn', _getInEventID];
		_currentVehicle removeEventHandler ['GetOut', _getOutEventID];
		call functionClearVehicleOccupancyHUD;
	};
};

/*functionUpdateTeamsInformationHUD =
{
	_amountPlayers = call functionGetPlayerCountForTeams;
	_amountBLUFORPlayers = _amountPlayers select 0;
	_amountOPFORPlayers = _amountPlayers select 1;
	((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudTeamsOld) ctrlSetStructuredText (parseText format ['<t size="2" shadow="2"><t color="#5882FA">Team 1 (%1)</t><br/>%2 Victories<br/>%3 Players<br/><t color="#FA5858">Team 2 (%4)</t><br/>%5 Victories<br/>%6 Players</t>', [BLUFOR] call functionGetTeamLiteral, victoriesTeam1, _amountBLUFORPlayers, [OPFOR] call functionGetTeamLiteral, victoriesTeam2, _amountOPFORPlayers]);
};

functionUpdateTeamsInformationHUDByInterval =
{
	while {true}
	do
	{
		call functionUpdateTeamsInformationHUD;
		_currentServerTime = serverTime;
		waitUntil {serverTime >= (_currentServerTime + teamsInformationHUDUpdateIntervalInSeconds)};
	};
};*/

functionHudSetOutsideRouteAlert =
{
	private _elapsed = _this select 0;
	private _text = '<t size="4" shadow="2"><t color="#FA5858">Return<br/>%1</t></t>';
	((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudAlert) ctrlSetStructuredText (parseText format [_text, (vipOutsideTunnelConvoyGracePeriod - _elapsed)]);
};

functionHudSetHoldAlert =
{
	private _elapsed = _this select 0;
	private _text = '<t size="4" shadow="2"><t color="#3FB421">Hold<br/>%1</t></t>';
	((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudAlert) ctrlSetStructuredText (parseText format [_text, (vipOutsideTunnelAmbushHoldPeriod - _elapsed)]);
};

functionHudClearAlert =
{
	((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudAlert) ctrlSetStructuredText (parseText '');
};

functionEstablishRouteHud =
{
	(uiName_customRouteHud call BIS_fnc_rscLayer) cutRsc [uiName_customRouteHud, 'PLAIN', 0, false];
	['routeHudFrameEvent', 'onEachFrame', functionHandleRouteHudFrameEvent] call BIS_fnc_addStackedEventHandler;
};

functionDisestablishRouteHud =
{
	(uiName_customRouteHud call BIS_fnc_rscLayer) cutText ['', 'PLAIN'];
	['routeHudFrameEvent', 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
};

functionHudUpdateTeamsByInterval =
{
	while {true}
	do
	{
		sleep monitorRoundTimeInterval;
		private _remainingSeconds = roundTime - (roundTimer getVariable 'elapsed');
		private _remainingTimeMinutes = [(floor (_remainingSeconds / 60))] call functionGetTwoDigits;
		private _remainingTimeSeconds = [(_remainingSeconds % 60)] call functionGetTwoDigits;
		private _friendlyTeamSide = teamOneSide;
		private _enemyTeamSide = teamTwoSide;
		private _friendlyColour = '#5882FA';
		private _enemyColour = '#FA5858';
		private _friendlyTeamVictories = victoriesTeam1;
		private _enemyTeamVictories = victoriesTeam2;
		if ((player getVariable 'team') == teamTwoSide)
		then
		{
			_friendlyTeamSide = teamTwoSide;
			_enemyTeamSide = teamOneSide;
			_friendlyTeamVictories = victoriesTeam2;
			_enemyTeamVictories = victoriesTeam1;
			_friendlyColour = '#FA5858';
			_enemyColour = '#5882FA';
		};
		private _friendlyPlayersAlive = [_friendlyTeamSide] call functionGetAlivePlayers;
		private _friendlyPlayers = [objNull, _friendlyTeamSide] call functionGetPlayers;
		private _enemyPlayersAlive = [_enemyTeamSide] call functionGetAlivePlayers;
		private _enemyPlayers = [objNull, _enemyTeamSide] call functionGetPlayers;
		private _friendlyTeamSegment = format ['<t align="left" color="%1"><t size="2">%2/%3</t> %4</t>', _friendlyColour, count _friendlyPlayersAlive, count _friendlyPlayers, _friendlyTeamVictories];
		private _roundTimeSegment = format ['<t align="center">%1:%2</t>', _remainingTimeMinutes, _remainingTimeSeconds];
		private _enemyTeamSegment = format ['<t align="right" color="%1">%2 <t size="2">%3/%4</t></t>', _enemyColour, _enemyTeamVictories, count _enemyPlayersAlive, count _enemyPlayers];
		private _statusSegment = format ['<t align="center" size="2">%1</t>', (toUpper ([] call functionGetVipStatus))];
		((uiNamespace getVariable uiName_customPlayerHud) displayCtrl uiId_HudTeams) ctrlSetStructuredText (parseText format ['<t size="4" shadow="2">%1%2%3<br/>%4</t>', _friendlyTeamSegment, _roundTimeSegment, _enemyTeamSegment, _statusSegment]);
	};
};

functionGetHudTeamsX =
{
	private _result = 0;
	with missionNamespace do
	{
		private _imageScreenWidth = ([uiDimension_HudTeamsWidth] call functionGetPixelsToScreen) select 0;
		_result = (safeZoneX + (safeZoneW / 2)) - (_imageScreenWidth / 2);
	};
	_result;
};

functionGetHudTeamsY =
{
	private _result = 0;
	with missionNamespace do
	{
		private _imageScreenHeight = ([uiDimension_HudTeamsHeight] call functionGetPixelsToScreen) select 1;
		private _screenOffset = ([uiDimension_HudTeamsOffset] call functionGetPixelsToScreen) select 1;
		_result = safeZoneY + _screenOffset;
	};
	_result;
};

functionGetHudTeamsWidth =
{
	private _result = 0;
	with missionNamespace do
	{
		_result = ([uiDimension_HudTeamsWidth] call functionGetPixelsToScreen) select 0;
	};
	_result;
};

functionGetHudTeamsHeight =
{
	private _result = 0;
	with missionNamespace do
	{
		_result = ([uiDimension_HudTeamsHeight] call functionGetPixelsToScreen) select 1;
	};
	_result;
};

/*functionGetHudRouteX =
{
	private _return = 0.467199 * safezoneW + safezoneX;
	_return;
};

functionGetHudRouteY =
{
	private _return = 0.878084 * safezoneH + safezoneY;
	_return;
};*/

/*functionGetHudRouteXY =
{
	private return = [([] call functionGetHudRouteX), ([] call functionGetHudRouteY)];
	_return;
};*/

functionGetHudRouteX =
{
	private _result = 0;
	with missionNamespace do
	{
		private _imagePixelsWidth = _this select 0;
		private _imageScreenWidth = ([_imagePixelsWidth] call functionGetPixelsToScreen) select 0;
		_result = (safeZoneX + (safeZoneW / 2)) - (_imageScreenWidth / 2);
	};
	_result;
};

functionGetHudRouteY =
{
	private _result = 0;
	with missionNamespace do
	{
		private _imagePixelsHeight = _this select 0;
		private _pixelsOffset = _this select 1;
		private _imageScreenHeight = ([_imagePixelsHeight] call functionGetPixelsToScreen) select 1;
		private _screenOffset = ([_pixelsOffset] call functionGetPixelsToScreen) select 1;
		_result = (safeZoneY + safeZoneH) - (_imageScreenHeight / 2) - _screenOffset;
	};
	_result;
};

functionGetHudRouteBoundariesX =
{

	private _result = 0;
	with missionNamespace do
	{
		_result = [uiDimension_HudRouteBoundariesWidth] call functionGetHudRouteX;
	};
	_result;
};

functionGetHudRouteBoundariesY =
{
	private _result = 0;
	with missionNamespace do
	{
		_result = [uiDimension_HudRouteBoundariesHeight, uiMisc_RouteOffset] call functionGetHudRouteY;
	};
	_result;
};

functionGetHudRoutePlayerX =
{
	private _result = 0;
	with missionNamespace do
	{
		_result = [uiDimension_PlayerWidth] call functionGetHudRouteX;
	};
	_result;
};

functionGetHudRoutePlayerY =
{
	private _result = 0;
	with missionNamespace do
	{
		_result = [uiDimension_PlayerHeight, uiMisc_RouteOffset] call functionGetHudRouteY;
	};
	_result;
};

functionHandleRouteHudFrameEvent =
{
	// Route Path
	_nextPoint = destinationPosition;
	_previousPoint = startPositionConvoy;
	if ((count routePoints) > 0)
	then
	{
		_nextPointIndex = [routePoints, position player] call getNextPathNode;
		_previousPointIndex = _nextPointIndex - 1;
		if (_nextPointIndex == 0)
		then
		{
			_nextPointIndex = 1;
			_previousPointIndex = 0;
		};
		_nextPoint = routePoints select _nextPointIndex;
		_previousPoint = routePoints select _previousPointIndex;
	};
	// HUD
	_routeDirection = _previousPoint getDir _nextPoint;
	_playerDirection = getDir player;
	_routeAngle = _routeDirection - _playerDirection;
	if (_routeAngle < -180)
	then
	{
		_routeAngle = _routeAngle + 360;
	}
	else
	{
		if (_routeAngle > 180)
		then
		{
			_routeAngle = _routeAngle - 360;
		};
	};
	_routeDistance = [[_previousPoint, _nextPoint], position player] call distanceToPath;
	_routeDistanceProportion = _routeDistance / vipTunnelRadius;
	_hudPositionOffset = (([uiDimension_HudRoutePlayerOffset] call functionGetPixelsToScreen) select 0) * _routeDistanceProportion;
	_hudColour = uiColour_HudRouteStandard;
	if (_routeDistanceProportion > 1)
	then
	{
		_hudColour = uiColour_HudRouteWarning;
		_overflowOffset = (([uiDimension_HudRoutePlayerOffsetOverflow] call functionGetPixelsToScreen) select 0);
		if (_hudPositionOffset > _overflowOffset)
		then
		{
			_hudPositionOffset = _overflowOffset;
		};
	};
	//systemChat format ['Left New: %1. Left Old: %2.', ([[_previousPoint, _nextPoint], position player] call functionIsPointLeftPath), ([[_previousPoint, _nextPoint], position player] call functionIsPointLeftPathOld)];
	if ([[_previousPoint, _nextPoint], position player] call functionIsPointLeftPath)
	then
	{
		_hudPositionOffset = -_hudPositionOffset;
	};
	_hudPosition = [([] call functionGetHudRoutePlayerX) + _hudPositionOffset, ([] call functionGetHudRoutePlayerY)];
	_hudPosition = [_hudPosition, [([] call functionGetHudRoutePlayerX), ([] call functionGetHudRoutePlayerY)], _routeAngle] call functionGetRotatedPoint;
	//systemChat format ['_routeDistance: %1. _routeDistanceProportion: %2. _hudPosition: %3. vipTunnelRadius: %4. routeHudWidth: %5.', _routeDistance, _routeDistanceProportion, _hudPosition, vipTunnelRadius, routeHudWidth];
	((uiNamespace getVariable uiName_customRouteHud) displayCtrl uiId_HudRouteBoundaries) ctrlSetTextColor _hudColour;
	((uiNamespace getVariable uiName_customRouteHud) displayCtrl uiId_HudRouteBoundaries) ctrlSetAngle [_routeAngle, 0.5, 0.5];
	((uiNamespace getVariable uiName_customRouteHud) displayCtrl uiId_HudRoutePlayer) ctrlSetPosition _hudPosition;
	((uiNamespace getVariable uiName_customRouteHud) displayCtrl uiId_HudRoutePlayer) ctrlCommit 0;
	((uiNamespace getVariable uiName_customRouteHud) displayCtrl uiId_HudRoutePlayer) ctrlSetTextColor _hudColour;
};