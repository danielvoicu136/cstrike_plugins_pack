
//=============== Items Configuration ===============================

#define MAX_ITEMS 5 		// Inventory Items

enum _: ItemType {
    ITEM_NONE,
    ITEM_SPEED,
    ITEM_DAMAGE,
    ITEM_GRAVITY,
    ITEM_INVISIBILITY,
    ITEM_LIFESTEAL,
    ITEM_HEALTH,
    ITEM_RESPAWN,
    ITEM_GRENADE,
    ITEM_REGENERATION,
	ITEM_MONEY,
	ITEM_WEAPONS
};

new const Items[][][] = {
    { "ITEM_ID", 			"Name",         "Commands",          												"Description", 							"Cost", "Value" },
    { "ITEM_SPEED", 		"Speed",        "speed, viteza, boots, boot, ms",         							"increase speed", 						"1", "300.0" },	// OK
    { "ITEM_DAMAGE", 		"Damage",       "damage, daune, claw, claws",       								"increase damage", 						"1", "10.0" 	},	// OK 
    { "ITEM_GRAVITY", 		"Gravity",      "gravity, gravitatie, saritura, jump, sari, jumps, sock, socks",    "higher jumps", 						"1", "0.3" 	},	// OK 
    { "ITEM_INVISIBILITY", 	"Invisibility", "invisibility, invis, panda, predator, camp, camper, cloak", 		"camp using knife to be invisible", 	"1", "35" 	},	// OK 
    { "ITEM_LIFESTEAL", 	"Vampirism",    "vampirism, vampir, lifesteal, steal, mask",     					"increase health when dealing damage", 	"1", "5" 	},	// OK
    { "ITEM_HEALTH", 		"Health",       "health, viata, life, live",        								"gives additional health base", 		"1", "35" 	},	// OK 
    { "ITEM_RESPAWN", 		"Respawn",      "respawn, resp, spawn, revive, scroll, scrolls",       				"respawn after death", 					"1", "1.0" 	},	// OK 
    { "ITEM_GRENADE", 		"Grenade",    	"grenadier, grenade, nade, bomb, bombs, bomberman, glove, gloves",  "gives explosive grenade periodically", "1", "20"	},	// OK 
    { "ITEM_REGENERATION", 	"Regeneration", "regeneration, regen, recover, recovery, medic, ring, rings",     	"healing over time", 					"1", "3" 	},	// OK
	{ "ITEM_MONEY", 		"Money", 		"money, bani, dolari, cash, gold, banii",     						"gives money periodically", 			"1", 	"35" 	},	// OK
	{ "ITEM_WEAPONS", 		"Weapons", 		"weap, weapons, weapon, save, guns, gun, arme, arma, ankh, equip",  "free guns after death", 				"1", "1.0" 	}	// OK
};
