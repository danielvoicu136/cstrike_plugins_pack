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


#define HEAL_SPRITE "sprites/medic3.spr" 
#define HEAL_SOUND "items/medshot4.wav"


// Plugin 

new Float:targetTime[33]; 
new targetPlayer[33]; 
new Float:healTick[33]; 
new SpriteHead;


 
 
public plugin_init() {
    register_plugin("Heal on Aim", "1.4", "Daniel");
	
    RegisterHam(Ham_Player_PreThink, "player", "on_prethink");
}

public plugin_precache() { 
	precache_sound(HEAL_SOUND);
	SpriteHead = precache_model(HEAL_SPRITE);
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
			
			
				new pacient[32];
				get_user_name(aimPlayer, pacient, charsmax(pacient));

				new medic[32];
				get_user_name(id, medic, charsmax(medic));

				client_print(aimPlayer, print_chat, "[ %s ] is healing you. Don't move !", medic);
				client_print(aimPlayer, print_center, "[ %s ] is healing you. Don't move !", medic);

				client_print(id, print_chat, "[ %s ] is being healed. Keep aiming at him !", pacient);
				client_print(id, print_center, "[ %s ] is being healed. Keep aiming at him !", pacient);
				
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
	
	emit_sound(id, CHAN_AUTO, HEAL_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM);
	Util_TE_PLAYERATTACHMENT(0, id, 40, SpriteHead, 20);
				
}

stock Util_TE_PLAYERATTACHMENT(id, playerIndex, verticalOffset, modelIndex, life)
{
    message_begin(id ? MSG_ONE : MSG_ALL, SVC_TEMPENTITY, _, id);
    write_byte(TE_PLAYERATTACHMENT);
    write_byte(playerIndex); // entity index of player
    write_coord(verticalOffset); // vertical offset (attachment origin.z = player origin.z + vertical offset)
    write_short(modelIndex); // model index
    write_short(life); // life * 10
    message_end();
} 