functionEstablishBasicItems =
{
	player linkItem 'ItemGPS';
	player linkItem 'Rangefinder';
};

functionUnitAddDamagePrevention =
{
	private ['_unit', '_eventID'];
	_unit = _this select 0;
	if ((typeName (_unit getVariable ['damageProtectionEventID', false])) == 'BOOL')
	then
	{
		_eventID = _unit addEventHandler ['HandleDamage', {0}];
		_unit setVariable ['damageProtectionEventID', _eventID];
	};
};

functionUnitRemoveDamagePrevention =
{
	private ['_unit'];
	_unit = _this select 0;
	if ((typeName (_unit getVariable ['damageProtectionEventID', false])) == 'SCALAR')
	then
	{
		_unit removeEventHandler ['HandleDamage', (_unit getVariable 'damageProtectionEventID')];
	};
};

functionEstablishListenDamage =
{
	private ['_object'];
	_object = _this select 0;
	_object addEventHandler ['HandleDamage', function_Common_HandleDamage];
};

function_Common_HandleDamage =
{
	private ['_damagedObject', '_damagerObject'];
	_damagedObject = _this select 0;
	_damagerObject = _this select 3;
	/*_log = format ['Damaged: %1. Team: %2. Damager: %3. Team: %4.', name _damagedObject, (_damagedObject getVariable 'team'), name _damagerObject, (_damagerObject getVariable 'team')];
	systemChat _log;
	diag_log _log;*/
	if (!roundAmbushed && !(isNull vip) && (_damagedObject getVariable 'team') == sideConvoy && (_damagerObject getVariable 'team') == sideAmbush && (_damagedObject distance vip) <= vipAmbushRadius)
	then
	{
		[[], 'function_Server_HandleAmbush', false] call BIS_fnc_MP;
	};
};

functionGetTeamFORName =
{
	private ['_team', '_returnValue'];
	_team = _this select 0;
	_returnValue = 'undefined';
	if (typeName _team == 'SIDE')
	then
	{
		if (_team == WEST)
		then
		{
			_returnValue = 'BLUFOR';
		};
		if (_team == EAST)
		then
		{
			_returnValue = 'OPFOR';
		};
	};
	if (_returnValue == 'undefined')
	then
	{
		diag_log 'Unrecognised team for functionGetTeamFORName.';
	};
	_returnValue;
};

functionPublicVariableSetValue =
{
	private ['_publicVariableName', '_publicVariableNewValue'];
	_publicVariableName = _this select 0;
	_publicVariableNewValue = _this select 1;
	missionNamespace setVariable [_publicVariableName, _publicVariableNewValue];
	publicVariable _publicVariableName;
};

functionPublicVariableIncrementInteger =
{
	private ['_publicVariableName', '_publicVariableIntegerCurrentValue'];
	_publicVariableName = _this select 0;
	_publicVariableIntegerCurrentValue = (missionNamespace getVariable _publicVariableName);
	missionNamespace setVariable [_publicVariableName, _publicVariableIntegerCurrentValue + 1];
	publicVariable _publicVariableName;
};

functionPublicVariableAppendToArray =
{
	private ['_publicVariableName', '_valueToAppend'];
	_publicVariableName = _this select 0;
	_valueToAppend = _this select 1;
	(missionNamespace getVariable _publicVariableName) pushBack _valueToAppend;
	publicVariable _publicVariableName;
};

functionPublicVariableRemoveFromArray =
{
	private ['_publicVariableName', '_valueToRemove'];
	_publicVariableName = _this select 0;
	_valueToRemove = _this select 1;
	_publicVariableValue = (missionNamespace getVariable _publicVariableName);
	_publicVariableValue deleteAt (_publicVariableValue find _valueToRemove);
	publicVariable _publicVariableName;
};

functionGetNumberAsMetre =
{
	// Arguments: number
	private ['_number', '_roundedNumber', '_metre'];
	_number = _this select 0;
	_roundedNumber = round _number;
	_metre = '';
	if (_roundedNumber < 1000)
	then
	{
		_metre = format ['%1m', _roundedNumber];
	}
	else
	{
		_metre = format ['%1km', (round (_roundedNumber * 0.01) * 0.1)];
	};
	_metre;
};

functionGetRealVisualPosition =
{
	// Arguments: object
	private ['_object', '_position'];
	_object = _this select 0;
	_position = visiblePositionASL _object;
	if (!(surfaceIsWater _position))
	then
	{
		_position = ASLtoATL _position;
	};
	_position;
};

functionGetPlayers =
{
	// Arguments: players to exclude (object or array of objects), side constraint (excludes other sides)
	private _players = [];
	{
		if (isPlayer _x)
		then
		{
			_players pushBack _x;
		};
	} forEach playableUnits;
	if ((count _this) > 0)
	then
	{
		private _excludePlayers = _this select 0;
		if ((typeName _excludePlayers) == 'OBJECT')
		then
		{
			private _excludePlayer = _players find _excludePlayers;
			if (_excludePlayer > -1)
			then
			{
				_players deleteAt _excludePlayer;
			};
		}
		else
		{
			if ((typeName _excludePlayers) == 'ARRAY')
			then
			{
				{
					_excludePlayer = _players find _x;
					if (_excludePlayer > -1)
					then
					{
						_players deleteAt _excludePlayer;
					};
				} forEach _excludePlayers;
			}
			else
			{
				diag_log 'functionGetPlayers: excludePlayers must be of type object or array.';
			};
		};
		if ((count _this) > 1)
		then
		{
			private _teamConstraint = _this select 1;
			private _toDelete = [];
			if ((typeName _teamConstraint) == 'SIDE')
			then
			{
				{
					if ((_x getVariable 'team') != _teamConstraint)
					then
					{
						_toDelete pushBack _x;
					};
				} forEach _players;
				{
					_players deleteAt (_players find _x);
				} forEach _toDelete;
			}
			else
			{
				diag_log 'functionGetPlayers: teamConstraint must be of type side.';
			};
		};
	};
	_players;
};

functionGetPlayerCountForTeams =
{
	private ['_amountBLUFORPlayers', '_amountOPFORPlayers', '_count'];
	// Arguments: None
	// Returns: array containing two integers representing BLUFOR and OPFOR player counts respectively
	_amountBLUFORPlayers = 0;
	_amountOPFORPlayers = 0;
	{
		if (isPlayer _x)
		then
		{
			if ((_x getVariable 'team') == BLUFOR)
			then
			{
				_amountBLUFORPlayers = _amountBLUFORPlayers + 1;
			}
			else
			{
				if ((_x getVariable 'team') == OPFOR)
				then
				{
					_amountOPFORPlayers = _amountOPFORPlayers + 1;
				};
			};
		};
	} forEach playableUnits;
	_count = [_amountBLUFORPlayers, _amountOPFORPlayers];
	_count;
};

functionGetArrayObjectWithVariableValue =
{
	_array = _this select 0;
	_name = _this select 1;
	_value = _this select 2;
	_found = objNull;
	{
		scopeName 'loop';
		if (_x getVariable _name == _value)
		then
		{
			_found = _x;
			breakOut 'loop';
		};
	} forEach _array;
	_found;
};

functionGetTeamLiteral =
{
	// Arguments: team
	_team = _this select 0;
	_literal = 'undefined';
	if (_team == sideConvoy)
	then
	{
		_literal = 'Convoy';
	}
	else
	{
		_literal = 'Ambush';
	};
	_literal;
};

distanceToPath =
{
	private ["_path", "_point"];
	_path = _this select 0;
	_point = _this select 1;
	
	private ["_min", "_i", "_a", "_b", "_dot"];
	_min = (_path select 0) vectorDistance _point;
	for "_i" from 0 to ((count _path) - 2) do
	{
		_a = _path select _i;
		_b = _path select (_i + 1);

		_dot = (_b vectorDiff _a) vectorDotProduct (_point vectorDiff _b);
		if (_dot > 0) then
		{
			// Distance to B
			_min = _min min (_b distance _point);
		}
		else
		{
			//diag_log format ['_i: %1. _a: %2. _b: %3. _point: %4.', _i, _a, _b, _point];
			_dot = (_a vectorDiff _b) vectorDotProduct (_point vectorDiff _a);
			if (_dot > 0) then
			{
				// Distance to A
				_min = _min min (_a vectorDistance _point);
			}
			else
			{
				// Distance to line
				private ["_dir", "_dot", "_proj", "_dist"];
				_dir = _a vectorFromTo _b;
				_dot = (_point vectorDiff _a) vectorDotProduct _dir;
				_proj = _dir vectorMultiply _dot;
				_dist = _point vectorDistance (_a vectorAdd _proj);
				_min = _min min _dist;
			};
		};
	};
	
	/*return*/ _min
};

getNextPathNode =
{
    private ["_path", "_point"];
    _path = _this select 0;
    _point = _this select 1;
    
    private ["_ret", "_min", "_started", "_i", "_a", "_b", "_dot"];
    _ret = 0;
    _min = 999999999999;
    _started = false;
    for "_i" from 0 to ((count _path) - 2) do
    {
        _a = _path select _i;
        _b = _path select (_i + 1);

        _dot = (_b vectorDiff _a) vectorDotProduct (_point vectorDiff _b);
        if (_dot <= 0) then
        {
            _dot = (_a vectorDiff _b) vectorDotProduct (_point vectorDiff _a);
            if (_dot <= 0) then
            {
                // Distance to line
                private ["_dir", "_dot", "_proj", "_dist"];
                _dir = _a vectorFromTo _b;
                _dot = (_point vectorDiff _a) vectorDotProduct _dir;
                _proj = _dir vectorMultiply _dot;
                _dist = _point vectorDistance (_a vectorAdd _proj);
                if (_dist <= _min) then
                {
                    _min = _min min _dist;
                    _ret = _i + 1;
                }
            };
        }
        else
        {
            _started = true;
        };
    };
    
    // Special case if we passed the end point
    _ret = [_ret, (count _path) - 1] select (_started && (_ret isEqualTo 0));
    
    /*return*/ _ret
};

functionIsPointLeftPathOld =
{
	// Arguments: path array containing two points, side point
	// Returns: boolean
	private _path = _this select 0;
	private _sidePoint = _this select 1;

	private _pathPointOne = _path select 0;
	private _pathPointTwo = _path select 1;

	private _side = (((_pathPointTwo select 0) - (_pathPointOne select 0)) * ((_sidePoint select 1) - (startPositionConvoy select 1)) - ((_pathPointTwo select 1) - (startPositionConvoy select 1)) * ((_sidePoint select 0) - (startPositionConvoy select 0)));
	private _output = false;
	if (_side >= 0)
	then
	{
		_output = true;
	};
	_output;
};

functionIsPointLeftPath =
{
    // Arguments: path array containing two points, side point
    // Returns: boolean
    private _path = _this select 0;
    private _sidePoint = _this select 1;

    private _pathPointOne = _path select 0;
    private _pathPointTwo = _path select 1;
    
    private _pathDir = _pathPointOne vectorFromTo _pathPointTwo;
    private _pathRight = _pathDir vectorCrossProduct [0,0,1];
    private _toPoint = _sidePoint vectorDiff _pathPointOne;
    private _dot = _toPoint vectorDotProduct _pathRight;

    /*_log = format ['_pathDir: %1. _pathRight: %2. _toPoint: %3. _dot: %4.', _pathDir, _pathRight, _toPoint, _dot];
    systemChat _log;
    diag_log _log;*/
    
    private _output = false;
	if (_dot < 0)
	then
	{
		_output = true;
	};
	_output;
};

functionGetRotatedPoint =
{
	// Arguments: point one, point two, angle
	// Returns: relative point
	private _rotatePoint = _this select 0;
	private _centrePoint = _this select 1;
	private _angle = _this select 2;
	private _rotatedPoint = [0, 0];
	_rotatedPoint set [0, (cos _angle) * ((_rotatePoint select 0) - (_centrePoint select 0)) - (sin _angle) * ((_rotatePoint select 1) - (_centrePoint select 1)) + (_centrePoint select 0)];
	_rotatedPoint set [1, (sin _angle) * ((_rotatePoint select 0) - (_centrePoint select 0)) + (cos _angle) * ((_rotatePoint select 1) - (_centrePoint select 1)) + (_centrePoint select 1)];
	_rotatedPoint;
};

functionUnitDropBackpack =
{
	// Arguments: unit object
	// Returns: nothing
	_unit = _this select 0;
	_unit addBackpackGlobal 'B_AssaultPack_blk';
	removeBackpackGlobal _unit;
};

functionGetTwoDigits =
{
	private _number = _this select 0;
	private _result = _number;
	if (_number > -10 && _number < 10)
	then
	{
		if (_number < 0)
		then
		{
			_result = '-0' + (str (abs _number));
		}
		else
		{
			_result = '0' + (str (abs _number));
		};
	};
	_result;
};

functionLog =
{
	private _log = _this select 0;
	systemChat _log;
	diag_log _log;
};