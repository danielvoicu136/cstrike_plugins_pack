/* About : say /check to see the admin last connection */

#include <amxmodx>
#include <amxmisc>

#define PLUGIN_NAME "Admin Connection"
#define PLUGIN_VERSION "1.0.1"
#define PLUGIN_AUTHOR "Daniel" 

#define PLUGIN_REMINDER 60.0
#define PLUGIN_TAG "!g[ADMIN]"

new DataFile[128];
new AdminDate[33][128];

#define SELECT_DESIGN 10
#define DESIGN1_STYLE "<meta charset=UTF-8><style>body{background:#112233;font-family:Arial}th{background:#558866;color:#FFF;padding:10px 2px;text-align:left}td{padding:4px 3px}table{background:#EEEECC;font-size:12px;font-family:Arial}h2,h3{color:#FFF;font-family:Verdana}#c{background:#E2E2BC}img{height:10px;background:#09F;margin:0 3px}#r{height:10px;background:#B6423C}#clr{background:none;color:#FFF;font-size:20px}</style>"
#define DESIGN2_STYLE "<meta charset=UTF-8><style>body{font-family:Arial}th{background:#575757;color:#FFF;padding:5px;border-bottom:2px #BCE27F solid;text-align:left}td{padding:3px;border-bottom:1px #E7F0D0 solid}table{color:#3C9B4A;background:#FFF;font-size:12px}h2,h3{color:#333;font-family:Verdana}#c{background:#F0F7E2}img{height:10px;background:#62B054;margin:0 3px}#r{height:10px;background:#717171}#clr{background:none;color:#575757;font-size:20px}</style>"
#define DESIGN3_STYLE "<meta charset=UTF-8><style>body{background:#E6E6E6;font-family:Verdana}th{background:#F5F5F5;color:#A70000;padding:6px;text-align:left}td{padding:2px 6px}table{color:#333;background:#E6E6E6;font-size:10px;font-family:Georgia;border:2px solid #D9D9D9}h2,h3{color:#333;}#c{background:#FFF}img{height:10px;background:#14CC00;margin:0 3px}#r{height:10px;background:#CC8A00}#clr{background:none;color:#A70000;font-size:20px;border:0}</style>"
#define DESIGN4_STYLE "<meta charset=UTF-8><style>body{background:#E8EEF7;margin:2px;font-family:Tahoma}th{color:#0000CC;padding:3px}tr{text-align:left;background:#E8EEF7}td{padding:3px}table{background:#CCC;font-size:11px}h2,h3{font-family:Verdana}img{height:10px;background:#09F;margin:0 3px}#r{height:10px;background:#B6423C}#clr{background:none;color:#000;font-size:20px}</style>"
#define DESIGN5_STYLE "<meta charset=UTF-8><style>body{background:#555;font-family:Arial}th{border-left:1px solid #ADADAD;border-top:1px solid #ADADAD}table{background:#3C3C3C;font-size:11px;color:#FFF;border-right:1px solid #ADADAD;border-bottom:1px solid #ADADAD;padding:3px}h2,h3{color:#FFF}#c{background:#FF9B00;color:#000}img{height:10px;background:#00E930;margin:0 3px}#r{height:10px;background:#B6423C}#clr{background:none;color:#FFF;font-size:20px;border:0}</style>"
#define DESIGN6_STYLE "<meta charset=UTF-8><style>body{background:#FFF;font-family:Tahoma}th{background:#303B4A;color:#FFF}table{padding:6px 2px;background:#EFF1F3;font-size:12px;color:#222;border:1px solid #CCC}h2,h3{color:#222}#c{background:#E9EBEE}img{height:7px;background:#F8931F;margin:0 3px}#r{height:7px;background:#D2232A}#clr{background:none;color:#303B4A;font-size:20px;border:0}</style>"
#define DESIGN7_STYLE "<meta charset=UTF-8><style>body{background:#FFF;font-family:Verdana}th{background:#2E2E2E;color:#FFF;text-align:left}table{padding:6px 2px;background:#FFF;font-size:11px;color:#333;border:1px solid #CCC}h2,h3{color:#333}#c{background:#F0F0F0}img{height:7px;background:#444;margin:0 3px}#r{height:7px;background:#999}#clr{background:none;color:#2E2E2E;font-size:20px;border:0}</style>"
#define DESIGN8_STYLE "<meta charset=UTF-8><style>body{background:#242424;margin:20px;font-family:Tahoma}th{background:#2F3034;color:#BDB670;text-align:left} table{padding:4px;background:#4A4945;font-size:10px;color:#FFF}h2,h3{color:#D2D1CF}#c{background:#3B3C37}img{height:12px;background:#99CC00;margin:0 3px}#r{height:12px;background:#999900}#clr{background:none;color:#FFF;font-size:20px}</style>"
#define DESIGN9_STYLE "<meta charset=UTF-8><style>body{background:#FFF;font-family:Tahoma}th{background:#056B9E;color:#FFF;padding:3px;text-align:left;border-top:4px solid #3986AC}td{padding:2px 6px}table{color:#006699;background:#FFF;font-size:12px;border:2px solid #006699}h2,h3{color:#F69F1C;}#c{background:#EFEFEF}img{height:5px;background:#1578D3;margin:0 3px}#r{height:5px;background:#F49F1E}#clr{background:none;color:#056B9E;font-size:20px;border:0}</style>"
#define DESIGN10_STYLE "<meta charset=UTF-8><style>body{background:#4C5844;font-family:Tahoma}th{background:#1E1E1E;color:#C0C0C0;padding:2px;text-align:left;}td{padding:2px 10px}table{color:#AAC0AA;background:#424242;font-size:13px}h2,h3{color:#C2C2C2;font-family:Tahoma}#c{background:#323232}img{height:3px;background:#B4DA45;margin:0 3px}#r{height:3px;background:#6F9FC8}#clr{background:none;color:#FFF;font-size:20px}</style>"
#define DESIGN11_STYLE "<meta charset=UTF-8><style>body{background:#F2F2F2;font-family:Arial}th{background:#175D8B;color:#FFF;padding:7px;text-align:left}td{padding:3px;border-bottom:1px #BFBDBD solid}table{color:#153B7C;background:#F4F4F4;font-size:11px;border:1px solid #BFBDBD}h2,h3{color:#153B7C}#c{background:#ECECEC}img{height:8px;background:#54D143;margin:0 3px}#r{height:8px;background:#C80B0F}#clr{background:none;color:#175D8B;font-size:20px;border:0}</style>"
#define DESIGN12_STYLE "<meta charset=UTF-8><style>body{background:#283136;font-family:Arial}th{background:#323B40;color:#6ED5FF;padding:10px 2px;text-align:left}td{padding:4px 3px;border-bottom:1px solid #DCDCDC}table{background:#EDF1F2;font-size:10px;border:2px solid #505A62}h2,h3{color:#FFF}img{height:10px;background:#A7CC00;margin:0 3px}#r{height:10px;background:#CC3D00}#clr{background:none;color:#6ED5FF;font-size:20px;border:0}</style>"
#define DESIGN13_STYLE "<meta charset=UTF-8><style>body{background:#220000;font-family:Tahoma}th{background:#3E0909;color:#FFF;padding:5px 2px;text-align:left;border-bottom:1px solid #DEDEDE}td{padding:2px 2px;}table{background:#FFF;font-size:11px;border:1px solid #791616}h2,h3{color:#FFF}#c{background:#F4F4F4;color:#7B0000}img{height:7px;background:#a00000;margin:0 3px}#r{height:7px;background:#181818}#clr{background:none;color:#CFCFCF;font-size:20px;border:0}</style>"
#define DEFAULT_STYLE "<meta charset=UTF-8><style>body{background:#000}tr{text-align:left}table{font-size:13px;color:#FFB000;padding:2px}h2,h3{color:#FFF;font-family:Verdana}img{height:5px;background:#0000FF;margin:0 3px}#r{height:5px;background:#FF0000}</style>"

public plugin_init() {

    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	new DataDir[64];
	get_datadir(DataDir, 63);
	format(DataFile, 127, "%s/AdminData.dat", DataDir);
	
    register_clcmd("say /check", "CMD_AdminConnection");
    register_clcmd("say_team /check", "CMD_AdminConnection");
	register_clcmd("say check", "CMD_AdminConnection");
    register_clcmd("say_team check", "CMD_AdminConnection");
	
	register_clcmd("say /admin", "CMD_AdminConnection");
    register_clcmd("say_team /admin", "CMD_AdminConnection");
	register_clcmd("say admin", "CMD_AdminConnection");
    register_clcmd("say_team admin", "CMD_AdminConnection");
	
	set_task(PLUGIN_REMINDER, "SENT_Reminder", 0, "", 0, "b"); 

}

public client_putinserver(id) {
    if (is_user_admin(id)) {
        SaveData(id);
        LoadData(id);
    }
}

public CMD_AdminConnection(id) {
    new szContent[2048], szName[64];
    new iPos = 0;

    new Arg1[32], Arg2[32];
    new Line[128];

    get_user_name(id, szName, 63);

    switch (SELECT_DESIGN) {
        case 1: iPos = format(szContent, 2047, DESIGN1_STYLE);
        case 2: iPos = format(szContent, 2047, DESIGN2_STYLE); 
        case 3: iPos = format(szContent, 2047, DESIGN3_STYLE); 
        case 4: iPos = format(szContent, 2047, DESIGN4_STYLE); 
        case 5: iPos = format(szContent, 2047, DESIGN5_STYLE); 
        case 6: iPos = format(szContent, 2047, DESIGN6_STYLE); 
        case 7: iPos = format(szContent, 2047, DESIGN7_STYLE); 
        case 8: iPos = format(szContent, 2047, DESIGN8_STYLE); 
        case 9: iPos = format(szContent, 2047, DESIGN9_STYLE); 
        case 10: iPos = format(szContent, 2047, DESIGN10_STYLE); 
        case 11: iPos = format(szContent, 2047, DESIGN11_STYLE); 
        case 12: iPos = format(szContent, 2047, DESIGN12_STYLE); 
        case 13: iPos = format(szContent, 2047, DESIGN13_STYLE); 
        default: iPos = format(szContent, 2047, DEFAULT_STYLE);
    }

		new FileOpen = fopen(DataFile, "rt");
		if (!FileOpen) {
			client_print(id, print_chat, "Error: Could not open data file.");
			return;
		}

		new Date[32];
		get_time("%d %B %y", Date, 31);

		iPos += format(szContent[iPos], 2047 - iPos, "<body><center><table border=0 width=75%%><th>Name<th>Last Seen %s", Date);


		while (fgets(FileOpen, Line, 127)) {
			trim(Line);
			parse(Line, Arg1, 31, Arg2, 31);

			if (equal(szName, Arg1))
				iPos += format(szContent[iPos], 2047 - iPos, "<tr id=c><td>%s<td>%s", Arg1, Arg2);
			else
				iPos += format(szContent[iPos], 2047 - iPos, "<tr><td>%s<td>%s", Arg1, Arg2);
		}

		fclose(FileOpen);


			if (iPos > 0) {
				show_motd(id, szContent, "Admin Connection");
			} else {
				client_print(id, print_chat, "Error: No data to display.");
			}
		}

public SENT_Reminder() {
   ColorChat(0, "%s!n Verify the!g admins!n connection using!g /check",PLUGIN_TAG)
}

public SaveData(id) {
    new Name[32];
    get_user_name(id, Name, 31);

    new Date[32];
    get_time("%d %B %y", Date, 31);

    new Save[64];
    format(Save, sizeof(Save) - 1, "^"%s^" ^"%s^"", Name, Date);

    new Line[64], iLine = 0, IsPlayer = false, Arg1[64];

    new FileOpen = fopen(DataFile, "rt");
    if (FileOpen) {
        while (!feof(FileOpen)) {
            fgets(FileOpen, Line, 63);
            trim(Line);

            parse(Line, Arg1, 63);

            if (equali(Arg1, Name)) {
                write_file(DataFile, Save, iLine);
                IsPlayer = true;
                break;
            }

            iLine++;
        }
        fclose(FileOpen);
    }
    if (!IsPlayer) {
        write_file(DataFile, Save, -1);
    }
}

public LoadData(id) {
    new Name[32];
    get_user_name(id, Name, 31);

    new Line[64], IsPlayer = false, Arg1[32], Arg2[32];

    new FileOpen = fopen(DataFile, "rt");
    if (FileOpen) {
        while (!feof(FileOpen)) {
            fgets(FileOpen, Line, 63);
            trim(Line);

            parse(Line, Arg1, 31, Arg2, 31);

            if (equali(Arg1, Name)) {
                copy(AdminDate[id], 128, Arg2); 
                IsPlayer = true;
                break;
            }
        }
        fclose(FileOpen);
    }

    if (!IsPlayer) {
        new Date[32];
        get_time("%d %B %y", Date, 31);

        copy(AdminDate[id], 128, Date); 
    }
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