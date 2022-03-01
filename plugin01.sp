//danl:     STEAM_1:1:432977205
#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "DanL, NoRysq"
#define PLUGIN_VERSION "0.03"
#define WEBSOCKET_PORT 22121

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
// Websocket Server by Peace-Maker: https://forums.alliedmods.net/showthread.php?t=182615
#include <websocket>

#pragma newdecls required

EngineVersion g_Game;

public Plugin myinfo = 
{
    name = "DDG-Tournament",
    author = PLUGIN_AUTHOR,
    description = "Custom Plugin for the DDG 2v2 Tournament System",
    version = PLUGIN_VERSION,
    url = ""
};

//--------------------------------------------------------------------------------------------------------------------------//

//static bool matchupDone = false;
static bool _debug = true;
bool isTournamentMode = false;

Handle g_hChilds;
WebsocketHandle g_hListenSocket = INVALID_WEBSOCKET_HANDLE;

public void OnPluginStart()
{
    g_Game = GetEngineVersion();
    g_hChilds = CreateArray();
    if(g_Game != Engine_CSGO)
    {
        SetFailState("This plugin is for CSGO only.");  
    }
    
    if(_debug)
        PrintToServer("---> plugin01 loaded");
    
    HookEvent("player_connect_full", onFullConnect, EventHookMode_Pre);
    HookEvent("player_say", onChatMessage);

    RegServerCmd("start", startTournament);
    RegServerCmd("stop", stopTournament);
}

public void OnAllPluginsLoaded()
{
    char sServerIP[40];
    int longip = GetConVarInt(FindConVar("hostip"));
    FormatEx(sServerIP, sizeof(sServerIP), "%d.%d.%d.%d", (longip >> 24) & 0x000000FF, (longip >> 16) & 0x000000FF, (longip >> 8) & 0x000000FF, longip & 0x000000FF);

    if (g_hListenSocket == INVALID_WEBSOCKET_HANDLE)
        g_hListenSocket = Websocket_Open(sServerIP, WEBSOCKET_PORT, OnWebsocketIncoming, OnWebsocketMasterError, OnWebsocketMasterClose);
}

public Action onFullConnect(Event event, const char[] name, bool dontbroadcast)
{
    if(_debug)
        PrintToServer("---> Player connected");
    
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    // change team to spectator if tournament mode is engaged
    if(isTournamentMode)
        ChangeClientTeam(client, CS_TEAM_SPECTATOR);
    
    // send steam bot friend request to user
    return Plugin_Continue;
}

public Action onChatMessage(Event event, const char[] name, bool dontbroadcast)
{
    /* int client = GetClientOfUserId(GetEventInt(event, "userid")); */

    return Plugin_Continue;
}


public Action startTournament(int _args)
{
    

    // set local tournament mode
    isTournamentMode = true;
    return Plugin_Continue;
}

public Action stopTournament(int _args)
{
    isTournamentMode = false;
    return Plugin_Continue;
}

public void OnMapStart()
{
    if(_debug)
        PrintToServer("---> New map started");
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

public void OnPluginEnd() {
    if (g_hListenSocket != INVALID_WEBSOCKET_HANDLE)
        Websocket_Close(g_hListenSocket);
}





// 
// WebSocket Server methods below
//
public Action OnWebsocketIncoming(WebsocketHandle websocket, WebsocketHandle newWebsocket, const char[] remoteIP, int remotePort, char protocols[256])
{
    Format(protocols, sizeof(protocols), "");
    Websocket_HookChild(newWebsocket, OnWebsocketReceive, OnWebsocketDisconnect, OnChildWebsocketError);
    PushArrayCell(g_hChilds, newWebsocket);
    //PrintToServer("readyState: %d", view_as<int>(Websocket_GetReadyState)(newWebsocket));
    return Plugin_Continue;
}

public void OnWebsocketMasterError(WebsocketHandle websocket, const int errorType, const int errorNum)
{
    LogError("MASTER SOCKET ERROR: handle: %d type: %d, errno: %d", view_as<int>(websocket), errorType, errorNum);
    g_hListenSocket = INVALID_WEBSOCKET_HANDLE;
}

public void OnWebsocketMasterClose(WebsocketHandle websocket)
{
    g_hListenSocket = INVALID_WEBSOCKET_HANDLE;
}

public void OnChildWebsocketError(WebsocketHandle websocket, const int errorType, const int errorNum)
{
    LogError("CHILD SOCKET ERROR: handle: %d, type: %d, errno: %d", view_as<int>(websocket), errorType, errorNum);
    RemoveFromArray(g_hChilds, FindValueInArray(g_hChilds, websocket));
}

public void OnWebsocketReceive(WebsocketHandle websocket, WebsocketSendType iType, const char[] receiveData, const int dataSize)
{
    if(iType == SendType_Text)
    {
        PrintToServer("Socket %d: %s (%d)", view_as<int>(websocket), receiveData, dataSize);
        PrintToChatAll("Socket %d: %s", view_as<int>(websocket), receiveData);
        
        // Need some more space in that string to add that "Socket %d: ..." stuff
        char[] sBuffer = new char[dataSize+30];
        Format(sBuffer, dataSize+30, "Socket %d: %s", view_as<int>(websocket), receiveData);
        
        // relay this chat to other sockets connected
        int iSize = GetArraySize(g_hChilds);
        for(int i = 0; i < iSize; i++)
            // Don't echo the message back to the user sending it!
            if(GetArrayCell(g_hChilds, i) != websocket)
                Websocket_Send(GetArrayCell(g_hChilds, i), SendType_Text, sBuffer);
    }
}

public void OnWebsocketDisconnect(WebsocketHandle websocket)
{
    RemoveFromArray(g_hChilds, FindValueInArray(g_hChilds, websocket));
}
