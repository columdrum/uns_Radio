
['Uns_radio', {_this spawn Uns_radio_FNC_Play}] call CBA_fnc_addEventHandler;


[] spawn {
	sleep 10;

	if (isNil "Uns_Radio_enabled") then {Uns_Radio_enabled=true};
	if (Uns_Radio_enabled) then {
		if (isServer) then {
			{[_x] call Uns_radio_FNC_InitSide} foreach [0,1,2,3];
		};
	};
};
