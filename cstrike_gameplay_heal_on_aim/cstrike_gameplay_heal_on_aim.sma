#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <fun>
#include <engine>


// Configs 
#define HEAL_AMOUNT 5 			// how much healing per tick 
#define TARGET_TIME 1.0 		// how many seconds you need to aim a player to start ticking
#define MAX_HEALTH 100			// what max health a player can have , heal until this value 

#define SHOW_AIM_INFO 0			// show central hud player name and health 0 OFF 1 ON 


new Float:targetTime[33]; 
new targetPlayer[33]; 
new Float:healTick[33]; 



public plugin_init() {
    register_plugin("Heal on Aim", "1.4", "Daniel");
	
    RegisterHam(Ham_Player_PreThink, "player", "on_prethink");
}

public plugin_precache() { 
	precache_sound("items/medshot4.wav");
} 

public client_disconnect(id) {
    targetTime[id] = 0.0;
    targetPlayer[id] = 0;
    healTick[id] = 0.0;
}

public on_prethink(id) {
    if (!is_user_alive(id)) {
        targetTime[id] = 0.0;
        targetPlayer[id] = 0;
        healTick[id] = 0.0;
        return;
    }

    new aimPlayer = get_aiming_player(id);

    if (aimPlayer > 0 && aimPlayer != id && is_user_alive(aimPlayer) && is_teammate(id, aimPlayer)) {
        if (targetPlayer[id] != aimPlayer) {
            targetTime[id] = get_gametime();
            targetPlayer[id] = aimPlayer;
            healTick[id] = 0.0;
        }
		else if (get_gametime() - targetTime[id] >= TARGET_TIME) {
            if (get_gametime() - healTick[id] >= 1.0) {
                heal_player(aimPlayer);
				heal_player(id);
                healTick[id] = get_gametime();
            }
        }
		
        new name[32];
        get_user_name(aimPlayer, name, charsmax(name));
        new health = get_user_health(aimPlayer);

        new red, green, blue;
        if (health > 80) {
            red = 0; green = 255; blue = 0; // Verde
        } else if (health > 60) {
            red = 127; green = 255; blue = 0; // Verde deschis
        } else if (health > 40) {
            red = 255; green = 255; blue = 0; // Galben
        } else if (health > 20) {
            red = 255; green = 127; blue = 0; // Portocaliu
        } else {
            red = 255; green = 0; blue = 0; // Roșu
        }

		if(SHOW_AIM_INFO > 0) { 
			set_hudmessage(red, green, blue, -1.0, 0.60, 0, 6.0, 1.0, 0.1, 0.1, -1);
			show_hudmessage(id, "%s ^n[ %d HP ]", name, health);
		}
		
		
    } else {
    
        targetTime[id] = 0.0;
        targetPlayer[id] = 0;
        healTick[id] = 0.0;
    }
}

public get_aiming_player(id) {
    new aimPlayer, body;
    get_user_aiming(id, aimPlayer, body);
    return aimPlayer;
}

public is_teammate(id1, id2) {
    return (get_user_team(id1) == get_user_team(id2));
}

public heal_player(id) {

	new health = get_user_health(id);
	
	if(health < MAX_HEALTH) { 
		new newHealth = min(health + HEAL_AMOUNT, MAX_HEALTH); 
		set_user_health(id, newHealth);
	}
	
	emit_sound(id, CHAN_AUTO, "items/medshot4.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static Float:FOrigin3[3] 
	pev(id, pev_origin, FOrigin3)
		
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin3, 0)
	write_byte(TE_IMPLOSION)
	engfunc(EngFunc_WriteCoord, FOrigin3[0])
	engfunc(EngFunc_WriteCoord, FOrigin3[1])
	engfunc(EngFunc_WriteCoord, FOrigin3[2])
	write_byte(200)
	write_byte(100)
	write_byte(5)  
	message_end()
			
}


