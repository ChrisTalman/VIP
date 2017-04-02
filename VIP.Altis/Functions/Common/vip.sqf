functionIsVipOutsideRoute =
{
	private _outside = (([routePoints, position (objectParent vip)] call distanceToPath) > vipTunnelRadius);
	_outside;
};

functionCreateVip =
{
	private _vipPosition = [startPositionConvoy, 0, startPositionSpawnRadius, 0, 0, 180, 0] call BIS_fnc_findSafePos;
	private _vip = vipBackpackType createVehicle _vipPosition;
	['vip', _vip] call functionPublicVariableSetValue;
};