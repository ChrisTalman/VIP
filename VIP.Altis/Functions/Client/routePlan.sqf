functionPlanRoute =
{
	openMap true;
	hint parseText routePlanner_Instructions;
	routePlanNamespace = [] call function_PseudoObject_Create;
	routePlanPoints = [startPositionConvoy];
	routeLineDrawing = false;
	disableSerialization;
	private _display = (findDisplay mapDisplayID);
	private _control = _display displayCtrl mapControlID;
	mapFrameEventID = _control ctrlAddEventHandler ['Draw', {call functionHandleMapFrameEvent;}];
	mouseDownEventID = _control ctrlAddEventHandler ['MouseButtonDown', {_this call functionHandleMapMouseDownEvent}];
	mouseUpEventID = _control ctrlAddEventHandler ['MouseButtonUp', {_this call functionHandleMapMouseUpEvent}];
	mouseMovingEventID = _control ctrlAddEventHandler ['MouseMoving', {_this call functionHandleMapMouseMovingEvent}];
	routePlanNamespace setVariable ['keyUpEventId', (_display displayAddEventHandler ['KeyUp', {_this call functionHandleMapKeyUpEvent}])];
	routePlanNamespace setVariable ['mapEventId', (addMissionEventHandler ['Map', functionHandleMapEvent])];
	[startPositionConvoy] call functionStartRouteLine;
};

functionHandleMapFrameEvent =
{
	{
		if (_forEachIndex < ((count routePlanPoints) - 1))
		then
		{
			(_this select 0) drawLine [_x, (routePlanPoints select (_forEachIndex + 1)), lineColourSelected];
		};
	} forEach routePlanPoints;
	if (routeLineDrawing)
	then
	{
		(_this select 0) drawLine [newLineStartPosition, newLineMovingEndPosition, lineColourSelected];
	};
};

functionStartRouteLine =
{
	newLineStartPosition = _this select 0;
	newLineMovingEndPosition = newLineStartPosition;
	routeLineDrawing = true;
};

functionHandleMapMouseMovingEvent =
{
	_cursorPosition = ((findDisplay mapDisplayID) displayCtrl mapControlID) ctrlMapScreenToWorld [_this select 1, _this select 2];
	if (routeLineDrawing)
	then
	{
		newLineMovingEndPosition = _cursorPosition;
	};
};

functionHandleMapMouseDownEvent =
{
	_pressedButton = _this select 1;
	_shiftPressed = _this select 4;
	if (_pressedButton == mouseButtonCodeLeft)
	then
	{
		_clickedScreenCoordinates = [_this select 2, _this select 3];
		_destinationScreenCoordinates = ((findDisplay mapDisplayID) displayCtrl mapControlID) ctrlMapWorldToScreen destinationPosition;
		/*_clickedDestination = _clickedScreenCoordinates inArea [_destinationScreenCoordinates, generalIconWidth / 2, generalIconHeight / 2, 0, true];
		if (_clickedDestination)
		then
		{
			call functionPlanRouteFinish;
		}
		else
		{*/
			_clickedPosition = ((findDisplay mapDisplayID) displayCtrl mapControlID) ctrlMapScreenToWorld _clickedScreenCoordinates;
			if (_pressedButton == mouseButtonCodeLeft)
			then
			{
				if (routeLineDrawing)
				then
				{
					_newLineEndPosition = _clickedPosition;
					_newLineEndPosition pushBack 0;
					routePlanPoints pushBack _newLineEndPosition;
					newLineStartPosition = _newLineEndPosition;
				};
			};
		//};
	};
};

functionHandleMapKeyUpEvent =
{
	_keyUpID = _this select 1;
	_ctrlPressed = _this select 3;
	_preventDefaultKeyBehaviour = false;
	switch (_keyUpID)
	do
	{
		case keyCodeRETURN:
		{
			call functionPlanRouteFinish;
		};
	};
	_preventDefaultKeyBehaviour;
};

functionPlanRouteFinish =
{
	diag_log 'Client handling route plan finished.';
	openMap false;
	player removeAction (player getVariable 'actionIdPlanRoute');
	routePlanPoints = routePlanPoints + [destinationPosition];
	routeLineDrawing = false;
	[[routePlanPoints], 'function_Server_HandleRoutePlan', false] call BIS_fnc_MP;
};

functionHandleMapEvent =
{
	private _mapOpen = _this select 0;
	diag_log format ['Map Open: %1.', _mapOpen];
	if (!_mapOpen)
	then
	{
		diag_log 'Handling map close.';
		hint '';
		disableSerialization;
		private _display = (findDisplay mapDisplayID);
		private _control = _display displayCtrl mapControlID;
		_control ctrlRemoveEventHandler ['Draw', mapFrameEventID];
		_control ctrlRemoveEventHandler ['MouseButtonDown', mouseDownEventID];
		_control ctrlRemoveEventHandler ['MouseButtonUp', mouseUpEventID];
		_control ctrlRemoveEventHandler ['MouseMoving', mouseMovingEventID];
		_display displayRemoveEventHandler ['KeyUp', (routePlanNamespace getVariable 'keyUpEventId')];
		removeMissionEventHandler ['Map', (routePlanNamespace getVariable 'mapEventId')];
		diag_log 'Handled map close.';
		diag_log '---';
	};
};