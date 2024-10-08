#include <amxmodx>
#include <amxmisc>
#include <csx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "Bomb Finder"
#define VERSION "1.0"
#define AUTHOR "Daniel"

new C4Sprite;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPreThink, "FWD_PreThink");
	
	return PLUGIN_CONTINUE
	
}


public FWD_PreThink(id) {

	if(is_user_connected(id) && is_user_alive(id) && get_user_team(id) == 1 && !is_user_bot(id)) { 
	
				new _C4 = find_ent_by_model(-1, "weaponbox", "models/w_backpack.mdl")
				
				if(is_valid_ent(_C4)) {
					new Float:MyOrigin[3], Float:TargetOrigin[3]
					entity_get_vector(id, EV_VEC_origin, MyOrigin)
					entity_get_vector(_C4, EV_VEC_origin, TargetOrigin)
					
					if(is_in_viewcone(id, TargetOrigin)) {
						new Float:Middle[3], Float:HitPoint[3]
						xs_vec_sub(TargetOrigin, MyOrigin, Middle)
						trace_line(-1, MyOrigin, TargetOrigin, HitPoint)
						
						new Float:WallOffset[3], Float:DistanceToWall
						DistanceToWall = vector_distance(MyOrigin, HitPoint) - 10.0
						new Float:Len = xs_vec_len(Middle)
						xs_vec_copy(Middle, WallOffset)
						
						WallOffset[0] /= Len, WallOffset[1] /= Len, WallOffset[2] /= Len
						WallOffset[0] *= DistanceToWall, WallOffset[1] *= DistanceToWall, WallOffset[2] *= DistanceToWall
						
						new Float:SpriteOffset[3]
						xs_vec_add(WallOffset, MyOrigin, SpriteOffset)
						
						message_begin(MSG_ONE, SVC_TEMPENTITY, _, id)
						write_byte(TE_SPRITE)
						write_coord(floatround(SpriteOffset[0]))
						write_coord(floatround(SpriteOffset[1]))
						write_coord(floatround(SpriteOffset[2]+36.0))
						write_short(C4Sprite)
						write_byte(floatround(2.5))
						write_byte(50)
						message_end()
					}
				}

	}
}	
	
public plugin_precache() {
	C4Sprite = precache_model("sprites/warcraft3/c4marker.spr");
}