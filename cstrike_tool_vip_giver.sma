#include <amxmodx>
#include <amxmisc>

#define VIP_FLAGS "btimy"


public plugin_init()
{
	register_plugin("Steam Player VIP", "1.0" , "Daniel")
}

public client_putinserver(id)
{

	if(is_user_steam(id) || !is_user_bot(id))
	{
		set_task(10.0, "Delayed_AddSteamFreeFlags", id)
	}

}



public Delayed_AddSteamFreeFlags(id)
{
	if (!is_user_connected(id))
	return
	
	if (is_user_admin(id))
	return
	
	remove_user_flags(id, read_flags("z"))
	set_user_flags(id, read_flags(VIP_FLAGS))

	ColorChat(id, "!g[VIP]!n You earned!t VIP!n you have!g Double XP")
	ColorChat(id, "!g[VIP]!n You earned!t VIP!n you have!g Double XP")
	ColorChat(id, "!g[VIP]!n You earned!t VIP!n you have!g Double XP")
	
}

bool:is_user_steam(id)
{
	static iPointer

	if (iPointer || (iPointer = get_cvar_pointer("dp_r_id_provider")))
	{
		server_cmd("dp_clientinfo %d", id); server_exec()
		return get_pcvar_num(iPointer) == 2
	}
	return false
}

stock ColorChat(const id, const input[], any:...) {
	new count = 1, players[32];
	static msg[191];
	vformat(msg, 190, input, 3);

	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!n", "^1");
	replace_all(msg, 190, "!t", "^3");

	if(id) players[0] = id;
	else get_players(players, count, "ch"); {
	for(new i = 0; i < count; i++) {
	if(is_user_connected(players[i])) {
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
	write_byte(players[i]);
	write_string(msg);
	message_end();
}
}
}
}