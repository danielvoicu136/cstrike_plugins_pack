#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta>
#include <fakemeta_util> 
#include <cstrike>
#include <hamsandwich>
#include <string>

#include "rpg_items/configuration.inl"
#include "rpg_items/constants.inl"
#include "rpg_items/inventory.inl"
#include "rpg_items/events.inl"

#define PLUGIN_NAME "RPG Items" 
#define PLUGIN_AUTHOR "Daniel" 
#define PLUGIN_VERSION "1.0.1"


public plugin_init() {

register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
register_cvar("rpgitems", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED);
	
	gmsgStatusText = get_user_msgid("StatusText");
		
    register_event("DeathMsg", "on_Death", "a");
    RegisterHam(Ham_TakeDamage, "player", "on_TakeDamage");
	RegisterHam(Ham_Spawn, "player", "on_Spawn", 1);
	register_forward(FM_PlayerPreThink, "FWD_PlayerPreThink");
	
	set_task(1.0, "TASK_SET", _, _, _, "b");
	set_task(1.0, "TASK_HUD", _, _, _, "b");

	
	register_clcmd( "say"				, "cmd_Say"			, -1 );
	register_clcmd( "say_team"			, "cmd_Say"			, -1 );
	
	register_clcmd( "shop"				, "CMD_Handler"			, -1 );
	register_clcmd( "shop2"				, "CMD_Handler"			, -1 );
	register_clcmd( "shopmenu"			, "CMD_Handler"			, -1 );
	register_clcmd( "shopmenu2"			, "CMD_Handler"			, -1 );
	

for (new i = 1; i < sizeof(Items); i++) {
    copy(szAlias, sizeof(szAlias), Items[i][ITEM_COMMAND]);

    new szSingleAlias[64];
    new szLowerCommand[64]; 

    new iLen = strlen(szAlias); 
    new iPos = 0, iAliasPos = 0; 

    while (iPos <= iLen) { 
        if (szAlias[iPos] == ',' || szAlias[iPos] == '^0') { 
            szSingleAlias[iAliasPos] = '^0';

            if (iAliasPos > 0) { 
              
                trim(szSingleAlias);

                copy(szLowerCommand, sizeof(szLowerCommand), szSingleAlias);
                strtolower(szLowerCommand);

                register_clcmd(szLowerCommand, "CMD_Handler", -1);
            }

            iAliasPos = 0;
        } else {
          
            szSingleAlias[iAliasPos++] = szAlias[iPos];
        }
		
        iPos++;
    }
}





	
	
}

public client_putinserver(id) { 
	ITEM_RemoveItems(id); 
	g_iNextGrenade[id] = 0;
	g_iSaveWeapons[id] = 0;
} 


public client_disconnect(id) { 
	ITEM_RemoveItems(id);
	g_iNextGrenade[id] = 0;
	g_iSaveWeapons[id] = 0;
} 


public cmd_Say( id ) {

	new szSaid[32];
	read_args( szSaid, 31 );

	remove_quotes( szSaid );

	CMD_Handle( id, szSaid, true );

	return;
}

public CMD_Handler( id )
{

	new szCmd[32];

	read_argv( 0, szCmd, 31 );

	CMD_Handle( id, szCmd, false );

	return PLUGIN_HANDLED;
}

public CMD_Handle(id, szCmd[], bool:bThroughSay) {
    new szAlias[128], szSingleAlias[32];

for (new i = 1; i < sizeof(Items); i++) {
  
    copy(szAlias, sizeof(szAlias), Items[i][ITEM_COMMAND]);

    new szSingleAlias[64]; 
    new iPos = 0, iAliasPos = 0; 
    new iLen = strlen(szAlias); 

    while (iPos <= iLen) { 
        if (szAlias[iPos] == ',' || szAlias[iPos] == '^0') { 
           
            szSingleAlias[iAliasPos] = '^0';

            if (iAliasPos > 0) { 
                
                trim(szSingleAlias);

                if (CMD_Equal(id, szCmd, szSingleAlias)) {
                    ITEM_Buy(id, i);
                    return;
                }
            }

            iAliasPos = 0;
        } else {
            szSingleAlias[iAliasPos++] = szAlias[iPos];
        }

        iPos++;
    }
}

	
	if ( CMD_Equal( id,  szCmd, "shopmenu" ) || CMD_Equal( id, szCmd, "shop" ) || CMD_Equal( id, szCmd, "shopmenu2" ) || CMD_Equal( id, szCmd, "shop2" ) )
	{
		MENU_Shop( id );
	}
		
    return;
}

CMD_Equal( id,  szCmd[], szCorrectCmd[] )
{

	new szTmp[64];
	formatex( szTmp, 63, "/%s", szCorrectCmd );

	new bool:bValid = equali( szCmd, szTmp ) || equali( szCmd, szCorrectCmd );

	return bValid;
}

public TASK_HUD() 
{
    new Players[32], Num;
    get_players(Players, Num, "ch");
    
    for (new index = 0; index < Num; index++) 
    {
        new id = Players[index];
        
        if (!is_valid_player(id) || !is_user_alive(id)) 
            continue;

        new szItems[256];
        new count = 0;

        for (new i = 0; i < MAX_ITEMS; i++) 
        {
            if (g_iPlayerItems[id][i] != ITEM_NONE) 
            {
                if (count > 0) 
                {
                    format(szItems, sizeof(szItems), "%s, %s", szItems, Items[g_iPlayerItems[id][i]][ITEM_NAME]);
                } 
                else 
                {
                    format(szItems, sizeof(szItems), "%s", Items[g_iPlayerItems[id][i]][ITEM_NAME]);
                }
                count++;
            }
        }

        if (count == 0) 
        {
          //  format(szItems, sizeof(szItems), "Items: None");
		  format(szItems, sizeof(szItems), " ");
        }

        Create_StatusText(id, 0, szItems);
    }
}


stock bool:is_valid_player(id)
{
    return (1 <= id <= 32 && is_user_connected(id));
}

stock Create_StatusText(id, linenumber, text[]){
	message_begin( MSG_ONE, gmsgStatusText, {0,0,0}, id )
	write_byte( linenumber )			
	write_string( text )			
	message_end()
}
