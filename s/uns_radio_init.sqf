/**
 * Unsung - Vietnam War Mod for ArmA 2
 * Radio receiver system (selectable channels playing a set of tracks in a random sequence)
 * 
 * It can be applied to an object, a vehicle or a man (ie a radio operator)
 * All players can select a radio channel or switch off the radio.
 * All players hear the same track. Players joining in progress hear also the right track.
 * The sound source comes from the radio even if it is in move.
 * The volume decreases when the distance increases.
 * 
 * SP & MP & JIP compatible
 * 
 * Launch this script for each object wich can be used as a radio
 * @param 0 the radio Object
 * 
 * Edit your own channels and tracks list in UNS_RADIO_channels_list
 * 
 * You can call the functions UNS_RADIO_FNCT_tune_in and UNS_RADIO_FNCT_switch_off
 * in your own scripts to automatically tune in or switch off the radio.
 */

// Initialization of the functions of the radio system (only at first call)
if (isNil "UNS_RADIO_init") then
{
	UNS_RADIO_init = true;
	
	/**
	 * Array of channels. Each channel is described by an array of tracks.
	 * A track corresponds to a CfgSounds class name and a duration in seconds (format : ["track_classname", duration])
	 */
	UNS_RADIO_channels_list = [
		// Channel 0 - combat
		[
			// Tracks (format : ["track_classname", duration])
			["UNS_RADIO_CHAN0_TRACK0", 9*60+7],
			["UNS_RADIO_CHAN0_TRACK1", 1*60+41],
			["UNS_RADIO_CHAN0_TRACK2", 2*60+32],
			["UNS_RADIO_CHAN0_TRACK3", 2*60+10],
			["UNS_RADIO_CHAN0_TRACK4", 4*60+3],
			["UNS_RADIO_CHAN0_TRACK5", 3*60+13],
			["UNS_RADIO_CHAN0_TRACK6", 0*60+10],
			["UNS_RADIO_CHAN0_TRACK7", 0*60+9],
			["UNS_RADIO_CHAN0_TRACK8", 1*60+34],
			["UNS_RADIO_CHAN0_TRACK9", 7*60+32],
			["UNS_RADIO_CHAN0_TRACK10", 1*60+0],
			["UNS_RADIO_CHAN0_TRACK11", 0*60+9],
			["UNS_RADIO_CHAN0_TRACK12", 0*60+15],
			["UNS_RADIO_CHAN0_TRACK13", 0*60+14]
		],
		// Channel 1 - AFVN Radio
		[
			// Tracks (format : ["track_classname", duration])
			["UNS_RADIO_CHAN1_TRACK0", 49*60+35]
		],
		// Channel 2 - Radio First Termer
		[
			// Tracks (format : ["track_classname", duration])
			["UNS_RADIO_CHAN2_TRACK0", 49*60+35]
		]
	];
	
	/** Public variable to broadcast the new status of a radio Object (format : [Object radio, Channel index, Track index]) */
	UNS_RADIO_PUBVAR_update_status = [objNull, -1, -1];
	
	/*
	 * In addition to UNS_RADIO_PUBVAR_update_status we have a public Object's variable UNS_RADIO_status
	 * to inform JIP players of current channel and track on the concerned radio (format : [Channel index, Track index])
	 *
	 * We have two other local Object's variables : UNS_RADIO_sound_source to save the sound source vehicle
	 * created and UNS_RADIO_server_timer (server only) to save the handle of the timer thread
	 */
	
	/**
	 * When a radio update order is received
	 */
	"UNS_RADIO_PUBVAR_update_status" addPublicVariableEventHandler
	{
		private ["_radio", "_channel", "_track"];
		_radio = UNS_RADIO_PUBVAR_update_status select 0;
		_channel = UNS_RADIO_PUBVAR_update_status select 1;
		_track = UNS_RADIO_PUBVAR_update_status select 2;
		
		// New status = new track
		if (_channel != -1) then
		{
			[_radio, _channel, _track] call UNS_RADIO_FNCT_create_sound_source;
		}
		// New status = off
		else
		{
			[_radio] call UNS_RADIO_FNCT_delete_sound_source;
		};
	};
	
	/**
	 * Tune in the radio to the specified channel (global effect)
	 * @param 0 the radio Object
	 * @param 1 the channel index in UNS_RADIO_channels_list
	 */
	UNS_RADIO_FNCT_tune_in =
	{
		private ["_radio", "_channel", "_track"];
		_radio = _this select 0;
		_channel = _this select 1;
		
		if (alive _radio) then
		{
			// Choose randomly a track number in the channel but not the same twice
			_track = -1;
			if (count (UNS_RADIO_channels_list select _channel) > 1) then
			{
				while {_track == -1 || [_radio] call UNS_RADIO_FNCT_get_current_track == _track} do
				{
					_track = floor random count (UNS_RADIO_channels_list select _channel);
				};
			}
			else
			{
				_track = 0;
			};
			
			// Update status locally and over the network
			_radio setVariable ["UNS_RADIO_status", [_channel, _track], true];
			sleep 0.05;
			
			// Notice other computers to tune in this radio
			UNS_RADIO_PUBVAR_update_status = [_radio, _channel, _track];
			publicVariable "UNS_RADIO_PUBVAR_update_status";
			sleep 0.25;
			
			[_radio, _channel, _track] call UNS_RADIO_FNCT_create_sound_source;
		}
		else
		{
			[_radio] call UNS_RADIO_FNCT_switch_off;
		};
	};
	
	/**
	 * Scitch off the radio (global effect)
	 * @param 0 the radio Object
	 */
	UNS_RADIO_FNCT_switch_off =
	{
		private ["_radio"];
		_radio = _this select 0;
		
		// Update status locally and over the network
		_radio setVariable ["UNS_RADIO_status", [-1, -1], true];
		sleep 0.05;
		
		// Notice other computers to switch off this radio
		UNS_RADIO_PUBVAR_update_status = [_radio, -1, -1];
		publicVariable "UNS_RADIO_PUBVAR_update_status";
		sleep 0.25;
		
		[_radio] call UNS_RADIO_FNCT_delete_sound_source;
	};
	
	/**
	 * Create and attach a sound source to a radio (or any object) (local effect)
	 * @param 0 the radio Object
	 * @param 1 the channel index in UNS_RADIO_channels_list
	 * @param 2 the track index in the channel
	 */
	UNS_RADIO_FNCT_create_sound_source =
	{
		private ["_radio", "_channel", "_track"];
		_radio = _this select 0;
		_channel = _this select 1;
		_track = _this select 2;
		
		// Be sure there is no previous sound source
		[_radio] call UNS_RADIO_FNCT_delete_sound_source;
		
		// Create a local sound source attached to the radio
		_sound_source = "Logic" createVehicleLocal (getPos _radio);
		
		// Save locally the local sound source
		_radio setVariable ["UNS_RADIO_sound_source", _sound_source, false];
		
		// Make the sound source follow the radio
		_sound_source attachTo [_radio, [0, 0, 0]];
		
		// Play the track
		_sound_source say (UNS_RADIO_channels_list select _channel select _track select 0);
		
		// The server must automatically launch a new track when the current finished
		if (isServer) then
		{
			private ["_server_timer"];
			_server_timer = _radio getVariable "UNS_RADIO_server_timer";
			
			// Kill the previous timer (if exists)
			if (!isNil "_server_timer") then
			{
				if (typeName _server_timer == "SCRIPT") then
				{
					if (!scriptDone _server_timer) then
					{
						terminate _server_timer;
					};
				};
			};
			
			// New timer
			_server_timer = [_radio, _channel, _track] spawn
			{
				private ["_radio", "_channel", "_track"];
				_radio = _this select 0;
				_channel = _this select 1;
				_track = _this select 2;
				
				// Wait the duration time and launch a new track
				sleep (UNS_RADIO_channels_list select _channel select _track select 1);
				[_radio, _channel] spawn UNS_RADIO_FNCT_tune_in;
			};
			_radio setVariable ["UNS_RADIO_server_timer", _server_timer, false];
		};
	};
	
	/**
	 * Delete a sound source of a radio (or any object) (local effect)
	 * @param 0 the radio Object
	 */
	UNS_RADIO_FNCT_delete_sound_source =
	{
		private ["_radio", "_sound_source"];
		_radio = _this select 0;
		_sound_source = _radio getVariable "UNS_RADIO_sound_source";
		
		// Delete the sound source if it exists
		if (!isNil "_sound_source") then
		{
			if (typeName _sound_source == "OBJECT") then
			{
				if (!isNull _sound_source) then {deleteVehicle _sound_source};
			};
		};
		_radio setVariable ["UNS_RADIO_sound_source", nil, false];
		
		if (isServer) then
		{
			private ["_server_timer"];
			_server_timer = _radio getVariable "UNS_RADIO_server_timer";
			
			// Kill the previous timer (if exists)
			if (!isNil "_server_timer") then
			{
				if (typeName _server_timer == "SCRIPT") then
				{
					if (!scriptDone _server_timer) then
					{
						terminate _server_timer;
					};
				};
			};
			_radio setVariable ["UNS_RADIO_server_timer", nil, false];
		};
	};
	
	/**
	 * Indicates if the current channel of the radio
	 * @param 0 the radio Object
	 * @return the index in UNS_RADIO_channels_list of the current channel, -1 if the radio is switched off
	 */
	UNS_RADIO_FNCT_get_current_channel =
	{
		private ["_radio", "_status", "_return"];
		_radio = _this select 0;
		_status = _radio getVariable "UNS_RADIO_status";
		_return = -1;
		
		if (!isNil "_status") then
		{
			if (typeName _status == "ARRAY") then
			{
				_return = _status select 0;
			};
		};
		
		_return
	};
	
	/**
	 * Indicates if the current track index in the channel
	 * @param 0 the radio Object
	 * @return the index in UNS_RADIO_channels_list of the current channel, -1 if the radio is switched off
	 */
	UNS_RADIO_FNCT_get_current_track =
	{
		private ["_radio", "_status", "_return"];
		_radio = _this select 0;
		_status = _radio getVariable "UNS_RADIO_status";
		_return = -1;
		
		if (!isNil "_status") then
		{
			if (typeName _status == "ARRAY") then
			{
				_return = _status select 1;
			};
		};
		
		_return
	};
};

_this spawn
{
	sleep 2;
	
	// Initialization of the radio
	private ["_radio"];
	_radio = _this select 0;
	
	// If the radio is yet switched on when joining (ie JIP)
	if (alive _radio && ([_radio] call UNS_RADIO_FNCT_get_current_channel != -1)) then
	{
		private ["_status"];
		_status = _radio getVariable "UNS_RADIO_status";
		
		// Play music
		[_radio, _status select 0, _status select 1] call UNS_RADIO_FNCT_create_sound_source;
	};
};