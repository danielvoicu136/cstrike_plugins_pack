#include <amxmodx> 
#include <amxmisc> 
#include <cstrike> 
#include <fun> 
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cs_player_models_api>

#define TERO_MODEL		"war3ft_tero"
#define CT_MODEL		"war3ft_ct"


public plugin_init() {
    register_plugin("Day Night Cycle", "1.0.1", "Daniel");
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled");
	RegisterHam(Ham_Spawn, "player", "ham_spawn_post", 1);
	
}


new bool:isNight = false;
new const Float:cycleTime = 45.0; 
new const Float:rewardInterval = 1.0; 
new const dayMoneyReward = 25; 
new const nightHealthReward = 1; 

new ConstFogDensity[    ]  =
{
	0,0,0,0,111,18,3,58,111,18,125,58,66,96,27,59,
		90,101,60,59,90,101,68,59,10,41,95,59,
		111,18,125,59,111,18,3,60,68,116,19,60,0,0,0,0
};

new const daySounds[][] = {
    "warcraft3/day1.wav",
    "warcraft3/day2.wav"
};

new const nightSounds[][] = {
    "warcraft3/night1.wav",
    "warcraft3/night2.wav"
};

public plugin_precache() {
    for (new i = 0; i < sizeof(daySounds); i++) {
        precache_sound(daySounds[i]);
    }
    for (new j = 0; j < sizeof(nightSounds); j++) {
        precache_sound(nightSounds[j]);
    }
	
	new TeroModel[128]
	formatex(TeroModel, charsmax(TeroModel), "models/player/%s/%s.mdl", TERO_MODEL, TERO_MODEL)
	precache_model(TeroModel)
	if(file_exists(TeroModel)) precache_model(TeroModel)
	
	new CTModel[128]
	formatex(CTModel, charsmax(CTModel), "models/player/%s/%s.mdl", CT_MODEL, CT_MODEL)
	precache_model(CTModel)
	if(file_exists(CTModel)) precache_model(CTModel)
	
}

public plugin_cfg() {
    set_task(cycleTime, "toggleDayNight", _, _, _, "b");
    set_task(rewardInterval, "rewardPlayers", _, _, _, "b");
}

public toggleDayNight() {

    isNight = !isNight;

    if (isNight) {
	
       
        set_lights("j");
		MakeFogToPlayer( 0 );
        new randomIndex = random_num(0, sizeof(nightSounds) - 1);
        emit_sound(0, CHAN_AUTO, nightSounds[randomIndex], 1.0, ATTN_NORM, 0, PITCH_NORM);
        client_print_color(0, print_chat, "!n* [WAR3FT]!n Time to survive, it's !tNIGHT TIME !n( Healing and Double XP )");
	
		
    } else {
       
        set_lights("m");
		MakeFog(  0,  0, 0 ,0, 0, 0 ,0, 0 );
        new randomIndex = random_num(0, sizeof(daySounds) - 1);
        emit_sound(0, CHAN_AUTO, daySounds[randomIndex], 1.0, ATTN_NORM, 0, PITCH_NORM);
        client_print_color(0, print_chat, "!n* [WAR3FT]!n Get to work, it's !tDAY TIME !n( Farming and Mining $ )");
    }

}

public rewardPlayers() {
    new players[32], playerCount;
    get_players(players, playerCount, "ch"); 

    for (new i = 0; i < playerCount; i++) {
        new player = players[i];

        if (isNight) {
            new health = get_user_health(player);
            set_user_health(player, health + nightHealthReward);
        } 
		else {
            new money = cs_get_user_money(player);
            cs_set_user_money(player, money + dayMoneyReward);
        }
    }
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || attacker == victim || !attacker)
	return HAM_IGNORED;
	
	if(isNight)		
	{
		static Float:FOrigin3[3] 
		pev(victim, pev_origin, FOrigin3)
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin3, 0)
		write_byte(TE_IMPLOSION)
		engfunc(EngFunc_WriteCoord, FOrigin3[0])
		engfunc(EngFunc_WriteCoord, FOrigin3[1])
		engfunc(EngFunc_WriteCoord, FOrigin3[2])
		write_byte(200)
		write_byte(100)
		write_byte(5)  
		message_end()
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin3, 0)
		write_byte(TE_PARTICLEBURST) // TE id
		engfunc(EngFunc_WriteCoord, FOrigin3[0]) // x
		engfunc(EngFunc_WriteCoord, FOrigin3[1]) // y
		engfunc(EngFunc_WriteCoord, FOrigin3[2]) // z
		write_short(50) // radius
		write_byte(72) // color
		write_byte(6) // duration (will be randomized a bit)
		message_end()
	}  
	return PLUGIN_HANDLED
} 

public ham_spawn_post(id)
{
    if (is_user_alive(id) && isNight)
    {	
			switch(get_user_team(id)) 
			{
				case 1: {	cs_set_player_model(id, TERO_MODEL);			}
				case 2: {  	cs_set_player_model(id, CT_MODEL);  			}
			}	
    }
	else if (is_user_alive(id))
	{ 
		cs_reset_player_model(id);
	}
}



public MakeFogToPlayer(  id  )
{
		new iRed  =  clamp(  135, 0, 255 );
		new iGreen  =  clamp(  135, 0, 255 );
		new iBlue =  clamp(  135, 0, 255 );
		
		new iDensity  =  clamp(  1, 1, 9 );
		
		new iSD = 4 * iDensity;
		new iED = iSD + 1;
		new iD1 = iSD + 2;
		new iD2 = iSD + 3;
		
		MakeFog(  id,  iRed, iGreen, iBlue, ConstFogDensity[ iSD ], ConstFogDensity[ iED ], ConstFogDensity[ iD1 ], ConstFogDensity[ iD2 ] );
	
	return 0;
}


MakeFog(  id,  const iRed,  const iGreen,  const iBlue,  const iSD,  const iED,  const iD1,  const iD2  )
{
	
	message_begin(  id  ==  0 ? MSG_ALL  : MSG_ONE,  get_user_msgid( "Fog" ),  {0, 0, 0},  id  );
	write_byte( iRed );  // R
	write_byte( iGreen );  // G
	write_byte( iBlue );  // B
	write_byte( iSD ); // SD
	write_byte( iED );  // ED
	write_byte( iD1 );   // D1
	write_byte( iD2 );  // D2
	message_end(  );
}

stock client_print_color(id, type, const text[], any:...)
{
 if(type == print_chat)
 {
  new g_iMsgidSayText;
  g_iMsgidSayText = get_user_msgid("SayText");

  new szMsg[191], iPlayers[32], iCount = 1;
  vformat(szMsg, charsmax(szMsg), text, 3);

  replace_all(szMsg, charsmax(szMsg), "!g","^x04");
  replace_all(szMsg, charsmax(szMsg), "!n","^x01");
  replace_all(szMsg, charsmax(szMsg), "!t","^x03");

  if(id)
   iPlayers[0] = id;
  else
   get_players(iPlayers, iCount, "ch");

  for(new i = 0 ; i < iCount ; i++)
  {
   if(!is_user_connected(iPlayers[i]))
    continue;
   
   message_begin(MSG_ONE_UNRELIABLE, g_iMsgidSayText, _, iPlayers[i]);
   write_byte(iPlayers[i]);
   write_string(szMsg);
   message_end();
  }
 }
} 