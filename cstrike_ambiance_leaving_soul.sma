#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < engine >
#include < hamsandwich >

#define PLUGIN "Leaving Soul"
#define VERSION "1.0"
#define AUTHOR "Daniel"

#define SOUL_MODEL "models/warcraft3/ghostspirit2.mdl"
#define SOUL_TRANSPARENCY 	85.0        
#define SOUL_VELOCITY  		135.0
#define SOUL_ROTATION 		65.0
#define SOUL_LONGEVITY 		2.5

public plugin_init() {

    register_plugin(PLUGIN, VERSION, AUTHOR)

    RegisterHam(Ham_Killed, "player", "Ham_KilledPlayer_Post", 1)
}

public Ham_KilledPlayer_Post(id, attacker)
{
    new Float: vecOrigin[3];
	entity_get_vector(id, EV_VEC_origin, vecOrigin)
	
    new ent = create_entity("info_target")
    
    if( !ent )
        return
		
	engfunc(EngFunc_SetModel, ent, SOUL_MODEL);
	engfunc(EngFunc_SetSize, ent, {-10.0, -10.0, -10.0}, {10.0, 10.0, 10.0});
	engfunc(EngFunc_SetOrigin, ent, vecOrigin);
        
    entity_set_string(ent, EV_SZ_classname, "ghostspirit")
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_NOCLIP)
    entity_set_int(ent, EV_INT_solid, SOLID_NOT)
      
    entity_set_int(ent, EV_INT_sequence, 64)   
    entity_set_float(ent, EV_FL_frame, 0.0)
    
	entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell)
	entity_set_int(ent, EV_INT_rendermode, kRenderTransAlpha)
	entity_set_float(ent, EV_FL_renderamt, SOUL_TRANSPARENCY)

    new Float:fVelocity[3]
    fVelocity[2] = SOUL_VELOCITY;
    entity_set_vector(ent, EV_VEC_velocity, fVelocity)
	
	new Float:aVelocity[3]
	aVelocity[1] = SOUL_ROTATION; 
	set_pev(ent, pev_avelocity, aVelocity);
	
    set_task(SOUL_LONGEVITY, "TASK_RemoveSoul", ent)
	
	 
}

public TASK_RemoveSoul(ent)
{
    if(is_valid_ent(ent))
        entity_set_int(ent, EV_INT_flags, FL_KILLME)
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, SOUL_MODEL);
}

