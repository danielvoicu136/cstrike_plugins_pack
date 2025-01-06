#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>

#define PLUGIN "UWC3X Bonus Box"
#define VERSION "1.0"
#define AUTHOR "xReforged"
#define BOX_TAG "!g[ !tUWC3X !g]"

new const item_class_name[] = "dm_item";
new g_models[][] = { "models/boxs_weapon.mdl" };

public plugin_precache() {
    for (new i = 0; i < sizeof g_models; i++) {
        precache_model(g_models[i]);
    }
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_forward(FM_Touch, "FWD_Touch");
    register_event("HLTV", "EVENT_Round_Start", "a", "1=0", "2=0");

    RegisterHam(Ham_Killed, "player", "FWD_PlayerKilled");
	
	set_task(5.0, "FWD_RotateBoxes");
}

public FWD_Touch(toucher, touched) {
    if (!is_user_alive(toucher) || !pev_valid(touched)) {
        return FMRES_IGNORED;
    }

    new classname[32];
    pev(touched, pev_classname, classname, charsmax(classname));
    if (!equal(classname, item_class_name)) {
        return FMRES_IGNORED;
    }

    giveItem(toucher);
    set_pev(touched, pev_effects, EF_NODRAW);
    set_pev(touched, pev_solid, SOLID_NOT);

    return FMRES_IGNORED;
}

public FWD_PlayerKilled(victim, attacker) {
    if (!is_user_connected(attacker) || !is_user_connected(victim) || attacker == victim) {
        return HAM_IGNORED;
    }

    new origin[3];
    get_user_origin(victim, origin, 0);
    addItem(origin);

    return HAM_IGNORED;
}

public addItem(origin[3])
{
   new ent = fm_create_entity("info_target")
   set_pev(ent, pev_classname, item_class_name)
   
   engfunc(EngFunc_SetModel,ent, g_models[random_num(0, sizeof g_models - 1)])

   set_pev(ent,pev_mins,Float:{-10.0,-10.0,0.0})
   set_pev(ent,pev_maxs,Float:{10.0,10.0,25.0})
   set_pev(ent,pev_size,Float:{-10.0,-10.0,0.0,10.0,10.0,25.0})
   engfunc(EngFunc_SetSize,ent,Float:{-10.0,-10.0,0.0},Float:{10.0,10.0,25.0})

   set_pev(ent,pev_solid,SOLID_BBOX)
   set_pev(ent,pev_movetype,MOVETYPE_TOSS)
   
   new Float:fOrigin[3]
   IVecFVec(origin, fOrigin)
   set_pev(ent, pev_origin, fOrigin)
   
}

public giveItem(id) {
    new i = random_num(0, 2);
    switch (i) {
        case 0: {
            new name[32];
            get_user_name(id, name, charsmax(name));

            new XP = random_num(20, 550);
            server_cmd("amx_givexp %s %d", name, XP);

            ChatColor(id, "%s You received!t + %d XP ", BOX_TAG, XP);
        }

        case 1: {
			give_item(id, "weapon_hegrenade");
            ChatColor(id, "%s You received!t + HE Grenade ", BOX_TAG);
        }

        case 2: {
            new MONEY = random_num(20, 1250);
            cs_set_user_money(id, cs_get_user_money(id) + MONEY);

            ChatColor(id, "%s You received!t + %d $ ", BOX_TAG, MONEY);
        }
    }
}

public FWD_RotateBoxes() {
    new ent = FM_NULLENT;
    while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", item_class_name))) {
        if (pev_valid(ent)) {
           
            new Float:angles[3];
            pev(ent, pev_angles, angles);

            angles[1] += 5.0; 

            set_pev(ent, pev_angles, angles);
        }
    }

    set_task(0.1, "FWD_RotateBoxes");
}

public EVENT_Round_Start() {
    new ent = FM_NULLENT;
    static string_class[] = "classname";
    while ((ent = engfunc(EngFunc_FindEntityByString, ent, string_class, item_class_name))) {
        engfunc(EngFunc_RemoveEntity, ent);
    }
}

stock ChatColor(const id, const input[], any:...) {
    new count = 1, players[32];
    static msg[191];
    vformat(msg, charsmax(msg), input, 3);

    replace_all(msg, charsmax(msg), "!g", "^4"); // Green Color
    replace_all(msg, charsmax(msg), "!y", "^1"); // Default Color
    replace_all(msg, charsmax(msg), "!t", "^3"); // Team Color
    replace_all(msg, charsmax(msg), "!t2", "^0"); // Team2 Color

    if (id) players[0] = id;
    else get_players(players, count, "ch");

    for (new i = 0; i < count; i++) {
        if (is_user_connected(players[i])) {
            message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
            write_byte(players[i]);
            write_string(msg);
            message_end();
        }
    }
    return 1;
}
