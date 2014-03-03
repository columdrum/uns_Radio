
Uns_radio_MaxDistance=getNumber (configFile >> "uns_radio" >> "config" >> "MaxDistance");
Uns_radio_numSound=getArray (configFile >> "uns_radio" >> "config" >> "NumSounds"); //[ EAST , WEST , RESISTANCE , CIVILIAN];
Uns_radio_sleep_delays=[getArray (configFile >> "uns_radio" >> "config" >> "sleepTimeGround"),
	getArray (configFile >> "uns_radio" >> "config" >> "sleepTimeAir"),
	getArray (configFile >> "uns_radio" >> "config" >> "sleepTimeGeneric")];


		
uns_radio_emisor=[[[],[]],[[],[]],[[],[]],[[],[]]];
uns_radio_lastsounds=[[0,0,0],[0,0,0],[0,0,0],[0,0,0]];
Uns_radio_timeLastCheck=0;
Uns_radio_sides=[east,west,resistance,civilian];
uns_radio_allair=[];
uns_radio_allground=[];
uns_radio_allgeneric=[];
uns_radio_LastChanel=3;
uns_radio_selectedChannel=1;
uns_radio_manualShwon=false;
uns_radio_calltypes=["AIREXTRAC", "RESUPPLY", "CAS", "MORTAR", "ARTY"];


Uns_radio_FNC_Play = {
	//Plays a sound on all the sources near to the player on the chanel
	private["_chanel", "_Soundindex", "_chanelSide","_SoundName","_SpecialSound"];
	_chanel=_this select 0;
	_chanelSide=_this select 1;
	_Soundindex=_this select 2;
	_SpecialSound=if (count _this > 3) then {_this select 3} else {false};
	
	
	if (isDedicated) exitwith{}; // No sounds on dedi :)

	if (_SpecialSound && _chanel==0) then {call Uns_radio_FNC_ResetUnitEmiters};
	
	if (time >Uns_radio_timeLastCheck) then {call Uns_radio_FNC_BuildEmisorList};
	if (!_SpecialSound) then {
		_SoundName=format["Uns_radio_%1_CHAN%2_TRACK%3",(Uns_radio_sides select _chanelSide),_chanel,_Soundindex];
		(uns_radio_lastsounds select _chanelSide) set [_chanel,_Soundindex];
	}else {
		_SoundName=format["Uns_radio_%1_ANSWER_%2",(Uns_radio_sides select _chanelSide),(uns_radio_calltypes select _Soundindex)];
	};
	{if ((_x distance player) < Uns_radio_MaxDistance) then {_x say3d _SoundName}} foreach ((uns_radio_emisor select _chanelSide) select _chanel);
	
};

Uns_radio_FNC_MainRadioLoop = {
	private["_chanel", "_Soundindex", "_chanelSide","_duracion","_NextSound","_MinSleep","_MaxSleep"];
	_chanel=_this select 0;
	_chanelSide=_this select 1;
	
	_MinSleep=(Uns_radio_sleep_delays select _chanel) select 0;
	_MaxSleep=((Uns_radio_sleep_delays select _chanel) select 1)-_MinSleep;
	sleep 10;
	while {true} do {
		_Soundindex=floor(random ((Uns_radio_numSound select _chanelSide)select _chanel));
		_NextSound= format ["Uns_radio_%1_CHAN%2_TRACK%3",(Uns_radio_sides select _chanelSide),_chanel,_Soundindex];
		['Uns_radio', [_chanel,_chanelSide,_Soundindex]] call CBA_fnc_globalEvent;
		_duracion = getnumber(ConfigFile >> "CfgSounds" >>_NextSound>>"duration");
		sleep _duracion;
		sleep (_MinSleep + (random _MaxSleep));
	};
};

Uns_radio_FNC_InitSide = {
	private["_chanel", "_Soundindex", "_chanelSide","_duracion","_NextSound"];
	_Sideinit=_this select 0;
	
	//init ground  chanel
	if (((Uns_radio_numSound select _Sideinit)select 0) >0)then {
		[0,_Sideinit] spawn Uns_radio_FNC_MainRadioLoop;
	};
	
	//init air chanel
	if (((Uns_radio_numSound select _Sideinit) select 1) >0)then {
		[1,_Sideinit] spawn Uns_radio_FNC_MainRadioLoop;
	};
	
	//init generic  chanel
	if (((Uns_radio_numSound select _Sideinit) select 2) >0)then {
		[2,_Sideinit] spawn Uns_radio_FNC_MainRadioLoop;
	};
};

Uns_radio_FNC_RadioCallAndANS = {
	private["_caller", "_side", "_callType","_duracion","_callTrack","_lastTrackAir","_lastTrackGround"];
	_caller=_this select 0;
	_side=_this select 1;
	_callType=_this select 2;
	//uns_radio_calltypes=["AIREXTRAC", "RESUPPLY", "CAS", "MORTAR", "ARTY"]

	_lastTrackGround=(uns_radio_lastsounds select _side) select 0;
	_lastTrackAir=(uns_radio_lastsounds select _side) select 1;
	

	_callTrack= format ["Uns_radio_%1_CALL_%2",(Uns_radio_sides select _side),(uns_radio_calltypes select _callType)];
	_duracion = getnumber(ConfigFile >> "CfgSounds" >>_callTrack>>"duration");
	[_caller, _callTrack] call CBA_fnc_globalSay3d;
	
	sleep (_duracion + (random 4));
	_callTrack= format ["Uns_radio_%1_ANSWER_%2",(Uns_radio_sides select _side),(uns_radio_calltypes select _callType)];
	_duracion = getnumber(ConfigFile >> "CfgSounds" >>_callTrack>>"duration");
	
	//play on ground channel
	['Uns_radio', [0,_side,_callType,true]] call CBA_fnc_globalEvent;
	
	sleep (_duracion + (random 4));
	
	['Uns_radio', [0,_side,_lastTrackGround]] call CBA_fnc_globalEvent;
};

Uns_radio_FNC_getSideNum = {
	//Uns_radio_sides=[east,west,resistance,civilian];
	switch (_this) do 
	{ 
		case east: {0}; 
		case west: {1}; 
		case resistance: {2}; 
		case civilian: {3}; 
	};
};

Uns_radio_FNC_ResetUnitEmiters = {
	private["_LocalLogic"];
	if (isDedicated) exitwith{}; // No sounds on dedi :)
	
	Uns_radio_timeLastCheck=0;
	//delete all logics, create them again to reset any playing sound :S
	//Fun enough seems to be no other way to stop a sound played with say3d except killing/deleting the unit
	{
		if (!isnil {_x getvariable "uns_radio_locLogic"}) then {
			_LocalLogic =_x getvariable "uns_radio_locLogic";
			deletevehicle _LocalLogic;
			
			_LocalLogic = "Logic" createVehicleLocal (getPos _x);
			_x setVariable ["uns_radio_locLogic", _LocalLogic];
			[_x,_LocalLogic] spawn Uns_radio_FNC_UnitRadioCheck;
		};
	} foreach allunits;
};
Uns_radio_FNC_BuildEmisorList = {
	//Plays a sound on all the sources near to the player on the chanel
	private["_chanel", "_Soundindex", "_chanelSide","_SoundName","_eastTransG","_eastTransA",
	"_westTransG","_westTransA","_resisTransG","_resisTransA","_civTransG","_civTransA","_sideR",
	"_eastTransGE","_westTransGE","_resisTransGE","_civTransGE","_LocalLogic"];
	_eastTransG=[];_westTransG=[]; _eastTransA=[];_westTransA=[]; _eastTransGE=[];_westTransGE=[];
	_resisTransG=[];_civTransG=[]; _resisTransA=[];_civTransA=[]; _resisTransGE=[];_civTransGE=[];
	
	if (isDedicated) exitwith{}; // No sounds on dedi :)
	
	//Units with radio (ground chanel)
	{
		if (_x call uns_radio_FNC_HasRadio) then {
			if (isnil {_x getvariable "uns_radio_locLogic"}) then {
				_LocalLogic = "Logic" createVehicleLocal (getPos _x);
				_x setVariable ["uns_radio_locLogic", _LocalLogic];
				[_x,_LocalLogic] spawn Uns_radio_FNC_UnitRadioCheck;
			} else {
				_LocalLogic =_x getvariable "uns_radio_locLogic";
			};

			switch (side (group _x)) do {
				case west : {_westTransG=_westTransG+[_LocalLogic]};
				case east : {_eastTransG=_eastTransG+[_LocalLogic]};
				case Resistance : {_resisTransG=_resisTransG+[_LocalLogic]};
				case Civilian : {_civTransG=_civTransG+[_LocalLogic]};
				default {};                          
			};
		};
	} foreach allunits;
	
	//ground vehicles with radio. TODO no need to constant check
	{
		if (! isnull (driver _x)) then
		{
			_sideR=side (group (driver _x));
		} else{
			_sideR=Uns_radio_sides select (getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "side"));
		};
		
		switch _sideR do {
			case west : {_westTransG=_westTransG+[_x]};
			case east : {_eastTransG=_eastTransG+[_x]};
			case Resistance : {_resisTransG=_resisTransG+[_x]};
			case Civilian : {_civTransG=_civTransG+[_x]};
			default {};                          
		};
	} foreach uns_radio_allground;
		
	//air vehicles with radio. TODO no need to constant check
	{
		if (! isnull (driver _x)) then
		{
			_sideR=side (group  driver _x);
		} else{
			_sideR=Uns_radio_sides select (getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "side"));
		};
		
		switch _sideR do {
			case west : {_westTransA=_westTransA+[_x]};
			case east : {_eastTransA=_eastTransA+[_x]};
			case Resistance : {_resisTransA=_resisTransA+[_x]};
			case Civilian : {_civTransA=_civTransA+[_x]};
			default {};                          
		};
	} foreach uns_radio_allair;
	
	//Generic objects with radio. TODO no need to constant check
	{
		if (isNumber (configFile>>"CfgVehicles" >> typeOf _x >> "Uns_has_Radio")) then
		{
			_sideR=Uns_radio_sides select (getNumber (configFile>>"CfgVehicles" >> typeOf _x >> "Uns_has_Radio"));
		} else{
			//_sideR=getNumber (configFile>>"CfgVehicles" >> typeOf _vehicle >> "Uns_has_Radio") // read from config
			_sideR=sideEnemy; //Not recogniced 
		};
		
		switch _sideR do {
			case west : {_westTransGE=_westTransGE+[_x]};
			case east : {_eastTransGE=_eastTransGE+[_x]};
			case Resistance : {_resisTransGE=_resisTransGE+[_x]};
			case Civilian : {_civTransGE=_civTransGE+[_x]};
			default {};                          
		};
	} foreach uns_radio_allgeneric;
	
	uns_radio_emisor=[[_eastTransG,_eastTransA,_eastTransGE],[_westTransG,_westTransA,_westTransGE],[_resisTransG,_resisTransA,_resisTransGE],[_civTransG,_civTransA,_civTransGE]];
	
	Uns_radio_timeLastCheck=time+10;// only refresh this each 10 seconds and needed -->long loop :)
	//TODO: improve the way to get the transmiters? this is just the first test
};

Uns_radio_FNC_AddVehicle = {
	private["_vehicle", "_Soundindex", "_chanelSide","_duracion","_NextSound"];
	_vehicle=_this select 0;
	
	if (_vehicle iskindof "Air") then{
		//if (getNumber (configFile>>"CfgVehicles" >> typeOf _vehicle >> "Uns_has_Radio")>0) then {
			uns_radio_allair=uns_radio_allair+[_vehicle];
		//};
	} else {
		if (_vehicle iskindof "Car") then{
			//if (getNumber (configFile>>"CfgVehicles" >> typeOf _vehicle >> "Uns_has_Radio")>0) then {
				uns_radio_allground=uns_radio_allground+[_vehicle];
			//};
		} else {
			if (_vehicle iskindof "uns_transitor") then{
				uns_radio_allgeneric=uns_radio_allgeneric+[_vehicle];
			};
		};
	};
};



uns_radio_FNC_HasRadio = {
	(_this hasweapon "UNS_ItemRadio");
};
uns_radio_FNC_HasRadio_OFF = {
	(_this hasweapon "UNS_ItemRadio_OFF")
};

uns_radio_FNC_HasAnyRadio = {
	((_this hasweapon "UNS_ItemRadio") || (_this hasweapon "UNS_ItemRadio_OFF"))
};

uns_radio_FNC_Radio_Toggle_ONOFF = {
	private["_unit", "_radioStatus", "_inVehicle","_LastInVehicle"];
	_unit=_this;
	_radioStatus=(_this hasweapon "UNS_ItemRadio");
	
	if (_radioStatus) then
	{
		_this removeweapon "UNS_ItemRadio";
		_this addweapon "UNS_ItemRadio_OFF";
	} else {
		_this removeweapon "UNS_ItemRadio_OFF";
		_this addweapon "UNS_ItemRadio";
	};
	call Uns_radio_FNC_GUI_UpdatePower;
	!_radioStatus;
};

Uns_radio_FNC_UnitRadioCheck = {
	private["_unit", "_LocalLogic", "_inVehicle","_LastInVehicle"];
	_unit=_this select 0;
	_LocalLogic=_this select 1;
	_inVehicle=(_unit != vehicle _unit);
	_LastInVehicle=_inVehicle;
	_LocalLogic attachTo [vehicle _unit,[0,0,0.5]];
	
	While {!isnull _unit && (_unit call uns_radio_FNC_HasRadio)} do {
		_inVehicle=(_unit != vehicle _unit);
		//Units goes into a vehicle, attach the logic to the vehicle
		if (_inVehicle && !_LastInVehicle) then {
			detach _LocalLogic;
			_LocalLogic attachTo [(vehicle _unit),[0,0,0.5]];
		};
		
		//Units goes out a vehicle, attach the logic to the unit
		if (!_inVehicle && _LastInVehicle) then {
			detach _LocalLogic;
			_LocalLogic attachTo [_unit,[0,0,0.5]];
		};		
		_LastInVehicle=_inVehicle;
		sleep 2;
	};
	deletevehicle _LocalLogic;
	if (!isnull _unit) then {
		_unit setVariable ["uns_radio_locLogic", nil];
	};
};


uns_radio_ainRadioDialogLoad =
{
	uns_radio_manualShwon=false;
	call Uns_radio_FNC_GUI_UpdateSelector;
	call Uns_radio_FNC_GUI_UpdatePower;
	call Uns_radio_FNC_GUI_Manual;
};



uns_radio_FNC_Radio_SelectChannel=
{
	if ((count _this) > 1) then {
		uns_radio_selectedChannel=_this select 1
	} else{
		uns_radio_selectedChannel=uns_radio_selectedChannel+1;
	};
	
	if ((uns_radio_selectedChannel <= 0) || (uns_radio_selectedChannel > uns_radio_LastChanel)) then {uns_radio_selectedChannel=1;};
	call Uns_radio_FNC_GUI_UpdateSelector;
};


uns_radio_FNC_Radio_UseRadio=
{
	_radioStatus=(_this hasweapon "UNS_ItemRadio");
	if (!_radioStatus) exitwith	{player sidechat "Turn ON your radio before!"};
	
	playSound ["UNS_RADIO_TRANS",true];
	
	switch (uns_radio_selectedChannel) do 
	{ 
	  case 1: {call uns_radio_callExtractionButton}; 
	  case 2: {execVM '\UNS_Support\scripts\airsupport\airsupport_call.sqf'}; 
	  case 3: {hint "no supplies left"}; 
	};
};

Uns_radio_FNC_GUI_UpdateSelector = {
	private["_ctrlSelector","_ctrlSelector2","_DialogDisplayVar"];
	disableSerialization;
	_DialogDisplayVar=(uiNamespace getVariable 'uns_radio_MainDiag_var');
	_ctrlSelector=_DialogDisplayVar displayCtrl 1205;
	_ctrlSelector2=_DialogDisplayVar displayCtrl 1206;
	_ctrlSelector3=_DialogDisplayVar displayCtrl 1207;
	
	
	{ _x ctrlShow false }foreach [_ctrlSelector,_ctrlSelector2,_ctrlSelector3];
	
	switch (uns_radio_selectedChannel) do 
	{ 
	  case 1: {_ctrlSelector ctrlShow true;}; 
	  case 2: {_ctrlSelector2 ctrlShow true;}; 
	  case 3: {_ctrlSelector3 ctrlShow true;}; 
	};
};

Uns_radio_FNC_GUI_UpdatePower = {
	private["_radioStatus","_DialogDisplayVar","_ctrlPowerON","_ctrlPowerOFF","_ctrlPowerSelector1","_ctrlPowerSelector2","_ctrlPowerONTransmit"];
	_radioStatus=(uns_radio_owner hasweapon "UNS_ItemRadio");
	disableSerialization;
	_DialogDisplayVar=(uiNamespace getVariable 'uns_radio_MainDiag_var');
	_ctrlPowerONTransmit=_DialogDisplayVar displayCtrl 1202;
	_ctrlPowerON=_DialogDisplayVar displayCtrl 1201;
	_ctrlPowerOFF=_DialogDisplayVar displayCtrl 1200;
	
	
	_ctrlPowerSelector1=_DialogDisplayVar displayCtrl 1203;
	_ctrlPowerSelector2=_DialogDisplayVar displayCtrl 1204;
	
	
	{ _x ctrlShow false }foreach [_ctrlPowerONTransmit,_ctrlPowerON,_ctrlPowerOFF,_ctrlPowerSelector1,_ctrlPowerSelector2];
	
	if (_radioStatus) then{
		_ctrlPowerON ctrlShow true;
		_ctrlPowerSelector2 ctrlShow true;
	} else {
		_ctrlPowerOFF ctrlShow true;
		_ctrlPowerSelector1 ctrlShow true;
	};
};

Uns_radio_FNC_GUI_Manual= {
	private["_radioStatus","_DialogDisplayVar","_ctrlManualBG","_ctrlManualCloseMan"];
	_radioStatus=(uns_radio_owner hasweapon "UNS_ItemRadio");
	
	disableSerialization;
	
	_DialogDisplayVar=(uiNamespace getVariable 'uns_radio_MainDiag_var');
	_ctrlManualBG=_DialogDisplayVar displayCtrl 1208;
	_ctrlManualCloseMan=_DialogDisplayVar displayCtrl 1608;
	
	
	{ _x ctrlShow false }foreach [_ctrlManualBG,_ctrlManualCloseMan];
	
	if (uns_radio_manualShwon) then{
		_ctrlManualBG ctrlShow true;
		_ctrlManualCloseMan ctrlShow true;
	};
};

uns_radio_FNC_Radio_Manual={
	private["_radioStatus"];
	_radioStatus=(uns_radio_owner hasweapon "UNS_ItemRadio");
	//if (!uns_radio_manualShwon && _radioStatus) exitwith{};
	
	uns_radio_manualShwon=not uns_radio_manualShwon;
	call Uns_radio_FNC_GUI_Manual;
};
