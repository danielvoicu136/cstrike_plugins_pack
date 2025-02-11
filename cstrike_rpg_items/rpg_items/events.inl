// Events 


public on_Death() {
    new victim = read_data(2);
    if (ITEM_Has(victim, ITEM_RESPAWN)) 
	{
        set_task(2.0, "respawn_player", victim);
    }
	
	if (ITEM_Has(victim, ITEM_WEAPONS)) 
	{
       g_iSaveWeapons[victim] = 1;
    }
	
	ITEM_RemoveItems(victim);
}


public respawn_player(id) {
    if (!is_valid_player(id) || is_user_alive(id)) return;
		ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public on_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type) {
	if (!is_valid_player(attacker) || !is_valid_player(victim)) return HAM_IGNORED;
    if (!is_user_alive(attacker) || !is_user_alive(victim)) return HAM_IGNORED;

    if (ITEM_Has(attacker, ITEM_DAMAGE)) {
		new Float:bonus = str_to_float(Items[ITEM_DAMAGE][ITEM_BONUS]);
        damage += bonus;
        SetHamParamFloat(4, damage); 
    }

    if (ITEM_Has(attacker, ITEM_LIFESTEAL)) {
        new HP = get_user_health(attacker);
        new MAX_HP = get_user_maxhealth(attacker);
        if (HP < MAX_HP) { 
			new BONUS = str_to_num(Items[ITEM_HEALTH][ITEM_BONUS]);
            new NEW_HP = min(HP + BONUS, MAX_HP); 
            set_user_health(attacker, NEW_HP);
        }
    }

    return HAM_HANDLED;
}


public on_Spawn(id) {
	if(is_user_connected(id)) {
		set_task(0.2, "restore_player", id);
	}
}

public restore_player(id) {
    if (!is_valid_player(id) || !is_user_alive(id)) return;
	
		if(ITEM_Has(id, ITEM_HEALTH)) { 
			fm_set_user_health(id, get_user_health(id) + str_to_num(Items[ITEM_HEALTH][ITEM_BONUS]));
		}
		
		if(g_iSaveWeapons[id]) { 
		
			g_iSaveWeapons[id] = 0;
		
			new team = cs_get_user_team(id);
        
			strip_user_weapons(id);

			give_item(id, "weapon_knife");
			
			cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
			//give_item(id, "item_assaultsuit");
			
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_smokegrenade");
			
			if (is_map_restricted()) {
				return;
			}
		
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id, CSW_DEAGLE, 35); 

			if (team == CS_TEAM_T) { 
				give_item(id, "weapon_ak47");
				cs_set_user_bpammo(id, CSW_AK47, 90);  
			} else if (team == CS_TEAM_CT) { 
				give_item(id, "weapon_m4a1");
				cs_set_user_bpammo(id, CSW_M4A1, 90);     
			}
		}
}
		



public FWD_PlayerPreThink(id) {	
	if(is_user_connected(id)) {
		if(is_user_alive(id)) {
			
			if(ITEM_Has(id, ITEM_SPEED)) {
				if(pev(id, pev_maxspeed) < str_to_float(Items[ITEM_SPEED][ITEM_BONUS]) && pev(id, pev_maxspeed) > 1.0)
					set_pev(id, pev_maxspeed, str_to_float(Items[ITEM_SPEED][ITEM_BONUS]));
			}
			
			if(ITEM_Has(id, ITEM_GRAVITY)) { 
					if(pev(id, pev_gravity) > str_to_float(Items[ITEM_GRAVITY][ITEM_BONUS])  && pev(id, pev_gravity) > 0.1)
					set_pev(id, pev_gravity, str_to_float(Items[ITEM_GRAVITY][ITEM_BONUS]));
			}
		}	
	}
}


public TASK_SET() 
{
    new Players[32], Num;
    get_players(Players, Num, "ch");
	new iGrenadeTime = str_to_num(Items[ITEM_GRENADE][ITEM_BONUS]);
    
    for (new index = 0; index < Num; index++) 
    {
        new id = Players[index];
        
        if (!is_valid_player(id) || !is_user_alive(id)) 
            continue;
		
		if(ITEM_Has(id, ITEM_GRENADE)) { 
		
			if( iGrenadeTime < g_iNextGrenade[id] ) { 
				g_iNextGrenade[id] = 0;
				fm_give_item(id, "weapon_hegrenade");
			} 
			
			g_iNextGrenade[id]++;
		} 
	
			
		client_cmd( id, "cl_righthand 1" );
			
		if(ITEM_Has(id, ITEM_INVISIBILITY) && SHARED_IsHoldingKnife(id) && SHARED_IsCurrentSpeedLessThan(id, 35.0))  { 
			set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRenderTransTexture, str_to_num(Items[ITEM_INVISIBILITY][ITEM_BONUS]));	
		}
		else { 
			set_user_rendering( id );
		}		
		
		if(ITEM_Has(id, ITEM_REGENERATION)) { 
		
			new HP = str_to_num(Items[ITEM_REGENERATION][ITEM_BONUS]);
			if(get_user_health(id) + HP <= get_user_maxhealth(id)) {
				fm_set_user_health(id, get_user_health(id) + HP);
			}
			else {
				fm_set_user_health(id, get_user_maxhealth(id));
			}
		}
		
		if(ITEM_Has(id, ITEM_MONEY)) { 
			new MAX_CASH = 16000;
			new CASH = str_to_num(Items[ITEM_MONEY][ITEM_BONUS]);
			if(cs_get_user_money(id) + CASH <= MAX_CASH) {
				cs_set_user_money(id, cs_get_user_money(id) + CASH);
			}
			else {
				cs_set_user_money(id, MAX_CASH);
			}
		}
			
    }
}


stock bool:SHARED_IsCurrentSpeedLessThan(id, Float:fValue) 
{ 

    new Float:fVecVelocity[3];
    entity_get_vector(id, EV_VEC_velocity, fVecVelocity);
    
    if (vector_length(fVecVelocity) < fValue) 
        return true;
     
    return false;
}

stock bool:is_map_restricted() {
    new mapname[32];
    get_mapname(mapname, charsmax(mapname)); 

    if (containi(mapname, "35hp_") != -1) {
        return true;
    }

    return false;
}


public SHARED_IsHoldingKnife( id )
{
	new iClip, iAmmo, iWeapon;
	iWeapon = get_user_weapon( id, iClip, iAmmo );


	if ( iWeapon == CSW_KNIFE )
	{
		return true;
	}

	return false;
}
