#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Show Damage but NO WALL"
#define VERSION "1.0"
#define AUTHOR "Mihai PK"

new Float:BDPosition[][] = {
	{0.50, 0.40},
	{0.56, 0.44},
	{0.60, 0.50},
	{0.56, 0.56},
	{0.50, 0.60},
	{0.44, 0.56},
	{0.40, 0.50},
	{0.44, 0.44}
}

new PlayerPos[33];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)	
	RegisterHam(Ham_TakeDamage,"player","HAM_TakeDamage");
}

public HAM_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type) {

	if(is_user_connected(attacker) && is_user_connected(victim) && attacker != victim)  {
	
		if(is_user_alive(attacker) && get_user_team(victim) != get_user_team(attacker)) {
		
			if( ( damage_type & DMG_BULLET ) && ( ExecuteHam( Ham_FVisible, attacker, victim ) ) ) {
			
				new Pos = ++PlayerPos[attacker]
				if(Pos >= sizeof(BDPosition))
					Pos = PlayerPos[attacker] = 0
					
				new Damage[16];
				formatex(Damage,sizeof(Damage)-1,"%d", floatround(damage));
				
				HudMessage(attacker, Damage, 50, 205, 50, Float:BDPosition[Pos][0], Float:BDPosition[Pos][1], 2, 1.0, 2.5, 0.02, 0.02)
				
			}
		}
	}
}


#define clamp_byte(%1)       ( clamp( %1, 0, 255 ) )
#define pack_color(%1,%2,%3) ( %3 + ( %2 << 8 ) + ( %1 << 16 ) )
				
stock HudMessage(const id, const message[], red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 6.0, Float:holdtime = 3.0, Float:fadeintime = 0.1, Float:fadeouttime = 1.5) {
	new count = 1, players[32];
	
	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
		for(new i = 0; i < count; i++) {
			if(is_user_connected(players[i])) {	
				new color = pack_color(clamp_byte(red), clamp_byte(green), clamp_byte(blue))
				
				message_begin(MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, players[i]);
				write_byte(strlen(message) + 31);
				write_byte(DRC_CMD_MESSAGE);
				write_byte(effects);
				write_long(color);
				write_long(_:x);
				write_long(_:y);	
				write_long(_:fadeintime);
				write_long(_:fadeouttime);
				write_long(_:holdtime);
				write_long(_:fxtime);
				write_string(message);
				message_end();
			}
		}
	}
}


