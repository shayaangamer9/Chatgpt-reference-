// File: invtrunk.pwn
#define MAX_VEH_TRUNK_SLOTS 80
/* 1 trunk, 2 closet, 3 fam storage */
enum E_TRUNK_ITEM_STRUCT
{
    trunk_carId,
    trunk_itemId,
    trunk_itemCount,
    trunk_itemSlot,
    trunk_itemPlate[32],
    trunk_itemType
}

new g_vehicle_trunk_data[MAX_VEHICLES][MAX_VEH_TRUNK_SLOTS][E_TRUNK_ITEM_STRUCT];

stock Trunk_LoadVehicle(vehicleid, oc_id)
{
    new query[256];
    new Cache:result;
    new rows;
    
    for(new i = 0; i < MAX_VEH_TRUNK_SLOTS; i++)
    {
        g_vehicle_trunk_data[vehicleid][i][trunk_itemId] = 0;
        g_vehicle_trunk_data[vehicleid][i][trunk_itemCount] = 0;
        g_vehicle_trunk_data[vehicleid][i][trunk_itemSlot] = i;
        g_vehicle_trunk_data[vehicleid][i][trunk_itemPlate][0] = 0;
        g_vehicle_trunk_data[vehicleid][i][trunk_itemType] = 0;
    }
    
    mysql_format(mysql, query, sizeof(query), 
        "SELECT * FROM trunks WHERE oc_id = %d ORDER BY slot ASC", oc_id);
    result = mysql_query(mysql, query, true);
    rows = cache_num_rows();
    
    for(new i = 0; i < rows && i < MAX_VEH_TRUNK_SLOTS; i++)
    {
        new slot = cache_get_field_content_int(i, "slot");
        if(slot >= 0 && slot < MAX_VEH_TRUNK_SLOTS)
        {
            g_vehicle_trunk_data[vehicleid][slot][trunk_itemId] = cache_get_field_content_int(i, "item_id");
            g_vehicle_trunk_data[vehicleid][slot][trunk_itemCount] = cache_get_field_content_int(i, "amount");
            g_vehicle_trunk_data[vehicleid][slot][trunk_itemSlot] = slot;
            g_vehicle_trunk_data[vehicleid][slot][trunk_itemType] = cache_get_field_content_int(i, "item_type");
            cache_get_field_content(i, "item_plate", g_vehicle_trunk_data[vehicleid][slot][trunk_itemPlate], 32);
        }
    }
    
    cache_delete(result);
    return 1;
}

stock Trunk_SaveVehicle(vehicleid, oc_id)
{
    new query[256];
    new Cache:result;
    new rows;
    
    for(new i = 0; i < MAX_VEH_TRUNK_SLOTS; i++)
    {
        if(g_vehicle_trunk_data[vehicleid][i][trunk_itemId] > 0)
        {
            mysql_format(mysql, query, sizeof(query), 
                "SELECT id FROM trunks WHERE oc_id = %d AND slot = %d LIMIT 1", 
                oc_id, i);
            result = mysql_query(mysql, query, true);
            rows = cache_num_rows();
            
            if(rows > 0)
            {
                mysql_format(mysql, query, sizeof(query),
                    "UPDATE trunks SET item_id = %d, amount = %d, item_type = %d, item_plate = '%e', WHERE oc_id = %d AND slot = %d",
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemId],
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemCount],
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemType],
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemPlate],
                    oc_id, i);
                mysql_query(mysql, query, false);
            }
            else
            {
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO trunks (oc_id, slot, item_id, amount, item_type, item_plate) VALUES (%d, %d, %d, %d, %d, '%e')",
                    oc_id, i,
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemId],
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemCount],
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemType],
                    g_vehicle_trunk_data[vehicleid][i][trunk_itemPlate]);
                mysql_query(mysql, query, false);
            }
            
            cache_delete(result);
        }
        else
        {
            mysql_format(mysql, query, sizeof(query), 
                "DELETE FROM trunks WHERE oc_id = %d AND slot = %d", 
                oc_id, i);
            mysql_query(mysql, query, false);
        }
    }
    return 1;
}

stock Trunk_AddItems(vehicleid, slot, item_id, count, const plate[] = "")
{
    if(slot < 0 || slot >= MAX_VEH_TRUNK_SLOTS) return 0;
    
    g_vehicle_trunk_data[vehicleid][slot][trunk_itemId] = item_id;
    g_vehicle_trunk_data[vehicleid][slot][trunk_itemCount] = count;
    g_vehicle_trunk_data[vehicleid][slot][trunk_itemSlot] = slot;
    g_vehicle_trunk_data[vehicleid][slot][trunk_itemType] = GetItemType(item_id);
    
    if(strlen(plate) > 0)
        format(g_vehicle_trunk_data[vehicleid][slot][trunk_itemPlate], 32, plate);
    
    return 1;
}

stock Trunk_RemoveOneItem(vehicleid, slot)
{
    if(slot < 0 || slot >= MAX_VEH_TRUNK_SLOTS) return 0;
    if(g_vehicle_trunk_data[vehicleid][slot][trunk_itemId] == 0) return 0;
    
    new current_count = g_vehicle_trunk_data[vehicleid][slot][trunk_itemCount];
    
    if(current_count <= 1)
    {
        g_vehicle_trunk_data[vehicleid][slot][trunk_itemId] = 0;
        g_vehicle_trunk_data[vehicleid][slot][trunk_itemCount] = 0;
        g_vehicle_trunk_data[vehicleid][slot][trunk_itemSlot] = slot;
        g_vehicle_trunk_data[vehicleid][slot][trunk_itemPlate][0] = 0;
        g_vehicle_trunk_data[vehicleid][slot][trunk_itemType] = 0;
        
        new query[256];
        new oc_id = GetVehicleData(vehicleid, V_ACTION_ID);
        
        if(oc_id != -1)
        {
            mysql_format(mysql, query, sizeof(query), 
                "DELETE FROM trunks WHERE oc_id = %d AND slot = %d",
                GetOwnableCarData(oc_id, OC_SQL_ID), slot);
            mysql_query(mysql, query, false);
        }
    }
    else
    {
        new new_count = current_count - 1;
        g_vehicle_trunk_data[vehicleid][slot][trunk_itemCount] = new_count;
        
        new query[256];
        new oc_id = GetVehicleData(vehicleid, V_ACTION_ID);
        
        if(oc_id != -1)
        {
            mysql_format(mysql, query, sizeof(query), 
                "UPDATE trunks SET amount = %d WHERE oc_id = %d AND slot = %d",
                new_count, GetOwnableCarData(oc_id, OC_SQL_ID), slot);
            mysql_query(mysql, query, false);
        }
    }
    
    return 1;
}

stock Trunk_RemoveItem(vehicleid, slot, count)
{
    for(new i = 0; i < count; i++)
    {
        if(!Trunk_RemoveOneItem(vehicleid, slot))
            return 0;
    }
    return 1;
}

stock Trunk_GetFreeSlot(vehicleid)
{
    for(new i = 0; i < MAX_VEH_TRUNK_SLOTS; i++)
    {
        if(g_vehicle_trunk_data[vehicleid][i][trunk_itemId] == 0)
        {
            return i;
        }
    }
    return -1;
}

stock Trunk_Reset(vehicleid)
{
	for(new i = 0; i < MAX_VEH_TRUNK_SLOTS; i++)
	{
   	g_vehicle_trunk_data[vehicleid][i][trunk_itemId] = 0;
   	g_vehicle_trunk_data[vehicleid][i][trunk_itemCount] = 0;
   	g_vehicle_trunk_data[vehicleid][i][trunk_itemSlot] = i;
   	g_vehicle_trunk_data[vehicleid][i][trunk_itemType] = 0;
       g_vehicle_trunk_data[vehicleid][i][trunk_itemPlate] = 0;
    } 
    return 1;
}

stock Trunk_DeleteItemCompletely(vehicleid, slot)
{
    if(slot < 0 || slot >= MAX_VEH_TRUNK_SLOTS) return 0;
    if(g_vehicle_trunk_data[vehicleid][slot][trunk_itemId] == 0) return 0;
    
    new item_id = g_vehicle_trunk_data[vehicleid][slot][trunk_itemId];
    new count = g_vehicle_trunk_data[vehicleid][slot][trunk_itemCount];

    g_vehicle_trunk_data[vehicleid][slot][trunk_itemId] = 0;
	g_vehicle_trunk_data[vehicleid][slot][trunk_itemCount] = 0;
	g_vehicle_trunk_data[vehicleid][slot][trunk_itemSlot] =slot;
	g_vehicle_trunk_data[vehicleid][slot][trunk_itemType] = 0;
    g_vehicle_trunk_data[vehicleid][slot][trunk_itemPlate] = 0;
    
    new query[256];
    new oc_id = GetVehicleData(vehicleid, V_ACTION_ID);
    mysql_format(mysql, query, sizeof(query), 
        "DELETE FROM `trunks` WHERE `oc_id` = %d AND `slot` = %d",
        GetOwnableCarData(oc_id, OC_SQL_ID), slot);
    mysql_tquery(mysql, query);
    
    return 1;
}

stock ShowPlayerCarTrunkGUI(playerid, vehicleid)
{
    new Node:json = JSON_Object(), 
        Node:tempArray, 
        Node:itemsArray = JSON_Array(), 
        Node:activeSlotsArray = JSON_Array(), 
        Node:trunkSlotsArray = JSON_Array();
    
    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(g_PlayerInventory[playerid][i][inv_itemId] > 0)
        {
            new itemId = g_PlayerInventory[playerid][i][inv_itemId];
            
            if(itemId == 59 || itemId == 81 || itemId == 82 || itemId == 83)
            {
                tempArray = JSON_Array(
                    JSON_Int(itemId),
                    JSON_String(g_PlayerInventory[playerid][i][inv_itemPlate]),
                    JSON_Int(i),
                    JSON_Int(0)
                );
            }
            else
            {
                tempArray = JSON_Array(
                    JSON_Int(itemId),
                    JSON_Int(g_PlayerInventory[playerid][i][inv_itemCount]), 
                    JSON_Int(i),
                    JSON_Int(0)
                );
            }
            
            itemsArray = JSON_Append(itemsArray, tempArray);
        }
    }
    
    for(new i = 0; i < MAX_ACTIVE_SLOTS; i++)
    {
        if(g_PlayerActiveSlots[playerid][i][inv_itemId] > 0)
        {
            new itemId = g_PlayerActiveSlots[playerid][i][inv_itemId];
            new itemCount = g_PlayerActiveSlots[playerid][i][inv_itemCount];
            
            if(itemId == 134)
            {
                tempArray = JSON_Array(
                    JSON_Int(134),
                    JSON_Int(GetPlayerSkin(playerid)),
                    JSON_Int(6),
                    JSON_Int(0)
                );
            }
            else
            {
                tempArray = JSON_Array(
                    JSON_Int(itemId),
                    JSON_Int(itemCount),
                    JSON_Int(i),
                    JSON_Int(0)
                );
            }
            
            if(strlen(g_PlayerActiveSlots[playerid][i][inv_itemPlate]) > 0)
            {
                JSON_SetString(tempArray, "nt", g_PlayerActiveSlots[playerid][i][inv_itemPlate]);
            }
            
            activeSlotsArray = JSON_Append(activeSlotsArray, tempArray);
        }
    }
    
    for(new i = 0; i < MAX_VEH_TRUNK_SLOTS; i++)
    {
        if(g_vehicle_trunk_data[vehicleid][i][trunk_itemId] > 0)
        {
            new itemId = g_vehicle_trunk_data[vehicleid][i][trunk_itemId];
            
            if(itemId == 59 || itemId == 81 || itemId == 82 || itemId == 83)
            {
                tempArray = JSON_Array(
                    JSON_Int(itemId),
                    JSON_String(g_vehicle_trunk_data[vehicleid][i][trunk_itemPlate]),
                    JSON_Int(i),
                    JSON_Int(0)
                );
            }
            else
            {
                tempArray = JSON_Array(
                    JSON_Int(itemId),
                    JSON_Int(g_vehicle_trunk_data[vehicleid][i][trunk_itemCount]),
                    JSON_Int(i),
                    JSON_Int(0)
                );
            }
            
            trunkSlotsArray = JSON_Append(trunkSlotsArray, tempArray);
        }
    }
    
    json = JSON_Object
    (
        "o", JSON_Int(1),
        "tb", JSON_Int(0),
        "w", JSON_Int(0),
        "mw", JSON_Int(150),
        "bw", JSON_Int(0),
        "cw", JSON_Int(1500),
        "sl", JSON_Int(40),
        "nm", JSON_Int(GetPlayerPhone(playerid)), 
        "it", itemsArray,
        "sb", JSON_Int(80),
        "ai", activeSlotsArray, 
        "ic", trunkSlotsArray
    );
    
    SetPVarInt(playerid, "typeinv", 1);
    SendPacketToClient(playerid, 34, json);
    JSON_Cleanup(json);
    return 1;
}

CMD:trunk(playerid)
{
    new vehicleid = INVALID_VEHICLE_ID;
    new Float: x, Float: y, Float: z;
    new Float: angle, Float: distance;
    
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(!IsValidVehicle(i)) continue;
        
        GetCoordVehicle(i, VEHICLE_COORD_TYPE_BOOT, x, y, z, angle, distance);
        
        if(IsPlayerInRangeOfPoint(playerid, 2.0, x, y, z))
        {
            vehicleid = i;
            break;
        }
    }
    
    if(vehicleid == INVALID_VEHICLE_ID)
        return SendClientMessage(playerid, 0x999999FF, "You must stand near the vehicle's trunk!");
        
    if(IsAOwnableCar(vehicleid))
    {
        new index = GetVehicleData(vehicleid, V_ACTION_ID);
        if(GetOwnableCarData(index, OC_OWNER_ID) != GetPlayerAccountID(playerid))
        {
            return SendClientMessage(playerid, 0x999999FF, "This is not your vehicle!");
        }
    }
    else
    {
        return SendClientMessage(playerid, 0x999999FF, "This vehicle does not support a trunk!");
    }
    
    ShowPlayerCarTrunkGUI(playerid, vehicleid);
    return 1;
}

CMD:givetrunk(playerid, params[])
{
    if(strcmp(GetPlayerNameEx(playerid), "Danya_Coder", true) != 0) 
        return ShowNotificationSile(playerid, 2, 6, -1, -1, "The command you entered was not found", "");
    
    new vehicleid, item_id, count, slot;
    
    if(sscanf(params, "iii", vehicleid, item_id, count))
    {
        SendClientMessage(playerid, -1, "Usage: /givetrunk [vehicleid] [item_id] [count]");
        return 1;
    }
    
    if(vehicleid < 1 || vehicleid >= MAX_VEHICLES)
    {
        SendClientMessage(playerid, -1, "Invalid vehicle ID");
        return 1;
    }
    
    if(!IsValidVehicle(vehicleid))
    {
        SendClientMessage(playerid, -1, "Vehicle does not exist");
        return 1;
    }
    
    if(item_id <= 0 || count <= 0 || count > 1000)
    {
        SendClientMessage(playerid, -1, "Invalid item ID or quantity (1-1000)");
        return 1;
    }
    slot = Trunk_GetFreeSlot(vehicleid);
    if(slot == -1)
    {
        SendClientMessage(playerid, -1, "Trunk is full!");
        return 1;
    }
    new index = GetVehicleData(vehicleid, V_ACTION_ID);
    if(index == -1)
    {
        SendClientMessage(playerid, -1, "This vehicle does not support a trunk");
        return 1;
    }
    
    new sql_id = GetOwnableCarData(index, OC_SQL_ID);
    new item_name[64];
    
    Trunk_AddItems(vehicleid, slot, item_id, count, "");
    Trunk_SaveVehicle(vehicleid, index);
    
    new msg[128];
    format(msg, sizeof(msg), "You gave vehicle ID %d item %d in quantity %d pcs. (slot %d)", 
        vehicleid, item_id, count, slot);
    SendClientMessage(playerid, -1, msg);
    
    return 1;
}

stock PacketIncomingTrunkOrCloset(playerid, Node:JSONObject)
{
    new Node:response = JSON_Object();
    new type, item_id, count, old_pos, pos, item_plate[32];
    
    JSON_GetInt(JSONObject, "t", type);
    
    switch(type)
    {
        case 0: // From inventory to trunk
        {
            JSON_GetInt(JSONObject, "ga", item_id);
            JSON_GetInt(JSONObject, "os", old_pos);
            JSON_GetInt(JSONObject, "ns", pos);
            JSON_GetInt(JSONObject, "v", count); 
   
            new vehicleid = GetNearestVehicleID(playerid, 5.0), skin_model = g_PlayerInventory[playerid][old_pos][inv_itemCount];
            new debug_msg[256];
            
            if(vehicleid == INVALID_VEHICLE_ID)
            {
                format(debug_msg, sizeof(debug_msg), "Error: Vehicle not found (Item ID: %d)", item_id);
                ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                JSON_SetInt(response, "t", 0);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(IsAOwnableCar(vehicleid))
            {
                new index = GetVehicleData(vehicleid, V_ACTION_ID);
                if(GetOwnableCarData(index, OC_OWNER_ID) != GetPlayerAccountID(playerid))
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Not your vehicle (Item ID: %d)", item_id);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 0);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
            }
            else
            {
                format(debug_msg, sizeof(debug_msg), "Error: Not a personal vehicle (Item ID: %d)", item_id);
                ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                JSON_SetInt(response, "t", 0);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(item_id == 134)  // Skin ID
            {
                if(!IsValidSkinModel(skin_model))
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Invalid skin (model: %d, slot: %d)", skin_model, old_pos);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 0);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
                Trunk_AddItems(vehicleid, pos, 134, skin_model, "");
                Inventory_DeleteItemCompletely(playerid, old_pos);
                
                format(debug_msg, sizeof(debug_msg), "Skin moved (model: %d, slot %d -> %d)", skin_model, old_pos, pos);
                ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
            }
            else if(item_id == 58)  // SIM card
            {
                if(g_PlayerInventory[playerid][old_pos][inv_itemId] != item_id)
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Item not in slot (expected %d, slot %d)", item_id, old_pos);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 0);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
                new phone_number = g_PlayerInventory[playerid][old_pos][inv_itemCount];
                Inventory_DeleteItemCompletely(playerid, old_pos);
                Trunk_AddItems(vehicleid, pos, item_id, phone_number, "");
                
                new index = GetVehicleData(vehicleid, V_ACTION_ID);
                new sql_id = GetOwnableCarData(index, OC_SQL_ID);
                
                new query[512];
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO trunks (oc_id, slot, item_id, amount, item_type, item_plate) VALUES (%d, %d, %d, %d, %d, '%e')",
                    sql_id, pos, item_id, count, GetItemType(item_id), item_plate);
                mysql_query(mysql, query, false);
                
                format(debug_msg, sizeof(debug_msg), "SIM card moved (ID: %d, amount: %d, slot %d -> %d)", item_id, phone_number, old_pos, pos);
                ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
            }
            else if(item_id == 59 || item_id == 83)  // Plates with region (e.g. "A123AA 52")
    {
        new fmtn[32];
        format(fmtn, sizeof(fmtn), "%s", g_PlayerInventory[playerid][old_pos][inv_itemPlate]);
        Trunk_AddItems(vehicleid, pos, item_id, 1, fmtn);
        Inventory_DeleteItemCompletely(playerid, old_pos);
        
        format(debug_msg, sizeof(debug_msg), "License plate moved (type: %d, plate: %s, slot %d -> %d)", item_id, fmtn, old_pos, pos);
        ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
    } 
    else if(item_id == 81 || item_id == 82)  // Plates without region (e.g. "A123AA")
    {
        new fmtn[32];
        format(fmtn, sizeof(fmtn), "%s", g_PlayerInventory[playerid][old_pos][inv_itemPlate]);
        
        Trunk_AddItems(vehicleid, pos, item_id, 1, fmtn);
        Inventory_DeleteItemCompletely(playerid, old_pos);
        
        format(debug_msg, sizeof(debug_msg), "License plate moved (type: %d, plate: %s, slot %d -> %d)", item_id, fmtn, old_pos, pos);
        ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
    }
            else
            {
                if(g_PlayerInventory[playerid][old_pos][inv_itemId] != item_id)
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Item ID mismatch (expected %d, found in slot %d)", item_id, old_pos);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 0);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
                
                if(g_PlayerInventory[playerid][old_pos][inv_itemCount] < count)
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Not enough items (need %d, have %d, ID: %d)", count, g_PlayerInventory[playerid][old_pos][inv_itemCount], item_id);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 0);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
                
                format(item_plate, 32, g_PlayerInventory[playerid][old_pos][inv_itemPlate]);
                
                new found_slot = -1;
                for(new i = 0; i < MAX_VEH_TRUNK_SLOTS; i++)
                {
                    if(g_vehicle_trunk_data[vehicleid][i][trunk_itemId] == item_id)
                    {
                        found_slot = i;
                        break;
                    }
                }
                
                if(found_slot != -1)
                {
                    new new_count = g_vehicle_trunk_data[vehicleid][found_slot][trunk_itemCount] + count;
                    g_vehicle_trunk_data[vehicleid][found_slot][trunk_itemCount] = new_count;
                    
                    if(count == 1)
                        Inventory_RemoveOneItem(playerid, old_pos);
                    else
                        Inventory_RemoveItem(playerid, old_pos, count);
                    
                    new idx = GetVehicleData(vehicleid, V_ACTION_ID);
                    new sql_id = GetOwnableCarData(idx, OC_SQL_ID);
                    
                    new query[512];
                    mysql_format(mysql, query, sizeof(query),
                        "UPDATE trunks SET amount = %d WHERE oc_id = %d AND slot = %d",
                        new_count, sql_id, found_slot);
                    mysql_query(mysql, query, false);
                    
                    format(debug_msg, sizeof(debug_msg), "Item added to existing slot (ID: %d, amount: %d, new stack: %d)", item_id, count, new_count);
                    ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
                    
                    JSON_SetInt(response, "t", 0);
                    JSON_SetInt(response, "s", 1);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
                
                if(count == 1)
                    Inventory_RemoveOneItem(playerid, old_pos);
                else
                    Inventory_RemoveItem(playerid, old_pos, count);
                
                Trunk_AddItems(vehicleid, pos, item_id, count, item_plate);
                
                format(debug_msg, sizeof(debug_msg), "Item moved (ID: %d, amount: %d, slot %d -> %d)", item_id, count, old_pos, pos);
                ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
            }
            
            new index = GetVehicleData(vehicleid, V_ACTION_ID);
            new sql_id = GetOwnableCarData(index, OC_SQL_ID);
            
            new query[512];
            mysql_format(mysql, query, sizeof(query),
                "INSERT INTO trunks (oc_id, slot, item_id, amount, item_type, item_plate) VALUES (%d, %d, %d, %d, %d, '%e')",
                sql_id, pos, item_id, 
                (item_id == 134) ? skin_model : count,
                GetItemType(item_id), item_plate);
            mysql_query(mysql, query, false);
            
            JSON_SetInt(response, "t", 0);
            JSON_SetInt(response, "s", 1);
            SendPacketToClient(playerid, 34, response);
            JSON_Cleanup(response);
        }
        
        case 1: // From trunk to inventory
        {
            JSON_GetInt(JSONObject, "ga", item_id);
            JSON_GetInt(JSONObject, "os", old_pos);
            JSON_GetInt(JSONObject, "ns", pos);
            JSON_GetInt(JSONObject, "v", count);  
            
            new vehicleid = GetNearestVehicleID(playerid, 5.0);
            new debug_msg[256];
            
            printf("[DEBUG] Case 1 - Player %d: item_id=%d, old_pos=%d, new_pos=%d, count=%d", playerid, item_id, old_pos, pos, count);
            
            if(vehicleid == INVALID_VEHICLE_ID)
            {
                format(debug_msg, sizeof(debug_msg), "Error: Vehicle not found (Item ID: %d, slot: %d)", item_id, old_pos);
                ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                JSON_SetInt(response, "t", 1);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(IsAOwnableCar(vehicleid))
            {
                new index = GetVehicleData(vehicleid, V_ACTION_ID);
                if(GetOwnableCarData(index, OC_OWNER_ID) != GetPlayerAccountID(playerid))
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Not your vehicle (Item ID: %d, trunk slot: %d)", item_id, old_pos);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 1);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
            }
            else
            {
                format(debug_msg, sizeof(debug_msg), "Error: Not a personal vehicle (Item ID: %d)", item_id);
                ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                JSON_SetInt(response, "t", 1);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(g_vehicle_trunk_data[vehicleid][old_pos][trunk_itemId] != item_id)
            {
                format(debug_msg, sizeof(debug_msg), "Error: ID mismatch (expected %d, in trunk %d, slot %d)", 
                    item_id, g_vehicle_trunk_data[vehicleid][old_pos][trunk_itemId], old_pos);
                ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                JSON_SetInt(response, "t", 1);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(item_id == 134)  // Skin
            {
                new skin_model = g_vehicle_trunk_data[vehicleid][old_pos][trunk_itemCount];
                
                Trunk_DeleteItemCompletely(vehicleid, old_pos);
                Inventory_AddItem(playerid, 134, pos, skin_model, "");
                
                format(debug_msg, sizeof(debug_msg), "Skin retrieved from trunk (model: %d, trunk slot %d -> inventory %d)", skin_model, old_pos, pos);
                ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
            }
            else if(item_id == 58)  // SIM card
            {
           	 new phone_number = g_vehicle_trunk_data[vehicleid][old_pos][trunk_itemCount];
                Trunk_DeleteItemCompletely(vehicleid, old_pos);
                Inventory_AddItem(playerid, item_id, pos, phone_number, "");
                
                format(debug_msg, sizeof(debug_msg), "SIM card retrieved from trunk (ID: %d, amount: %d, trunk slot %d -> inventory %d)", 
                    item_id, phone_number, old_pos, pos);
                ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
            }
            else if(item_id == 59 || item_id == 83)  // Plates with region
    {
        new fmtn[32], debug_msg[512];
        format(fmtn, sizeof(fmtn), "%s", g_vehicle_trunk_data[vehicleid][old_pos][trunk_itemPlate]);
        
        Trunk_DeleteItemCompletely(vehicleid, old_pos);
        Inventory_AddItem(playerid, item_id, pos, 1, fmtn);
        
        format(debug_msg, sizeof(debug_msg), "License plate retrieved from trunk (type: %d, plate: %s, slot %d -> %d)", 
            item_id, fmtn, old_pos, pos);
        ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
    } 
    else if(item_id == 81 || item_id == 82)  // Plates without region
    {
        new fmtn[32];
        format(fmtn, sizeof(fmtn), "%s", g_vehicle_trunk_data[vehicleid][old_pos][trunk_itemPlate]);
        
        Trunk_DeleteItemCompletely(vehicleid, old_pos);
        Inventory_AddItem(playerid, item_id, pos, 1, fmtn);
        
        format(debug_msg, sizeof(debug_msg), "License plate retrieved from trunk (type: %d, plate: %s, slot %d -> %d)", 
            item_id, fmtn, old_pos, pos);
        ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
    }
            else
            {
                new current_count = 0;
                new max_limit = 0;
                
                switch(item_id)
                {
                    case 21: max_limit = 1;
                    case 22: max_limit = 5;
                    case 23: max_limit = 3;
                    case 116: max_limit = 3;
                    default: max_limit = 999;
                }
                
                for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
                {
                    if(g_PlayerInventory[playerid][i][inv_itemId] == item_id)
                    {
                        current_count += g_PlayerInventory[playerid][i][inv_itemCount];
                    }
                }
                
                if(max_limit != 999 && current_count + count > max_limit)
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Item limit (ID: %d, max: %d, current: %d, attempt: %d)", 
                        item_id, max_limit, current_count, count);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 1);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
                
                new found_slot = -1;
                for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
                {
                    if(g_PlayerInventory[playerid][i][inv_itemId] == item_id)
                    {
                        found_slot = i;
                        break;
                    }
                }
                
                new trunk_amount = g_vehicle_trunk_data[vehicleid][old_pos][trunk_itemCount];
                Trunk_RemoveItem(vehicleid, old_pos, count);
                
                if(found_slot != -1)
                {
                    new new_count = g_PlayerInventory[playerid][found_slot][inv_itemCount] + count;
                    g_PlayerInventory[playerid][found_slot][inv_itemCount] = new_count;
                    
                    format(debug_msg, sizeof(debug_msg), "Item added to existing inventory slot (ID: %d, amount: %d, new stack: %d, trunk slot %d)", 
                        item_id, count, new_count, old_pos);
                    ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
                    
                    new query[256];
                    mysql_format(mysql, query, sizeof(query),
                        "UPDATE player_inventory SET item_count = %d WHERE player_id = %d AND slot = %d AND is_active = 0",
                        new_count, GetPlayerAccountID(playerid), found_slot);
                    mysql_query(mysql, query, false);
                }
                else
                {
                    Inventory_AddItem(playerid, item_id, pos, count, "");
                    format(debug_msg, sizeof(debug_msg), "Item retrieved from trunk (ID: %d, amount: %d, trunk slot %d -> inventory %d)", 
                        item_id, count, old_pos, pos);
                    ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
                }
                
                format(debug_msg, sizeof(debug_msg), "Item moved from trunk: ID %d, amount %d, was in trunk: %d, remaining: %d",
                    item_id, count, trunk_amount, trunk_amount - count);
                ShowNotificationSile(playerid, 2, 4, -1, -1, debug_msg, "");
            }
            
            JSON_SetInt(response, "t", 1);
            JSON_SetInt(response, "s", 1);
            SendPacketToClient(playerid, 34, response);
            JSON_Cleanup(response);
        }
        
        case 2: // From active slot to inventory
        {
            JSON_GetInt(JSONObject, "ga", item_id);
            JSON_GetInt(JSONObject, "os", old_pos);
            JSON_GetInt(JSONObject, "ns", pos);
            JSON_GetInt(JSONObject, "v", count);
            
            new debug_msg[256];
            format(debug_msg, sizeof(debug_msg), "Moving: ID %d, from active slot %d to inventory slot %d", item_id, old_pos, pos);
            ShowNotificationSile(playerid, 2, 4, -1, -1, debug_msg, "");
            
            if(item_id == 134 && old_pos == 6)
            {
                ShowNotificationSile(playerid, 2, 6, -1, -1, "Error: Cannot remove clothes (ID: 134, slot: 6)", "");
                JSON_SetInt(response, "t", 2);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return;
            }
            
            new model_id = Accessory_GetModelIdByItemId(item_id);
            if(model_id != -1 && !IsShopWeaponItem(item_id))
            {
                if(Inventory_UnequipAccessory(playerid, old_pos, pos))
                {
                    format(debug_msg, sizeof(debug_msg), "Accessory unequipped (ID: %d, model: %d, slot %d -> %d)", item_id, model_id, old_pos, pos);
                    ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 2);
                    JSON_SetInt(response, "s", 1);
                }
                else
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Cannot unequip accessory (ID: %d, slot: %d)", item_id, old_pos);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 2);
                    JSON_SetInt(response, "s", 0);
                }
            }
            else
            {
                if(Inventory_MoveFromSlotToInv(playerid, item_id, old_pos, pos))
                {
                    format(debug_msg, sizeof(debug_msg), "Item moved (ID: %d, slot %d -> %d)", item_id, old_pos, pos);
                    ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 2);
                    JSON_SetInt(response, "s", 1);
                }
                else
                {
                    format(debug_msg, sizeof(debug_msg), "Error: Failed to move item (ID: %d, slot %d -> %d)", item_id, old_pos, pos);
                    ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                    JSON_SetInt(response, "t", 2);
                    JSON_SetInt(response, "s", 0);
                }
            }
            
            SendPacketToClient(playerid, 34, response);
            JSON_Cleanup(response);
        }
        
        case 8:
        {
            SetPVarInt(playerid, "typeinv", 0);
            ShowNotificationSile(playerid, 2, 4, -1, -1, "Inventory mode reset (typeinv=0)", "");
        }
        
        case 9: // Extract SIM card
        {
            JSON_GetInt(JSONObject, "ga", item_id);
            JSON_GetInt(JSONObject, "os", old_pos);
            JSON_GetInt(JSONObject, "s", pos);
            JSON_GetInt(JSONObject, "v", count);
            
            new phone_number = GetPlayerData(playerid, P_PHONE);
            new debug_msg[256];
            
            format(debug_msg, sizeof(debug_msg), "Extracting SIM card: number %d, to slot %d", phone_number, pos);
            ShowNotificationSile(playerid, 2, 4, -1, -1, debug_msg, "");
            
            g_PlayerInventory[playerid][pos][inv_itemId] = 58;
            g_PlayerInventory[playerid][pos][inv_itemCount] = phone_number;
            g_PlayerInventory[playerid][pos][inv_itemSlot] = pos;
            g_PlayerInventory[playerid][pos][inv_itemPlate][0] = 0;
            g_PlayerInventory[playerid][pos][inv_itemType] = GetItemType(58);
            g_PlayerInventory[playerid][pos][inv_itemWeight] = GetItemWeight(58);
            GetItemName(58, g_PlayerInventory[playerid][pos][inv_itemName]);
            g_PlayerInventory[playerid][pos][inv_itemActive] = false;
            
            SaveInventoryItem(playerid, pos);
            
            SetPlayerData(playerid, P_PHONE, 0);
            UpdatePlayerDatabaseInt(playerid, "phone", 0);
            
            format(debug_msg, sizeof(debug_msg), "SIM card extracted (number: %d, slot: %d, count: %d, old_pos: %d)", phone_number, pos, count, old_pos);
            ShowNotificationSile(playerid, 2, 5, -1, -1, debug_msg, "");
            
            JSON_SetInt(response, "t", 9);
            JSON_SetInt(response, "s", 1);
            JSON_SetInt(response, "s", pos);
            JSON_SetInt(response, "nm", 0);
            
            SendPacketToClient(playerid, 34, response);
            JSON_Cleanup(response);
        }
    }
}