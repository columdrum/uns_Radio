

#define _ARMA_

//Class uns_radio : config.bin{
class CfgPatches
{
	class uns_radio
	{
		units[] = {};
		weapons[] = {};
		requiredAddons[] ={"CAData","CASounds","CA_Modules","CBA_main","Extended_Eventhandlers","uns_main","UNS_Buildings"};
		version = 1.04;
	};
};

class uns_radio
{
	class config
	{
		MaxDistance = 900;
		sleepTimeGround[] = {10,30}; // {min,max} in seconds
		sleepTimeAir[] = {30,60}; // {min,max} in seconds
		sleepTimeGeneric[] = {0,1}; // {min,max} in seconds	
		OnlyOccupied=1; // only play sounds on vehicles with driver.
		MaxSounds=13; // max number of sounds that can be played at the same time, -1 old behaviour aka unlimited
		
		class MaxSoundsArr {
			ground=5; //max number of simultaneus ground radio playing
			air=5; //max number of simultaneus air radio playing
			generic=3; //max number of simultaneus generic radio playing
		};
		
		class NumSounds{ //number of sounds of each class
			class EAST {
				ground=48; //east ground channel
				air=0;
				generic=0;
			};
			class WEST {
				ground=17; 	//west ground channel
				air=14;		//west air channel
				generic=85; //west generic radio channel
			};
			class RESISTANCE {
				ground=0;
				air=0;
				generic=0;
			};
			class CIVILIAN {
				ground=0;
				air=0;
				generic=0;
			};
		};
	};
};

class Extended_PreInit_EventHandlers
{
	class uns_radio
	{
		init = "call ('\uns_radio\XEH_preInit.sqf' call SLX_XEH_COMPILE)";
	};
};
class Extended_PostInit_EventHandlers
{
	class uns_radio
	{
		init = "call ('\uns_radio\XEH_postInit.sqf' call SLX_XEH_COMPILE)";
	};
};


class Extended_Init_EventHandlers
{
	class Man
	{
		UNS_radio_man = "[(_this select 0)] execVM ""\UNS_radio\s\radio_addaction.sqf""";
	};
	class LandVehicle
	{
		uns_radio_LandVehicleInit = "[_this select 0] spawn Uns_radio_FNC_AddVehicle;";
	};
	class Air
	{
		uns_radio_AirInit = "[_this select 0] spawn Uns_radio_FNC_AddVehicle;";
	};
	class uns_transitor
	{
		uns_radio_transitorInit = "[_this select 0] spawn Uns_radio_FNC_AddVehicle;";
	};
};

class CfgVehicles
{
	class Logic;
	class Thing;
	class Camera1: Thing{};
	class beer: Camera1	{};
	class uns_radioEnable_Logic: Logic
	{
		scope=1;
		displayName = "UNS: Enable environment radio sounds";
		icon = "\uns_radio\images\icon_uns_radio.paa";
		picture = "\uns_radio\images\icon_uns_radio.paa";
		vehicleClass = "Modules";
		class Eventhandlers
		{
			init = "Uns_Radio_enabled = true;";
		};
	};
	class uns_radioDisable_Logic: Logic
	{
		displayName = "UNS: Disable environment radio sounds";
		icon = "\uns_radio\images\icon_uns_radio.paa";
		picture = "\uns_radio\images\icon_uns_radio.paa";
		vehicleClass = "Modules";
		class Eventhandlers
		{
			init = "Uns_Radio_enabled = false;";
		};
	};
	
	class uns_transitor: beer
	{
		Uns_has_Radio=1;
	};
};

class CfgWeapons
{
	class Default;
	class ItemRadio;
	class UNS_ItemRadio: ItemRadio{
		picture = "\uns_radio\images\gear_picture_radio_ca.paa";
	};
	class UNS_ItemRadio_OFF: UNS_ItemRadio{};
};


class CfgSounds
{
	class UNS_RADIO_GUI_CLICK
	{
		name = "UNS_RADIO_GUI_CLICK";
		sound[] = {"uns_radio\sounds\GUI_sounds\click.ogg",1,1};
		titles[] = {};
	};
	class UNS_RADIO_TRANS
	{
		name = "UNS_RADIO_TRANS";
		sound[] = {"uns_radio\sounds\GUI_sounds\START01.ogg",1,1};
		titles[] = {};
	};
	#include "soundconfig\West\GroundChanel.hpp"
	#include "soundconfig\West\AirChanel.hpp"
	#include "soundconfig\West\GenericChanel.hpp"
	#include "soundconfig\West\RadioCall.hpp"
	
	#include "soundconfig\East\GroundChanel.hpp"
	#include "soundconfig\East\AirChanel.hpp"
	#include "soundconfig\East\GenericChanel.hpp"
	#include "soundconfig\East\RadioCall.hpp"
	
	#include "soundconfig\Resistance\GroundChanel.hpp"
	#include "soundconfig\Resistance\AirChanel.hpp"
	#include "soundconfig\Resistance\GenericChanel.hpp"
	#include "soundconfig\Resistance\RadioCall.hpp"
	
	#include "soundconfig\Civ\GroundChanel.hpp"
	#include "soundconfig\Civ\AirChanel.hpp"
	#include "soundconfig\Civ\GenericChanel.hpp"
	
	

};


///////////////////////////////////////////////////////////////////////////
/// Styles
///////////////////////////////////////////////////////////////////////////

// Control types
#define CT_STATIC           0
#define CT_BUTTON           1
#define CT_EDIT             2
#define CT_SLIDER           3
#define CT_COMBO            4
#define CT_LISTBOX          5
#define CT_TOOLBOX          6
#define CT_CHECKBOXES       7
#define CT_PROGRESS         8
#define CT_HTML             9
#define CT_STATIC_SKEW      10
#define CT_ACTIVETEXT       11
#define CT_TREE             12
#define CT_STRUCTURED_TEXT  13
#define CT_CONTEXT_MENU     14
#define CT_CONTROLS_GROUP   15
#define CT_SHORTCUTBUTTON   16
#define CT_XKEYDESC         40
#define CT_XBUTTON          41
#define CT_XLISTBOX         42
#define CT_XSLIDER          43
#define CT_XCOMBO           44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT           80
#define CT_OBJECT_ZOOM      81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK        98
#define CT_USER             99
#define CT_MAP              100
#define CT_MAP_MAIN         101
#define CT_LISTNBOX         102

// Static styles
#define ST_POS            0x0F
#define ST_HPOS           0x03
#define ST_VPOS           0x0C
#define ST_LEFT           0x00
#define ST_RIGHT          0x01
#define ST_CENTER         0x02
#define ST_DOWN           0x04
#define ST_UP             0x08
#define ST_VCENTER        0x0C

#define ST_TYPE           0xF0
#define ST_SINGLE         0x00
#define ST_MULTI          0x10
#define ST_TITLE_BAR      0x20
#define ST_PICTURE        0x30
#define ST_FRAME          0x40
#define ST_BACKGROUND     0x50
#define ST_GROUP_BOX      0x60
#define ST_GROUP_BOX2     0x70
#define ST_HUD_BACKGROUND 0x80
#define ST_TILE_PICTURE   0x90
#define ST_WITH_RECT      0xA0
#define ST_LINE           0xB0

#define ST_SHADOW         0x100
#define ST_NO_RECT        0x200
#define ST_KEEP_ASPECT_RATIO  0x800

#define ST_TITLE          ST_TITLE_BAR + ST_CENTER

// Slider styles
#define SL_DIR            0x400
#define SL_VERT           0
#define SL_HORZ           0x400

#define SL_TEXTURES       0x10

// progress bar 
#define ST_VERTICAL       0x01
#define ST_HORIZONTAL     0

// Listbox styles
#define LB_TEXTURES       0x10
#define LB_MULTI          0x20

// Tree styles
#define TR_SHOWROOT       1
#define TR_AUTOCOLLAPSE   2

// MessageBox styles
#define MB_BUTTON_OK      1
#define MB_BUTTON_CANCEL  2
#define MB_BUTTON_USER    4


///////////////////////////////////////////////////////////////////////////
/// Base Classes
///////////////////////////////////////////////////////////////////////////
class RscText;
class RscStructuredText;
class RscPicture;
class RscEdit;
class RscCombo;
class RscListBox;
class RscButton;
class RscShortcutButton;
class RscShortcutButtonMain;
class RscFrame;
class RscSlider;



class RscUns_radio_invisible_Button:RscButton
{
	colorText[] = {0,0,0,0};
	colorDisabled[] = {0,0,0,0};
	colorBackground[] = {0,0,0,0};
	colorBackgroundDisabled[] = {0,0,0,0};
	colorBackgroundActive[] = {0,0,0,0};
	colorFocused[] = {0,0,0,0};
	colorShadow[] = {0,0,0,0};
	colorBorder[] = {0,0,0,0};
	shadow=0;
};

class uns_radio_MainDiag
{
	onLoad = "uinamespace setvariable ['uns_radio_MainDiag_var',_this select 0];uns_radio_MaiDiag = true; [] spawn uns_radio_ainRadioDialogLoad";
	onUnLoad = "uns_radio_MaiDiag = false; ";
	idd = 45798;
	movingenable = 0;
	class Controls
	{
	
	class RscPicture_1200: RscPicture
	{
		idc = 1200;
		text = "\uns_radio\GUI\RADIO_OFF_ca.paa";
		x = 0.176795 * safezoneW + safezoneX;
		y = 0.117071 * safezoneH + safezoneY;
		w = 0.638904 * safezoneW;
		h = 0.769854 * safezoneH;
	};
	class RscPicture_1201: RscPicture
	{
		idc = 1201;
		text = "\uns_radio\GUI\RADIO_ON_ca.paa";
		x = 0.176795 * safezoneW + safezoneX;
		y = 0.117071 * safezoneH + safezoneY;
		w = 0.638904 * safezoneW;
		h = 0.769854 * safezoneH;
	};
	class RscPicture_1202: RscPicture
	{
		idc = 1202;
		text = "\uns_radio\GUI\RADIO_ON_TRANSMIT_ca.paa";
		x = 0.176795 * safezoneW + safezoneX;
		y = 0.117071 * safezoneH + safezoneY;
		w = 0.638904 * safezoneW;
		h = 0.769854 * safezoneH;
	};
	class RscPicture_1203: RscPicture
	{
		idc = 1203;
		text = "\uns_radio\GUI\xSelector_OFF_ca.paa";
		x = 0.552383 * safezoneW + safezoneX;
		y = 0.522847 * safezoneH + safezoneY;
		w = 0.0553575 * safezoneW;
		h = 0.0702107 * safezoneH;
	};
	class RscPicture_1204: RscPicture_1203
	{
		idc = 1204;
		text = "\uns_radio\GUI\xSelector_ON_ca.paa";
	};
	class RscPicture_1205: RscPicture
	{
		idc = 1205;
		text = "\uns_radio\GUI\xSelector1_ca.paa";
		x = 0.299406 * safezoneW + safezoneX;
		y = 0.464775 * safezoneH + safezoneY;
		w = 0.0666666 * safezoneW;
		h = 0.0968669 * safezoneH;
	};
	class RscPicture_1206: RscPicture_1205
	{
		idc = 1206;
		text = "\uns_radio\GUI\xSelector2_ca.paa";
	};
	class RscPicture_1207: RscPicture_1205
	{
		idc = 1207;
		text = "\uns_radio\GUI\xSelector3_ca.paa";
	};
	class RscPicture_1208: RscPicture
	{
		idc = 1208;
		text = "\uns_radio\GUI\MANUAL_OPEN_ca.paa";
		x = 0.176795 * safezoneW + safezoneX;
		y = 0.117071 * safezoneH + safezoneY;
		w = 0.638904 * safezoneW;
		h = 0.769854 * safezoneH;
	};
	class RscButton_1600: RscUns_radio_invisible_Button
	{
		idc = 1600;
		x = 0.552381 * safezoneW + safezoneX;
		y = 0.522848 * safezoneH + safezoneY;
		w = 0.0428571 * safezoneW;
		h = 0.0616426 * safezoneH;
		tooltip = "Power";
		onButtonClick="uns_radio_owner call uns_radio_FNC_Radio_Toggle_ONOFF;";
		soundClick[] = {"uns_radio\sounds\GUI_sounds\click.ogg",1,1};
	};
	class RscButton_1601: RscUns_radio_invisible_Button
	{
		idc = 1601;
		x = 0.307145 * safezoneW + safezoneX;
		y = 0.478105 * safezoneH + safezoneY;
		w = 0.0541666 * safezoneW;
		h = 0.0683067 * safezoneH;
		tooltip = "selector";
		onButtonClick="[uns_radio_owner] call uns_radio_FNC_Radio_SelectChannel;";
		soundClick[] = {"uns_radio\sounds\GUI_sounds\click.ogg",1,1};
	};
	class RscButton_1602: RscUns_radio_invisible_Button
	{
		idc = 1602;
		x = 0.701786 * safezoneW + safezoneX;
		y = 0.458112 * safezoneH + safezoneY;
		w = 0.0345238 * safezoneW;
		h = 0.166364 * safezoneH;
		tooltip = "use";
		onButtonClick="uns_radio_owner call uns_radio_FNC_Radio_UseRadio;";
	};
	class RscButton_1603: RscUns_radio_invisible_Button
	{
		idc = 1604;
		text = "evac";
		x = 0.458333 * safezoneW + safezoneX;
		y = 0.513328 * safezoneH + safezoneY;
		w = 0.0446429 * safezoneW;
		h = 0.0188022 * safezoneH;
		tooltip = "Air extract";
		onButtonClick="[uns_radio_owner,1] call uns_radio_FNC_Radio_SelectChannel;";
		soundClick[] = {"uns_radio\sounds\GUI_sounds\click.ogg",1,1};
	};
	class RscButton_1604: RscUns_radio_invisible_Button
	{
		idc = 1605;
		text = "support";
		x = 0.457142 * safezoneW + safezoneX;
		y = 0.539985 * safezoneH + safezoneY;
		w = 0.0476191 * safezoneW;
		h = 0.0159461 * safezoneH;
		tooltip = "Support channel";
		onButtonClick="[uns_radio_owner,2] call uns_radio_FNC_Radio_SelectChannel;";
		soundClick[] = {"uns_radio\sounds\GUI_sounds\click.ogg",1,1};
	};
	class RscButton_1605: RscUns_radio_invisible_Button
	{
		idc = 1606;
		text = "evac";
		x = 0.46012 * safezoneW + safezoneX;
		y = 0.564737 * safezoneH + safezoneY;
		w = 0.0452383 * safezoneW;
		h = 0.0159461 * safezoneH;
		tooltip = "Resuply";
		onButtonClick="[uns_radio_owner,3] call uns_radio_FNC_Radio_SelectChannel;";
		soundClick[] = {"uns_radio\sounds\GUI_sounds\click.ogg",1,1};
	};
	class RscButton_1606: RscUns_radio_invisible_Button
	{
		idc = 1607;
		text = "evac";
		x = 0.328571 * safezoneW + safezoneX;
		y = 0.249621 * safezoneH + safezoneY;
		w = 0.196429 * safezoneW;
		h = 0.127331 * safezoneH;
		tooltip = "manual";
		onButtonClick="call uns_radio_FNC_Radio_Manual;";
	};
	class RscButton_1608: RscUns_radio_invisible_Button
	{
		idc = 1608;
		x = 0.176795 * safezoneW + safezoneX;
		y = 0.117071 * safezoneH + safezoneY;
		w = 0.638904 * safezoneW;
		h = 0.769854 * safezoneH;
		tooltip = "close manual";
		onButtonClick="call uns_radio_FNC_Radio_Manual;";
	};
	
	class RscButton_1609: RscUns_radio_invisible_Button
	{
		idc = 1609;
		tooltip = "transmit";
		x = 0.626239 * safezoneW + safezoneX;
		y = 0.39376 * safezoneH + safezoneY;
		w = 0.0297515 * safezoneW;
		h = 0.148296 * safezoneH;
		onButtonClick="uns_radio_owner call uns_radio_FNC_Radio_UseRadio;";
	};
	};
};

