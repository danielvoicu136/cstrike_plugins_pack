#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <fun>

// Configs 

#define RES_RADIUS 75.0				// Distance from alive player to victim body 
#define RES_TIME 5					// Time requested to complete the revive process 
#define RES_LIMIT 99				// How many times a player can revive 


// Plugin 

#define TASK_REVIVE 134663
#define TASK_SECONDS 24658
#define TASK_MENU 934576

#define MAX_NAME_LENGTH 32
#define MAX_PLAYERS 32



new Name[MAX_PLAYERS + 1][MAX_NAME_LENGTH];
new Float:Origin[MAX_PLAYERS + 1][3];
new bool:IsDead[MAX_PLAYERS + 1];
new Limit[MAX_PLAYERS + 1];

new stuck[MAX_PLAYERS + 1];

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

new const g_szClassName[] = "dead_corpse";

new bool:g_blReviving[MAX_PLAYERS + 1], bool:g_blRevived[MAX_PLAYERS + 1], bool:g_blMenuOpen[MAX_PLAYERS + 1];
new g_iSeconds[MAX_PLAYERS + 1];

public plugin_init() {
    register_plugin("Revive on E / R", "1.4", "Player");
    
    register_event("HLTV", "NewRoundEvent", "a", "1=0", "2=0");
    
    RegisterHam(Ham_Spawn, "player", "hamSpawn", 1);
    RegisterHam(Ham_Killed, "player", "hamKilled", 1);
    RegisterHam(Ham_Player_PreThink, "player", "hamPlayerPreThink");
}

public NewRoundEvent() {
    fm_remove_entity_name(g_szClassName);
    
    new iPlayers[MAX_PLAYERS], iNum;
    get_players(iPlayers, iNum);
    
    for (new i = 0; i < iNum; i++) {
        Limit[iPlayers[i]] = 0;
    }
}

public hamSpawn(id) {
    if (!is_user_alive(id)) {
        return;
    }
    
    new iTask = id + TASK_REVIVE;
    
    if (task_exists(iTask)) {
        remove_task(iTask);
    }
    
    new iTask2 = id + TASK_SECONDS;
    
    if (task_exists(iTask2)) {
        remove_task(iTask2);
    }
    
    g_blReviving[id] = false;
    IsDead[id] = false;
}

public hamKilled(iVictim, iAttacker, iCorpse) {
    set_task(3.5, "taskCreateCorpse", iVictim);
}

public taskCreateCorpse(id) {
    if (!is_user_alive(id) && is_user_connected(id)) {
        IsDead[id] = true;
        get_user_origin(id, Origin[id]);
        get_user_name(id, Name[id], 32);
        set_task(0.2, "taskHideRealCorpse", id);
        
        new szModel[32], szModelDir[64], Float:flOrigin[3], Float:flMin[3], Float:flMax[3], Float:flAngles[3];
        cs_get_user_model(id, szModel, charsmax(szModel));
        formatex(szModelDir, charsmax(szModelDir), "models/player/%s/%s.mdl", szModel, szModel);
        
        pev(id, pev_origin, flOrigin);
        pev(id, pev_angles, flAngles);
        pev(id, pev_sequence);
        
        flMin[0] = -50.0;
        flMin[1] = -50.0;
        flMin[2] = -50.0;
        flMax[0] = 50.0;
        flMax[1] = 50.0;
        flMax[2] = 50.0;
        
        new iSequence = pev(id, pev_sequence);
        new iEnt = fm_create_entity("info_target");
        
        if (iEnt) {
            set_pev(iEnt, pev_classname, g_szClassName);
            engfunc(EngFunc_SetModel, iEnt, szModelDir);
            engfunc(EngFunc_SetOrigin, iEnt, flOrigin);
            engfunc(EngFunc_SetSize, iEnt, flMin, flMax);
            set_pev(iEnt, pev_solid, SOLID_TRIGGER);
            set_pev(iEnt, pev_movetype, MOVETYPE_TOSS);
            set_pev(iEnt, pev_owner, id);
            set_pev(iEnt, pev_angles, flAngles);
            set_pev(iEnt, pev_sequence, iSequence);
            set_pev(iEnt, pev_frame, 9999.9);
        }
    }
}

public taskHideRealCorpse(id) {
    set_pev(id, pev_effects, EF_NODRAW);
}

public hamPlayerPreThink(id) {
    if (!is_user_alive(id) || g_blReviving[id]) {
        return;
    }
    
    set_task(0.1, "taskPlayerPreThink", id);
}

public taskPlayerPreThink(id) {
    new Float:flOrigin[3], iEnt;
    pev(id, pev_origin, flOrigin);
    
    while ((iEnt = fm_find_ent_in_sphere(iEnt, flOrigin, RES_RADIUS)) != 0) {
        new szClassName[32];
        pev(iEnt, pev_classname, szClassName, charsmax(szClassName));
        
        if (equali(szClassName, g_szClassName) && fm_is_ent_visible(id, iEnt) && !g_blReviving[id]) {
            g_blMenuOpen[id] = true;
            new iPevOwner = pev(iEnt, pev_owner);
        
            if (IsDead[iPevOwner] && Limit[iPevOwner] < RES_LIMIT) {
                menuRevive(id, iPevOwner);
            }
        } else {
            g_blMenuOpen[id] = false;
        }
    }
}

public menuRevive(id, deadid) {
    if (!is_user_alive(id) || get_user_team(id) != get_user_team(deadid)) {
        return;
    }
    
    set_task(0.1, "taskMenuOpened", id + TASK_MENU, .flags = "b");
    
    new szTitle[256];
    formatex(szTitle, charsmax(szTitle), "Press R to revive %s ? ", Name[deadid]);
    
    if (pev(id, pev_button) & IN_RELOAD || pev(id, pev_button) & IN_USE  ) {
        g_blReviving[id] = true;
        g_blRevived[id] = false;
        g_iSeconds[id] = RES_TIME;
        
        formatex(szTitle, charsmax(szTitle), "Revive %s in %d", Name[deadid], g_iSeconds[id]);
        
        new iDead[1];
        iDead[0] = deadid;
        
        set_task(1.0, "taskCountSeconds", id + TASK_SECONDS, iDead, sizeof(iDead), "b");
        set_task(float(RES_TIME), "taskResurrect", id + TASK_REVIVE, iDead, sizeof(iDead));
        
      
        // fm_set_user_frozen(id, 1); 
        
    }
    
    show_menu(id, 0123, szTitle);
}

public taskMenuOpened(id) {
    id -= TASK_MENU;
    
    if (g_blReviving[id] || !is_user_alive(id)) {
        return;
    }
    
    if (!g_blMenuOpen[id]) {
        show_menu(id, 0, "^n", 1);
        remove_task(id + TASK_MENU);
        return;
    }
}

public taskCountSeconds(iDead[1], id) {
    id -= TASK_SECONDS;
    
    if (g_blRevived[id] || !is_user_alive(id)) {
        remove_task(id + TASK_SECONDS);
        return;
    }
    
    if (--g_iSeconds[id] > 0) {
        new szTitle[256];
        formatex(szTitle, charsmax(szTitle), "Revive %s in %d", Name[iDead[0]], g_iSeconds[id]);
        show_menu(id, 0123, szTitle);
    } else {
        remove_task(id + TASK_SECONDS);
        return;
    }
}

public taskResurrect(iDead[1], id) {
    id -= TASK_REVIVE;
    
    if (!IsDead[iDead[0]] || !is_user_connected(iDead[0]) || !is_user_alive(id)) {
        remove_task(id + TASK_REVIVE);
        return;
    }
    
    Limit[iDead[0]]++;
    IsDead[iDead[0]] = false;
    fm_remove_entity(fm_find_ent_by_owner(-1, g_szClassName, iDead[0]));
    ExecuteHamB(Ham_CS_RoundRespawn, iDead[0]);
    
    set_user_origin(iDead[0], Origin[iDead[0]]);
    checkstuck(iDead[0]);
    
    new szTitle[256];
    formatex(szTitle, charsmax(szTitle), "Player %s is Ready !", Name[iDead[0]]);
    
    new szName[32];
    get_user_name(id, szName, charsmax(szName));
    client_print(0, print_chat, "[ CS.DAEVA.RO ] Player %s revived %s ... Good Job !", szName, Name[iDead[0]]);
    
    show_menu(id, 0123, szTitle);
    set_task(3.0, "taskHideMenu", id);
    
    g_blRevived[id] = true;
    
   // fm_set_user_frozen(id, 0);
}

public taskHideMenu(id) {
    g_blReviving[id] = false;
    show_menu(id, 0, "^n", 1);
}

public resurrectEffects(id) {
    static Float:flOrigin[3];
    pev(id, pev_origin, flOrigin);
    
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0);
    write_byte(TE_IMPLOSION);
    engfunc(EngFunc_WriteCoord, flOrigin[0]);
    engfunc(EngFunc_WriteCoord, flOrigin[1]);
    engfunc(EngFunc_WriteCoord, flOrigin[2]);
    write_byte(100);
    write_byte(50);
    write_byte(5);
    message_end();
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
    if (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid)) { // Adjusted condition
        return true;
    }
    
    return false;
}

stock fm_set_user_frozen(client, frozen) {
    if (!is_user_alive(client)) return 0;
    
    new flags = pev(client, pev_flags);
    if (frozen && !(flags & FL_FROZEN)) {
        set_pev(client, pev_flags, (flags | FL_FROZEN));
    } else if (!frozen && (flags & FL_FROZEN)) {
        set_pev(client, pev_flags, (flags & ~FL_FROZEN));
    }
    
    return 1;
}
