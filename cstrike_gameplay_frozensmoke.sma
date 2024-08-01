#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < engine >
#include < hamsandwich >

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

new const plugin_info[ 3 ][ ] = {
    "Frostnades",
    "1.0",
    "Unknown"
}

public plugin_precache( )
{
    for( new i = 0 ; i < FrostSounds ; i ++ )
        precache_sound( szFrostSoundsPath[ i ] );
        
    g_iBeaconSprite = precache_model( "sprites/shockwave.spr" );
    g_iExplodeSprite = precache_model( "sprites/xmasreborn/frost_explode.spr" );

    engfunc(EngFunc_PrecacheModel, ice_model);
	
	trailSPR = precache_model(SPR_TRAIL);

}

public plugin_init() 
{
    register_plugin( plugin_info[ 0 ] , plugin_info[ 1 ] , plugin_info[ 2 ] );
    register_forward( FM_SetModel, "Fwd_SetModel_Pre" );
    RegisterHam( Ham_Killed, "player", "fnPlayerDead" );
    register_event( "HLTV", "Event_NewRound", "a", "1=0", "2=0" );
}

public Fwd_SetModel_Pre( iEnt, const Model[] )
{
    new iOwner = pev( iEnt, pev_owner );
    if( !pev_valid( iEnt ) || !equal( Model, "models/w_smokegrenade.mdl" ) || !is_user_connected( iOwner ) )
        return;
    set_pev( iEnt, pev_nextthink, get_gametime( ) + 5.0 );
    set_task( 1.5, "fnExplodeNade", TASK_EXPLODE( iEnt ) );
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
        if( !is_user_connected( i ) || !is_user_alive( i ) || i == iOwner || g_bFreezed[ i ])
            continue;
            
        pev( i, pev_origin, g_flPlayerOrigin );
        
        if( get_distance_f( g_flPlayerOrigin, g_flOrigin ) > 240.0 )
            continue;

        if(!is_user_alive(i))
            continue
        if(cs_get_user_team(i) == cs_get_user_team(iOwner))
            continue

        ice_entity( i, 1 )
        
        g_bFreezed[ i ] = true;
        
        set_task( 2.5, "Fwd_Unfreeze", TASK_UNFREEZE( i ) );
              
        
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
    
    engfunc( EngFunc_RemoveEntity , iEnt )
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