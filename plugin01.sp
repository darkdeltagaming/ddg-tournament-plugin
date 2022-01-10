//danl: 	STEAM_1:1:432977205
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
static bool _debug = true;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO)
	{
		SetFailState("This plugin is for CSGO only.");	
	}
	
	if(_debug)PrintToServer("---> plugin01 loaded");
	
	HookEvent("player_connect_full", onFullConnect, EventHookMode_Pre);
}

public Action onFullConnect(Event event, const char[] name, bool dontbroadcast)
{
	if(_debug)PrintToServer("---> Player connected");
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	ChangeClientTeam(client, CS_TEAM_SPECTATOR);
}

public void OnMapStart()
{
	if(_debug)PrintToServer("---> New map started");
}

public int getClientIndex(char[] authString)
{
	for (int i = 1; i <= MaxClients; ++i)
	{
		if(IsClientInGame(i))
		{
			char sAuth[32];
			GetClientAuthId(i, AuthId_Steam2, sAuth, 32);
			if(StrEqual(authString, sAuth))
			{
				return i;
			}
		}
	}
	return -1;
}

