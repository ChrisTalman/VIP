// Engine
missionRoot = str missionConfigFile select [0, count str missionConfigFile - 15];

// Mode Settings
vipClientMonitorPositionIntervalSeconds = 1;
vipServerMonitorPositionIntervalSeconds = 2;
vipDestinationRadius = 30;
vipBackpackType = 'B_AssaultPack_blk';
roundGapSeconds = 10;
vipAmbushRadius = 200;
vipTunnelRadius = 50;
vipOutsideTunnelConvoyGracePeriod = 10;
vipOutsideTunnelAmbushHoldPeriod = 10;
backpackParentType = 'GroundWeaponHolder';
roundTime = 600;
monitorRoundTimeInterval = 1;
teamOneSide = BLUFOR;
teamTwoSide = OPFOR;

// UI
// Names
uiName_customPlayerHud = 'customPlayerHud';
uiName_customRouteHud = 'customRouteHud';
//
// IDs
uiId_HudPanel = 102;
uiId_HudVehicleOccupancy = 103;
uiId_HudTeamsOld = 104;
uiId_HudRouteBoundaries = 105;
uiId_HudRoutePlayer = 106;
uiId_HudAlert = 107;
uiId_HudTeams = 108;
//
// Images
uiImage_Empty = '#(argb,8,8,3)color(0,0,0,0)';
uiImage_Player = 'Assets\player.paa';
uiImage_Base = 'Assets\baseIcon.paa';
uiImage_Fob = 'Assets\fobIcon.paa';
uiImage_Spotted = 'Assets\spotted.paa';
uiImage_Waypoint = 'Assets\waypoint.paa';
uiImage_Vip = 'Assets\vip.paa';
uiImage_RouteBoundaries = 'Assets\walls.paa';
//
// Dimensions
uiDimension_HudRouteBoundariesWidth = 512;
uiDimension_HudRouteBoundariesHeight = 512;
uiDimension_PlayerWidth = 64;
uiDimension_PlayerHeight = 64;
uiDimension_HudRoutePlayerOffset = 60;
uiDimension_HudRoutePlayerOffsetOverflow = uiDimension_HudRoutePlayerOffset + 30;
uiDimension_HudTeamsWidth = 300;
uiDimension_HudTeamsHeight = 100;
uiDimension_HudTeamsOffset = 10;
uiDimension_StandardIconWidth = 2;
uiDimension_StandardIconHeight = 2;
//
// Colours
uiColour_HudRouteStandard = [1, 1, 1, 1];
uiColour_HudRouteWarning = [1, 0, 0, 1];
//
// Misc
uiMisc_RouteOffset = 80;
uiMisc_StandardShadow = 2;

// Generic
standardUnitHeight = 2.1;
controlFatigueLossInterval = 20;
controlFatigueLossCorrection = 0.3;
serverOwnershipID = 2;

// Respawn
respawnIslandPosition = [2328.68,9268.62];
startPositions = [
	[
		[19669.3,12806.4,0],
		[16949.2,13186.5,0]
	]
];
startPositionSpawnRadius = 30;

// Route Planner
routePlanner_Instructions = 'Click on points of the map to determine your convoy route.<br/><br/>Press ENTER to finish the route.';

// Loadouts
defaultLoadoutConvoy = ["U_B_CombatUniform_mcam","V_PlateCarrier1_rgr","","H_HelmetB","",[["arifle_MX_ACO_pointer_F","","acc_pointer_IR","optic_Aco",["30Rnd_65x39_caseless_mag",30],""],["hgun_P07_F","","","",["16Rnd_9x21_Mag",16],""]],["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles"],["FirstAidKit","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","Chemlight_green"],["30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","16Rnd_9x21_Mag","16Rnd_9x21_Mag","SmokeShell","SmokeShellGreen","Chemlight_green","HandGrenade","HandGrenade"],[]];
defaultLoadoutAmbush = ["U_O_CombatUniform_ocamo","V_HarnessO_brn","","H_HelmetO_ocamo","",[["arifle_Katiba_ACO_pointer_F","","acc_pointer_IR","optic_ACO_grn",["30Rnd_65x39_caseless_green",30],""],["hgun_Rook40_F","","","",["16Rnd_9x21_Mag",16],""]],["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles_OPFOR"],["FirstAidKit","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","Chemlight_red"],["30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","16Rnd_9x21_Mag","16Rnd_9x21_Mag","HandGrenade","HandGrenade","SmokeShell","SmokeShellRed","Chemlight_red"],[]];

// HUD
panelHUDUpdateIntervalInSeconds = 5;
teamsInformationHUDUpdateIntervalInSeconds = 30;
vehicleOccupancyHUDUpdateIntervalInSeconds = 5;

// Map
generalIconWidth = 64;
generalIconHeight = 64;

// Colours
colourTeamMapMarkersBLUFOR = 'ColorBlue';
colourTeamMapMarkersOPFOR = 'ColorRed';
colourTeamMapDrawingsConvoy = [0, 0, 1, 1];
colourTeamMapDrawingsAmbush = [1, 0, 0, 1];
colourTeamMapDrawingsDeceased = [0.518, 0.518, 0.518, 1];
colourTeamMapDrawingsIndependent = [0, 1, 0, 1];
colourStandard = [1, 1, 1, 1];

// Textures
lineColourSelected = [0,0,1,1];
lineColourNotSelected = [0,0,1,0.5];

// Screen Display ID
screenDisplayID = 46;
mapDisplayID = 12;
mapControlID = 51;

// Mouse Codes
mouseButtonCodeLeft = 0;

// Key Codes
keyCodeA = 0x1E;
keyCodeB = 0x30;
keyCodeC = 0x2E;
keyCodeD = 0x20;
keyCodeE = 0x12;
keyCodeF = 0x21;
keyCodeG = 0x22;
keyCodeH = 0x23;
keyCodeI = 0x17;
keyCodeJ = 0x24;
keyCodeK = 0x25;
keyCodeL = 0x26;
keyCodeM = 0x32;
keyCodeN = 0x31;
keyCodeO = 0x18;
keyCodeP = 0x19;
keyCodeQ = 0x10;
keyCodeR = 0x13;
keyCodeS = 0x1F;
keyCodeT = 0x14;
keyCodeU = 0x16;
keyCodeV = 0x2F;
keyCodeW = 0x11;
keyCodeX = 0x2D;
keyCodeY = 0x15;
keyCodeZ = 0x2C;

keyCodeESCAPE = 0x01;
keyCodeTAB = 0x0F;
keyCodeLSHIFT = 0x2A;
keyCodeRSHIFT = 0x36;
keyCodeLCONTROL = 0x1D;
keyCodeRCONTROL = 0x9D;
keyCodeBACK = 0x0E;
keyCodeBACKSPACE = keyCodeBACK;
keyCodeRETURN = 0x1C;
keyCodeNUMPADENTER = 0x9C;
keyCodeLMENU =  0x38;
keyCodeLALT = keyCodeLMENU;
keyCodeSPACE =  0x39;
keyCodeCAPITAL =  0x3A;
keyCodeCAPSLOCK = keyCodeCAPITAL;
keyCodeNUMLOCK =  0x45;
keyCodeSCROLL = 0x46;
keyCodeRMENU =  0xB8;
keyCodeRALT = keyCodeRMENU;
keyCodeLWIN = 0xDB;

keyCodeDELETE = 0xD3;