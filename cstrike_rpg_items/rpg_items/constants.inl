#define MAX_PLAYERS 33
new g_iPlayerItems[MAX_PLAYERS][MAX_ITEMS];

enum _: ItemData {
    ITEM_ID,
    ITEM_NAME,
	ITEM_COMMAND,
    ITEM_DESCRIPTION,
    ITEM_COST,
    ITEM_BONUS
};

new szAlias[128], szSingleAlias[32], szLowerCommand[32];

new g_iNextGrenade[MAX_PLAYERS];
new g_iSaveWeapons[MAX_PLAYERS];


new gmsgStatusText;