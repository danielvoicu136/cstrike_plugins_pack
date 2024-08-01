#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>

public plugin_init()
{
	register_plugin("ResetScore", "1.0", "Simple")
	
	register_clcmd("say /resetscore", "reset_score")
	register_clcmd("say resetscore", "reset_score")
	register_clcmd("say /rs", "reset_score")
	register_clcmd("say rs", "reset_score")
	register_clcmd("say /reset", "reset_score")
	register_clcmd("say reset", "reset_score")
	register_clcmd("say /restartscore", "reset_score")
	register_clcmd("say restartscore", "reset_score")
	
	register_clcmd("say_team /resetscore", "reset_score")
	register_clcmd("say_team resetscore", "reset_score")
	register_clcmd("say_team /rs", "reset_score")
	register_clcmd("say_team rs", "reset_score")
	register_clcmd("say_team /reset", "reset_score")
	register_clcmd("say_team reset", "reset_score")
	register_clcmd("say_team /restartscore", "reset_score")
	register_clcmd("say_team restartscore", "reset_score")
	
}

public reset_score(id)
{

	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)
	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)
	
	client_print(id, print_chat, "* Your score is now 0 - 0")

}
