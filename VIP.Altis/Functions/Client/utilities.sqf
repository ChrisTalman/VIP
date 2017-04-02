functionExposeDisplayToUiNamespace =
{
	private _properties = _this select 0;
	private _identifier = _this select 1;
	private _display = _properties select 0;
	uiNamespace setVariable [_identifier, _display];
};

functionGetPixelsToScreen =
{
	private _pixels = _this select 0;
	private _resolution = getResolution;
	private _width = (safeZoneW * _pixels) / (_resolution select 0);
	private _height = (safeZoneH * _pixels) / (_resolution select 1);
	private _output = [_width, _height];
	_output;
};