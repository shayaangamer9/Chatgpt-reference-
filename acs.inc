#if defined _acs_included
    #endinput
#endif
#define _acs_included

#include <a_samp>
//#include "../include/system/inv.inc"
// acsessory.inc dropped: it duplicates CMD:myacs/CMD:accedit (and several
// stock helpers) already fully implemented below in this file, which would
// be a compile-time duplicate-symbol error if both were included. Nothing
// below calls into acsessory.inc-only code (verified: Accessory_MarketBuy/
// Accessory_OpenMarket/Accessory_CloseMarket are all defined locally).

#define ACCESSORY_DIALOG_SLOT_SELECT (1190)
#define ACCESSORY_DIALOG_EDITOR_ACTION (1191)
#define ACCESSORY_DIALOG_WEAR_CONFIRM (1192)
#define ACCESSORY_DIALOG_BONE_SELECT (1193)
#define ACCESSORY_DIALOG_BUY_CONFIRM (1194)

// New constants (not present anywhere else in the project): a cosmetic
// item-type tag for GetItemType() (real types use 0,1,2,3,4,5,7; 6 is
// unused) and a private inventory item-id range reserved for accessories
// with no entry in ipacket.inc's Accessory_GetItemIdByModel table, chosen
// well clear of every real item id used in the project.
#define ITEM_TYPE_ACCESSORY (6)
// Accessory active-slot range. Real Inventory.inc has MAX_ACTIVE_SLOTS active slots
// (SIM_SLOT / SKIN_SLOT among them); every accessory lookup below also checks the
// item type, so non-accessory slots are filtered out. Attached-object index == active slot.
#define SLOT_ACCESSORY_START (0)
#define SLOT_ACCESSORY_END (MAX_ACTIVE_SLOTS - 1)
#define INVENTORY_ACCESSORY_ITEM_BASE (50000)
#define INVENTORY_ACCESSORY_ITEM_LIMIT (51000)

// enum E_ACCESSORY and the accessory[][E_ACCESSORY] table used to be
// declared right here, but had to move to laird.pwn itself, BEFORE its
// "../include/system/Inventory.inc" include. Pawn requires a plain
// global array to be declared (lexically) before any earlier-included
// file's function bodies reference it, and the real Inventory.inc
// (Accessory_FindAccessoryIndexByModel / GetAccessoryBoneByItemId) was
// already written assuming a global "accessory[]" table exists that
// early - exactly like the old inline shop's table used to sit near the
// top of laird.pwn, long before Inventory.inc's include. See laird.pwn
// for the real declaration (same enum/table, unchanged).

stock Accessory_GetCount()
{
    return sizeof(accessory);
}

stock Accessory_GetIndexByModelId(modelid)
{
    for(new i = 0; i < sizeof(accessory); i++)
    {
        if(accessory[i][ID_ACCESSORY] == modelid) return i;
    }
    return -1;
}

stock Accessory_GetModelIdByIndex(accessoryId)
{
    if(accessoryId < 0 || accessoryId >= sizeof(accessory)) return 0;
    return accessory[accessoryId][ID_ACCESSORY];
}

new g_AccessoryEditorSlot[MAX_PLAYERS] = {-1, ...};
new Text:acsv2_fix_TD[26];
new PlayerText:acsv2_coords_fix_PTD[MAX_PLAYERS][1];
new Text:acsmagaz_button_TD[5];
new PlayerText:acsmagaz_price_PTD[MAX_PLAYERS][1];
new bool:create_player_btn[MAX_PLAYERS];
new pl_accessory[MAX_PLAYERS];
new pl_id_accessory[MAX_PLAYERS];
new bool:acs_market_active[MAX_PLAYERS];
new g_PendingAccessory[MAX_PLAYERS];
new g_PendingInvSlot[MAX_PLAYERS];
new g_WearFromInventory[MAX_PLAYERS];
new g_PendingBone[MAX_PLAYERS];

forward Accessory_OnEquipped(playerid, activeSlot, accessoryId);
forward Accessory_OnUnequipped(playerid, activeSlot);
forward Accessory_OnInventoryLoaded(playerid);
forward bool:Accessory_CanEquip(playerid, accessoryId);
forward bool:Accessory_UseFromInventory(playerid, invSlot);
forward Accessory_Init();
forward Accessory_LoadAllFromDB(playerid);
forward Accessory_SaveAllSlots(playerid);
forward Accessory_DeleteSlotFromDB(playerid, activeSlot);

stock Accessory_GetImmnventoryItemId(accessoryId)
{
    if(accessoryId < 0 || accessoryId >= sizeof(accessory)) return 0;
    return Accessory_GetInventoryItemId(accessoryId);
}

stock Accessory_Init()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        g_AccessoryEditorSlot[i] = -1;
        g_PendingAccessory[i] = -1;
        g_PendingInvSlot[i] = -1;
        g_WearFromInventory[i] = 0;
        g_PendingBone[i] = -1;
    }
    CreateTextDrawButtonBR();
    CreateEditAccessoryTD();
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `player_accessories` (`id` INT AUTO_INCREMENT PRIMARY KEY, `account_id` INT NOT NULL, `active_slot` INT NOT NULL, `accessory_id` INT NOT NULL, `bone` INT NOT NULL, `x` FLOAT NOT NULL DEFAULT 0.0, `y` FLOAT NOT NULL DEFAULT 0.0, `z` FLOAT NOT NULL DEFAULT 0.0, `rx` FLOAT NOT NULL DEFAULT 0.0, `ry` FLOAT NOT NULL DEFAULT 0.0, `rz` FLOAT NOT NULL DEFAULT 0.0, `scale` FLOAT NOT NULL DEFAULT 1.0, UNIQUE KEY `unique_slot` (`account_id`, `active_slot`))", "", "");
    return 1;
}

stock ConvertMoneyACS(money, string[], length = sizeof string)
{
    format(string, length, "%d", money < 0 ? -money : money);
    for(new i = strlen(string); (i -= 3) > 0;)
    {
        if(string[i] != '\0' && '0' <= string[i] <= '9') strins(string, ".", i, length);
        else return;
    }
    if(money < 0) strins(string, "-", 0, length);
}

stock CreatePlTDButtonBR(playerid)
{
    acsmagaz_price_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 319.7778, 373.6799, "100.000_руб.");
    PlayerTextDrawLetterSize(playerid, acsmagaz_price_PTD[playerid][0], 0.2531, 1.3509);
    PlayerTextDrawTextSize(playerid, acsmagaz_price_PTD[playerid][0], 0.0000, -17.0000);
    PlayerTextDrawAlignment(playerid, acsmagaz_price_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, acsmagaz_price_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, acsmagaz_price_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, acsmagaz_price_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, acsmagaz_price_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, acsmagaz_price_PTD[playerid][0], 1);
    create_player_btn[playerid] = true;
    return 1;
}

stock CreateTextDrawButtonBR()
{
    acsmagaz_button_TD[0] = TextDrawCreate(69.0000, 202.0000, "txd:brrainleft");
    TextDrawTextSize(acsmagaz_button_TD[0], 27.0000, 43.0000);
    TextDrawAlignment(acsmagaz_button_TD[0], 1);
    TextDrawColor(acsmagaz_button_TD[0], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[0], 255);
    TextDrawFont(acsmagaz_button_TD[0], 4);
    TextDrawSetSelectable(acsmagaz_button_TD[0], true);

    acsmagaz_button_TD[1] = TextDrawCreate(542.0000, 202.0000, "txd:brrainright");
    TextDrawTextSize(acsmagaz_button_TD[1], 27.0000, 43.0000);
    TextDrawAlignment(acsmagaz_button_TD[1], 1);
    TextDrawColor(acsmagaz_button_TD[1], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[1], 255);
    TextDrawFont(acsmagaz_button_TD[1], 4);
    TextDrawSetSelectable(acsmagaz_button_TD[1], true);

    acsmagaz_button_TD[2] = TextDrawCreate(234.7776, 371.0354, "txd:brtuning4nstage2");
    TextDrawTextSize(acsmagaz_button_TD[2], 171.0000, 21.0000);
    TextDrawAlignment(acsmagaz_button_TD[2], 1);
    TextDrawColor(acsmagaz_button_TD[2], -12705281);
    TextDrawBackgroundColor(acsmagaz_button_TD[2], 255);
    TextDrawFont(acsmagaz_button_TD[2], 4);

    acsmagaz_button_TD[3] = TextDrawCreate(240.4443, 384.0000, "txd:braucubuy");
    TextDrawTextSize(acsmagaz_button_TD[3], 78.0000, 58.0000);
    TextDrawAlignment(acsmagaz_button_TD[3], 1);
    TextDrawColor(acsmagaz_button_TD[3], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[3], 255);
    TextDrawFont(acsmagaz_button_TD[3], 4);
    TextDrawSetSelectable(acsmagaz_button_TD[3], true);

    acsmagaz_button_TD[4] = TextDrawCreate(320.2221, 382.5065, "txd:braucexit");
    TextDrawTextSize(acsmagaz_button_TD[4], 83.0000, 60.0000);
    TextDrawAlignment(acsmagaz_button_TD[4], 1);
    TextDrawColor(acsmagaz_button_TD[4], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[4], 255);
    TextDrawFont(acsmagaz_button_TD[4], 4);
    TextDrawSetSelectable(acsmagaz_button_TD[4], true);
    return 1;
}

stock CreateEditAccessoryTD()
{
    acsv2_fix_TD[0] = TextDrawCreate(35.0000, 18.0000, "txd:bracstext");
    TextDrawTextSize(acsv2_fix_TD[0], 127.0000, 45.0000);
    TextDrawAlignment(acsv2_fix_TD[0], 1);
    TextDrawColor(acsv2_fix_TD[0], -1);
    TextDrawBackgroundColor(acsv2_fix_TD[0], 255);
    TextDrawFont(acsv2_fix_TD[0], 4);

    acsv2_fix_TD[1] = TextDrawCreate(600.0000, 0.1, "txd:bracsbtnexit");
    TextDrawTextSize(acsv2_fix_TD[1], 45.0000, 50.0000);
    TextDrawAlignment(acsv2_fix_TD[1], 1);
    TextDrawColor(acsv2_fix_TD[1], -1);
    TextDrawBackgroundColor(acsv2_fix_TD[1], 255);
    TextDrawFont(acsv2_fix_TD[1], 4);
    TextDrawSetSelectable(acsv2_fix_TD[1], true);

    acsv2_fix_TD[2] = TextDrawCreate(453.0000, 355.0000, "txd:bracssave");
    TextDrawTextSize(acsv2_fix_TD[2], 130.0000, 40.0000);
    TextDrawAlignment(acsv2_fix_TD[2], 1);
    TextDrawColor(acsv2_fix_TD[2], -1);
    TextDrawBackgroundColor(acsv2_fix_TD[2], 255);
    TextDrawFont(acsv2_fix_TD[2], 4);
    TextDrawSetSelectable(acsv2_fix_TD[2], true);

    for(new i = 3; i < 10; i++)
    {
        new txdStr[16];
        format(txdStr, sizeof(txdStr), "txd:bracsn%d", i-2);
        acsv2_fix_TD[i] = TextDrawCreate(35.0000, 65.0 + (i-3)*45.0, txdStr);
        TextDrawTextSize(acsv2_fix_TD[i], 117.0000, 42.0000);
        TextDrawAlignment(acsv2_fix_TD[i], 1);
        TextDrawColor(acsv2_fix_TD[i], -1);
        TextDrawBackgroundColor(acsv2_fix_TD[i], 255);
        TextDrawFont(acsv2_fix_TD[i], 4);
        TextDrawSetSelectable(acsv2_fix_TD[i], true);
    }

    for(new i = 10; i < 17; i++)
    {
        new txdStr[16];
        format(txdStr, sizeof(txdStr), "txd:bracsa%d", i-9);
        acsv2_fix_TD[i] = TextDrawCreate(35.0000, 65.0 + (i-10)*45.0, txdStr);
        TextDrawTextSize(acsv2_fix_TD[i], 117.0000, 42.0000);
        TextDrawAlignment(acsv2_fix_TD[i], 1);
        TextDrawColor(acsv2_fix_TD[i], -1);
        TextDrawBackgroundColor(acsv2_fix_TD[i], 255);
        TextDrawFont(acsv2_fix_TD[i], 4);
    }

    for(new i = 17; i < 24; i++)
    {
        new txdStr[16];
        format(txdStr, sizeof(txdStr), "txd:bracsm%d", i-16);
        acsv2_fix_TD[i] = TextDrawCreate(430.0000, 100.0000, txdStr);
        TextDrawTextSize(acsv2_fix_TD[i], 180.0000, 230.0000);
        TextDrawAlignment(acsv2_fix_TD[i], 1);
        TextDrawColor(acsv2_fix_TD[i], -1);
        TextDrawBackgroundColor(acsv2_fix_TD[i], 255);
        TextDrawFont(acsv2_fix_TD[i], 4);
        TextDrawSetProportional(acsv2_fix_TD[i], 0);
        TextDrawSetShadow(acsv2_fix_TD[i], 0);
    }

    acsv2_fix_TD[24] = TextDrawCreate(460.0000, 205.0000, "ld_beat:up");
    TextDrawTextSize(acsv2_fix_TD[24], 45.0000, 45.0000);
    TextDrawAlignment(acsv2_fix_TD[24], 1);
    TextDrawColor(acsv2_fix_TD[24], 0xFFFFFF00);
    TextDrawBackgroundColor(acsv2_fix_TD[24], 255);
    TextDrawFont(acsv2_fix_TD[24], 4);
    TextDrawSetSelectable(acsv2_fix_TD[24], true);

    acsv2_fix_TD[25] = TextDrawCreate(530.0000, 205.0000, "ld_beat:up");
    TextDrawTextSize(acsv2_fix_TD[25], 45.0000, 45.0000);
    TextDrawAlignment(acsv2_fix_TD[25], 1);
    TextDrawColor(acsv2_fix_TD[25], 0xFFFFFF00);
    TextDrawBackgroundColor(acsv2_fix_TD[25], 255);
    TextDrawFont(acsv2_fix_TD[25], 4);
    TextDrawSetSelectable(acsv2_fix_TD[25], true);
    return 1;
}

stock SetPriceAccesory(playerid, acs)
{
    new string[32], moneyStringAcs[24];
    if(acs < 0 || acs >= sizeof(accessory)) return 0;
    ConvertMoneyACS(accessory[acs][PRICE_ACCESSORY], moneyStringAcs);
    format(string, sizeof string, "%s_руб.", moneyStringAcs);
    PlayerTextDrawSetString(playerid, acsmagaz_price_PTD[playerid][0], string);
    return 1;
}

stock Accessory_SaveEditedSlot(playerid)
{
    new slot = g_AccessoryEditorSlot[playerid];
    if(slot < 2 || slot >= MAX_ACTIVE_SLOTS) return 0;
    if(GetPlayerAccountID(playerid) <= 0) return 0;
    new acs = GetPVarInt(playerid, "acs_id");
    if(acs < 0 || acs >= sizeof(accessory)) return 0;
    new bone = GetPVarInt(playerid, "bone");
    new Float:x = GetPVarFloat(playerid, "edit_x");
    new Float:y = GetPVarFloat(playerid, "edit_y");
    new Float:z = GetPVarFloat(playerid, "edit_z");
    new Float:rx = GetPVarFloat(playerid, "edit_rX");
    new Float:ry = GetPVarFloat(playerid, "edit_rY");
    new Float:rz = GetPVarFloat(playerid, "edit_rZ");
    new Float:scale = GetPVarFloat(playerid, "edit_scale");
    new query[512];
    mysql_format(mysql, query, sizeof(query), "INSERT INTO `player_accessories` (`account_id`, `active_slot`, `accessory_id`, `bone`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `scale`) VALUES (%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f) ON DUPLICATE KEY UPDATE `accessory_id` = VALUES(`accessory_id`), `bone` = VALUES(`bone`), `x` = VALUES(`x`), `y` = VALUES(`y`), `z` = VALUES(`z`), `rx` = VALUES(`rx`), `ry` = VALUES(`ry`), `rz` = VALUES(`rz`), `scale` = VALUES(`scale`)", GetPlayerAccountID(playerid), slot, acs, bone, x, y, z, rx, ry, rz, scale);
    mysql_query(mysql, query);
    return 1;
}

stock Accessory_ApplyAndSaveSlot(playerid, activeSlot, accessoryId, bone)
{
    if(activeSlot < 2 || activeSlot >= MAX_ACTIVE_SLOTS) return 0;
    if(accessoryId < 0 || accessoryId >= sizeof(accessory)) return 0;

    new Float:x = 0.0, Float:y = 0.0, Float:z = 0.0;
    new Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, Float:scale = 1.0;

    if(GetPlayerAccountID(playerid) > 0)
    {
        new q[256];
        mysql_format(mysql, q, sizeof(q), "SELECT `x`,`y`,`z`,`rx`,`ry`,`rz`,`scale` FROM `player_accessories` WHERE `account_id` = %d AND `active_slot` = %d LIMIT 1", GetPlayerAccountID(playerid), activeSlot);
        new Cache:result = mysql_query(mysql, q);
        if(cache_num_rows() > 0)
        {
            x = cache_get_field_content_float(0, "x");
            y = cache_get_field_content_float(0, "y");
            z = cache_get_field_content_float(0, "z");
            rx = cache_get_field_content_float(0, "rx");
            ry = cache_get_field_content_float(0, "ry");
            rz = cache_get_field_content_float(0, "rz");
            scale = cache_get_field_content_float(0, "scale");
            if(scale <= 0.0) scale = 1.0;
        }
        cache_delete(result);

        new query[512];
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `player_accessories` (`account_id`, `active_slot`, `accessory_id`, `bone`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `scale`) VALUES (%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f) ON DUPLICATE KEY UPDATE `accessory_id` = VALUES(`accessory_id`), `bone` = VALUES(`bone`), `x` = VALUES(`x`), `y` = VALUES(`y`), `z` = VALUES(`z`), `rx` = VALUES(`rx`), `ry` = VALUES(`ry`), `rz` = VALUES(`rz`), `scale` = VALUES(`scale`)", GetPlayerAccountID(playerid), activeSlot, accessoryId, bone, x, y, z, rx, ry, rz, scale);
        mysql_query(mysql, query);
    }

    SetPlayerAttachedObject(playerid, activeSlot, accessory[accessoryId][ID_ACCESSORY], bone, x, y, z, rx, ry, rz, scale, scale, scale);
    return 1;
}

stock Accessory_OnEquipped(playerid, activeSlot, accessoryId)
{
    return Accessory_LoadAndApplySlot(playerid, activeSlot, accessoryId);
}

stock bool:Accessory_CanEquip(playerid, accessoryId)
{
    return true;
}

stock Accessory_OnUnequipped(playerid, activeSlot)
{
    if(activeSlot < 2 || activeSlot >= MAX_ACTIVE_SLOTS) return 0;
    if(IsPlayerAttachedObjectSlotUsed(playerid, activeSlot)) RemovePlayerAttachedObject(playerid, activeSlot);
    return 1;
}

stock Accessory_GetSlotAccessoryId(playerid, slot)
{
    if(slot < SLOT_ACCESSORY_START || slot > SLOT_ACCESSORY_END) return -1;
    if(GetItemType(g_PlayerActiveSlots[playerid][slot][inv_itemId]) != ITEM_TYPE_ACCESSORY) return -1;

    new acs = -1;
    if(g_PlayerActiveSlots[playerid][slot][inv_itemPlate][0] != 0) acs = strval(g_PlayerActiveSlots[playerid][slot][inv_itemPlate]);
    if(acs < 0 || acs >= sizeof(accessory)) acs = Accessory_GetAccIdByInvItem(g_PlayerActiveSlots[playerid][slot][inv_itemId]);
    if(acs < 0 || acs >= sizeof(accessory)) acs = g_PlayerActiveSlots[playerid][slot][inv_itemCount];
    if(acs < 0 || acs >= sizeof(accessory)) return -1;
    return acs;
}

stock Accessory_OnInventoryLoaded(playerid)
{
    new bool:needSave = false;

    for(new s = 2; s < MAX_ACTIVE_SLOTS; s++)
    {
        if(GetItemType(g_PlayerActiveSlots[playerid][s][inv_itemId]) == ITEM_TYPE_ACCESSORY)
        {
            new acs = -1;

            if(g_PlayerActiveSlots[playerid][s][inv_itemPlate][0] != 0)
            {
                acs = strval(g_PlayerActiveSlots[playerid][s][inv_itemPlate]);
            }

            if(acs < 0 || acs >= sizeof(accessory))
            {
                acs = Accessory_GetAccIdByInvItem(g_PlayerActiveSlots[playerid][s][inv_itemId]);
            }

            if(acs < 0 || acs >= sizeof(accessory))
            {
                acs = g_PlayerActiveSlots[playerid][s][inv_itemCount];
            }

            if(acs >= 0 && acs < sizeof(accessory))
            {
                new guiItemId = Accessory_GetInventoryItemId(acs);
                new acsPlate[12];
                valstr(acsPlate, acs);

                if(g_PlayerActiveSlots[playerid][s][inv_itemId] != guiItemId || strcmp(g_PlayerActiveSlots[playerid][s][inv_itemPlate], acsPlate, true) != 0)
                {
                    g_PlayerActiveSlots[playerid][s][inv_itemId] = guiItemId;
                    g_PlayerActiveSlots[playerid][s][inv_itemCount] = 1;
                    g_PlayerActiveSlots[playerid][s][inv_itemType] = ITEM_TYPE_ACCESSORY;
                    format(g_PlayerActiveSlots[playerid][s][inv_itemPlate], 32, "%s", acsPlate);
                    needSave = true;
                }

                Accessory_LoadAndApplySlot(playerid, s, acs);
            }
        }
        else
        {
            if(IsPlayerAttachedObjectSlotUsed(playerid, s)) RemovePlayerAttachedObject(playerid, s);
        }
    }

    if(needSave) Inventory_Save(playerid);
    return 1;
}

stock Accessory_OnPlayerSpawn(playerid)
{
    Accessory_LoadAllFromDB(playerid);
    return Accessory_OnInventoryLoaded(playerid);
}

stock Accessory_StopEditor(playerid, bool:save)
{
    if(g_AccessoryEditorSlot[playerid] < 2) return 0;
    if(save)
    {
        Accessory_SaveEditedSlot(playerid);
        Accessory_OnInventoryLoaded(playerid);
        Inventory_Save(playerid);
    }
    for(new i = 0; i < sizeof(acsv2_fix_TD); i++) TextDrawHideForPlayer(playerid, acsv2_fix_TD[i]);
    if(acsv2_coords_fix_PTD[playerid][0] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, acsv2_coords_fix_PTD[playerid][0]);
        acsv2_coords_fix_PTD[playerid][0] = PlayerText:INVALID_TEXT_DRAW;
    }
    CancelSelectTextDraw(playerid);
    g_AccessoryEditorSlot[playerid] = -1;
    DeletePVar(playerid, "acs_id");
    DeletePVar(playerid, "bone");
    DeletePVar(playerid, "edit_x");
    DeletePVar(playerid, "edit_y");
    DeletePVar(playerid, "edit_z");
    DeletePVar(playerid, "edit_rX");
    DeletePVar(playerid, "edit_rY");
    DeletePVar(playerid, "edit_rZ");
    DeletePVar(playerid, "edit_scale");
    DeletePVar(playerid, "acss_TD_use");
    if(g_WearFromInventory[playerid])
    {
        g_WearFromInventory[playerid] = 0;
        ShowPlayerInventory(playerid);
    }
    return 1;
}

stock Accessory_WearWithBone(playerid, accessoryId, invSlot, bone)
{
    new activeSlot = -1;

    for(new s = 2; s < MAX_ACTIVE_SLOTS; s++)
    {
        if(g_PlayerActiveSlots[playerid][s][inv_itemId] == 0)
        {
            activeSlot = s;
            break;
        }
    }

    if(activeSlot < 2 || activeSlot >= MAX_ACTIVE_SLOTS)
    {
        ShowNotificationSile(playerid, 2, 6, 0, 0, "Нет свободного слота для аксессуара", "");
        ShowPlayerInventory(playerid);
        return false;
    }

    new itemId = Accessory_GetInventoryItemId(accessoryId);
    new plateStr[12];
    valstr(plateStr, accessoryId);

    Inventory_SetActiveItem(playerid, activeSlot, itemId, 1, plateStr);
    Inventory_DeleteItem(playerid, invSlot);
    Inventory_Save(playerid);
    Accessory_ApplyAndSaveSlot(playerid, activeSlot, accessoryId, bone);
    ShowNotificationSile(playerid, 1, 6, 0, 0, "Аксессуар надет", "");
    return true;
}

stock Accessory_ShowWearDialog(playerid, accessoryId, invSlot)
{
    g_PendingAccessory[playerid] = accessoryId;
    g_PendingInvSlot[playerid] = invSlot;
    g_WearFromInventory[playerid] = 1;

    new dialogText[256];
    dialogText[0] = EOS;
    strcat(dialogText, "{DD5757}1. {FFFFFF}Отредактировать аксессуар\n");
    strcat(dialogText, "{DD5757}2. {FFFFFF}Изменить часть тела\n");
    strcat(dialogText, "{DD5757}3. {FFFFFF}Продолжить без изменений");

    ShowPlayerDialog(playerid, ACCESSORY_DIALOG_WEAR_CONFIRM, DIALOG_STYLE_LIST, "{DD5757}RAGE RUSSIA {FFFFFF}| Управление аксессуарами", dialogText, "Выбрать", "Закрыть");
}

stock bool:Accessory_UseFromInventory(playerid, invSlot)
{
    if(invSlot < 0 || invSlot >= MAX_INVENTORY_SLOTS) return false;
    if(GetItemType(g_PlayerInventory[playerid][invSlot][inv_itemId]) != ITEM_TYPE_ACCESSORY) return false;

    new accessoryId = -1;

    if(g_PlayerInventory[playerid][invSlot][inv_itemPlate][0] != EOS)
    {
        accessoryId = strval(g_PlayerInventory[playerid][invSlot][inv_itemPlate]);
    }

    if(accessoryId < 0 || accessoryId >= sizeof(accessory))
    {
        accessoryId = Accessory_GetAccIdByInvItem(g_PlayerInventory[playerid][invSlot][inv_itemId]);
    }

    if(accessoryId < 0 || accessoryId >= sizeof(accessory))
    {
        accessoryId = g_PlayerInventory[playerid][invSlot][inv_itemCount];
    }

    if(accessoryId < 0 || accessoryId >= sizeof(accessory))
    {
        ShowNotificationSile(playerid, 2, 6, 0, 0, "Ошибка: неизвестный аксессуар", "");
        return false;
    }

    Accessory_ShowWearDialog(playerid, accessoryId, invSlot);
    return true;
}

stock bool:Accessory_HandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused inputtext
    if(dialogid == ACCESSORY_DIALOG_WEAR_CONFIRM)
    {
        if(!response)
        {
            g_PendingAccessory[playerid] = -1;
            g_PendingInvSlot[playerid] = -1;
            g_WearFromInventory[playerid] = 0;
            ShowPlayerInventory(playerid);
            return true;
        }

        new accessoryId = g_PendingAccessory[playerid];
        new invSlot = g_PendingInvSlot[playerid];

        if(accessoryId < 0 || accessoryId >= sizeof(accessory) || invSlot < 0 || invSlot >= MAX_INVENTORY_SLOTS)
        {
            ShowNotificationSile(playerid, 2, 6, 0, 0, "Ошибка: аксессуар не найден", "");
            ShowPlayerInventory(playerid);
            g_PendingAccessory[playerid] = -1;
            g_PendingInvSlot[playerid] = -1;
            g_WearFromInventory[playerid] = 0;
            return true;
        }

        switch(listitem)
        {
            case 0:
            {
                new activeSlot = -1;
                for(new s = 2; s < MAX_ACTIVE_SLOTS; s++)
                {
                    if(g_PlayerActiveSlots[playerid][s][inv_itemId] == 0)
                    {
                        activeSlot = s;
                        break;
                    }
                }
                if(activeSlot < 2 || activeSlot >= MAX_ACTIVE_SLOTS)
                {
                    ShowNotificationSile(playerid, 2, 6, 0, 0, "Нет свободного слота для аксессуара", "");
                    ShowPlayerInventory(playerid);
                    g_PendingAccessory[playerid] = -1;
                    g_PendingInvSlot[playerid] = -1;
                    return true;
                }

                new plateStr[12];
                valstr(plateStr, accessoryId);
                Inventory_SetActiveItem(playerid, activeSlot, Accessory_GetInventoryItemId(accessoryId), 1, plateStr);
                Inventory_DeleteItem(playerid, invSlot);
                Inventory_Save(playerid);
                Accessory_ApplyAndSaveSlot(playerid, activeSlot, accessoryId, accessory[accessoryId][BONE_ACCESSORY]);
                Accessory_StartEditor(playerid, activeSlot);
                g_PendingAccessory[playerid] = -1;
                g_PendingInvSlot[playerid] = -1;
            }
            case 1:
            {
                new boneList[1024];
                boneList[0] = EOS;
                strcat(boneList, "{DD5757}1. {FFFFFF}Спина\n");
                strcat(boneList, "{DD5757}2. {FFFFFF}Голова\n");
                strcat(boneList, "{DD5757}3. {FFFFFF}Левое предплечье\n");
                strcat(boneList, "{DD5757}4. {FFFFFF}Правое предплечье\n");
                strcat(boneList, "{DD5757}5. {FFFFFF}Левая рука\n");
                strcat(boneList, "{DD5757}6. {FFFFFF}Правая рука\n");
                strcat(boneList, "{DD5757}7. {FFFFFF}Левое бедро\n");
                strcat(boneList, "{DD5757}8. {FFFFFF}Правое бедро\n");
                strcat(boneList, "{DD5757}9. {FFFFFF}Левая нога\n");
                strcat(boneList, "{DD5757}10. {FFFFFF}Правая нога\n");
                strcat(boneList, "{DD5757}11. {FFFFFF}Правая голень\n");
                strcat(boneList, "{DD5757}12. {FFFFFF}Левая голень\n");
                strcat(boneList, "{DD5757}13. {FFFFFF}Левое плечо\n");
                strcat(boneList, "{DD5757}14. {FFFFFF}Правое плечо\n");
                strcat(boneList, "{DD5757}15. {FFFFFF}Левая ключица\n");
                strcat(boneList, "{DD5757}16. {FFFFFF}Правая ключица\n");
                strcat(boneList, "{DD5757}17. {FFFFFF}Шея\n");
                strcat(boneList, "{DD5757}18. {FFFFFF}Челюсть");
                SetPVarInt(playerid, "temp_acc_id", accessoryId);
                SetPVarInt(playerid, "temp_inv_slot", invSlot);
                ShowPlayerDialog(playerid, ACCESSORY_DIALOG_BONE_SELECT, DIALOG_STYLE_LIST, "{DD5757}Выберите часть тела для аксессуара", boneList, "Выбрать", "Закрыть");
            }
            case 2:
            {
                Accessory_WearWithBone(playerid, accessoryId, invSlot, accessory[accessoryId][BONE_ACCESSORY]);
                g_PendingAccessory[playerid] = -1;
                g_PendingInvSlot[playerid] = -1;
                g_WearFromInventory[playerid] = 0;
                ShowPlayerInventory(playerid);
            }
        }
        return true;
    }
    if(dialogid == ACCESSORY_DIALOG_BONE_SELECT)
    {
        if(!response)
        {
            Accessory_ShowWearDialog(playerid, GetPVarInt(playerid, "temp_acc_id"), GetPVarInt(playerid, "temp_inv_slot"));
            DeletePVar(playerid, "temp_acc_id");
            DeletePVar(playerid, "temp_inv_slot");
            return true;
        }

        new bone = listitem + 1;
        SetPVarInt(playerid, "temp_bone", bone);

        new editText[192];
        editText[0] = EOS;
        strcat(editText, "{DD5757}1. {FFFFFF}Отредактировать аксессуар\n");
        strcat(editText, "{DD5757}2. {FFFFFF}Продолжить без изменений");

        ShowPlayerDialog(playerid, ACCESSORY_DIALOG_EDITOR_ACTION, DIALOG_STYLE_LIST, "{DD5757}RAGE RUSSIA {FFFFFF}| Управление аксессуарами", editText, "Выбрать", "Назад");
        return true;
    }
    if(dialogid == ACCESSORY_DIALOG_EDITOR_ACTION && GetPVarInt(playerid, "temp_bone") != 0)
    {
        if(!response)
        {
            Accessory_ShowWearDialog(playerid, GetPVarInt(playerid, "temp_acc_id"), GetPVarInt(playerid, "temp_inv_slot"));
            DeletePVar(playerid, "temp_acc_id");
            DeletePVar(playerid, "temp_inv_slot");
            DeletePVar(playerid, "temp_bone");
            return true;
        }

        new accessoryId = GetPVarInt(playerid, "temp_acc_id");
        new invSlot = GetPVarInt(playerid, "temp_inv_slot");
        new bone = GetPVarInt(playerid, "temp_bone");
        DeletePVar(playerid, "temp_acc_id");
        DeletePVar(playerid, "temp_inv_slot");
        DeletePVar(playerid, "temp_bone");

        if(accessoryId < 0 || accessoryId >= sizeof(accessory) || invSlot < 0 || invSlot >= MAX_INVENTORY_SLOTS) return true;

        new activeSlot = -1;
        for(new s = 2; s < MAX_ACTIVE_SLOTS; s++)
        {
            if(g_PlayerActiveSlots[playerid][s][inv_itemId] == 0)
            {
                activeSlot = s;
                break;
            }
        }

        if(activeSlot < 2 || activeSlot >= MAX_ACTIVE_SLOTS)
        {
            ShowNotificationSile(playerid, 2, 6, 0, 0, "Нет свободного слота для аксессуара", "");
            ShowPlayerInventory(playerid);
            return true;
        }

        new plateStr[12];
        valstr(plateStr, accessoryId);
        Inventory_SetActiveItem(playerid, activeSlot, Accessory_GetInventoryItemId(accessoryId), 1, plateStr);
        Inventory_DeleteItem(playerid, invSlot);
        Inventory_Save(playerid);
        Accessory_ApplyAndSaveSlot(playerid, activeSlot, accessoryId, bone);

        if(listitem == 0)
        {
            Accessory_StartEditor(playerid, activeSlot);
            SetPVarInt(playerid, "bone", bone);
            SetPlayerAttachedObject(playerid, activeSlot, accessory[accessoryId][ID_ACCESSORY], bone, GetPVarFloat(playerid, "edit_x"), GetPVarFloat(playerid, "edit_y"), GetPVarFloat(playerid, "edit_z"), GetPVarFloat(playerid, "edit_rX"), GetPVarFloat(playerid, "edit_rY"), GetPVarFloat(playerid, "edit_rZ"), GetPVarFloat(playerid, "edit_scale"), GetPVarFloat(playerid, "edit_scale"), GetPVarFloat(playerid, "edit_scale"));
        }
        else if(listitem == 1)
        {
            ShowNotificationSile(playerid, 1, 6, 0, 0, "Аксессуар надет", "");
            g_WearFromInventory[playerid] = 0;
            ShowPlayerInventory(playerid);
        }
        return true;
    }
    if(dialogid == ACCESSORY_DIALOG_SLOT_SELECT)
    {
        if(!response) return true;
        new idx = 0;
        for(new s = 2; s < MAX_ACTIVE_SLOTS; s++)
        {
            if(GetItemType(g_PlayerActiveSlots[playerid][s][inv_itemId]) != ITEM_TYPE_ACCESSORY) continue;
            if(idx == listitem)
            {
                SetPVarInt(playerid, "acc_sel_slot", s);
                ShowPlayerDialog(playerid, ACCESSORY_DIALOG_EDITOR_ACTION, DIALOG_STYLE_TABLIST_HEADERS, "{E0584B}BAZE RUSSIA{FFFFFF} | Управление аксессуаром", "#\tДействие\n1\tРедактировать\n2\tСнять", "Выбрать", "Закрыть");
                return true;
            }
            idx++;
        }
        return true;
    }
    if(dialogid == ACCESSORY_DIALOG_EDITOR_ACTION && GetPVarInt(playerid, "acc_sel_slot") != -1)
    {
        if(!response) return true;
        new slot = GetPVarInt(playerid, "acc_sel_slot");
        if(slot < 2 || slot >= MAX_ACTIVE_SLOTS) return true;
        if(listitem == 0) Accessory_StartEditor(playerid, slot);
        else if(listitem == 1)
        {
            new freeSlot = Inventory_GetFreeSlot(playerid);
            if(freeSlot == -1) return SendClientMessage(playerid, 0xFF0000FF, "Инвентарь заполнен"), true;
            if(Inventory_MoveFromSlotToInv(playerid, g_PlayerActiveSlots[playerid][slot][inv_itemId], slot, freeSlot)) Inventory_Save(playerid);
        }
        DeletePVar(playerid, "acc_sel_slot");
        return true;
    }
    if(dialogid == ACCESSORY_DIALOG_BUY_CONFIRM)
    {
        if(!response)
        {
            Accessory_OpenMarket(playerid);
            return true;
        }
        new acs = GetPVarInt(playerid, "buy_acs_id");
        if(acs < 0 || acs >= sizeof(accessory))
        {
            ShowNotificationSile(playerid, 2, 6, 0, 0, "Ошибка", "");
            Accessory_OpenMarket(playerid);
            return true;
        }
        new price = accessory[acs][PRICE_ACCESSORY];
        if(GetPlayerMoneyEx(playerid) < price)
        {
            ShowNotificationSile(playerid, 0, 5, 0, 0, "Недостаточно денег", "");
            Accessory_OpenMarket(playerid);
            return true;
        }
        new itemId = Accessory_GetInventoryItemId(acs);
        if(GetPlayerWeight(playerid) + GetItemWeight(itemId) > GetPlayerMaxWeight(playerid))
        {
            ShowNotificationSile(playerid, 2, 6, 0, 0, "Инвентарь полон", "");
            Accessory_OpenMarket(playerid);
            return true;
        }
        // Was: Inventory_AddItem(playerid, itemId, 1) - a 3-arg overload
        // that doesn't exist (real signature: playerid, item_id, slot,
        // count, plate=""). Find a real free slot first, same as every
        // other buy flow in this project.
        new buyFreeSlot = Inventory_GetFreeSlot(playerid);
        if(buyFreeSlot == -1 || !Inventory_AddItem(playerid, itemId, buyFreeSlot, 1, ""))
        {
            ShowNotificationSile(playerid, 2, 6, 0, 0, "Инвентарь полон", "");
            Accessory_OpenMarket(playerid);
            return true;
        }
        // Was: Player[][pMoney] -= price; ResetPlayerMoney(); GivePlayerMoney();
        // + a manual "UPDATE players SET money" query - none of that exists
        // in the real codebase. GivePlayerMoneyEx(..., save=true) deducts
        // and persists the balance by itself.
        GivePlayerMoneyEx(playerid, -price, "Accessory purchase", true, true);
        Inventory_Save(playerid);
        ShowNotificationSile(playerid, 1, 6, 0, 0, "Аксессуар приобретён", "");
        Accessory_CloseMarket(playerid);
        ShowPlayerInventory(playerid);
        return true;
    }
    return false;
}

stock bool:Accessory_HandleTextDraw(playerid, Text:clickedid)
{
    if(g_AccessoryEditorSlot[playerid] < 2) return false;
    if(clickedid == acsv2_fix_TD[1]) { Accessory_StopEditor(playerid, false); return true; }
    if(clickedid == acsv2_fix_TD[2]) { Accessory_StopEditor(playerid, true); return true; }
    if(acsv2_fix_TD[3] <= clickedid <= acsv2_fix_TD[9])
    {
        new TD = -1;
        for(new i = 3; i < 10; i++) if(clickedid == acsv2_fix_TD[i]) { TD = i; break; }
        if(TD == -1) return false;
        new td_use = GetPVarInt(playerid, "acss_TD_use");
        new count_TD = TD - 3;
        TextDrawHideForPlayer(playerid, acsv2_fix_TD[9 + td_use]);
        TextDrawShowForPlayer(playerid, acsv2_fix_TD[2 + td_use]);
        TextDrawHideForPlayer(playerid, acsv2_fix_TD[16 + td_use]);
        TextDrawHideForPlayer(playerid, acsv2_fix_TD[3 + count_TD]);
        TextDrawShowForPlayer(playerid, acsv2_fix_TD[10 + count_TD]);
        TextDrawShowForPlayer(playerid, acsv2_fix_TD[17 + count_TD]);
        SetPVarInt(playerid, "acss_TD_use", count_TD + 1);
        new Float:float_count;
        switch(TD)
        {
            case 3: float_count = GetPVarFloat(playerid, "edit_x");
            case 4: float_count = GetPVarFloat(playerid, "edit_y");
            case 5: float_count = GetPVarFloat(playerid, "edit_z");
            case 6: float_count = GetPVarFloat(playerid, "edit_scale");
            case 7: float_count = GetPVarFloat(playerid, "edit_rX");
            case 8: float_count = GetPVarFloat(playerid, "edit_rY");
            case 9: float_count = GetPVarFloat(playerid, "edit_rZ");
        }
        new acs_coords[18];
        format(acs_coords, sizeof acs_coords, "%.4f", float_count);
        PlayerTextDrawSetString(playerid, acsv2_coords_fix_PTD[playerid][0], acs_coords);
        return true;
    }
    if(clickedid == acsv2_fix_TD[24] || clickedid == acsv2_fix_TD[25])
    {
        new delta = (clickedid == acsv2_fix_TD[24]) ? 1 : -1;
        new td_use = GetPVarInt(playerid, "acss_TD_use");
        new Float:newVal;
        new acs_coords[18];
        switch(td_use)
        {
            case 1:
            {
                newVal = GetPVarFloat(playerid, "edit_x") + (delta * 0.01);
                if(newVal > 0.5 || newVal < -0.5) return true;
                SetPVarFloat(playerid, "edit_x", newVal);
                format(acs_coords, sizeof acs_coords, "%.4f", newVal);
            }
            case 2:
            {
                newVal = GetPVarFloat(playerid, "edit_y") + (delta * 0.01);
                if(newVal > 1.0 || newVal < -1.0) return true;
                SetPVarFloat(playerid, "edit_y", newVal);
                format(acs_coords, sizeof acs_coords, "%.4f", newVal);
            }
            case 3:
            {
                newVal = GetPVarFloat(playerid, "edit_z") + (delta * 0.01);
                if(newVal > 0.5 || newVal < -0.5) return true;
                SetPVarFloat(playerid, "edit_z", newVal);
                format(acs_coords, sizeof acs_coords, "%.4f", newVal);
            }
            case 4:
            {
                newVal = GetPVarFloat(playerid, "edit_scale") + (delta * 0.1);
                if(newVal > 2.0 || newVal < 0.1) return true;
                SetPVarFloat(playerid, "edit_scale", newVal);
                format(acs_coords, sizeof acs_coords, "%.4f", newVal);
            }
            case 5:
            {
                newVal = GetPVarFloat(playerid, "edit_rX") + (delta * 5.0);
                if(newVal > 360.0) SetPVarFloat(playerid, "edit_rX", -5.0);
                else if(newVal < -360.0) SetPVarFloat(playerid, "edit_rX", 5.0);
                else SetPVarFloat(playerid, "edit_rX", newVal);
                format(acs_coords, sizeof acs_coords, "%.4f", GetPVarFloat(playerid, "edit_rX"));
            }
            case 6:
            {
                newVal = GetPVarFloat(playerid, "edit_rY") + (delta * 5.0);
                if(newVal > 360.0) SetPVarFloat(playerid, "edit_rY", -5.0);
                else if(newVal < -360.0) SetPVarFloat(playerid, "edit_rY", 5.0);
                else SetPVarFloat(playerid, "edit_rY", newVal);
                format(acs_coords, sizeof acs_coords, "%.4f", GetPVarFloat(playerid, "edit_rY"));
            }
            case 7:
            {
                newVal = GetPVarFloat(playerid, "edit_rZ") + (delta * 5.0);
                if(newVal > 360.0) SetPVarFloat(playerid, "edit_rZ", -5.0);
                else if(newVal < -360.0) SetPVarFloat(playerid, "edit_rZ", 5.0);
                else SetPVarFloat(playerid, "edit_rZ", newVal);
                format(acs_coords, sizeof acs_coords, "%.4f", GetPVarFloat(playerid, "edit_rZ"));
            }
        }
        PlayerTextDrawSetString(playerid, acsv2_coords_fix_PTD[playerid][0], acs_coords);
        SetPlayerAttachedObject(playerid, g_AccessoryEditorSlot[playerid], accessory[GetPVarInt(playerid, "acs_id")][ID_ACCESSORY], GetPVarInt(playerid, "bone"), GetPVarFloat(playerid, "edit_x"), GetPVarFloat(playerid, "edit_y"), GetPVarFloat(playerid, "edit_z"), GetPVarFloat(playerid, "edit_rX"), GetPVarFloat(playerid, "edit_rY"), GetPVarFloat(playerid, "edit_rZ"), GetPVarFloat(playerid, "edit_scale"), GetPVarFloat(playerid, "edit_scale"), GetPVarFloat(playerid, "edit_scale"));
        return true;
    }
    return false;
}

stock Accessory_OpenMarket(playerid) // was static: laird.pwn (business-entry handler) calls it
{
    if(acs_market_active[playerid]) return;
    acs_market_active[playerid] = true;
    pl_accessory[playerid] = 0;
    pl_id_accessory[playerid] = -1;
    SetPlayerPos(playerid, 2896.610839, 1496.067871, 2499.343750);
    SetPlayerFacingAngle(playerid, 355.015014);
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, 2000);
    InterpolateCameraPos(playerid, 2901.951660, 1498.124877, 2499.343750, 2900.450927, 1500.220703, 2499.363750, 2000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, 2903.739257, 1499.161499, 2499.343750, 2899.104980, 1503.386230, 2499.562500, 2000, CAMERA_MOVE);
    if(pl_id_accessory[playerid] != -1) DestroyPlayerObject(playerid, pl_id_accessory[playerid]);
    pl_id_accessory[playerid] = CreatePlayerObject(playerid, accessory[0][ID_ACCESSORY], 2899.104980, 1503.386230, 2499.062500, 0.0, 0.0, 0.0);
    if(!create_player_btn[playerid]) CreatePlTDButtonBR(playerid);
    SetPriceAccesory(playerid, 0);
    SelectTextDraw(playerid, 0xFF5252FF);
    for(new i; i < sizeof(acsmagaz_button_TD); i++) TextDrawShowForPlayer(playerid, acsmagaz_button_TD[i]);
    PlayerTextDrawShow(playerid, acsmagaz_price_PTD[playerid][0]);
    TogglePlayerControllable(playerid, false);
}

static Accessory_MarketNext(playerid)
{
    new acs = pl_accessory[playerid];
    if(acs < sizeof(accessory) - 1)
    {
        if(pl_id_accessory[playerid] != -1) DestroyPlayerObject(playerid, pl_id_accessory[playerid]);
        pl_id_accessory[playerid] = CreatePlayerObject(playerid, accessory[acs + 1][ID_ACCESSORY], 2899.104980, 1503.386230, 2499.062500, 0.0, 0.0, 0.0);
        pl_accessory[playerid] = acs + 1;
        SetPriceAccesory(playerid, acs + 1);
    }
}

static Accessory_MarketPrev(playerid)
{
    new acs = pl_accessory[playerid];
    if(acs > 0)
    {
        if(pl_id_accessory[playerid] != -1) DestroyPlayerObject(playerid, pl_id_accessory[playerid]);
        pl_id_accessory[playerid] = CreatePlayerObject(playerid, accessory[acs - 1][ID_ACCESSORY], 2899.104980, 1503.386230, 2499.062500, 0.0, 0.0, 0.0);
        pl_accessory[playerid] = acs - 1;
        SetPriceAccesory(playerid, acs - 1);
    }
}

stock bool:Accessory_MarketHandleTextDraw(playerid, Text:clickedid)
{
    if(!acs_market_active[playerid]) return false;
    if(clickedid == acsmagaz_button_TD[0]) { Accessory_MarketPrev(playerid); return true; }
    if(clickedid == acsmagaz_button_TD[1]) { Accessory_MarketNext(playerid); return true; }
    if(clickedid == acsmagaz_button_TD[3]) { Accessory_MarketBuy(playerid); return true; }
    if(clickedid == acsmagaz_button_TD[4]) { Accessory_CloseMarket(playerid); return true; }
    return false;
}

CMD:acs(playerid, params[])
{
    Accessory_OpenMarket(playerid);
    return 1;
}

CMD:myacs(playerid, params[])
{
    new list[1024];
    format(list, sizeof(list), "Слот\tАксессуар\n");
    new count = 0;
    for(new s = 2; s < MAX_ACTIVE_SLOTS; s++)
    {
        if(GetItemType(g_PlayerActiveSlots[playerid][s][inv_itemId]) != ITEM_TYPE_ACCESSORY) continue;
        new acs = -1;
        if(g_PlayerActiveSlots[playerid][s][inv_itemPlate][0] != 0) acs = strval(g_PlayerActiveSlots[playerid][s][inv_itemPlate]);
        if(acs < 0 || acs >= sizeof(accessory)) acs = Accessory_GetAccIdByInvItem(g_PlayerActiveSlots[playerid][s][inv_itemId]);
        if(acs < 0 || acs >= sizeof(accessory)) acs = g_PlayerActiveSlots[playerid][s][inv_itemCount];
        if(acs < 0 || acs >= sizeof(accessory)) continue;
        new row[128];
        format(row, sizeof(row), "%d\t%s\n", s-1, accessory[acs][NAME_ACCESSORY]);
        strcat(list, row, sizeof(list));
        count++;
    }
    if(count == 0) return SendClientMessage(playerid, -1, "У вас нет надетых аксессуаров.");
    ShowPlayerDialog(playerid, ACCESSORY_DIALOG_SLOT_SELECT, DIALOG_STYLE_TABLIST_HEADERS, "{E0584B}BAZE RUSSIA{FFFFFF} | Мои аксессуары", list, "Выбрать", "Закрыть");
    return 1;
}

CMD:accedit(playerid, params[])
{
    new slot;
    if(sscanf(params, "i", slot)) return SendClientMessage(playerid, -1, "Использование: /accedit [слот 1-6]");
    slot += 1;
    if(slot < 2 || slot >= MAX_ACTIVE_SLOTS) return SendClientMessage(playerid, -1, "Неверный слот (1-6)");
    if(GetItemType(g_PlayerActiveSlots[playerid][slot][inv_itemId]) != ITEM_TYPE_ACCESSORY) return SendClientMessage(playerid, -1, "В этом слоте нет аксессуара.");
    Accessory_StartEditor(playerid, slot);
    return 1;
}

stock Accessory_LoadAndApplySlot(playerid, activeSlot, accessoryId)
{
    if(activeSlot < 2 || activeSlot >= MAX_ACTIVE_SLOTS) return 0;
    if(accessoryId < 0 || accessoryId >= sizeof(accessory)) return 0;
    new bone = accessory[accessoryId][BONE_ACCESSORY];
    new Float:x = 0.0, Float:y = 0.0, Float:z = 0.0;
    new Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, Float:scale = 1.0;
    if(GetPlayerAccountID(playerid) > 0)
    {
        new q[256];
        mysql_format(mysql, q, sizeof(q), "SELECT `bone`,`x`,`y`,`z`,`rx`,`ry`,`rz`,`scale` FROM `player_accessories` WHERE `account_id` = %d AND `active_slot` = %d LIMIT 1", GetPlayerAccountID(playerid), activeSlot);
        new Cache:result = mysql_query(mysql, q);
        if(cache_num_rows() > 0)
        {
            bone = cache_get_field_content_int(0, "bone");
            x = cache_get_field_content_float(0, "x");
            y = cache_get_field_content_float(0, "y");
            z = cache_get_field_content_float(0, "z");
            rx = cache_get_field_content_float(0, "rx");
            ry = cache_get_field_content_float(0, "ry");
            rz = cache_get_field_content_float(0, "rz");
            scale = cache_get_field_content_float(0, "scale");
        }
        cache_delete(result);
    }
    SetPlayerAttachedObject(playerid, activeSlot, accessory[accessoryId][ID_ACCESSORY], bone, x, y, z, rx, ry, rz, scale, scale, scale);
    SetPVarInt(playerid, "acc_id_slot", accessoryId);
    SetPVarInt(playerid, "acc_bone_slot", bone);
    SetPVarFloat(playerid, "acc_x_slot", x);
    SetPVarFloat(playerid, "acc_y_slot", y);
    SetPVarFloat(playerid, "acc_z_slot", z);
    SetPVarFloat(playerid, "acc_rx_slot", rx);
    SetPVarFloat(playerid, "acc_ry_slot", ry);
    SetPVarFloat(playerid, "acc_rz_slot", rz);
    SetPVarFloat(playerid, "acc_scale_slot", scale);
    return 1;
}

stock Accessory_DeleteSlotFromDB(playerid, activeSlot)
{
    if(GetPlayerAccountID(playerid) <= 0) return 0;
    if(activeSlot < SLOT_ACCESSORY_START || activeSlot > SLOT_ACCESSORY_END) return 0;

    new query[160];
    mysql_format(mysql, query, sizeof(query), "DELETE FROM `player_accessories` WHERE `account_id` = %d AND `active_slot` = %d LIMIT 1", GetPlayerAccountID(playerid), activeSlot);
    mysql_query(mysql, query);
    return 1;
}

stock Accessory_SaveAllSlots(playerid)
{
    if(GetPlayerAccountID(playerid) <= 0) return 0;

    for(new slot = SLOT_ACCESSORY_START; slot <= SLOT_ACCESSORY_END; slot++)
    {
        new accessoryId = Accessory_GetSlotAccessoryId(playerid, slot);

        if(accessoryId < 0 || accessoryId >= sizeof(accessory))
        {
            Accessory_DeleteSlotFromDB(playerid, slot);
            continue;
        }

        new bone = accessory[accessoryId][BONE_ACCESSORY];
        new Float:x = 0.0, Float:y = 0.0, Float:z = 0.0;
        new Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, Float:scale = 1.0;

        new load_query[192];
        mysql_format(mysql, load_query, sizeof(load_query), "SELECT `bone`,`x`,`y`,`z`,`rx`,`ry`,`rz`,`scale` FROM `player_accessories` WHERE `account_id` = %d AND `active_slot` = %d LIMIT 1", GetPlayerAccountID(playerid), slot);
        new Cache:result = mysql_query(mysql, load_query);
        if(cache_num_rows() > 0)
        {
            bone = cache_get_field_content_int(0, "bone");
            x = cache_get_field_content_float(0, "x");
            y = cache_get_field_content_float(0, "y");
            z = cache_get_field_content_float(0, "z");
            rx = cache_get_field_content_float(0, "rx");
            ry = cache_get_field_content_float(0, "ry");
            rz = cache_get_field_content_float(0, "rz");
            scale = cache_get_field_content_float(0, "scale");
        }
        cache_delete(result);

        if(g_AccessoryEditorSlot[playerid] == slot && GetPVarInt(playerid, "acs_id") == accessoryId)
        {
            bone = GetPVarInt(playerid, "bone");
            x = GetPVarFloat(playerid, "edit_x");
            y = GetPVarFloat(playerid, "edit_y");
            z = GetPVarFloat(playerid, "edit_z");
            rx = GetPVarFloat(playerid, "edit_rX");
            ry = GetPVarFloat(playerid, "edit_rY");
            rz = GetPVarFloat(playerid, "edit_rZ");
            scale = GetPVarFloat(playerid, "edit_scale");
        }

        new query[512];
        mysql_format(mysql, query, sizeof(query), "INSERT INTO `player_accessories` (`account_id`, `active_slot`, `accessory_id`, `bone`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `scale`) VALUES (%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f) ON DUPLICATE KEY UPDATE `accessory_id` = VALUES(`accessory_id`), `bone` = VALUES(`bone`), `x` = VALUES(`x`), `y` = VALUES(`y`), `z` = VALUES(`z`), `rx` = VALUES(`rx`), `ry` = VALUES(`ry`), `rz` = VALUES(`rz`), `scale` = VALUES(`scale`)", GetPlayerAccountID(playerid), slot, accessoryId, bone, x, y, z, rx, ry, rz, scale);
        mysql_query(mysql, query);
    }
    return 1;
}

stock Accessory_LoadAllFromDB(playerid)
{
    if(GetPlayerAccountID(playerid) <= 0) return 0;
    new query[256];
    mysql_format(mysql, query, sizeof(query), "SELECT `active_slot`, `accessory_id`, `bone`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `scale` FROM `player_accessories` WHERE `account_id` = %d", GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query, "OnAccessoriesLoadedFromDB", "i", playerid);
    return 1;
}

forward OnAccessoriesLoadedFromDB(playerid);
public OnAccessoriesLoadedFromDB(playerid)
{
    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++)
    {
        new activeSlot = cache_get_field_content_int(i, "active_slot");
        new accessoryId = cache_get_field_content_int(i, "accessory_id");
        new bone = cache_get_field_content_int(i, "bone");
        new Float:x = cache_get_field_content_float(i, "x");
        new Float:y = cache_get_field_content_float(i, "y");
        new Float:z = cache_get_field_content_float(i, "z");
        new Float:rx = cache_get_field_content_float(i, "rx");
        new Float:ry = cache_get_field_content_float(i, "ry");
        new Float:rz = cache_get_field_content_float(i, "rz");
        new Float:scale = cache_get_field_content_float(i, "scale");

        if(activeSlot >= SLOT_ACCESSORY_START && activeSlot <= SLOT_ACCESSORY_END && accessoryId >= 0 && accessoryId < sizeof(accessory))
        {
            if(GetItemType(g_PlayerActiveSlots[playerid][activeSlot][inv_itemId]) == ITEM_TYPE_ACCESSORY)
            {
                SetPlayerAttachedObject(playerid, activeSlot, accessory[accessoryId][ID_ACCESSORY], bone, x, y, z, rx, ry, rz, scale, scale, scale);
            }
        }
    }
    return 1;
}

stock Accessory_StartEditor(playerid, activeSlot)
{
    if(activeSlot < 2 || activeSlot >= MAX_ACTIVE_SLOTS) return 0;
    if(GetItemType(g_PlayerActiveSlots[playerid][activeSlot][inv_itemId]) != ITEM_TYPE_ACCESSORY) return 0;
    new acs = -1;
    if(g_PlayerActiveSlots[playerid][activeSlot][inv_itemPlate][0] != 0) acs = strval(g_PlayerActiveSlots[playerid][activeSlot][inv_itemPlate]);
    if(acs < 0 || acs >= sizeof(accessory)) acs = Accessory_GetAccIdByInvItem(g_PlayerActiveSlots[playerid][activeSlot][inv_itemId]);
    if(acs < 0 || acs >= sizeof(accessory)) acs = g_PlayerActiveSlots[playerid][activeSlot][inv_itemCount];
    if(acs < 0 || acs >= sizeof(accessory)) return 0;

    new guiItemId = Accessory_GetInventoryItemId(acs);
    new acsPlate[12];
    valstr(acsPlate, acs);
    if(g_PlayerActiveSlots[playerid][activeSlot][inv_itemId] != guiItemId || strcmp(g_PlayerActiveSlots[playerid][activeSlot][inv_itemPlate], acsPlate, true) != 0)
    {
        g_PlayerActiveSlots[playerid][activeSlot][inv_itemId] = guiItemId;
        g_PlayerActiveSlots[playerid][activeSlot][inv_itemCount] = 1;
        g_PlayerActiveSlots[playerid][activeSlot][inv_itemType] = ITEM_TYPE_ACCESSORY;
        format(g_PlayerActiveSlots[playerid][activeSlot][inv_itemPlate], 32, "%s", acsPlate);
        Inventory_Save(playerid);
    }

    new bone = accessory[acs][BONE_ACCESSORY];
    new Float:x = 0.0, Float:y = 0.0, Float:z = 0.0;
    new Float:rX = 0.0, Float:rY = 0.0, Float:rZ = 0.0, Float:scale = 1.0;
    if(GetPlayerAccountID(playerid) > 0)
    {
        new q[196];
        mysql_format(mysql, q, sizeof(q), "SELECT `bone`,`x`,`y`,`z`,`rx`,`ry`,`rz`,`scale` FROM `player_accessories` WHERE `account_id` = %d AND `active_slot` = %d LIMIT 1", GetPlayerAccountID(playerid), activeSlot);
        new Cache:result = mysql_query(mysql, q);
        if(cache_num_rows())
        {
            bone = cache_get_field_content_int(0, "bone");
            x = cache_get_field_content_float(0, "x");
            y = cache_get_field_content_float(0, "y");
            z = cache_get_field_content_float(0, "z");
            rX = cache_get_field_content_float(0, "rx");
            rY = cache_get_field_content_float(0, "ry");
            rZ = cache_get_field_content_float(0, "rz");
            scale = cache_get_field_content_float(0, "scale");
        }
        cache_delete(result);
    }
    g_AccessoryEditorSlot[playerid] = activeSlot;
    DeletePVar(playerid, "acc_id_slot");
    DeletePVar(playerid, "acc_bone_slot");
    DeletePVar(playerid, "acc_x_slot");
    DeletePVar(playerid, "acc_y_slot");
    DeletePVar(playerid, "acc_z_slot");
    DeletePVar(playerid, "acc_rx_slot");
    DeletePVar(playerid, "acc_ry_slot");
    DeletePVar(playerid, "acc_rz_slot");
    DeletePVar(playerid, "acc_scale_slot");
    SetPVarInt(playerid, "acs_id", acs);
    SetPVarInt(playerid, "bone", bone);
    SetPVarFloat(playerid, "edit_x", x);
    SetPVarFloat(playerid, "edit_y", y);
    SetPVarFloat(playerid, "edit_z", z);
    SetPVarFloat(playerid, "edit_rX", rX);
    SetPVarFloat(playerid, "edit_rY", rY);
    SetPVarFloat(playerid, "edit_rZ", rZ);
    SetPVarFloat(playerid, "edit_scale", scale);
    SetPVarInt(playerid, "acss_TD_use", 1);
    SetPlayerAttachedObject(playerid, activeSlot, accessory[acs][ID_ACCESSORY], bone, x, y, z, rX, rY, rZ, scale, scale, scale);
    SelectTextDraw(playerid, -1);
    for(new i = 0; i < 11; i++) TextDrawShowForPlayer(playerid, acsv2_fix_TD[i]);
    TextDrawShowForPlayer(playerid, acsv2_fix_TD[17]);
    TextDrawShowForPlayer(playerid, acsv2_fix_TD[24]);
    TextDrawShowForPlayer(playerid, acsv2_fix_TD[25]);
    new acs_coords[18];
    format(acs_coords, sizeof acs_coords, "%.4f", x);
    if(acsv2_coords_fix_PTD[playerid][0] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, acsv2_coords_fix_PTD[playerid][0]);
    acsv2_coords_fix_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 521.3996, 292.8998, acs_coords);
    PlayerTextDrawLetterSize(playerid, acsv2_coords_fix_PTD[playerid][0], 0.3000, 1.6000);
    PlayerTextDrawAlignment(playerid, acsv2_coords_fix_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, acsv2_coords_fix_PTD[playerid][0], 0xFFFFFFFF);
    PlayerTextDrawBackgroundColor(playerid, acsv2_coords_fix_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, acsv2_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, acsv2_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, acsv2_coords_fix_PTD[playerid][0], 0);
    PlayerTextDrawShow(playerid, acsv2_coords_fix_PTD[playerid][0]);
    SetCameraBehindPlayer(playerid);
    return 1;
}

stock Accessory_GetLegacyInvItemIdByModel(modelid)
{
    switch(modelid)
    {
        case 676: return 917;
        case 10492: return 939;
        case 677: return 918;
        case 787: return 682;
        case 790: return 685;
        case 2655: return 914;
        case 2656: return 915;
        case 2657: return 916;
        case 4160: return 531;
        case 4161: return 532;
        case 4162: return 533;
        case 4163: return 534;
        case 4165: return 536;
        case 4196: return 490;
        case 4199: return 493;
        case 4200: return 494;
        case 14647: return 944;
        case 4203: return 497;
        case 4204: return 498;
        case 4205: return 499;
        case 4206: return 500;
        case 4207: return 501;
        case 4208: return 502;
        case 7329: return 393;
        case 7330: return 394;
        case 7331: return 395;
        case 7332: return 396;
        case 7333: return 397;
        case 7334: return 398;
        case 7336: return 400;
        case 7337: return 401;
        case 7338: return 402;
        case 7339: return 403;
        case 7341: return 405;
        case 7342: return 406;
        case 7343: return 407;
        case 7344: return 408;
        case 7345: return 409;
        case 7346: return 410;
        case 7347: return 411;
        case 7348: return 412;
        case 7349: return 413;
        case 7350: return 414;
        case 7351: return 415;
        case 7352: return 416;
        case 7353: return 417;
        case 7354: return 418;
        case 7355: return 419;
        case 7356: return 420;
        case 7357: return 421;
        case 7358: return 422;
        case 7359: return 423;
        case 7360: return 424;
        case 7362: return 426;
        case 7364: return 428;
        case 7367: return 431;
        case 7368: return 432;
        case 7369: return 433;
        case 7370: return 434;
        case 7371: return 435;
        case 7372: return 436;
        case 7374: return 438;
        case 7375: return 439;
        case 7376: return 440;
        case 7377: return 441;
        case 7378: return 442;
        case 7379: return 443;
        case 7380: return 444;
        case 7381: return 445;
        case 7382: return 446;
        case 7383: return 447;
        case 7384: return 448;
        case 7385: return 449;
        case 7386: return 450;
        case 7387: return 451;
        case 7390: return 454;
        case 7391: return 455;
        case 7392: return 456;
        case 7393: return 457;
        case 7394: return 458;
        case 7395: return 459;
        case 9824: return 660;
        case 9825: return 661;
        case 9826: return 662;
        case 9827: return 663;
        case 9828: return 664;
        case 11919: return 579;
        case 11922: return 582;
        case 11923: return 583;
        case 11925: return 585;
        case 13801: return 576;
        case 13803: return 578;
        case 13883: return 508;
        case 14574: return 509;
        case 14575: return 511;
        case 14589: return 513;
        case 14591: return 515;
        case 14592: return 516;
        case 14593: return 517;
        case 14596: return 520;
        case 14597: return 521;
        case 14598: return 522;
        case 14603: return 527;
        case 14791: return 949;
        case 14643: return 945;
        case 4702: return 946;
        case 13884: return 510;
        case 5378: return 470;
        case 5384: return 476;
        case 5383: return 475;
        case 5372: return 464;
        case 5374: return 466;
        case 5375: return 467;
        case 15144: return 145;
        case 15145: return 146;
        case 15146: return 147;
        case 15147: return 148;
        case 15148: return 149;
        case 15149: return 150;
        case 15150: return 155;
        case 15151: return 159;
        case 15152: return 151;
        case 15153: return 152;
        case 15154: return 153;
        case 15155: return 154;
        case 15157: return 160;
        case 15158: return 161;
        case 15159: return 158;
        case 15160: return 156;
        case 15161: return 157;
        case 16055: return 709;
        case 18232: return 169;
        case 18233: return 170;
        case 18243: return 180;
        case 18250: return 187;
        case 18263: return 200;
        case 18264: return 201;
        case 18273: return 210;
        case 18279: return 216;
        case 18285: return 220;
        case 18286: return 221;
        case 18346: return 263;
        case 18347: return 264;
        case 18348: return 265;
        case 18369: return 281;
        case 18375: return 287;
        case 18377: return 289;
        case 18378: return 290;
        case 18379: return 291;
        case 18383: return 295;
        case 18384: return 296;
        case 18385: return 297;
        case 18386: return 298;
        case 18389: return 301;
        case 18390: return 302;
        case 18391: return 303;
        case 18392: return 304;
        case 18396: return 308;
        case 18397: return 309;
        case 18399: return 311;
        case 18400: return 312;
        case 18401: return 313;
        case 18402: return 314;
        case 18403: return 315;
        case 18404: return 316;
        case 18409: return 321;
        case 18410: return 322;
        case 18411: return 323;
        case 18412: return 324;
        case 18414: return 326;
        case 18497: return 347;
        case 18498: return 348;
        case 18499: return 349;
        case 18500: return 350;
        case 18501: return 351;
        case 18502: return 352;
        case 18503: return 353;
        case 18504: return 354;
        case 18505: return 355;
        case 18506: return 356;
        case 18507: return 357;
        case 18508: return 358;
        case 18509: return 359;
        case 18510: return 360;
        case 18511: return 361;
        case 18512: return 362;
        case 18513: return 363;
        case 18514: return 364;
        case 18515: return 365;
        case 18516: return 366;
        case 18517: return 367;
        case 18518: return 368;
        case 18519: return 369;
        case 18520: return 370;
        case 18521: return 371;
        case 18522: return 372;
        case 18523: return 373;
        case 18524: return 374;
        case 18525: return 375;
        case 18526: return 376;
        case 18527: return 377;
        case 18528: return 378;
        case 18529: return 379;
        case 18530: return 380;
    }
    

    return 0;
}

stock Accessory_GetInventoryItemId(accessoryId)
{
    if(accessoryId < 0 || accessoryId >= sizeof(accessory)) return 0;

    new modelid = accessory[accessoryId][ID_ACCESSORY];

    // 1) Real BR accessory id list (was: an undeclared InventoryItemss[][]
    // table - a dangling symbol that doesn't exist anywhere in this file or
    // the real codebase; the real equivalent table is ipacket.inc's).
    new mappedItem = Accessory_GetItemIdByModel(modelid);
    if(mappedItem > 0) return mappedItem;

    // 2) Fallback for old/custom object models already present in this mod.
    new legacyItem = Accessory_GetLegacyInvItemIdByModel(modelid);
    if(legacyItem > 0) return legacyItem;

    return INVENTORY_ACCESSORY_ITEM_BASE + accessoryId;
}

stock Accessory_GetAccIdByInvItem(itemId)
{
    // First check BR accessory ids from acsessory.inc: item_id -> object model -> local accessory index.
    // This is the important part for donate/BP/reward: inventory keeps the BR item id,
    // while item_plate keeps the local accessory index for wearing/editing.
    new modelid = Accessory_GetModelIdByItemId(itemId); // was: IsItemAccessoryy() - undefined anywhere; this is the real ipacket.inc lookup it was meant to call
    if(modelid > 0)
    {
        new mappedAcs = Accessory_GetIndexByModelId(modelid);
        if(mappedAcs >= 0) return mappedAcs;
    }

    for(new i = 0; i < sizeof(accessory); i++)
    {
        if(Accessory_GetInventoryItemId(i) == itemId) return i;
    }

    if(itemId >= INVENTORY_ACCESSORY_ITEM_BASE && itemId < INVENTORY_ACCESSORY_ITEM_LIMIT)
    {
        new acs = itemId - INVENTORY_ACCESSORY_ITEM_BASE;
        if(acs >= 0 && acs < sizeof(accessory)) return acs;
    }

    return -1;
}


static Accessory_MarketBuy(playerid)
{
    if(!acs_market_active[playerid]) return;
    new acs = pl_accessory[playerid];
    if(acs < 0 || acs >= sizeof(accessory)) return;
    
    new price = accessory[acs][PRICE_ACCESSORY];
    
    if(GetPlayerMoneyEx(playerid) < price)
    {
        ShowNotificationSile(playerid, 0, 5, 0, 0, "Недостаточно денег", "");
        return;
    }
    
    new itemId = Accessory_GetInventoryItemId(acs);
    
    if(GetPlayerWeight(playerid) + GetItemWeight(itemId) > GetPlayerMaxWeight(playerid))
    {
        ShowNotificationSile(playerid, 2, 6, 0, 0, "Инвентарь полон", "");
        return;
    }
    
    // Was: Inventory_AddAccessoryItem(playerid, acs, itemId) - never
    // implemented anywhere (only forward-declared in the dropped
    // acsessory.inc). Use the real Inventory_GetFreeSlot + Inventory_AddItem
    // pair instead, same as every other buy flow in this project.
    new mbFreeSlot = Inventory_GetFreeSlot(playerid);
    if(mbFreeSlot == -1 || !Inventory_AddItem(playerid, itemId, mbFreeSlot, 1, ""))
    {
        ShowNotificationSile(playerid, 2, 6, 0, 0, "Инвентарь полон", "");
        return;
    }
    
    // Was: Player[][pMoney] -= price; ResetPlayerMoney(); GivePlayerMoney();
    // + a manual "UPDATE players SET money" query - none of that exists in
    // the real codebase. GivePlayerMoneyEx(..., save=true) deducts and
    // persists the balance by itself.
    GivePlayerMoneyEx(playerid, -price, "Accessory purchase", true, true);
    
    Inventory_Save(playerid);
    ShowNotificationSile(playerid, 1, 6, 0, 0, "Аксессуар приобретён", "");
    Accessory_CloseMarket(playerid);
    ShowPlayerInventory(playerid);
}

static Accessory_CloseMarket(playerid)
{
    if(pl_id_accessory[playerid] != -1)
    {
        DestroyPlayerObject(playerid, pl_id_accessory[playerid]);
        pl_id_accessory[playerid] = -1;
    }
    for(new i; i < sizeof(acsmagaz_button_TD); i++) TextDrawHideForPlayer(playerid, acsmagaz_button_TD[i]);
    PlayerTextDrawHide(playerid, acsmagaz_price_PTD[playerid][0]);
    CancelSelectTextDraw(playerid);
    TogglePlayerControllable(playerid, true);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, 846.602600, 796.555847, 13.400512);
    SetPlayerFacingAngle(playerid, 69.896881);
    SetCameraBehindPlayer(playerid);
    acs_market_active[playerid] = false;
}
