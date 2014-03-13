
Uns_radio_MaxDistance=getNumber (configFile >> "uns_radio" >> "config" >> "MaxDistance");
//Uns_radio_numSound=getArray (configFile >> "uns_radio" >> "config" >> "NumSounds"); //[ EAST , WEST , RESISTANCE , CIVILIAN];
_tmparray=[[],[],[],[]];
_tmparray2=[];
uns_logics_updated=false;
{
	_tmparray2=[(getNumber (configFile >> "uns_radio" >> "config" >> "NumSounds" >> _x >> "ground")),
	(getNumber (configFile >> "uns_radio" >> "config" >> "NumSounds">> _x >> "air")),
	(getNumber (configFile >> "uns_radio" >> "config" >> "NumSounds" >> _x >> "generic"))];
	_tmparray set [_forEachIndex,_tmparray2];
} foreach ["EAST", "WEST", "RESISTANCE", "CIVILIAN"];
Uns_radio_numSound=_tmparray;


Uns_radio_sleep_delays=[getArray (configFile >> "uns_radio" >> "config" >> "sleepTimeGround"),
	getArray (configFile >> "uns_radio" >> "config" >> "sleepTimeAir"),
	getArray (configFile >> "uns_radio" >> "config" >> "sleepTimeGeneric")];


uns_radio_Logics=[];		
uns_radio_emisor=[[[],[],[]],[[],[],[]],[[],[],[]],[[],[],[]]];
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

uns_radio_MaxSounds=(getNumber (configFile >> "uns_radio" >> "config" >> "MaxSounds"));
uns_radio_MaxSoundsArr=[(getNumber (configFile >> "uns_radio" >> "config" >> "MaxSoundsArr" >> "ground")),
						(getNumber (configFile >> "uns_radio" >> "config" >> "MaxSoundsArr" >> "air")),
						(getNumber (configFile >> "uns_radio" >> "config" >> "MaxSoundsArr" >> "generic"))];
uns_radio_OnlyOccupied=(getNumber (configFile >> "uns_radio" >> "config" >> "OnlyOccupied")) ==1;



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

Uns_radio_FNC_Update_logics={
	private["_list","_chanel", "_Soundindex", "_chanelSide","_SoundName","_eastTransG","_eastTransA",
	"_westTransG","_westTransA","_resisTransG","_resisTransA","_civTransG","_civTransA","_sideR",
	"_eastTransGE","_westTransGE","_resisTransGE","_civTransGE","_LocalLogic"];
	_totalSourcesGroud=0;
	_totalSourcesAir=0;
	_totalSourcesGeneric=0;
	uns_logics_updated=false;
	
	//call uns_radio_FNC_createnewlogics;
	uns_radio_emisor=[[[],[],[]],[[],[],[]],[[],[],[]],[[],[],[]]];
	_eastTransG=[];_westTransG=[]; _eastTransA=[];_westTransA=[]; _eastTransGE=[];_westTransGE=[];
	_resisTransG=[];_civTransG=[]; _resisTransA=[];_civTransA=[]; _resisTransGE=[];_civTransGE=[];
	
	Uns_radio_timeLastCheck=time+10;// only refresh this each 10 seconds and needed -->long loop :)
	_list = (position player) nearEntities 150;
	diag_log["update","list:",_list,time];
	call Uns_radio_FNC_unassigAllLogics;

	{
		if (_x isKindOf "CAManBase") then {
			if (_x call uns_radio_FNC_HasRadio) then {
				
				switch (side (group _x)) do {
					case west : {_westTransG=_westTransG+[_x]};
					case east : {_eastTransG=_eastTransG+[_x]};
					case Resistance : {_resisTransG=_resisTransG+[_x]};
					case Civilian : {_civTransG=_civTransG+[_x]};
					default {};                          
				};
				_totalSourcesGroud=_totalSourcesGroud+1;
			};
		};
	
	
	//ground vehicles with radio. TODO no need to constant check
		if (_x isKindOf "Car") then {
			if (! isnull (driver _x)) then
			{
				_sideR=side (group (driver _x));
			} else{
				_sideR=Uns_radio_sides select (getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "side"));
			};
			
			if (!uns_radio_OnlyOccupied || ! isnull (driver _x)) then {
				switch _sideR do {
					case west : {_westTransG=_westTransG+[_x]};
					case east : {_eastTransG=_eastTransG+[_x]};
					case Resistance : {_resisTransG=_resisTransG+[_x]};
					case Civilian : {_civTransG=_civTransG+[_x]};
					default {};                          
				};
				_totalSourcesGroud=_totalSourcesGroud+1;
			};
		};
		
		//air vehicles with radio. TODO no need to constant check

		if (_x isKindOf "Air") then {
			if (! isnull (driver _x)) then
			{
				_sideR=side (group  driver _x);
			} else{
				_sideR=Uns_radio_sides select (getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "side"));
			};
			
			if (!uns_radio_OnlyOccupied || ! isnull (driver _x)) then {
				switch _sideR do {
					case west : {_westTransA=_westTransA+[_x]};
					case east : {_eastTransA=_eastTransA+[_x]};
					case Resistance : {_resisTransA=_resisTransA+[_x]};
					case Civilian : {_civTransA=_civTransA+[_x]};
					default {};                          
				};
				_totalSourcesAir=_totalSourcesAir+1;
			};
		};

	
		//Generic objects with radio. TODO no need to constant check
	
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
		_totalSourcesGeneric=_totalSourcesGeneric+1;
	} foreach _list;
	

	_params=[[_eastTransG,_eastTransA,_eastTransGE],[_westTransG,_westTransA,_westTransGE],[_resisTransG,_resisTransA,_resisTransGE],[_civTransG,_civTransA,_civTransGE]];
	uns_radio_totalSources=[_totalSourcesGroud,_totalSourcesAir,_totalSourcesGeneric];
	diag_log["update4","_params:",_params,time];
	_params call Uns_radio_FNC_assingLogics;
	uns_logics_updated=true;
	diag_log["*-**logics**-*-",uns_radio_Logics,"*-*****-*-"];
};

Uns_radio_FNC_unassigLogic={
	private["_logic","_unit"];
	_logic= _this;
	_unit=_logic getVariable "uns_radio_unitatt";
	
	if (!isnil "_unit") then {
		if (!isnull _unit) then {
			_unit setvariable ["uns_radio_locLogic",nil];
		};
	};
	
	detach _logic;
	_logic setvariable ["uns_radio_assigned",nil];
	_logic setpos [-1000,-1000,-1000];
};

Uns_radio_FNC_attachLogic={
	private["_logic","_emisor"];
	_logic= _this select 0;
	_emisor= _this select 1;

	diag_log["attaching",_this];
	_emisor setvariable ["uns_radio_locLogic",_logic];
	
	if (_emisor isKindOf "CAManBase") then {[_emisor,_logic] spawn Uns_radio_FNC_UnitRadioCheck;};
	
	_logic setvariable ["uns_radio_unitatt",_emisor];

	
	_logic setvariable ["uns_radio_assigned",true];
	_logic attachTo [vehicle _emisor,[0,0,0.5]];
	
	_logic call uns_radio_fnc_addemisor;
	
};

Uns_radio_FNC_unassigAllLogics={
	{
		_x call Uns_radio_FNC_unassigLogic;
	} foreach uns_radio_Logics;
};




uns_radio_fnc_addemisor= {
	private["_logic","_radio_side","_radio_channel"];
	_logic= _this;
	_radio_side = _logic getvariable "uns_radio_side";
	_radio_channel = _logic getvariable "uns_radio_channel";
	diag_log["add 1"];
	if (!isnil "_radio_side" && !isnil "_radio_channel") then {
		_tmparray1=uns_radio_emisor select _radio_side;
		_tmparray2= (uns_radio_emisor select _radio_side) select _radio_channel;
		_tmparray2= _tmparray2 + [_logic];
		_tmparray1 set [_radio_channel, _tmparray2];
		uns_radio_emisor set [_radio_side,_tmparray1];
		diag_log["add 5",_tmparray1, "arr 2", _tmparray2,"uns_radio_emisor", uns_radio_emisor];
	};
};

uns_radio_fnc_removeEmisor= {
	private["_logic","_radio_side","_radio_channel"];
	
	diag_log["remove 1"];
	_logic= _this;
	_radio_side = _logic getvariable "uns_radio_side";
	_radio_channel = _logic getvariable "uns_radio_channel";
	
	if (!isnil "_radio_side" && !isnil "_radio_channel") then {
		_tmparray1=uns_radio_emisor select _radio_side;
		_tmparray2= (uns_radio_emisor select _radio_side) select _radio_channel;
		diag_log["remove 2",_tmparray1, "arr 2", _tmparray2];
		_tmparray2= _tmparray2 - [_logic];
		diag_log["remove 3",_tmparray1, "arr 2", _tmparray2];
		_tmparray1 set [_radio_channel, _tmparray2];
		diag_log["remove 4",_tmparray1, "arr 2", _tmparray2,"uns_radio_emisor", uns_radio_emisor];
		uns_radio_emisor set [_radio_side,_tmparray1];
		diag_log["remove 5",_tmparray1, "arr 2", _tmparray2,"uns_radio_emisor", uns_radio_emisor];
	};
};

Uns_radio_FNC_assingLogics={
	private["_totalRadios","_totalRadiosGround","_totalRadiosAir","_totalRadiosGeneric","_totalSources",
	"_totalSourcesGround","_totalSourcesAir","_totalSourcesGeneric"];
	_totalRadios=uns_radio_MaxSounds;
	_totalRadiosGround= uns_radio_MaxSoundsArr select 0;
	_totalRadiosAir= uns_radio_MaxSoundsArr select 1;
	_totalRadiosGeneric= uns_radio_MaxSoundsArr select 2;
	
	_totalSourcesGround= uns_radio_totalSources select 0;
	_totalSourcesAir= uns_radio_totalSources select 1;
	_totalSourcesGeneric= uns_radio_totalSources select 2;
	_totalSources=_totalSourcesGround+_totalSourcesAir+_totalSourcesGeneric;
	
	diag_log["assinglogics","radio",_totalRadios,_totalRadiosGround,_totalRadiosAir,_totalRadiosGeneric,"source",_totalSourcesGround,_totalSourcesAir,_totalSourcesGeneric,_totalSources, time];
	
	//TODO: shitty implementation needs clean up
		//west:
			//ground
			_westTransG=(_this select 1) select 0;
			//Air
			_westTransA=(_this select 1) select 1;
			//Generic
			_westTransGE=(_this select 1) select 2;
		//east:
			//ground
			_eastTransG=(_this select 0) select 0;
			//Air
			_eastTransA=(_this select 0) select 1;
			//Generic
			_eastTransGE=(_this select 0) select 2;
		//reistance:
			//ground
			_resisTransG=(_this select 2) select 0;
			//Air
			_resisTransA=(_this select 2) select 1;
			//Generic
			_resisTransGE=(_this select 2) select 2;
		//civil:
			//ground
			_civTransG=(_this select 3) select 0;
			//Air
			_civTransA=(_this select 3) select 1;
			//Generic
			_civTransGE=(_this select 3) select 2;
	
	diag_log["assinglogics2",format["west: %1 %2 %3, east: %4 %5 %6, %7 %8 %9, %10 %11 %12",
	_westTransG,_westTransA,_westTransGE,_eastTransG,_eastTransA,_eastTransGE,
	_resisTransG,_resisTransA,_resisTransGE,_civTransG,_civTransA,_civTransGE]];
	uns_Radio_asingLogics=[];
	_lastTotalRadios=0;
	//distribute all the max radio sounds throught the total sources.
	while {_totalSources >0 && _totalRadios >0 && _lastTotalRadios !=_totalRadios } do {
		_lastTotalRadios=_totalRadios;
		
		//ground:
		if (_totalRadiosGround>0) then {
			if (count _westTransG > 0 && _totalRadiosGround>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGround=_totalRadiosGround-1;
				_totalSources=_totalSources-1;
				_emisor= _westTransG select 0;
				[_emisor,1, 0] call uns_radio_FNC_asingLogicFirstPass;
				_westTransG=_westTransG- [_emisor];
			};
			if (count _eastTransG > 0 && _totalRadiosGround>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGround=_totalRadiosGround-1;
				_totalSources=_totalSources-1;
				_emisor= _eastTransG select 0;
				[_emisor,0, 0] call uns_radio_FNC_asingLogicFirstPass;
				_eastTransG=_eastTransG- [_emisor];
			};
			if (count _resisTransG > 0 && _totalRadiosGround>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGround=_totalRadiosGround-1;
				_emisor= _resisTransG select 0;
				[_emisor,2, 0] call uns_radio_FNC_asingLogicFirstPass;
				_resisTransG=_resisTransG- [_emisor];
			};
			if (count _civTransG > 0 && _totalRadiosGround>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGround=_totalRadiosGround-1;
				_totalSources=_totalSources-1;
				_emisor= _civTransG select 0;
				[_emisor,3, 0] call uns_radio_FNC_asingLogicFirstPass;
				_civTransG=_civTransG- [_emisor];
			};
		};
		
		//air
		if (_totalRadiosAir>0) then {
			if (count _westTransA > 0 && _totalRadiosAir>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosAir=_totalRadiosAir-1;
				_totalSources=_totalSources-1;
				_emisor= _westTransA select 0;
				[_emisor,1, 1] call uns_radio_FNC_asingLogicFirstPass;
				_westTransA=_westTransA- [_emisor];
			};
			if (count _eastTransA > 0 && _totalRadiosAir>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosAir=_totalRadiosAir-1;
				_totalSources=_totalSources-1;
				_emisor= _eastTransA select 0;
				[_emisor,0, 1] call uns_radio_FNC_asingLogicFirstPass;
				_eastTransA=_eastTransA- [_emisor];
			};
			if (count _resisTransA > 0 && _totalRadiosAir>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosAir=_totalRadiosAir-1;
				_totalSources=_totalSources-1;
				_emisor= _resisTransA select 0;
				[_emisor,3, 1] call uns_radio_FNC_asingLogicFirstPass;
				_resisTransA=_resisTransA- [_emisor];
			};
			if (count _civTransA > 0 && _totalRadiosAir>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosAir=_totalRadiosAir-1;
				_totalSources=_totalSources-1;
				_emisor= _civTransA select 0;
				[_emisor,4, 1] call uns_radio_FNC_asingLogicFirstPass;
				_civTransA=_civTransA- [_emisor];
			};
		};
		

		//generic
		if (_totalRadiosGeneric>0) then {
			if (count _westTransGE > 0 && _totalRadiosGeneric>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGeneric=_totalRadiosGeneric-1;
				_totalSources=_totalSources-1;
				_emisor= _westTransGE select 0;
				[_emisor,1, 2] call uns_radio_FNC_asingLogicFirstPass;
				_westTransGE=_westTransGE- [_emisor];
			};
			if (count _eastTransGE > 0 && _totalRadiosGeneric>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGeneric=_totalRadiosGeneric-1;
				_totalSources=_totalSources-1;
				_emisor= _eastTransGE select 0;
				[_emisor,0, 2] call uns_radio_FNC_asingLogicFirstPass;
				_eastTransGE=_eastTransGE- [_emisor];
			};
			if (count _resisTransGE > 0 && _totalRadiosGeneric>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGeneric=_totalRadiosGeneric-1;
				_totalSources=_totalSources-1;
				_emisor= _resisTransGE select 0;
				[_emisor,3, 2] call uns_radio_FNC_asingLogicFirstPass;
				_resisTransGE=_resisTransGE- [_emisor];
			};
			if (count _civTransGE > 0 && _totalRadiosGeneric>0) then {
				_totalRadios=_totalRadios-1;
				_totalRadiosGeneric=_totalRadiosGeneric-1;
				_totalSources=_totalSources-1;
				_emisor= _civTransGE select 0;
				[_emisor,4, 2] call uns_radio_FNC_asingLogicFirstPass;
				_civTransGE=_civTransGE- [_emisor];
			};
		};
		diag_log["assinglogics3", _totalSources, "t",_lastTotalRadios,_totalRadios, time];
	};
	diag_log["assinglogics3",time];
	call uns_radio_FNC_asingLogicSecondPass;
	diag_log["assinglogics5",time];
};

//first pass, reuse old logics
uns_radio_FNC_asingLogicFirstPass={
	private["_emisor","_radio_side","_radio_channel","_found"];
	_emisor=_this select 0;
	_radio_side=_this select 1;
	_radio_channel=_this select 2;
	_found=false;
	
	diag_log["firstpass1"];
	{
		if (isnil {_x getvariable "uns_radio_assigned"} && _radio_side==(_x getvariable ["uns_radio_side",-1]) && _radio_channel==(_x getvariable ["uns_radio_channel",-1]) ) exitwith {
			[_x,_emisor] call Uns_radio_FNC_attachLogic;
			_found=true;
		};
	} foreach uns_radio_Logics;
	diag_log["firstpass2"];
	if (!_found) then {
		uns_Radio_asingLogics set [count uns_Radio_asingLogics, [_emisor,_radio_side,_radio_channel]];
	}
};

//second pass recreate them
uns_radio_FNC_asingLogicSecondPass={
	private["_emisor","_radio_side","_radio_channel","_logic"];
	
	diag_log["second pass"];
	{
		_emisor=_x select 0;
		_radio_side=_x select 1;
		_radio_channel=_x select 2;
		_found=false;
		{
			if (isnil {_x getvariable "uns_radio_assigned"}) exitwith {
				_logic=_x;
				[_x,_forEachIndex,_radio_side,_radio_channel] call uns_radio_FNC_recreatelogic;
				_found=true;
			};
			diag_log["second pass1"];
		} foreach uns_radio_Logics;
		if (!_found) then {
			_logic =[_radio_side,_radio_channel] call uns_radio_FNC_createlogic;
		};	
		[_logic,_emisor] call Uns_radio_FNC_attachLogic;
		diag_log["second pass2"];
	} foreach uns_Radio_asingLogics;
	diag_log["second pass3"];
};

uns_radio_FNC_recreatelogic={
	private["_logic","_index","_radio_side","_radio_channel","_unit"];
	_logic= _this select 0;
	_index= _this select 1;
	_radio_side= _this select 2;
	_radio_channel= _this select 3;
	
	diag_log["recreating", _this];
	if (!isnull _logic && ((uns_radio_Logics select _index) != _logic)) exitwith {diag_log["critical radio error 23"];};
	
	_unit=_logic getVariable "uns_radio_unitatt";
	_logic call uns_radio_fnc_removeEmisor;
	
	_LocalLogic = "Logic" createVehicleLocal (getPos _logic);
	deletevehicle _logic;
	
	uns_radio_Logics set [_index,_LocalLogic];
	
	_LocalLogic setvariable ["uns_radio_side",_radio_side];
	_LocalLogic setvariable ["uns_radio_channel",_radio_channel];
	if (!isnil "_unit") then {
		if (!isnull _unit) then {
			[_LocalLogic,_unit] call Uns_radio_FNC_attachLogic;
		};
	};
	
	diag_log["recreating", _LocalLogic,_logic, "-params-", _this];
	
};

uns_radio_FNC_recreateAllGroundlogics={
	{
		if (!isnil {_x getvariable "uns_radio_channel"}) then {
			if ((_x getvariable ["uns_radio_channel",-1])==0) then {
				[_x , _forEachIndex,(_x getvariable ["uns_radio_side",-1]),(_x getvariable ["uns_radio_channel",-1])] call uns_radio_FNC_recreatelogic;
			};
		};
	} foreach uns_radio_Logics;
};


uns_radio_FNC_createlogic={ //creates logics 1 by 1
	private["_LocalLogic","_radio_side","_radio_channel"];
	_radio_side=_this select 0;
	_radio_channel=_this select 1;
	
	diag_log["create",_radio_side,_radio_channel];
	_LocalLogic = "Logic" createVehicleLocal [-1000,-1000,0];
	if (!isnull _LocalLogic) then {
		uns_radio_Logics=uns_radio_Logics+[_LocalLogic];
		_LocalLogic setvariable ["uns_radio_side",_radio_side];
		_LocalLogic setvariable ["uns_radio_channel",_radio_channel];
	} else {diag_log["null logic radio created"]};
	
	_LocalLogic
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

if (uns_radio_MaxSounds < 0) then {
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
} else { 
	//Alternate play version with limited number of radio sounds
	Uns_radio_FNC_Play = {
		//Plays a sound on all the sources near to the player on the chanel
		private["_chanel", "_Soundindex", "_chanelSide","_SoundName","_SpecialSound"];
		_chanel=_this select 0;
		_chanelSide=_this select 1;
		_Soundindex=_this select 2;
		_SpecialSound=if (count _this > 3) then {_this select 3} else {false};
		
		diag_log["==============================play==================================", _this];
		if (isDedicated) exitwith{}; // No sounds on dedi :)
		diag_log["play1", time,"==============", _this];
		if (_SpecialSound && _chanel==0) then {call uns_radio_FNC_recreateAllGroundlogics};
		diag_log["play2", format["lastcheck %1",Uns_radio_timeLastCheck],time,"==============", _this];
		if (time >Uns_radio_timeLastCheck) then {call Uns_radio_FNC_Update_logics};
		waituntil{uns_logics_updated};
		diag_log["play3", time,"==============", _this];
		if (!_SpecialSound) then {
			_SoundName=format["Uns_radio_%1_CHAN%2_TRACK%3",(Uns_radio_sides select _chanelSide),_chanel,_Soundindex];
			(uns_radio_lastsounds select _chanelSide) set [_chanel,_Soundindex];
		}else {
			_SoundName=format["Uns_radio_%1_ANSWER_%2",(Uns_radio_sides select _chanelSide),(uns_radio_calltypes select _Soundindex)];
		};
		
		diag_log["play4", time,"==============", _this];
		{
			//if ((_x distance player) < Uns_radio_MaxDistance) then { //dist check shouldn't be needed
			_x say3d _SoundName
			//}; 
		} foreach ((uns_radio_emisor select _chanelSide) select _chanel);
		diag_log["play5", time,"==============", _this,"=========",uns_radio_emisor];
		
	};
	
	Uns_radio_FNC_UnitRadioCheck = {
		private["_unit", "_LocalLogic", "_inVehicle","_LastInVehicle"];
		_unit=_this select 0;
		_LocalLogic=_this select 1;
		
		diag_log["Uns_radio_FNC_UnitRadioCheck",_this];
		if (!isnil {_unit getvariable "uns_radio_UnitRadioCheck"}) exitwith{};
		_unit setvariable ["uns_radio_UnitRadioCheck",true];
		if (isnil "_LocalLogic") then {_LocalLogic=(_unit getVariable "uns_radio_locLogic")};
		
		_inVehicle=(_unit != vehicle _unit);
		_LastInVehicle=_inVehicle;
		_LocalLogic attachTo [vehicle _unit,[0,0,0.5]];
	
		
		diag_log["Uns_radio_FNC_UnitRadioCheck  continue",_this];
		While {!isnull _unit && (_unit call uns_radio_FNC_HasRadio) && !isnil "_LocalLogic"} do {
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
			_LocalLogic=_unit getVariable "uns_radio_locLogic";
		};

		diag_log["Uns_radio_FNC_UnitRadioCheck  ****FIn****",_this];
		if (!isnil "_LocalLogic") then {(_unit getVariable "uns_radio_locLogic") call Uns_radio_FNC_unassigLogic;};
		_unit setvariable ["uns_radio_UnitRadioCheck",nil];
	};
};