#include <amxmodx> 
#include <amxmisc> 
#include <cstrike> 
#include <fun> 
#include <engine>
#include <hamsandwich>
#include <fakemeta>

#define TASK_TIME 2.0

new g_BanList = WC3_MapDisableCheck("free_nade_ban_maps.cfg");

bool:WC3_MapDisableCheck(szFileName[])
{

	new szFile[128];
	get_configsdir(szFile, 127);
	formatex(szFile, 127, "%s/war3ft/disable/%s", szFile, szFileName);

	if (!file_exists(szFile))
		return false;

	new iLineNum, szData[64], iTextLen, iLen;
	new szMapName[64], szRestrictName[64];
	get_mapname(szMapName, 63);

	while (read_file(szFile, iLineNum, szData, 63, iTextLen))
	{
		iLen = copyc(szRestrictName, 63, szData, '*');

		if (equali(szMapName, szRestrictName, iLen))
		{
			return true;
		}

		iLineNum++;
	}

	return false;
}

public plugin_init()
{
    register_plugin("Free Silent Nades", "1.0", "Daniel");
    RegisterHam(Ham_Spawn, "player", "ham_spawn_post", 1);
	register_message(get_user_msgid("TextMsg"), "block_FITH_message");
	register_message(get_user_msgid("SendAudio"), "block_FITH_audio");
}

public ham_spawn_post(id)
{
    if(!g_BanList) { 
        set_task(TASK_TIME,"give_delay",id);
    }

}


public give_delay(id) { 

       if(is_user_alive(id)) {
		give_item(id, "weapon_smokegrenade");
		//client_print(id, print_chat, "* [WAR3FT] You earned a Frozen Smoke Grenade !");
	}

} 

public block_FITH_message(msg_id, msg_dest, entity)
{

	if(get_msg_args() == 5)
	{
		if(get_msg_argtype(5) == ARG_STRING)
		{
			new value5[64];
			get_msg_arg_string(5 ,value5 ,63);
			if(equal(value5, "#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED;
			}
		}
	}
	else if(get_msg_args() == 6)
	{
		if(get_msg_argtype(6) == ARG_STRING)
		{
			new value6[64];
			get_msg_arg_string(6 ,value6 ,63);
			if(equal(value6 ,"#Fire_in_the_hole"))
			{
				return PLUGIN_HANDLED;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public block_FITH_audio(msg_id, msg_dest, entity)
{
	if(get_msg_args() == 3)
	{
		if(get_msg_argtype(2) == ARG_STRING)
		{
			new value2[64];
			get_msg_arg_string(2 ,value2 ,63);
			if(equal(value2 ,"%!MRAD_FIREINHOLE"))
			{
				return PLUGIN_HANDLED;
			}
		}
	}
	return PLUGIN_CONTINUE;
}
