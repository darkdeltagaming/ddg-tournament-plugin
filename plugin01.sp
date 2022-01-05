#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "DanL, NoRysq"
#define PLUGIN_VERSION "0.02"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma newdecls required

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "plugin01",
	author = PLUGIN_AUTHOR,
	description = "custom plugin for ddg",
	version = PLUGIN_VERSION,
	url = ""
};

//--------------------------------------------------------------------------------------------------------------------------//

//static bool matchupDone = false;
ConVar g_cvWarmupTime;
static bool _debug = true;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	if(_debug)PrintToServer("---> plugin01 loaded");
	
	g_cvWarmupTime = FindConVar("mp_warmuptime");
}

public void OnMapStart()
{
	if(_debug)PrintToServer("---> New map started");
	g_cvWarmupTime.IntValue = 10000;
}