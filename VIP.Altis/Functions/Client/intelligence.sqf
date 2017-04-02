functionEstablishMapGraphics =
{
	disableSerialization;
	_defaultMapControl = ((findDisplay mapDisplayID) displayCtrl 51);
	_defaultMapControl ctrlAddEventHandler ['Draw', {call functionMapGraphicsMainMapFrameEvent;}];
	0 spawn
	{
		disableSerialization;
		_defaultMinimapControl = controlNull;
		while {isNull _defaultMinimapControl} do
		{
			{if !(isNil {_x displayctrl 101}) then {_defaultMinimapControl= _x displayctrl 101};} count (uiNamespace getVariable 'IGUI_Displays');
			sleep 0.1;
		};
		_defaultMinimapControl ctrlAddEventHandler ['Draw', {call functionMapGraphicsMiniMapFrameEvent;}];
	};
};

functionMapGraphicsMainMapFrameEvent =
{
	_this call functionMapGraphicsTeam;
	_this call functionMapGraphicsRoute;
};

functionMapGraphicsMiniMapFrameEvent =
{
	_this call functionMapGraphicsTeam;
	_this call functionMapGraphicsRoute;
};

functionMapGraphicsTeam =
{
	_teamLiteral = [player getVariable 'team'] call functionGetTeamFORName;
	{
		if (isPlayer _x && (_x getVariable 'team') == (player getVariable 'team') && !(_x getVariable 'respawning'))
		then
		{
			if ((vehicle _x) == _x)
			then
			{
				_unitName = name _x;
				(_this select 0) drawIcon [missionRoot + uiImage_Player, colourStandard, position _x, 45, 45, direction _x, '', uiMisc_StandardShadow, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
				(_this select 0) drawIcon [uiImage_Empty, colourStandard, position _x, 45, 45, 0, _unitName, uiMisc_StandardShadow, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
			};
		};
	} forEach playableUnits;
	// Consider changing vehicle icon to one that represents vehicles, rather than being same icon as for infantry
	{
		_vehicleName = _x getVariable ['vehicleName', (getText (configFile >> 'CfgVehicles' >> (typeOf _x) >> 'displayName'))];
		_vehicleDriver = '';
		if (!(isNull (driver _x)))
		then
		{
			if (alive (driver _x))
			then
			{
				_vehicleDriver = format [' (%1)', name (driver _x)];
			};
		};
		_vehicleIconColour = colourStandard;
		if (!(alive _x))
		then
		{
			_vehicleIconColour = colourTeamMapDrawingsDeceased;
		};
		(_this select 0) drawIcon ['\A3\ui_f\data\map\markers\nato\b_inf.paa', _vehicleIconColour, position _x, 29, 29, 0, format ['%1%2', _vehicleName, _vehicleDriver], uiMisc_StandardShadow, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	} forEach (missionNamespace getVariable (format ['vehicles%1', [(player getVariable 'team')] call functionGetTeamLiteral]));
	_textColour = [1, 1, 1, 1];
	// Destination
	(_this select 0) drawIcon [missionRoot + uiImage_Base, colourStandard, destinationPosition, generalIconWidth, generalIconHeight, 0, '', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	(_this select 0) drawIcon [uiImage_Empty, _textColour, destinationPosition, generalIconWidth, generalIconHeight, 0, 'Convoy Destination', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	// Convoy Start
	(_this select 0) drawIcon [missionRoot + uiImage_Fob, colourStandard, startPositionConvoy, generalIconWidth, generalIconHeight, 0, '', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	(_this select 0) drawIcon [uiImage_Empty, _textColour, startPositionConvoy, generalIconWidth, generalIconHeight, 0, 'Convoy Start', 0, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
	// VIP
	if (!(isNull vip))
	then
	{
		// Convoy
		if ((player getVariable 'team') == sideConvoy || ((player getVariable 'team') == sideAmbush && (typeOf (objectParent vip)) == backpackParentType))
		then
		{
			(_this select 0) drawIcon [missionRoot + uiImage_Vip, colourStandard, position (objectParent vip), 45, 45, 0, '', uiMisc_StandardShadow, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
			(_this select 0) drawIcon [uiImage_Empty, colourStandard, position (objectParent vip), 45, 45, 0, 'VIP', uiMisc_StandardShadow, 0.04 / (getResolution select 5), 'PuristaMedium', 'right'];
		};
	};
};

functionMapGraphicsRoute =
{
	{
		if (_forEachIndex < ((count routePoints) - 1))
		then
		{
			(_this select 0) drawLine [_x, (routePoints select (_forEachIndex + 1)), [(player getVariable 'team')] call functionGetTeamColour];
		};
	} forEach routePoints;
};

functionEstablishScreenKeyActions =
{
	(findDisplay screenDisplayID) displayAddEventHandler ['KeyUp', {_this call functionHandleScreenKeyUp;}];
};

functionHandleScreenKeyUp =
{
	_keyUpID = _this select 1;
	if (_keyUpID == keyCodeLWIN)
	then
	{
		[] call functionToggleOperationalHUD;
	};
};

functionToggleOperationalHUD =
{
	if (isNil 'operationalHUDEnabled')
	then
	{
		operationalHUDEnabled = false;
	};
	if (operationalHUDEnabled)
	then
	{
		operationalHUDEnabled = false;
		['operationalHUDFrameEvent', 'onEachFrame'] call BIS_fnc_removeStackedEventHandler;
		systemChat 'Operational HUD disabled.';
	}
	else
	{
		operationalHUDEnabled = true;
		['operationalHUDFrameEvent', 'onEachFrame', functionOperationalHUDFrameEvent] call BIS_fnc_addStackedEventHandler;
		systemChat 'Operational HUD enabled.';
	};
};

functionOperationalHUDFrameEvent =
{
	// Players
	{
		if (isPlayer _x && _x != player && (_x getVariable 'team') == (player getVariable 'team') && !(_x getVariable 'respawning'))
		then
		{
			if ((vehicle _x) == _x)
			then
			{
				_position = [_x] call functionGetRealVisualPosition;
				_position set [2, (_position select 2) + standardUnitHeight];
				_unitName = format ['%1 %2', name _x, ([(position player) distance (position _x)] call functionGetNumberAsMetre)];
				drawIcon3D [missionRoot + uiImage_Spotted, colourStandard, _position, uiDimension_StandardIconWidth, uiDimension_StandardIconHeight, 0, _unitName, uiMisc_StandardShadow, 0.03, 'PuristaMedium', 'center', true];
			};
		};
	} forEach playableUnits;
	// Destination
	_destinationTitle = format ['%1 %2', 'Destination', ([(position player) distance destinationPosition] call functionGetNumberAsMetre)];
	drawIcon3D [missionRoot + uiImage_Waypoint, colourStandard, destinationPosition, uiDimension_StandardIconWidth, uiDimension_StandardIconHeight, 0, _destinationTitle, uiMisc_StandardShadow, 0.03, 'PuristaMedium', 'center', true];
	// Next Waypoint
	if ((player getVariable 'team') == sideConvoy && (count routePoints) > 0)
	then
	{
		_nextPointIndex = [routePoints, position player] call getNextPathNode;
		_nextPoint = routePoints select _nextPointIndex;
		if (!(_nextPoint isEqualTo destinationPosition))
		then
		{
			_waypointTitle = format ['Waypoint %1 %2', (_nextPointIndex + 1), ([(position player) distance _nextPoint] call functionGetNumberAsMetre)];
			drawIcon3D [missionRoot + uiImage_Waypoint, colourStandard, _nextPoint, uiDimension_StandardIconWidth, uiDimension_StandardIconHeight, 0, _waypointTitle, uiMisc_StandardShadow, 0.03, 'PuristaMedium', 'center', true];
			if ((count routePoints) > (_nextPointIndex + 1))
			then
			{
				_nextNextPointIndex = _nextPointIndex + 1;
				_nextNextPoint = routePoints select _nextNextPointIndex;
				if (!(_nextNextPoint isEqualTo destinationPosition))
				then
				{
					_waypointTitle = format ['Waypint %1 %2', (_nextNextPointIndex + 1), ([(position player) distance _nextNextPoint] call functionGetNumberAsMetre)];
					drawIcon3D [missionRoot + uiImage_Waypoint, colourStandard, _nextNextPoint, uiDimension_StandardIconWidth, uiDimension_StandardIconHeight, 0, _waypointTitle, uiMisc_StandardShadow, 0.03, 'PuristaMedium', 'center', true];
				};
			};
		};
	};
	// VIP
	if (!(isNull vip) && objectParent vip != player)
	then
	{
		if ((player getVariable 'team') == sideConvoy || ((player getVariable 'team') == sideAmbush && ((vip getVariable 'team') == sideAmbush || (typeOf (objectParent vip)) == backpackParentType)))
		then
		{
			_VipTitle = format ['%1 %2', 'VIP', ([(position player) distance (position (objectParent vip))] call functionGetNumberAsMetre)];
			_position = [objectParent vip] call functionGetRealVisualPosition;
			_position set [2, (_position select 2) + standardUnitHeight];
			drawIcon3D [missionRoot + uiImage_Vip, colourStandard, _position, uiDimension_StandardIconWidth, uiDimension_StandardIconHeight, 0, _VipTitle, uiMisc_StandardShadow, 0.03, 'PuristaMedium', 'center', true];
		};
	};
};

functionGetTeamColour =
{
	// Arguments: team
	_team = _this select 0;
	_colour = [0, 0, 0, 1];
	if (_team == sideConvoy)
	then
	{
		_colour = colourTeamMapDrawingsConvoy;
	}
	else
	{
		_colour = colourTeamMapDrawingsAmbush;
	};
	_colour;
};