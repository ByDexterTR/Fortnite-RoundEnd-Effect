#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <overlays>
#include <emitsoundany>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

Handle g_OverlayCookie = null;
Handle g_SoundCookie = null;

public Plugin myinfo = 
{
	name = "Round End Fortnite win & lose effect", 
	author = "ByDexter - Quantum", 
	description = "", 
	version = "1.0.1", 
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	LoadTranslations("fortnite-effect.phrases.txt");
	g_OverlayCookie = RegClientCookie("ByDexter-RoundEndOverlay", "Overlay cookie for roundendoverlay", CookieAccess_Private);
	g_SoundCookie = RegClientCookie("ByDexter-RoundEndSound", "Sound overlay cookie for roundendsound", CookieAccess_Private);
	RegConsoleCmd("sm_effect", RoundEndEffect);
	RegConsoleCmd("sm_efekt", RoundEndEffect);
	HookEvent("round_end", Control_RoundEnd);
}

public void OnMapStart()
{
	ServerCommand("mp_round_restart_delay 9");
	PrecacheDecalAnyDownload("dexter/overlays/victory_royalef");
	PrecacheDecalAnyDownload("dexter/overlays/game_overf");
	PrecacheSoundAny("dexter/overlays/game_win.mp3");
	AddFileToDownloadsTable("sound/dexter/overlays/game_win.mp3");
	PrecacheSoundAny("dexter/overlays/game_over.mp3");
	AddFileToDownloadsTable("sound/dexter/overlays/game_over.mp3");
}

public void OnClientPutInServer(int client)
{
	CreateTimer(7.0, notify, client);
}

public Action notify(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		CPrintToChat(client, "%t", "notifymsg");
	}
}

public Action RoundEndEffect(int client, int args)
{
	effectmenu(client);
}

public Action effectmenu(int client)
{
	char opcionmenu[32];
	Menu menu = new Menu(menucallback);
	menu.SetTitle("%t", "Menutitle");
	
	if (GetIntCookie(client, g_OverlayCookie) == 0)
	{
		Format(opcionmenu, sizeof(opcionmenu), "%t", "ovon");
		
	}
	else if (GetIntCookie(client, g_OverlayCookie) == 1)
	{
		Format(opcionmenu, sizeof(opcionmenu), "%t", "ovoff");
	}
	menu.AddItem("option1", opcionmenu);
	
	if (GetIntCookie(client, g_SoundCookie) == 0)
	{
		Format(opcionmenu, sizeof(opcionmenu), "%t", "soon");
	}
	else if (GetIntCookie(client, g_SoundCookie) == 1)
	{
		Format(opcionmenu, sizeof(opcionmenu), "%t", "sooff");
	}
	menu.AddItem("option2", opcionmenu);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int menucallback(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(itemNum, info, sizeof(info));
		if (strcmp(info, "option1") == 0)
		{
			if (GetIntCookie(client, g_OverlayCookie) == 0)
			{
				CPrintToChat(client, "%t", "chatooff");
				SetClientCookie(client, g_OverlayCookie, "1");
			}
			else if (GetIntCookie(client, g_OverlayCookie) == 1)
			{
				CPrintToChat(client, "%t", "chatoon");
				SetClientCookie(client, g_OverlayCookie, "0");
			}
			effectmenu(client);
		}
		else if (strcmp(info, "option2") == 0)
		{
			if (GetIntCookie(client, g_SoundCookie) == 0)
			{
				CPrintToChat(client, "%t", "chatsoff");
				SetClientCookie(client, g_SoundCookie, "1");
			}
			else if (GetIntCookie(client, g_SoundCookie) == 1)
			{
				CPrintToChat(client, "%t", "chatson");
				SetClientCookie(client, g_SoundCookie, "0");
			}
			effectmenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action Control_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsPlayerAlive(i) && !IsFakeClient(i))
		{
			if (GetIntCookie(i, g_SoundCookie) == 0)
			{
				EmitSoundToClientAny(i, "dexter/overlays/game_win.mp3", SOUND_FROM_PLAYER, 1, 100);
			}
			if (GetIntCookie(i, g_OverlayCookie) == 0)
			{
				ShowOverlay(i, "dexter/overlays/victory_royalef", 9.0);
			}
		}
		else if (!IsPlayerAlive(i) && !IsFakeClient(i))
		{
			if (GetIntCookie(i, g_SoundCookie) == 0)
			{
				EmitSoundToClientAny(i, "dexter/overlays/game_over.mp3", SOUND_FROM_PLAYER, 1, 100);
			}
			if (GetIntCookie(i, g_OverlayCookie) == 0)
			{
				ShowOverlay(i, "dexter/overlays/game_overf", 9.0);
			}
		}
	}
}

int GetIntCookie(int client, Handle handle)
{
	char sCookieValue[32];
	GetClientCookie(client, handle, sCookieValue, sizeof(sCookieValue));
	return StringToInt(sCookieValue);
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}