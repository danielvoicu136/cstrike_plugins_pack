#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <fun>
#include <engine>


#define FROZEN_RADIUS 240.0		// Radius of Explosion 

#define FROZEN_TIME	2.5 		// Seconds of Freezing , Set 0 to Disable Freezing 

#define FROZEN_HEAL 100			// Amount of Healing , Set 0 to Disable Healing 


#define HEAL_SPRITE "sprites/medic3.spr" 
#define HEAL_SOUND "items/medshot4.wav"


#define TASK_EXPLODE(%1) ( 799 + %1 )
#define UNTASK_EXPLODE(%1) ( %1 - 799)

#define TASK_UNFREEZE(%1) ( 899 + %1 )
#define UNTASK_UNFREEZE(%1) ( %1 - 899 )

#define ice_model "models/xmasreborn/xmasice.mdl"

new bool: g_bFreezed[ 33 ], g_iBeaconSprite, g_iExplodeSprite;
new iceent[ 33 ];

new trailSPR;

#define SPR_TRAIL "sprites/smoke.spr"

#define TE_BEAMFOLLOW		22


enum _:FrostSounds
{
    Explode,
    Hit,
    Unfreeze
}

new const szFrostSoundsPath[ FrostSounds ][ ] = {
    "warcraft3/frostnova.wav",
    "warcraft3/impalehit.wav",
    "warcraft3/impalelaunch1.wav"
}


enum _:FrostModels
{
    V_MODEL,
    P_MODEL,
    W_MODEL
}

new const szFrostModelsPath[ FrostModels ][ ] = { 
	"models/v_he_mk_nade.mdl",
	"models/p_he_mk_nade.mdl",
	"models/w_he_mk_nade.mdl"
}

new const plugin_info[ 3 ][ ] = {
    "Frozen Healing Smokes",
    "1.0",
    "Unknown"
}

new SpriteHead;


public plugin_precache( )
{
    for( new i = 0 ; i < FrostSounds ; i ++ )
        precache_sound( szFrostSoundsPath[ i ] );
		
	for( new i = 0 ; i < FrostModels ; i ++ )
        precache_model( szFrostModelsPath[ i ] );
        
    g_iBeaconSprite = precache_model( "sprites/shockwave.spr" );
    g_iExplodeSprite = precache_model( "sprites/xmasreborn/frost_explode.spr" );

    engfunc(EngFunc_PrecacheModel, ice_model);
	
	trailSPR = precache_model(SPR_TRAIL);
	
	precache_sound(HEAL_SOUND);
	SpriteHead = precache_model(HEAL_SPRITE);

}

public plugin_init() 
{
    register_plugin( plugin_info[ 0 ] , plugin_info[ 1 ] , plugin_info[ 2 ] );
	register_forward( FM_SetModel, "Fwd_SetModel_Pre" );
	register_forward( FM_SetModel, "Fwd_SetModel_Post", 1 );
    RegisterHam( Ham_Killed, "player", "fnPlayerDead" );
    register_event( "HLTV", "Event_NewRound", "a", "1=0", "2=0" );
	register_event( "CurWeapon", "Event_CurWeapon", "be", "1=1" );
}


public Event_CurWeapon(id)
{
	if(is_user_connected(id) && is_user_alive(id))
	{
		if(get_user_weapon(id) == CSW_SMOKEGRENADE)
		{
			set_pev(id, pev_viewmodel2, szFrostModelsPath[V_MODEL])
			set_pev(id, pev_weaponmodel2, szFrostModelsPath[P_MODEL])
		}
	}
}

public Fwd_SetModel_Pre( iEnt, const Model[] )
{
    new iOwner = pev( iEnt, pev_owner );
	
    if( !pev_valid( iEnt ) || !equal( Model, "models/w_smokegrenade.mdl" ) || !is_user_connected( iOwner ) )
        return;
		
    set_pev( iEnt, pev_nextthink, get_gametime( ) + 5.0 );
    set_task( 1.5, "fnExplodeNade", TASK_EXPLODE( iEnt ) );
}

public Fwd_SetModel_Post( entity, const model[] )
{
	if( !pev_valid( entity ) ) return FMRES_IGNORED;
	
	if(equal( model, "models/w_smokegrenade.mdl" ))
	{
		engfunc ( EngFunc_SetModel, entity, szFrostModelsPath[W_MODEL] );
	}
	return FMRES_IGNORED;
}


public fnExplodeNade( Task_ID )
{
    new iEnt = UNTASK_EXPLODE( Task_ID );
    if( !pev_valid( iEnt ) )
        return;
    new iOwner = pev( iEnt, pev_owner ), Float: g_flOrigin[ 3 ], g_iOrigin[ 3 ], Float: g_flPlayerOrigin[ 3 ];
    
    pev( iEnt, pev_origin, g_flOrigin );
    
    g_iOrigin[ 0 ] = floatround( g_flOrigin[ 0 ] );
    g_iOrigin[ 1 ] = floatround( g_flOrigin[ 1 ] );
    g_iOrigin[ 2 ] = floatround( g_flOrigin[ 2 ] );
        
    CmdExplodeBeacon( g_iOrigin )
    
    engfunc( EngFunc_EmitSound, iEnt, CHAN_WEAPON, szFrostSoundsPath[ Explode ], 1.0, ATTN_NORM, 0, PITCH_NORM );
    
    for( new i = 1 ; i < get_maxplayers( ) ; i ++ )
    {
	
		if( is_user_connected( i ) && is_user_alive( i )) {
	
			 pev( i, pev_origin, g_flPlayerOrigin );
			 
			  if( get_distance_f( g_flPlayerOrigin, g_flOrigin ) < FROZEN_RADIUS ) { 
			  
					 if(cs_get_user_team(i) == cs_get_user_team(iOwner)) { 
					 
						if( FROZEN_HEAL ) { 

							message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, i)
							write_short(1<<10)
							write_short(1<<10)
							write_short(0x0000)
							write_byte(170)
							write_byte(255)
							write_byte(0)
							write_byte(75)
							message_end()
							
							set_user_rendering(i,kRenderFxGlowShell,0,255,50,kRenderNormal,20)
							set_task(1.5, "UnEffect", i)
							
							set_user_health(i,FROZEN_HEAL)
							
							emit_sound(i, CHAN_AUTO, HEAL_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM);
							Util_TE_PLAYERATTACHMENT(0, i, 40, SpriteHead, 20);
						}
							
					 } 
					 else if((cs_get_user_team(i) != cs_get_user_team(iOwner)) && !g_bFreezed[ i ] && (FROZEN_TIME > 0)) { 
					 
						ice_entity( i, 1 )
						g_bFreezed[ i ] = true;
						set_task( FROZEN_TIME, "Fwd_Unfreeze", TASK_UNFREEZE( i ) );
						 
						engfunc( EngFunc_EmitSound, i, CHAN_WEAPON, szFrostSoundsPath[ Hit ], 1.0, ATTN_NORM, 0, PITCH_NORM)    

						message_begin( MSG_ONE, get_user_msgid("ScreenFade"), _, i);
						write_short( ~0 );
						write_short( ~0 );
						write_short( 0x0004 );
						write_byte( 100 );
						write_byte( 200 );
						write_byte( 255 );
						write_byte( 100 );
						message_end( );
					 
					} 
			  
			  } 

		}  
  
    }
    
    engfunc( EngFunc_RemoveEntity , iEnt )
}

public UnEffect(id)
{
	if(is_user_alive(id))
	{
		set_user_rendering(id)
	}
}

public Fwd_Unfreeze( Task_ID )
{
    new client = UNTASK_UNFREEZE( Task_ID );
      
    message_begin( MSG_ONE, get_user_msgid("ScreenFade"), _, client);
    write_short( 0 );
    write_short( 0 );
    write_short( 0 );
    write_byte( 0 );
    write_byte( 0 );
    write_byte( 0 );
    write_byte( 0 );
    message_end( );
    
    ice_entity( client, 0 );

    g_bFreezed[ client ] = false;
    
    engfunc( EngFunc_EmitSound, client, CHAN_WEAPON, szFrostSoundsPath[ Unfreeze ], 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public Event_NewRound()
{
    for(new i = 0; i < get_maxplayers(); i++)
    {
        ice_entity( i, 0 )
    }
}

public fnPlayerDead(id)
{
    ice_entity( id, 0 )
}


public CmdExplodeBeacon( const g_iOrigin[3] )
{
	
	new vStartOrigin[3];
	vStartOrigin[0] = g_iOrigin[0];
	vStartOrigin[1] = g_iOrigin[1];
	vStartOrigin[2] = g_iOrigin[2] + 120;
	
	new vStartOriginX[3];
	vStartOriginX[0] = g_iOrigin[0];
	vStartOriginX[1] = g_iOrigin[1];
	vStartOriginX[2] = g_iOrigin[2];
	
	
	Create_TE_SPRITETRAIL( vStartOrigin, vStartOriginX, SpriteHead, 30, 10, 1, 50, 10 );

    message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
    write_byte( TE_BEAMCYLINDER );
    write_coord( g_iOrigin[0] );
    write_coord( g_iOrigin[1] );
    write_coord( g_iOrigin[2] );
    write_coord( g_iOrigin[0] );
    write_coord( g_iOrigin[1] );
    write_coord( g_iOrigin[2] + 385);
    write_short( g_iBeaconSprite );
    write_byte(0);
    write_byte(0);
    write_byte(4);
    write_byte(60);
    write_byte(0);
    write_byte(40);
    write_byte(100);
    write_byte(200);
    write_byte(200);
    write_byte(0);
    message_end();

    message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
    write_byte( TE_BEAMCYLINDER );
    write_coord( g_iOrigin[0] );
    write_coord( g_iOrigin[1] );
    write_coord( g_iOrigin[2] );
    write_coord( g_iOrigin[0] );
    write_coord( g_iOrigin[1] );
    write_coord( g_iOrigin[2] + 470);
    write_short( g_iBeaconSprite );
    write_byte(0);
    write_byte(0);
    write_byte(4);
    write_byte(60);
    write_byte(0);
    write_byte(40);
    write_byte(100);
    write_byte(200);
    write_byte(200);
    write_byte(0);
    message_end();

    message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
    write_byte( TE_BEAMCYLINDER );
    write_coord( g_iOrigin[0] );
    write_coord( g_iOrigin[1] );
    write_coord( g_iOrigin[2] );
    write_coord( g_iOrigin[0] );
    write_coord( g_iOrigin[1] );
    write_coord( g_iOrigin[2] + 550);
    write_short( g_iBeaconSprite );
    write_byte(0);
    write_byte(0);
    write_byte(4);
    write_byte(60);
    write_byte(0);
    write_byte( 40 );
    write_byte( 100 );
    write_byte( 200 );
    write_byte( 200 );
    write_byte( 0 );
    message_end();

    message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
    write_byte( TE_EXPLOSION )
    write_coord( g_iOrigin[0] )
    write_coord( g_iOrigin[1] ) 
    write_coord( g_iOrigin[2] + 75 )
    write_short( g_iExplodeSprite )
    write_byte(22)
    write_byte(35)
    write_byte(TE_EXPLFLAG_NOSOUND)
    message_end()
}

stock ice_entity( id, status ) 
{
    if(status)
    {
        static ent, Float:o[3]
        if(!is_user_alive(id))
        {
            ice_entity( id, 0 )
            return
        }
        
        if( is_valid_ent(iceent[id]) )
        {
            if( pev( iceent[id], pev_iuser3 ) != id )
            {
                if( pev(iceent[id], pev_team) == 6969 ) remove_entity(iceent[id])
            }
            else
            {
                pev( id, pev_origin, o )
                if( pev( id, pev_flags ) & FL_DUCKING  ) o[2] -= 15.0
                else o[2] -= 35.0
                entity_set_origin(iceent[id], o)
                return
            }
        }
        
        pev( id, pev_origin, o )
        if( pev( id, pev_flags ) & FL_DUCKING  ) o[2] -= 15.0
        else o[2] -= 35.0
        ent = create_entity("info_target")
        set_pev( ent, pev_classname, "DareDevil" )
        
        entity_set_model(ent, ice_model)
        dllfunc(DLLFunc_Spawn, ent)
        set_pev(ent, pev_solid, SOLID_BBOX)
        set_pev(ent, pev_movetype, MOVETYPE_FLY)
        entity_set_origin(ent, o)
        entity_set_size(ent, Float:{ -3.0, -3.0, -3.0 }, Float:{ 3.0, 3.0, 3.0 } )
        set_pev( ent, pev_iuser3, id )
        set_pev( ent, pev_team, 6969 )
        set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 255)
        iceent[id] = ent
    }
    else
    {
        if( is_valid_ent(iceent[id]) )
        {
            if( pev(iceent[id], pev_team) == 6969 ) remove_entity(iceent[id])
            iceent[id] = -1
        }
    }
}

// Forwards from the CSX module and DODX module
public grenade_throw( index, greindex, wId )
{
	
	// If user isn't alive do nothing!
	if ( !is_user_alive( index ) )
	{
		return;
	}

	if ( greindex )
	{
		
			// Then draw it!
			if ( SHARED_IsSmokeGrenade( wId ) )
			{
				new iWidth = 15;

				Create_TE_BEAMFOLLOW( greindex, trailSPR, 20, iWidth, 100, 200, 254, 196 );
			}
		
	}
	
	return;
}

bool:SHARED_IsSmokeGrenade( iWeapon )
{
		if ( iWeapon == CSW_SMOKEGRENADE )
		{
			return true;
		}
	


	return false;
}

stock Create_TE_BEAMFOLLOW(entity, iSprite, life, width, red, green, blue, alpha){

	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BEAMFOLLOW )
	write_short( entity )			// entity
	write_short( iSprite )			// model
	write_byte( life )				// life
	write_byte( width )				// width
	write_byte( red )				// red
	write_byte( green )				// green
	write_byte( blue )				// blue
	write_byte( alpha )				// brightness
	message_end()
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

stock Create_TE_SPRITETRAIL(start[3], end[3], iSprite, count, life, scale, velocity, random )
{

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( TE_SPRITETRAIL )
	write_coord( start[0] )				// start position (X)
	write_coord( start[1] )				// start position (Y)
	write_coord( start[2] )				// start position (Z)
	write_coord( end[0] )				// end position (X)
	write_coord( end[1] )				// end position (Y)
	write_coord( end[2] )				// end position (Z)
	write_short( iSprite )				// sprite index
	write_byte( count )					// count
	write_byte( life)					// life in 0.1's
	write_byte( scale)					// scale in 0.1's
	write_byte( velocity )				// velocity along vector in 10's
	write_byte( random )				// randomness of velocity in 10's
	message_end()
}
