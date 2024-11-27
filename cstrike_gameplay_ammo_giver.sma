#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>
#include <engine>

#define EV_INT_ammo1 49 
#define EV_INT_weaponid 4 
#define EV_ENT_g_iWeapon 367 

public plugin_init() {
    register_plugin("Auto Refill Weapons", "1.1", "Autor");

    RegisterHam(Ham_Spawn, "player", "player_spawn_post", 1);

    register_event("ItemPickup", "weapon_purchased", "be", "1=weapon_");
}


public player_spawn_post(id) {
    if (!is_user_alive(id) || is_user_bot(id)) return;

    give_full_ammo(id);
	cs_set_user_armor( id, 100, CS_ARMOR_VESTHELM );
}


public weapon_purchased(id) {
    if (!is_user_alive(id) || is_user_bot(id)) return; 

    new weapon_ent = find_ent_by_owner(-1, "weapon_*", id);
    if (weapon_ent > 0) {
 
        new weapon_id = entity_get_int(weapon_ent, EV_INT_weaponid);
        if (weapon_id > 0) {

            reload_weapon(id, weapon_id, weapon_ent);
        }
    }
}

stock give_full_ammo(id) {
    static const weapons[] = { 
        CSW_AK47, CSW_M4A1, CSW_DEAGLE, CSW_AWP, CSW_MP5NAVY, CSW_XM1014, 
        CSW_AUG, CSW_ELITE, CSW_USP, CSW_GLOCK18, CSW_P90, CSW_UMP45, 
        CSW_TMP, CSW_MAC10, CSW_SCOUT, CSW_SG550, CSW_SG552, CSW_GALIL, 
        CSW_FAMAS, CSW_M249, CSW_P228, CSW_FIVESEVEN, CSW_M3 
    };

    for (new i = 0; i < sizeof(weapons); i++) {
        if (cs_get_user_bpammo(id, weapons[i]) >= 0) {
           
            cs_set_user_bpammo(id, weapons[i], cs_get_weapon_maxammo(weapons[i]));
            
            new weapon_ent = find_weapon_ent(id, weapons[i]);
            if (weapon_ent > 0) {
               
                new max_clip = cs_get_weapon_ammo(weapons[i]);
                entity_set_int(weapon_ent, EV_INT_ammo1, max_clip);
  
                if (cs_get_user_weapon(id) == weapons[i]) {
                    execute_reload(id, weapons[i]);
                }
            }
        }
    }
}

stock reload_weapon(id, weapon_id, weapon_ent) {
    
    new max_clip = cs_get_weapon_ammo(weapon_id);
    entity_set_int(weapon_ent, EV_INT_ammo1, max_clip);

    cs_set_user_bpammo(id, weapon_id, cs_get_weapon_maxammo(weapon_id));

    if (cs_get_user_weapon(id) == weapon_id) {
        execute_reload(id, weapon_id);
    }
}

stock execute_reload(id, weapon_id) {
  
    cs_set_user_weapon(id, weapon_id);
}

stock cs_get_weapon_maxammo(weaponid) {
    switch (weaponid) {
        case CSW_AK47: return 90;
        case CSW_M4A1: return 90;
        case CSW_DEAGLE: return 35;
        case CSW_AWP: return 30;
        case CSW_MP5NAVY: return 120;
        case CSW_XM1014: return 32;
        case CSW_AUG: return 90;
        case CSW_ELITE: return 120;
        case CSW_USP: return 48;
        case CSW_GLOCK18: return 120;
        case CSW_P90: return 100;
        case CSW_UMP45: return 90;
        case CSW_TMP: return 120;
        case CSW_MAC10: return 120;
        case CSW_SCOUT: return 90;
        case CSW_SG550: return 90;
        case CSW_SG552: return 90;
        case CSW_GALIL: return 90;
        case CSW_FAMAS: return 90;
        case CSW_M249: return 200;
        case CSW_P228: return 52;
        case CSW_FIVESEVEN: return 100;
        case CSW_M3: return 32;
        default: return 0; 
    }
}


stock cs_get_user_weapon(id) {
    if (!is_user_alive(id)) return -1; 

    new weapon_ent = entity_get_edict(id, EV_ENT_g_iWeapon);
    if (weapon_ent > 0) {
       
        return entity_get_int(weapon_ent, EV_INT_weaponid);
    }
    return -1;
}

stock cs_set_user_weapon(id, weapon_id) {
    if (!is_user_alive(id)) return; 

    new weapon_ent = find_weapon_ent(id, weapon_id);
    if (weapon_ent > 0) {
      
        entity_set_edict(id, EV_ENT_g_iWeapon, weapon_ent);
    }
}

stock find_weapon_ent(id, weapon_id) {
    new weapon_ent = -1;
    while ((weapon_ent = find_ent_by_owner(weapon_ent, "weapon_*", id)) > 0) {
        if (entity_get_int(weapon_ent, EV_INT_weaponid) == weapon_id) {
            return weapon_ent;
        }
    }
    return -1;
}