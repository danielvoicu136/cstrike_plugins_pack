#include <amxmodx>
#include <hamsandwich>

new HUDSyncObject:g_SyncObj

public plugin_init() {
    register_plugin("Date, Time and Message", "1.0", "Daniel")

   
    g_SyncObj = CreateHudSyncObj()

    set_task(1.0, "UpdateDateTimeDisplay", _, _, _, "b")
}


public UpdateDateTimeDisplay() {
   
    new day[3], month[3], year[5], hour[3], minute[3]

    get_time("%d", day, charsmax(day))
    get_time("%m", month, charsmax(month))
    get_time("%Y", year, charsmax(year))
    get_time("%H", hour, charsmax(hour))
    get_time("%M", minute, charsmax(minute))

    new r = random_num(0, 255);
    new g = random_num(0, 255);
    new b = random_num(0, 255);

    set_hudmessage(r, g, b, 0.4, 0.00, 0, 0.1, 1.0, 0.1, 0.1, -1)

    ShowSyncHudMsg(0, g_SyncObj, "XHERO.DAEVA.RO - Warcraft 3 Respawn (Update 2024)^nDate: %s/%s/%s - Time: %s:%s - Admins: daeva.ro", day, month, year, hour, minute)
	
}

/*

some characters and formats 

ShowSyncHudMsg(0, g_SyncObj, "ஜ ^t xhero.daeva.ro ^t ๑ ^t admins : daeva.ro ^t ஜ");

ʕಠ_ಠʔ
ʕ•_•ʔ

ʕಠ_ಠʔ ๑ xhero.daeva.ro ஜ admins : daeva.ro ๑ ʕಠ_ಠʔ

ʕಠ̫͡ಠʕಠ̫͡ಠʔಠ̫͡ಠʔ•̫͡•ʕ•̫͡•ʔ•̫͡•ʕ•̫͡•ʕ•̫͡•ʔ•̫͡•ʔ•̫͡•

*/