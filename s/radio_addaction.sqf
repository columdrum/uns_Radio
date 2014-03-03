//Air support action
_unit = _this select 0;

if (isDedicated || !isnil {_unit getVariable "uns_radioActions"}) exitwith{};

//gx_asp_enablecond = format["((_target==_this) || (_this== leader _target)) && (_target call uns_radio_FNC_HasRadio)&& UNS_AIR_Support_%1_Enabled",playerside];
//_unit addAction ["<t color='#FFD201'>Call Support</t>", "\UNS_Support\scripts\airsupport\airsupport_call.sqf", "", 0, false, true, "", gx_asp_enablecond];
//_unit addAction ["<t color='#AE0000'>Turn Radio Off</t>", "\uns_radio\Actions\Action_Radio_Toggle.sqf", "", 0, false, true, "", "((_target==_this) || (_this== leader _target))&& (_target call uns_radio_FNC_HasRadio)"];
//_unit addAction ["<t color='#00AE17'>Turn Radio ON</t>", "\uns_radio\Actions\Action_Radio_Toggle.sqf", "", 0, false, true, "", "((_target==_this) || (_this== leader _target))&& (_target call uns_radio_FNC_HasRadio_OFF)"];
_unit setVariable ["uns_radioActions",true];

_unit addAction ["<t color='#FFD201'>Radio menu</t>", "\uns_radio\Actions\RadioDialog.sqf", "", 0, false, true, "", "((_target==_this) || (_this== leader _target))&&(_target call uns_radio_FNC_HasAnyRadio)"];

_unit addeventhandler ["respawn", {(_this select 0) setVariable ["uns_radioActions",nil];_this execVM "\UNS_radio\s\radio_addaction.sqf"}];

