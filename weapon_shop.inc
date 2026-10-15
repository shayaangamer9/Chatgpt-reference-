
// NOTE ON TEXT: this file was already uploaded with its Russian text corrupted
// (the original bytes had been replaced by Unicode replacement characters
// before it ever reached me - not something introduced here). That text is
// not recoverable from this file, so every player-facing string below has
// been rewritten in plain English placeholder text so the file compiles and
// works correctly. Swap any of these strings for your own wording/Russian
// text whenever you like - nothing below depends on the exact wording.

#define MAX_WEAPONS 5
#define WEAPON_CATEGORY_ALL 0
#define WEAPON_CATEGORY_PISTOL 1
#define WEAPON_CATEGORY_RIFLE 2
#define WEAPON_CATEGORY_SHOTGUN 3
#define WEAPON_CATEGORY_SNIPER 4
#define WEAPON_CATEGORY_MELEE 5
#define WEAPON_CATEGORY_AMMO 6
#define WEAPON_CATEGORY_ARMOR 7

// DIALOG_GUN_SHOP_MAIN / PISTOLS / AMMO / ARMOR / CONFIRM are real entries in
// laird.pwn's own enum-based DIALOG_ system (added alongside DIALOG_BIZ_SHOP_GUN),
// not hardcoded numbers - this avoids colliding with any other dialog in the project.

enum WeaponData
{
	W_ID,
	W_NAME[32],
	W_PRICE,
	W_AMMO,
	W_CATEGORY,
	W_DESCRIPTION[64]
};

new Weapons[MAX_WEAPONS][WeaponData] =
{
	{25, "Combat Shotgun", 40000, 50, WEAPON_CATEGORY_SHOTGUN, "Powerful short-range shotgun"},
	{29, "MP5", 60000, 100, WEAPON_CATEGORY_RIFLE, "Compact automatic weapon"},
	{31, "M4", 70000, 100, WEAPON_CATEGORY_RIFLE, "Automatic assault rifle"},
	{33, "Sniper Rifle", 50000, 50, WEAPON_CATEGORY_SNIPER, "Long-range precision rifle"},
	{24, "Desert Eagle", 65000, 50, WEAPON_CATEGORY_PISTOL, "Heavy combat pistol"}
};

enum AmmoPackData
{
	A_NAME[32],
	A_PRICE,
	A_AMOUNT,
	A_DESCRIPTION[64]
};

new AmmoPacks[4][AmmoPackData] =
{
	{"Pistol Ammo Pack", 1680, 50, "Ammo for pistols"},
	{"Rifle Ammo Pack", 3600, 100, "Ammo for automatic weapons"},
	{"Shotgun Ammo Pack", 1200, 30, "Ammo for shotguns"},
	{"Sniper Ammo Pack", 1250, 40, "Ammo for sniper rifles"}
};

enum ArmorData
{
	AR_NAME[32],
	AR_PRICE,
	AR_AMOUNT,
	AR_DESCRIPTION[64]
};

new Armor[4][ArmorData] =
{
	{"Light Armor", 2500, 50, "Basic protection"},
	{"Medium Armor", 5000, 100, "Improved protection"},
	{"Heavy Armor", 8000, 150, "Reinforced protection"},
	{"Max Armor", 12000, 200, "Maximum protection"}
};

new g_PlayerSelectedWeapon[MAX_PLAYERS] = {-1, ...};
new g_PlayerSelectedAmmoPack[MAX_PLAYERS] = {-1, ...};
new g_PlayerSelectedArmor[MAX_PLAYERS] = {-1, ...};
new g_PlayerWeaponCategory[MAX_PLAYERS] = {WEAPON_CATEGORY_ALL, ...};

#define STATIC_GUN_SHOP_COUNT (7)
#define STATIC_GUN_SHOP_INTERIOR (1)
#define STATIC_GUN_SHOP_WORLD (0)
#define STATIC_GUN_SHOP_PICKUP_MODEL (19132)
#define STATIC_GUN_SHOP_NPC_MODEL (102)
#define STATIC_GUN_SHOP_NPC_RANGE (2.2)
#define STATIC_GUN_SHOP_EXIT_DISTANCE (2.5)

new const Float:g_static_gun_shop_pos[STATIC_GUN_SHOP_COUNT][3] =
{
	{207.629000, 829.766000, 13.383100},
	{2350.050000, -2138.410000, 22.570600},
	{-2381.790000, -60.819000, 26.752400},
	{-1788.000000, 671.136000, 35.399800},
	{1950.070000, 1899.340000, 15.558000},
	{-1931.960000, 2380.450000, 58.652100},
	{-2560.400000, 1078.310000, 10.390000}
};

new const Float:g_static_gun_shop_enter_pos[4] = {91.174934, -4.497013, 1002.046936, 7.039999};
new const Float:g_static_gun_shop_exit_pos[4] = {91.463623, -6.881072, 1002.046936, 177.447967};
new const Float:g_static_gun_shop_npc_pos[4] = {94.211112, 7.443953, 1002.046936, 135.360992};

new g_static_gun_shop_npc_area = -1;
new g_static_gun_shop_player_entrance[MAX_PLAYERS] = {-1, ...};
new Float:g_static_gun_shop_player_exit_pos[MAX_PLAYERS][4];

stock bool:WeaponShop_IsPlayerNearStaticNpc(playerid)
{
	if(GetPlayerInterior(playerid) != STATIC_GUN_SHOP_INTERIOR) return false;
	if(GetPlayerVirtualWorld(playerid) != STATIC_GUN_SHOP_WORLD) return false;
	if(!IsPlayerInRangeOfPoint(playerid, STATIC_GUN_SHOP_NPC_RANGE, g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2])) return false;
	return true;
}

stock WeaponShop_UpdateStaticShopExitPos(playerid, shopid)
{
	new Float:x, Float:y, Float:z, Float:angle;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);

	new Float:dir_x = x - g_static_gun_shop_pos[shopid][0];
	new Float:dir_y = y - g_static_gun_shop_pos[shopid][1];
	new Float:distance = floatsqroot((dir_x * dir_x) + (dir_y * dir_y));

	if(distance < 0.25)
	{
		dir_x = floatsin(-angle + 180.0, degrees);
		dir_y = floatcos(-angle + 180.0, degrees);
	}
	else
	{
		dir_x /= distance;
		dir_y /= distance;
	}

	g_static_gun_shop_player_exit_pos[playerid][0] = g_static_gun_shop_pos[shopid][0] + (dir_x * STATIC_GUN_SHOP_EXIT_DISTANCE);
	g_static_gun_shop_player_exit_pos[playerid][1] = g_static_gun_shop_pos[shopid][1] + (dir_y * STATIC_GUN_SHOP_EXIT_DISTANCE);
	g_static_gun_shop_player_exit_pos[playerid][2] = g_static_gun_shop_pos[shopid][2];
	g_static_gun_shop_player_exit_pos[playerid][3] = angle;
	return 1;
}

stock WeaponShop_CreateStaticShops()
{
	new label_text[160];
	format(label_text, sizeof label_text, "{FFFF00}Gun Shop\n{FFFFFF}Press ENTER to go inside");

	for(new i; i < STATIC_GUN_SHOP_COUNT; i++)
	{
		CreatePickup(STATIC_GUN_SHOP_PICKUP_MODEL, 23, g_static_gun_shop_pos[i][0], g_static_gun_shop_pos[i][1], g_static_gun_shop_pos[i][2], STATIC_GUN_SHOP_WORLD, PICKUP_ACTION_TYPE_GUNSHOP, i);
		CreateDynamic3DTextLabel(label_text, 0xFFFF00FF, g_static_gun_shop_pos[i][0], g_static_gun_shop_pos[i][1], g_static_gun_shop_pos[i][2] + 1.0, 10.0, _, _, _, STATIC_GUN_SHOP_WORLD, 0);
	}

	new actorid = CreateActor(STATIC_GUN_SHOP_NPC_MODEL, g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2], g_static_gun_shop_npc_pos[3]);
	if(actorid != -1) SetActorVirtualWorld(actorid, STATIC_GUN_SHOP_WORLD);

	CreateDynamic3DTextLabel("{0b7ecf}Gun Dealer{0b7ecf}\n{FFFFFF}Talk to me{FFFFFF}", 0x0B7ECFFF, g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2] + 1.1, 8.0, _, _, _, STATIC_GUN_SHOP_WORLD, STATIC_GUN_SHOP_INTERIOR);
	g_static_gun_shop_npc_area = CreateDynamicSphere(g_static_gun_shop_npc_pos[0], g_static_gun_shop_npc_pos[1], g_static_gun_shop_npc_pos[2], STATIC_GUN_SHOP_NPC_RANGE, STATIC_GUN_SHOP_WORLD, STATIC_GUN_SHOP_INTERIOR);

	CreatePickup(STATIC_GUN_SHOP_PICKUP_MODEL, 23, g_static_gun_shop_exit_pos[0], g_static_gun_shop_exit_pos[1], g_static_gun_shop_exit_pos[2], STATIC_GUN_SHOP_WORLD, PICKUP_ACTION_TYPE_GUNSHOP_EXIT, 0);
	return 1;
}

stock WeaponShop_EnterStaticShop(playerid, shopid)
{
	if(shopid < 0 || shopid >= STATIC_GUN_SHOP_COUNT) shopid = 0;
	g_static_gun_shop_player_entrance[playerid] = shopid;
	WeaponShop_UpdateStaticShopExitPos(playerid, shopid);
	SetPlayerInBiz(playerid, -1);
	SetPlayerPosEx(playerid, g_static_gun_shop_enter_pos[0], g_static_gun_shop_enter_pos[1], g_static_gun_shop_enter_pos[2], g_static_gun_shop_enter_pos[3], STATIC_GUN_SHOP_INTERIOR, STATIC_GUN_SHOP_WORLD);
	return 1;
}

stock WeaponShop_ExitStaticShop(playerid)
{
	new shopid = g_static_gun_shop_player_entrance[playerid];
	new bool:has_exit_pos = (0 <= shopid < STATIC_GUN_SHOP_COUNT);
	if(!has_exit_pos) shopid = 0;
	g_static_gun_shop_player_entrance[playerid] = -1;

	if(has_exit_pos)
	{
		SetPlayerPosEx(playerid, g_static_gun_shop_player_exit_pos[playerid][0], g_static_gun_shop_player_exit_pos[playerid][1], g_static_gun_shop_player_exit_pos[playerid][2], g_static_gun_shop_player_exit_pos[playerid][3], 0, STATIC_GUN_SHOP_WORLD);
	}
	else
	{
		SetPlayerPosEx(playerid, g_static_gun_shop_pos[shopid][0], g_static_gun_shop_pos[shopid][1] - STATIC_GUN_SHOP_EXIT_DISTANCE, g_static_gun_shop_pos[shopid][2], 0.0, 0, STATIC_GUN_SHOP_WORLD);
	}
	return 1;
}

stock WeaponShop_OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid != g_static_gun_shop_npc_area) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return 1;
	ShowGunShopMenu(playerid);
	return 1;
}

stock ShowGunShopMenu(playerid)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;


	new string[512];
	string[0] = '\0';

	strcat(string, "{FF5252}1. {FFFFFF}Weapons\n");
	strcat(string, "{FF5252}2. {FFFFFF}Ammunition\n");
	strcat(string, "{FF5252}3. {FFFFFF}Armor\n");

	Dialog(playerid, DIALOG_GUN_SHOP_MAIN, DIALOG_STYLE_LIST,
		"{FF5252}BR BONUS {FFFFFF}| Gun Shop",
		string,
		"Select", "Close");
	return 1;
}

stock WeaponShop_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	// Note: DIALOG_BIZ_SHOP_GUN belongs to the existing biz gun shop (laird.pwn's
	// own DIALOG_BIZ_SHOP_GUN handler) and is NOT handled here - this static NPC
	// shop is entered purely via its own dynamic area (WeaponShop_OnPlayerEnterDynamicArea),
	// so it must never claim that dialog id or it would hijack the real shop.
	if(dialogid != DIALOG_GUN_SHOP_MAIN && dialogid != DIALOG_GUN_SHOP_PISTOLS && dialogid != DIALOG_GUN_SHOP_AMMO && dialogid != DIALOG_GUN_SHOP_ARMOR && dialogid != DIALOG_GUN_SHOP_CONFIRM)
		return 0;

	if(dialogid == DIALOG_GUN_SHOP_MAIN)
	{
		if(!response) return 1;

		if(listitem == 0)
		{
			ShowWeaponsByCategory(playerid, WEAPON_CATEGORY_ALL);
		}
		else if(listitem == 1)
		{
			ShowAmmoShopMenu(playerid);
		}
		else if(listitem == 2)
		{
			ShowArmorShopMenu(playerid);
		}
		else
		{
			ShowGunShopMenu(playerid);
		}
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_PISTOLS)
	{
		if(!response)
		{
			ShowGunShopMenu(playerid);
			return 1;
		}

		new category = g_PlayerWeaponCategory[playerid];
		new count = 0, weaponid = -1;

		for(new i = 0; i < MAX_WEAPONS; i++)
		{
			if(category == WEAPON_CATEGORY_ALL || Weapons[i][W_CATEGORY] == category)
			{
				if(count == listitem)
				{
					weaponid = i;
					break;
				}
				count++;
			}
		}

		if(weaponid == -1)
		{
			ShowWeaponsByCategory(playerid, category);
			return 1;
		}

		ShowWeaponConfirmDialog(playerid, weaponid);
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_AMMO)
	{
		if(!response)
		{
			ShowGunShopMenu(playerid);
			return 1;
		}

		new ammoid = listitem;
		if(ammoid < 0 || ammoid >= 4)
		{
			ShowAmmoShopMenu(playerid);
			return 1;
		}

		ShowAmmoConfirmDialog(playerid, ammoid);
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_ARMOR)
	{
		if(!response)
		{
			ShowGunShopMenu(playerid);
			return 1;
		}

		new armorid = listitem;
		if(armorid < 0 || armorid >= 4)
		{
			ShowArmorShopMenu(playerid);
			return 1;
		}

		ShowArmorConfirmDialog(playerid, armorid);
		return 1;
	}

	if(dialogid == DIALOG_GUN_SHOP_CONFIRM)
	{
		if(!response)
		{
			if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_AMMO)
				return ShowAmmoShopMenu(playerid), 1;
			else if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_ARMOR)
				return ShowArmorShopMenu(playerid), 1;
			return ShowWeaponsByCategory(playerid, g_PlayerWeaponCategory[playerid]), 1;
		}

		if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_AMMO)
			BuyAmmoFromShop(playerid);
		else if(g_PlayerWeaponCategory[playerid] == WEAPON_CATEGORY_ARMOR)
			BuyArmorFromShop(playerid);
		else
			BuyWeaponFromShop(playerid);
		return 1;
	}

	return 0;
}

stock ShowWeaponsByCategory(playerid, category)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;

	new string[2048], count = 0, temp[256], i;
	string[0] = '\0';

	strcat(string, "{FFFFFF}#\tName\tPrice\tDescription\n");
	new category_name[32] = "Weapons";

	if(category == WEAPON_CATEGORY_PISTOL)
	{
		format(category_name, sizeof(category_name), "Pistols");
	}
	else if(category == WEAPON_CATEGORY_RIFLE)
	{
		format(category_name, sizeof(category_name), "Rifles");
	}
	else if(category == WEAPON_CATEGORY_SHOTGUN)
	{
		format(category_name, sizeof(category_name), "Shotguns");
	}
	else if(category == WEAPON_CATEGORY_SNIPER)
	{
		format(category_name, sizeof(category_name), "Sniper Rifles");
	}
	else if(category == WEAPON_CATEGORY_MELEE)
	{
		format(category_name, sizeof(category_name), "Melee");
	}

	for(i = 0; i < MAX_WEAPONS; i++)
	{
		if(category == WEAPON_CATEGORY_ALL || Weapons[i][W_CATEGORY] == category)
		{
			format(temp, sizeof(temp), "{FF5252}%d.\t{FFFFFF}%s\t{FF5252}%d rub.\t{FFFFFF}Goes to your inventory\n",
				count + 1,
				Weapons[i][W_NAME],
				Weapons[i][W_PRICE]
			);
			strcat(string, temp);
			count++;
		}
	}

	if(count == 0) return SendClientMessage(playerid, 0xFF0000FF, "Error: no weapons in this category"), 0;

	new title[128];
	format(title, sizeof(title), "{FF5252}BR BONUS {FFFFFF}| %s", category_name);

	Dialog(playerid, DIALOG_GUN_SHOP_PISTOLS, DIALOG_STYLE_TABLIST_HEADERS,
		title, string, "Buy", "Back");

	g_PlayerWeaponCategory[playerid] = category;
	return 1;
}

stock ShowAmmoShopMenu(playerid)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;


	new string[2048], count = 0, temp[256], i;
	string[0] = '\0';
	strcat(string, "{FFFFFF}#\tName\tPrice\tDescription\n");

	for(i = 0; i < 4; i++)
	{
		format(temp, sizeof(temp), "{FF5252}%d.\t{FFFFFF}%s\t{FF5252}%d rub.\t{FFFFFF}Goes to your inventory\n",
			i + 1,
			AmmoPacks[i][A_NAME],
			AmmoPacks[i][A_PRICE]
		);
		strcat(string, temp);
		count++;
	}

	if(count == 0) return SendClientMessage(playerid, 0xFF0000FF, "Error: no ammo available"), 0;

	Dialog(playerid, DIALOG_GUN_SHOP_AMMO, DIALOG_STYLE_TABLIST_HEADERS,
		"{FF5252}BR BONUS {FFFFFF}| Ammunition",
		string,
		"Buy", "Back");

	g_PlayerWeaponCategory[playerid] = WEAPON_CATEGORY_AMMO;
	return 1;
}

stock ShowAmmoConfirmDialog(playerid, ammoid)
{
	if(ammoid < 0 || ammoid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid item"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;

	new message[512];
	format(message, sizeof(message),
		"{FFFFFF}You are about to buy: {FF5252}%s{FFFFFF}.\n\n\
		{FFFFFF}Amount ({FF5252}%d pcs{FFFFFF}): {FF5252}%d rub.",
		AmmoPacks[ammoid][A_NAME],
		AmmoPacks[ammoid][A_AMOUNT],
		AmmoPacks[ammoid][A_PRICE]
	);

	Dialog(playerid, DIALOG_GUN_SHOP_CONFIRM, DIALOG_STYLE_MSGBOX,
		"{FF5252}BR BONUS {FFFFFF}| Confirm Purchase",
		message, "Buy", "Cancel");

	g_PlayerSelectedAmmoPack[playerid] = ammoid;
	return 1;
}

stock BuyAmmoFromShop(playerid)
{
	new ammoid = g_PlayerSelectedAmmoPack[playerid];

	if(ammoid < 0 || ammoid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid item"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;

	new price = AmmoPacks[ammoid][A_PRICE];
	if(price <= 0) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid price"), 0;

	if(GetPlayerMoneyEx(playerid) < price)
	{
		new msg[128];
		format(msg, sizeof(msg), "Insufficient funds! Need %d rub.", price);
		return SendClientMessage(playerid, 0xFF0000FF, msg), 0;
	}

	AddPlayerData(playerid, P_AMMO, +, AmmoPacks[ammoid][A_AMOUNT]);
	UpdatePlayerDatabaseInt(playerid, "ammo", GetPlayerData(playerid, P_AMMO));
	GivePlayerMoneyEx(playerid, -price, "Gun shop: ammo", true, true);

	new playername[24];
	GetPlayerName(playerid, playername, sizeof(playername));
	new chatmsg[128];
	format(chatmsg, sizeof(chatmsg), "%s, you bought %s (%d pcs) for %d rub.", playername, AmmoPacks[ammoid][A_NAME], AmmoPacks[ammoid][A_AMOUNT], price);
	SendClientMessage(playerid, 0xFFFFFFFF, chatmsg);

	new notify[128];
	format(notify, sizeof(notify), "You spent %d rub", price);
	ShowNotificationSile(playerid, 0, 6, 0, 0, notify, " ");

	PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);

	g_PlayerSelectedAmmoPack[playerid] = -1;
	return 1;
}

stock ShowWeaponConfirmDialog(playerid, weaponid)
{
	if(weaponid < 0 || weaponid >= MAX_WEAPONS) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid item"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;

	new message[512];
	format(message, sizeof(message),
		"{FFFFFF}You are about to buy the weapon: {FF5252}%s{FFFFFF}.\n\n\
		{FFFFFF}Price: {FF5252}%d rub.",
		Weapons[weaponid][W_NAME],
		Weapons[weaponid][W_PRICE]
	);

	Dialog(playerid, DIALOG_GUN_SHOP_CONFIRM, DIALOG_STYLE_MSGBOX,
		"{FF5252}BR BONUS {FFFFFF}| Confirm Purchase", message, "Buy", "Cancel");

	g_PlayerSelectedWeapon[playerid] = weaponid;
	return 1;
}

// Maps this shop's real SA-MP weapon ids to the matching inventory item id so
// the purchase is stored in the player's inventory (same pattern as the
// DIALOG_BIZ_SHOP_GUN biz shop), rather than given directly via GivePlayerWeapon.
// Shotgun/MP5/Sniper Rifle/Deagle reuse the exact same ITEM_ID_SHOP_* constants
// (and therefore the exact same icon + "use" logic already confirmed working) as
// the other gun shop, since they are literally the same real weapons. The M4
// (weapon id 31) does not exist in the other shop, so it gets its own new
// ITEM_ID_SHOP_M4 constant - its inventory icon has NOT been verified in-game
// yet (same /itemtest process used for the other 5 items should be used on it
// before relying on the icon looking right; the weapon it gives will be
// correct either way).
stock WeaponShop_GetItemIdForWeapon(weapon_id)
{
	switch(weapon_id)
	{
		case 25: return ITEM_ID_SHOP_SHOTGUN;
		case 29: return ITEM_ID_SHOP_MP5;
		case 31: return ITEM_ID_SHOP_M4;
		case 33: return ITEM_ID_SHOP_RIFLE;
		case 24: return ITEM_ID_SHOP_DEAGLE;
	}
	return 0;
}

stock BuyWeaponFromShop(playerid)
{
	new weaponid = g_PlayerSelectedWeapon[playerid];

	if(weaponid < 0 || weaponid >= MAX_WEAPONS) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid item"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;

	new price = Weapons[weaponid][W_PRICE];
	new weapon_name[32];

	if(price <= 0) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid price"), 0;
	strmid(weapon_name, Weapons[weaponid][W_NAME], 0, strlen(Weapons[weaponid][W_NAME]));

	if(GetPlayerMoneyEx(playerid) < price)
	{
		new msg[128];
		format(msg, sizeof(msg), "Insufficient funds! Need %d rub.", price);
		return SendClientMessage(playerid, 0xFF0000FF, msg), 0;
	}

	new item_id = WeaponShop_GetItemIdForWeapon(Weapons[weaponid][W_ID]);
	if(item_id == 0) return SendClientMessage(playerid, 0xFF0000FF, "Error: this weapon is not set up for the inventory yet"), 0;

	new freeSlot = Inventory_GetFreeSlot(playerid);
	if(freeSlot == -1) return SendClientMessage(playerid, 0xFF0000FF, "You have no free inventory slots"), 0;

	Inventory_AddItem(playerid, item_id, freeSlot, 1, "");

	GivePlayerMoneyEx(playerid, -price, "Gun shop: weapon", true, true);

	new playername[24];
	GetPlayerName(playerid, playername, sizeof(playername));
	new chatmsg[128];
	format(chatmsg, sizeof(chatmsg), "%s, you bought a %s (1 pc) for %d rub. Check your inventory to use it.", playername, weapon_name, price);
	SendClientMessage(playerid, 0xFFFFFFFF, chatmsg);

	new notify[128];
	format(notify, sizeof(notify), "You spent %d rub", price);
	ShowNotificationSile(playerid, 0, 6, 0, 0, notify, " ");

	PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);

	g_PlayerSelectedWeapon[playerid] = -1;
	return 1;
}

stock GetWeaponIndexByName(const weapon_name[])
{
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if(!strcmp(Weapons[i][W_NAME], weapon_name, true)) return i;
	}
	return -1;
}

stock GetWeaponNameByID(weaponid)
{
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if(Weapons[i][W_ID] == weaponid) return i;
	}
	return -1;
}

stock ShowArmorShopMenu(playerid)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;


	new string[2048], count = 0, temp[256], i;
	string[0] = '\0';
	strcat(string, "{FFFFFF}#\tName\tPrice\tProtection\n");

	for(i = 0; i < 4; i++)
	{
		format(temp, sizeof(temp), "{FF5252}%d.\t{FFFFFF}%s\t{FF5252}%d rub.\t{FFFFFF}Applied immediately\n",
			i + 1,
			Armor[i][AR_NAME],
			Armor[i][AR_PRICE]
		);
		strcat(string, temp);
		count++;
	}

	if(count == 0) return SendClientMessage(playerid, 0xFF0000FF, "Error: no armor available"), 0;

	Dialog(playerid, DIALOG_GUN_SHOP_ARMOR, DIALOG_STYLE_TABLIST_HEADERS,
		"{FF5252}BR BONUS {FFFFFF}| Armor",
		string,
		"Buy", "Back");

	g_PlayerWeaponCategory[playerid] = WEAPON_CATEGORY_ARMOR;
	return 1;
}

stock ShowArmorConfirmDialog(playerid, armorid)
{
	if(armorid < 0 || armorid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid armor"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;

	new message[512];
	format(message, sizeof(message),
		"{FFFFFF}You are about to buy the armor: {FF5252}%s{FFFFFF}.\n\n\
		{FFFFFF}Price: {FF5252}%d rub.",
		Armor[armorid][AR_NAME],
		Armor[armorid][AR_PRICE]
	);

	Dialog(playerid, DIALOG_GUN_SHOP_CONFIRM, DIALOG_STYLE_MSGBOX,
		"{FF5252}BR BONUS {FFFFFF}| Confirm Purchase", message, "Buy", "Cancel");

	g_PlayerSelectedArmor[playerid] = armorid;
	return 1;
}

stock BuyArmorFromShop(playerid)
{
	new armorid = g_PlayerSelectedArmor[playerid];

	if(armorid < 0 || armorid >= 4) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid armor"), 0;
	if(!IsPlayerLogged(playerid)) return 0;
	if(!WeaponShop_IsPlayerNearStaticNpc(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "You must be near the gun dealer"), 0;

	new price = Armor[armorid][AR_PRICE];
	if(price <= 0) return SendClientMessage(playerid, 0xFF0000FF, "Error: invalid price"), 0;

	if(GetPlayerMoneyEx(playerid) < price)
	{
		new msg[128];
		format(msg, sizeof(msg), "Insufficient funds! Need %d rub.", price);
		return SendClientMessage(playerid, 0xFF0000FF, msg), 0;
	}

	SetPlayerArmour(playerid, Armor[armorid][AR_AMOUNT]);
	GivePlayerMoneyEx(playerid, -price, "Gun shop: armor", true, true);

	new playername[24];
	GetPlayerName(playerid, playername, sizeof(playername));
	new chatmsg[128];
	format(chatmsg, sizeof(chatmsg), "%s, you bought %s for %d rub.", playername, Armor[armorid][AR_NAME], price);
	SendClientMessage(playerid, 0xFFFFFFFF, chatmsg);

	new broadcast[128];
	format(broadcast, sizeof(broadcast), "%s bought %s", playername, Armor[armorid][AR_NAME]);
	SendClientMessage(-1, 0xFF66CCFF, broadcast);

	new notify[128];
	format(notify, sizeof(notify), "You spent %d rub", price);
	ShowNotificationSile(playerid, 0, 6, 0, 0, notify, " ");

	PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);

	g_PlayerSelectedArmor[playerid] = -1;
	return 1;
}
