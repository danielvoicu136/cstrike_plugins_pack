#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <fun>
#include <engine>

// Configs 

new const Float:REVIVE_DISTANCE = 100.0;
new const Float:REVIVE_DELAY = 7.0;

#define BOX_MODEL_TE "models/te_soul.mdl" 
#define BOX_MODEL_CT "models/ct_soul.mdl"

#define BOX_TRANSLATE_OFFSET_Z 1.0 


// Plugin 


#define MAX_BOXES 33

new stuck[MAX_BOXES];

new const Float:size[][3] = {
    {0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, 
    {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, 
    {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, 
    {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0}, {0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, 
    {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, 
    {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, 
    {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
    {0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, 
    {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, 
    {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, 
    {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0}, {0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, 
    {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, 
    {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, 
    {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
    {0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, 
    {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, 
    {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, 
    {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};


new boxes[MAX_BOXES];
new Float:box_origin[MAX_BOXES][3];
new box_owner[MAX_BOXES];
new bool:box_is_used[MAX_BOXES];
new Float:temp_origin[MAX_BOXES][3]; 




public plugin_init()
{
    register_plugin("Revive Box", "1.0", "Daniel");
    register_event("HLTV", "NewRoundEvent", "a", "1=0", "2=0");
    RegisterHam(Ham_Spawn, "player", "hamSpawn", 1);
    RegisterHam(Ham_Killed, "player", "hamKilled", 1);
    RegisterHam(Ham_Player_PreThink, "player", "hamPlayerPreThink");
	
}

public plugin_precache() {
  precache_model(BOX_MODEL_TE);
  precache_model(BOX_MODEL_CT);
} 


public NewRoundEvent()
{
    for (new i = 0; i < MAX_BOXES; i++)
    {
        if (boxes[i])
        {
            remove_entity(boxes[i]);
            boxes[i] = 0;
            box_owner[i] = 0;
            box_is_used[i] = false;
        }
    }
}

public hamKilled(victim, attacker, shouldgib)
{
    if (!is_user_connected(victim))
        return;

    if (!is_valid_player(victim))
        return;

    new Float:origin[3];
    entity_get_vector(victim, EV_VEC_origin, origin);

    origin[2] -= BOX_TRANSLATE_OFFSET_Z;

    new box = create_entity("info_target");
    if (box == -1)
        return;

    if (cs_get_user_team(victim) == CS_TEAM_T)
    {
        entity_set_model(box, BOX_MODEL_TE);
        fm_set_rendering(box, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 100); 
    }
    else if (cs_get_user_team(victim) == CS_TEAM_CT)
    {
        entity_set_model(box, BOX_MODEL_CT);
        fm_set_rendering(box, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 100);
    }

    entity_set_string(box, EV_SZ_classname, "revive_box");
    entity_set_origin(box, origin);

    for (new i = 0; i < MAX_BOXES; i++)
    {
        if (!boxes[i])
        {
            boxes[i] = box;
            box_owner[i] = victim;
            box_origin[i][0] = origin[0];
            box_origin[i][1] = origin[1];
            box_origin[i][2] = origin[2] + BOX_TRANSLATE_OFFSET_Z;
            box_is_used[i] = false;
            break;
        }
    }
}




public hamPlayerPreThink(id)
{
    if (!is_valid_player(id) || !is_user_alive(id))
        return;

    new Float:player_origin[3];
    entity_get_vector(id, EV_VEC_origin, player_origin);

    for (new i = 0; i < MAX_BOXES; i++)
    {
        if (boxes[i] && is_valid_player(box_owner[i])) 
        {
            if (get_distance_f(player_origin, box_origin[i]) <= REVIVE_DISTANCE)
            {
                if (cs_get_user_team(id) == cs_get_user_team(box_owner[i]) && !box_is_used[i])
                {
                    new name[32];
                    get_user_name(box_owner[i], name, charsmax(name));
                    client_print(id, print_center, "Press R to revive [ %s ]", name);

                    if (pev(id, pev_button) & IN_RELOAD || pev(id, pev_button) & IN_USE)
                    {
                        box_is_used[i] = true;
                        set_task(REVIVE_DELAY, "revivePlayer", i);
                        client_print(id, print_chat, "[ %s ] will revive in %.1f seconds !", name, REVIVE_DELAY );
                        client_print(id, print_center, "[ %s ] will revive in %.1f seconds !", name, REVIVE_DELAY );
                    }
                }
            }
        }
    }
}


public hamSpawn(id)
{
    for (new i = 0; i < MAX_BOXES; i++)
    {
        if (boxes[i] && box_owner[i] == id)
        {
            remove_entity(boxes[i]);
            boxes[i] = 0;
            box_owner[i] = 0;
            box_is_used[i] = false;
        }
    }
}

public revivePlayer(i)
{
    if (boxes[i] && is_valid_player(box_owner[i]) && is_user_connected(box_owner[i]) 
        && !is_user_alive(box_owner[i]) 
        && (cs_get_user_team(box_owner[i]) == CS_TEAM_T || cs_get_user_team(box_owner[i]) == CS_TEAM_CT))
    {
        remove_entity(boxes[i]);

        ExecuteHamB(Ham_CS_RoundRespawn, box_owner[i]);

        new player_id = box_owner[i];
        temp_origin[player_id][0] = box_origin[i][0];
        temp_origin[player_id][1] = box_origin[i][1];
        temp_origin[player_id][2] = box_origin[i][2];

        set_task(0.2, "movePlayerToBox", player_id);

        boxes[i] = 0;
        box_owner[i] = 0;
        box_is_used[i] = false;
    }
}

public movePlayerToBox(player_id)
{
    if (is_valid_player(player_id) && is_user_alive(player_id))
    {
	
		temp_origin[player_id][2] = temp_origin[player_id][2] + BOX_TRANSLATE_OFFSET_Z  ;
		
      
        set_user_origin(player_id, temp_origin[player_id]);
        checkstuck(player_id);
	   
        temp_origin[player_id][0] = 0.0;
        temp_origin[player_id][1] = 0.0;
        temp_origin[player_id][2] = 0.0;
    }
}


public checkstuck(id) {
    static Float:origin[3];
    static Float:mins[3], hull;
    static Float:vec[3];
    static o;
    if (is_user_connected(id) && is_user_alive(id)) {
        pev(id, pev_origin, origin);
        hull = pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN;
        if (!is_hull_vacant(origin, hull, id) && !get_user_noclip(id) && !(pev(id, pev_solid) & SOLID_NOT)) {
            ++stuck[id];
            pev(id, pev_mins, mins);
            vec[2] = origin[2];
            for (o = 0; o < sizeof(size); ++o) {
                vec[0] = origin[0] - mins[0] * size[o][0];
                vec[1] = origin[1] - mins[1] * size[o][1];
                vec[2] = origin[2] - mins[2] * size[o][2];
                if (is_hull_vacant(vec, hull, id)) {
                    engfunc(EngFunc_SetOrigin, id, vec);
                    set_pev(id, pev_velocity, {0.0, 0.0, 0.0});
                    o = sizeof(size);
                }
            }
        } else {
            stuck[id] = 0;
        }
    }
}

stock bool:is_hull_vacant(const Float:origin[3], hull, id) {
    static tr;
    engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr);
    if (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid)) { 
        return true;
    }
    
    return false;
}


bool:is_valid_player(id) {
    return (id > 0 && id <= 32 && is_user_connected(id));
}

