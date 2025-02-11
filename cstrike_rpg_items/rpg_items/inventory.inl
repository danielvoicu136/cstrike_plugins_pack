// Inventory 

stock bool:ITEM_Has(id, iItem) {
    for (new i = 0; i < MAX_ITEMS; i++) {
        if (g_iPlayerItems[id][i] == iItem)
            return true;
    }
    return false;
}

stock bool:ITEM_CanBuy(id, iItem) {
    new cost = str_to_num(Items[iItem][ITEM_COST]);
    if (cs_get_user_money(id) < cost) {
        client_print(id, print_chat, "Insufficient funds!");
        return false;
    }
    if (ITEM_Has(id, iItem)) {
        client_print(id, print_chat, "You already own this item!");
        return false;
    }
    if (!is_user_alive(id)) {
        client_print(id, print_chat, "Items cannot be purchased while dead!");
        return false;
    }
    return true;
}

public ITEM_Remove(id, slot, bool:notify) {
    if (g_iPlayerItems[id][slot] == ITEM_NONE)
        return;
    
    new iItem = g_iPlayerItems[id][slot];
    g_iPlayerItems[id][slot] = ITEM_NONE;
    
    if (notify) {
        client_print(id, print_chat, "You lost %s!", Items[iItem][ITEM_NAME]);
    }
}

public ITEM_Buy(id, iItem) {
    if (!ITEM_CanBuy(id, iItem)) return;
    
    for (new i = 0; i < MAX_ITEMS; i++) {
        if (g_iPlayerItems[id][i] == ITEM_NONE) {
            new cost = str_to_num(Items[iItem][ITEM_COST]);
            g_iPlayerItems[id][i] = iItem;
            cs_set_user_money(id, cs_get_user_money(id) - cost);
            client_print(id, print_chat, "You bought %s!", Items[iItem][ITEM_NAME]);
			client_cmd( id, "speak ambience/thunder_clap.wav" );
			
			if(iItem == ITEM_HEALTH) { 
				fm_set_user_health(id, get_user_health(id) + str_to_num(Items[ITEM_HEALTH][ITEM_BONUS]));
			}
		
            return;
        }
    }
	
    ITEM_Remove(id, 0, true);
	
    for (new i = 0; i < MAX_ITEMS - 1; i++) {
        g_iPlayerItems[id][i] = g_iPlayerItems[id][i + 1];
    }
	
    g_iPlayerItems[id][MAX_ITEMS - 1] = iItem;
	
    new cost = str_to_num(Items[iItem][ITEM_COST]);
    cs_set_user_money(id, cs_get_user_money(id) - cost);
	
    client_print(id, print_chat, "You bought %s!", Items[iItem][ITEM_NAME]);
	client_cmd( id, "speak ambience/thunder_clap.wav" );
	
	if(iItem == ITEM_HEALTH) { 
		fm_set_user_health(id, get_user_health(id) + str_to_num(Items[ITEM_HEALTH][ITEM_BONUS]));
	}
			
}

public ITEM_RemoveItems(id) {
    for (new i = 0; i < MAX_ITEMS; i++) {
        g_iPlayerItems[id][i] = ITEM_NONE;
    }
}

stock bool:ITEM_CanBuyItem(id, iItem) {
    return cs_get_user_money(id) >= str_to_num(Items[iItem][ITEM_COST]) && !ITEM_Has(id, iItem) && is_user_alive(id);
}

stock get_user_maxhealth(id) {
    new Float:bonus_health = 0.0;
    if (ITEM_Has(id, ITEM_HEALTH)) {
        bonus_health = str_to_float(Items[ITEM_HEALTH][ITEM_BONUS])
    }

    return floatround(100 + bonus_health); 
}


// Shop Menu 

public MENU_Shop(id) {
    if (!is_user_connected(id)) return;
    
    new Title[64];
	formatex(Title,sizeof(Title)-1,"\yShop \d(quick buy /item) \R\yCo st $^nPage:");
	new Menu = menu_create(Title, "_MENU_Shop");
    new szItem[256];
    
    for (new i = 1; i < sizeof(Items); i++) {
        formatex(szItem, sizeof(szItem) - 1, ITEM_CanBuyItem(id, i) ? "\w%s \d(%s) \R\y%d $" : "\d%s (%s) \R%d $", Items[i][ITEM_NAME], Items[i][ITEM_DESCRIPTION], str_to_num(Items[i][ITEM_COST]));
		
		new szKey[6];
		num_to_str(i,szKey,5);
		
		menu_additem(Menu, szItem, szKey, 0);
			
    }
    
    menu_setprop(Menu, MPROP_NUMBER_COLOR, "\y");
    menu_setprop(Menu, MPROP_EXIT, MEXIT_ALL);
    menu_display(id, Menu, 0);
}

public _MENU_Shop(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    
    new Data[6], Name[64];
    new Access, CallBack;
    menu_item_getinfo(menu, item, Access, Data, 5, Name, 63, CallBack);
    new Key = str_to_num(Data);
    
    if (Key > 0 && Key < sizeof(Items)) {
        ITEM_Buy(id, Key);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}


