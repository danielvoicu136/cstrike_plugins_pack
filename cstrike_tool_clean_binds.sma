// API Natives 
native open_user_shopmenu(id); 
native open_user_shopmenu2(id); 
native start_ultimate(id);

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define PLUGIN_NAME 		"Client Clean Binds" 
#define PLUGIN_VERSION		"1.0.0"
#define PLUGIN_DEVELOPER	"Daniel"

#define SPRAY				201 			
#define FLASHLIGHT 			100

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_DEVELOPER)

	register_clcmd( "radio1","openShop")
	register_clcmd( "radio2","openShop")
    register_clcmd( "radio3","openShop2")
	
	register_forward(FM_CmdStart, "FWD_CmdStart");

}

public openShop(id)
{
	open_user_shopmenu(id);

    return PLUGIN_HANDLED
}

public openShop2(id)
{
	open_user_shopmenu2(id);
	
    return PLUGIN_HANDLED
}


public FWD_CmdStart(id, uc_handle, seed)
{
	static Impulse;
	Impulse = get_uc(uc_handle, UC_Impulse);
	
	if(Impulse == FLASHLIGHT)
	{
		start_ultimate(id);
	
		set_uc(uc_handle, UC_Impulse, 0);
		
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}




