/* 
Tested with configuration below 
AMX Mod X 1.9.0.5294 (http://www.amxmodx.org)
Authors:
        David "BAILOPAN" Anderson, Pavol "PM OnoTo" Marko
        Felix "SniperBeamer" Geyer, Jonny "Got His Gun" Bergstrom
        Lukasz "SidLuke" Wlasinski, Christian "Basic-Master" Hammacher
        Borja "faluco" Ferrer, Scott "DS" Ehlert
Compiled: Dec  3 2021 15:54:56
Built from: https://github.com/alliedmodders/amxmodx/commit/363871a
Build ID: 5294:363871a
Core mode: JIT+ASM32
[20] ReAPI             RUN   -    reapi_amxx_i386.so          v5.26.0.338-dev  pl2  ANY   Never
Exe version 1.1.2.7/Stdio (cstrike)
ReHLDS version: 3.14.0.857-dev
Build date: 19:52:21 Mar 27 2025 (4002)
Build from: https://github.com/rehlds/ReHLDS/commit/89958d3
*/

#include <amxmodx>
#include <reapi>
 
public plugin_init()
{
    RegisterHookChain(RH_ExecuteServerStringCmd, "ExecuteServerString")
}
 
public ExecuteServerString(cmd[], source, id)
{
    server_print("%s", cmd)

    if (equali(cmd, "status"))
    {
		show_data(id)
        return HC_SUPERCEDE
    }
	if (equali(cmd, "ping"))
    {
		show_ping(id)
        return HC_SUPERCEDE
    }
    return HC_CONTINUE
}


public show_data(id)
{
    new maxplayers = get_maxplayers()
    console_print(id, "#      name userid uniqueid frag time ping loss adr")

    for (new i = 1; i <= maxplayers; i++)
    {
        if (!is_user_connected(i)) continue

        new name[32], authid[64], ip[32]
        new userid = get_user_userid(i)
        new frags = get_user_frags(i)
        new ping = random_num(10, 90) 
        new time = get_user_time(i)
        new minutes = time / 60
        new seconds = time % 60

        get_user_name(i, name, charsmax(name))

        if (is_user_bot(i))
        {
           
            frags = random_num(0, 10)
            minutes = random_num(0, 59)
            seconds = random_num(0, 59)

            formatex(authid, charsmax(authid), "STEAM_1:%d:%d", random_num(0, 1), random_num(100000000, 999999999))
        
            formatex(ip, charsmax(ip), "%d.%d.%d.%d", random_num(80, 254), random_num(1, 254), random_num(1, 254), random_num(1, 254))

             console_print(id, "#%d ^"%s^" %d %s %d %d:%d %d 0",
                i, name, userid, authid, frags, minutes, seconds, ping)
        }
        else
        {
           
            get_user_authid(i, authid, charsmax(authid))
            get_user_ip(i, ip, charsmax(ip), 1)
            new real_ping, loss
            get_user_ping(i, real_ping, loss)

            console_print(id, "#%d ^"%s^" %d %s %d %d:%d %d %d",
                i, name, userid, authid, frags, minutes, seconds, real_ping, loss)
        }
    }

    console_print(id, "%d users", get_playersnum())
}

public show_ping(id)
{
    console_print(id, "Client ping times:")

    new maxplayers = get_maxplayers()
    for (new i = 1; i <= maxplayers; i++)
    {
        if (!is_user_connected(i)) continue

        new name[32]
        get_user_name(i, name, charsmax(name))

        if (is_user_bot(i))
        {
            new fake_ping = random_num(10, 70)
             console_print(id, "%d %s", fake_ping, name)
        }
        else
        {
            new ping, loss
            get_user_ping(i, ping, loss)
			console_print(id, "%d %s", ping, name)
        }
    }
}


