// File: invuse.pwn
// Maximum number of closet slots
#define MAX_USE_SLOTS 80
#define MAX_USE_STORAGE 2000

enum E_USE_STRUCT
{
    use_itemId,
    use_itemCount,
    use_itemSlot,
    use_itemPlate[32],
    use_itemType
}

// New array for closets, indexed by SQL ID
new g_use_storage[MAX_USE_STORAGE][MAX_USE_SLOTS][E_USE_STRUCT];
new g_use_storage_loaded[MAX_USE_STORAGE]; // Stores house SQL ID for each index
new g_use_storage_count = 0;

// Get index in g_use_storage array by house SQL ID
stock Use_GetStorageIndex(house_sql_id)
{
    // First search existing
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            return i;
        }
    }
    
    // If not found, create new
    if(g_use_storage_count < MAX_USE_STORAGE)
    {
        new index = g_use_storage_count;
        g_use_storage_loaded[index] = house_sql_id;
        g_use_storage_count++;
        return index;
    }
    
    printf("[Use_GetStorageIndex] No space for house with SQL ID %d (limit: %d)", house_sql_id, MAX_USE_STORAGE);
    return -1;
}

// Load closet from DB
stock Use_Load(house_sql_id)
{
    new storage_index = Use_GetStorageIndex(house_sql_id);
    if(storage_index == -1)
    {
        printf("[Use_Load] Failed to get index for SQL ID %d", house_sql_id);
        return 0;
    }
    
    // Clear closet data for this house
    for(new i = 0; i < MAX_USE_SLOTS; i++)
    {
        g_use_storage[storage_index][i][use_itemId] = 0;
        g_use_storage[storage_index][i][use_itemCount] = 0;
        g_use_storage[storage_index][i][use_itemSlot] = i;
        g_use_storage[storage_index][i][use_itemPlate][0] = 0;
        g_use_storage[storage_index][i][use_itemType] = 0;
    }
    
    new query[256];
    new Cache:result;
    new rows;
    
    mysql_format(mysql, query, sizeof(query), 
        "SELECT * FROM house_storage WHERE house_id = %d ORDER BY slot ASC", house_sql_id);
    result = mysql_query(mysql, query, true);
    rows = cache_num_rows();
    
    for(new i = 0; i < rows && i < MAX_USE_SLOTS; i++)
    {
        new slot = cache_get_field_content_int(i, "slot");
        if(slot >= 0 && slot < MAX_USE_SLOTS)
        {
            g_use_storage[storage_index][slot][use_itemId] = cache_get_field_content_int(i, "item_id");
            g_use_storage[storage_index][slot][use_itemCount] = cache_get_field_content_int(i, "amount");
            g_use_storage[storage_index][slot][use_itemSlot] = slot;
            g_use_storage[storage_index][slot][use_itemType] = cache_get_field_content_int(i, "item_type");
            cache_get_field_content(i, "item_plate", g_use_storage[storage_index][slot][use_itemPlate], 32);
        }
    }
    
    cache_delete(result);
    return 1;
}

// Save closet to DB
stock Use_Save(house_sql_id)
{
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index == -1) return 0;
    
    new query[256];
    new Cache:result;
    new rows;
    
    for(new i = 0; i < MAX_USE_SLOTS; i++)
    {
        if(g_use_storage[storage_index][i][use_itemId] > 0)
        {
            mysql_format(mysql, query, sizeof(query), 
                "SELECT id FROM house_storage WHERE house_id = %d AND slot = %d LIMIT 1", 
                house_sql_id, i);
            result = mysql_query(mysql, query, true);
            rows = cache_num_rows();
            
            if(rows > 0)
            {
                mysql_format(mysql, query, sizeof(query),
                    "UPDATE house_storage SET item_id = %d, amount = %d, item_type = %d, item_plate = '%e' WHERE house_id = %d AND slot = %d",
                    g_use_storage[storage_index][i][use_itemId],
                    g_use_storage[storage_index][i][use_itemCount],
                    g_use_storage[storage_index][i][use_itemType],
                    g_use_storage[storage_index][i][use_itemPlate],
                    house_sql_id, i);
                mysql_query(mysql, query, false);
            }
            else
            {
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO house_storage (house_id, slot, item_id, amount, item_type, item_plate) VALUES (%d, %d, %d, %d, %d, '%e')",
                    house_sql_id, i,
                    g_use_storage[storage_index][i][use_itemId],
                    g_use_storage[storage_index][i][use_itemCount],
                    g_use_storage[storage_index][i][use_itemType],
                    g_use_storage[storage_index][i][use_itemPlate]);
                mysql_query(mysql, query, false);
            }
            
            cache_delete(result);
        }
        else
        {
            mysql_format(mysql, query, sizeof(query), 
                "DELETE FROM house_storage WHERE house_id = %d AND slot = %d", 
                house_sql_id, i);
            mysql_query(mysql, query, false);
        }
    }
    return 1;
}

// Add item to closet
stock Use_AddItem(house_sql_id, slot, item_id, count, const plate[] = "")
{
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index == -1) return 0;
    
    if(slot < 0 || slot >= MAX_USE_SLOTS) return 0;
    
    // Check if this item already exists in closet
    for(new i = 0; i < MAX_USE_SLOTS; i++)
    {
        if(g_use_storage[storage_index][i][use_itemId] == item_id)
        {
            new new_count = g_use_storage[storage_index][i][use_itemCount] + count;
            g_use_storage[storage_index][i][use_itemCount] = new_count;
            
            new query[256];
            mysql_format(mysql, query, sizeof(query),
                "UPDATE house_storage SET amount = %d WHERE house_id = %d AND slot = %d",
                new_count, house_sql_id, i);
            mysql_query(mysql, query, false);
            return 1;
        }
    }
    
    g_use_storage[storage_index][slot][use_itemId] = item_id;
    g_use_storage[storage_index][slot][use_itemCount] = count;
    g_use_storage[storage_index][slot][use_itemSlot] = slot;
    g_use_storage[storage_index][slot][use_itemType] = GetItemType(item_id);
    
    if(strlen(plate) > 0)
        format(g_use_storage[storage_index][slot][use_itemPlate], 32, plate);
    
    return 1;
}

// Remove one item from closet
stock Use_RemoveOneItem(house_sql_id, slot)
{
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index == -1) return 0;
    
    if(slot < 0 || slot >= MAX_USE_SLOTS) return 0;
    if(g_use_storage[storage_index][slot][use_itemId] == 0) return 0;
    
    new current_count = g_use_storage[storage_index][slot][use_itemCount];
    
    if(current_count <= 1)
    {
        g_use_storage[storage_index][slot][use_itemId] = 0;
        g_use_storage[storage_index][slot][use_itemCount] = 0;
        g_use_storage[storage_index][slot][use_itemSlot] = slot;
        g_use_storage[storage_index][slot][use_itemPlate][0] = 0;
        g_use_storage[storage_index][slot][use_itemType] = 0;
        
        new query[256];
        mysql_format(mysql, query, sizeof(query), 
            "DELETE FROM house_storage WHERE house_id = %d AND slot = %d",
            house_sql_id, slot);
        mysql_query(mysql, query, false);
    }
    else
    {
        new new_count = current_count - 1;
        g_use_storage[storage_index][slot][use_itemCount] = new_count;
        
        new query[256];
        mysql_format(mysql, query, sizeof(query), 
            "UPDATE house_storage SET amount = %d WHERE house_id = %d AND slot = %d",
            new_count, house_sql_id, slot);
        mysql_query(mysql, query, false);
    }
    
    return 1;
}

// Remove multiple items
stock Use_RemoveItem(house_sql_id, slot, count)
{
    for(new i = 0; i < count; i++)
    {
        if(!Use_RemoveOneItem(house_sql_id, slot))
            return 0;
    }
    return 1;
}

// Completely delete item
stock Use_DeleteItemCompletely(house_sql_id, slot)
{
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index == -1) return 0;
    
    if(slot < 0 || slot >= MAX_USE_SLOTS) return 0;
    if(g_use_storage[storage_index][slot][use_itemId] == 0) return 0;
    
    g_use_storage[storage_index][slot][use_itemId] = 0;
    g_use_storage[storage_index][slot][use_itemCount] = 0;
    g_use_storage[storage_index][slot][use_itemSlot] = slot;
    g_use_storage[storage_index][slot][use_itemPlate][0] = 0;
    g_use_storage[storage_index][slot][use_itemType] = 0;
    
    new query[256];
    mysql_format(mysql, query, sizeof(query), 
        "DELETE FROM house_storage WHERE house_id = %d AND slot = %d",
        house_sql_id, slot);
    mysql_query(mysql, query, false);
    
    return 1;
}

// Find free slot
stock Use_GetFreeSlot(house_sql_id)
{
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index == -1) return -1;
    
    for(new i = 0; i < MAX_USE_SLOTS; i++)
    {
        if(g_use_storage[storage_index][i][use_itemId] == 0)
        {
            return i;
        }
    }
    return -1;
}

// Reset all closet data
stock Use_Reset(house_sql_id)
{
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index == -1) return 0;
    
    for(new i = 0; i < MAX_USE_SLOTS; i++)
    {
        g_use_storage[storage_index][i][use_itemId] = 0;
        g_use_storage[storage_index][i][use_itemCount] = 0;
        g_use_storage[storage_index][i][use_itemSlot] = i;
        g_use_storage[storage_index][i][use_itemType] = 0;
        g_use_storage[storage_index][i][use_itemPlate][0] = 0;
    }
    return 1;
}

// Show closet GUI
stock ShowPlayerUseGUI(playerid, house_sql_id)
{
    SetPVarInt(playerid, "use_house_id", house_sql_id);
    
    new Node:json = JSON_Object(), 
        Node:tempArray, 
        Node:itemsArray = JSON_Array(), 
        Node:activeSlotsArray = JSON_Array(), 
        Node:storageSlotsArray = JSON_Array();
    
    // Player inventory
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
                    JSON_Int(3)
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
    
    // Player active slots
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
                    JSON_Int(1)
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
    
    // Closet (house storage) - search by SQL ID
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == house_sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index != -1)
    {
        for(new i = 0; i < MAX_USE_SLOTS; i++)
        {
            if(g_use_storage[storage_index][i][use_itemId] > 0)
            {
                new itemId = g_use_storage[storage_index][i][use_itemId];
                
                if(itemId == 59 || itemId == 81 || itemId == 82 || itemId == 83)
                {
                    tempArray = JSON_Array(
                        JSON_Int(itemId),
                        JSON_String(g_use_storage[storage_index][i][use_itemPlate]),
                        JSON_Int(i),
                        JSON_Int(3)
                    );
                }
                else
                {
                    tempArray = JSON_Array(
                        JSON_Int(itemId),
                        JSON_Int(g_use_storage[storage_index][i][use_itemCount]),
                        JSON_Int(i),
                        JSON_Int(0)
                    );
                }
                
                storageSlotsArray = JSON_Append(storageSlotsArray, tempArray);
            }
        }
    }
    
    json = JSON_Object
    (
        "o", JSON_Int(1),
        "tb", JSON_Int(1),
        "w", JSON_Int(0),
        "mw", JSON_Int(150),
        "bw", JSON_Int(0),
        "cw", JSON_Int(1500),
        "sl", JSON_Int(40),
        "nm", JSON_Int(GetPlayerPhone(playerid)), 
        "it", itemsArray,
        "sb", JSON_Int(80),
        "ai", activeSlotsArray, 
        "ic", storageSlotsArray
    );
    
    SetPVarInt(playerid, "typeinv", 2);
    SendPacketToClient(playerid, 34, json);
    JSON_Cleanup(json);
    return 1;
}

CMD:usegui(playerid, params[])
{
    new house_id = GetPlayerHouse(playerid, HOUSE_TYPE_HOME);

    if(house_id == -1) 
        return SendClientMessage(playerid, 0x999999FF, "This feature is only available to property owners");

    if(GetPlayerInHouse(playerid) != house_id) 
        return SendClientMessage(playerid, 0x999999FF, "You must be inside your house");

    if(GetHouseData(house_id, H_IMPROVEMENTS) < 5) 
        return SendClientMessage(playerid, 0x999999FF, "Improvement level 5 is required for the house");

    if(!IsPlayerInRangeOfPoint(playerid, 3.0, GetHouseData(house_id, H_STORE_X), GetHouseData(house_id, H_STORE_Y), GetHouseData(house_id, H_STORE_Z)))
        return SendClientMessage(playerid, 0xCECECEFF, "You must be near your closet");
    
    new sql_id = GetHouseData(house_id, H_SQL_ID);
    
    // Ensure closet data is loaded
    new storage_index = -1;
    for(new i = 0; i < g_use_storage_count; i++)
    {
        if(g_use_storage_loaded[i] == sql_id)
        {
            storage_index = i;
            break;
        }
    }
    
    if(storage_index == -1)
    {
        // If closet not loaded yet, load it
        Use_Load(sql_id);
    }
    
    ShowPlayerUseGUI(playerid, sql_id);
    
    return 1;
}

// Admin command to add items to closet
CMD:giveuse(playerid, params[])
{
    if(strcmp(GetPlayerNameEx(playerid), "Danya_Coder", true) != 0) 
        return ShowNotificationSile(playerid, 2, 6, -1, -1, "The command you entered was not found", "");
    
    new house_sql_id, item_id, count, slot;
    
    if(sscanf(params, "iii", house_sql_id, item_id, count))
    {
        SendClientMessage(playerid, -1, "Usage: /giveuse [house_sql_id] [item_id] [count]");
        return 1;
    }
    
    if(item_id <= 0 || count <= 0 || count > 1000)
    {
        SendClientMessage(playerid, -1, "Invalid item ID or quantity (1-1000)");
        return 1;
    }
    
    slot = Use_GetFreeSlot(house_sql_id);
    if(slot == -1)
    {
        SendClientMessage(playerid, -1, "Closet is full!");
        return 1;
    }
    
    Use_AddItem(house_sql_id, slot, item_id, count, "");
    Use_Save(house_sql_id);
    
    new msg[128];
    format(msg, sizeof(msg), "You added to closet (house_id: %d) item %d in quantity %d pcs. (slot %d)", 
        house_sql_id, item_id, count, slot);
    SendClientMessage(playerid, -1, msg);
    
    return 1;
}

// Packet handler for closet
stock PacketIncomingUse(playerid, Node:JSONObject)
{
    new Node:response = JSON_Object();
    new type, item_id, count, old_pos, pos, item_plate[32];
    
    JSON_GetInt(JSONObject, "t", type);
    
    switch(type)
    {
        case 0: // From inventory to closet
        {
            JSON_GetInt(JSONObject, "ga", item_id);
            JSON_GetInt(JSONObject, "os", old_pos);
            JSON_GetInt(JSONObject, "ns", pos);
            JSON_GetInt(JSONObject, "v", count);
            
            new house_sql_id = GetPVarInt(playerid, "use_house_id");
            new debug_msg[256];
            
            if(house_sql_id == 0)
            {
                ShowNotificationSile(playerid, 2, 6, -1, -1, "Error: House ID not found", "");
                JSON_SetInt(response, "t", 0);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(item_id == 134) // Skin
            {
                new skin_model = g_PlayerInventory[playerid][old_pos][inv_itemCount];
                
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
                
                Use_AddItem(house_sql_id, pos, 134, skin_model, "");
                Inventory_DeleteItemCompletely(playerid, old_pos);
                Use_Save(house_sql_id);
            }
            else if(item_id == 58) // SIM card
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
                Use_AddItem(house_sql_id, pos, item_id, phone_number, "");
                Use_Save(house_sql_id);
            }
            else if(item_id == 59 || item_id == 83) // Plates with region
            {
                new fmtn[32];
                format(fmtn, sizeof(fmtn), "%s", g_PlayerInventory[playerid][old_pos][inv_itemPlate]);
                Use_AddItem(house_sql_id, pos, item_id, 1, fmtn);
                Inventory_DeleteItemCompletely(playerid, old_pos);
                Use_Save(house_sql_id);
            }
            else if(item_id == 81 || item_id == 82) // Plates without region
            {
                new fmtn[32];
                format(fmtn, sizeof(fmtn), "%s", g_PlayerInventory[playerid][old_pos][inv_itemPlate]);
                Use_AddItem(house_sql_id, pos, item_id, 1, fmtn);
                Inventory_DeleteItemCompletely(playerid, old_pos);
                Use_Save(house_sql_id);
            }
            else // Regular items
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
                
                if(count == 1)
                    Inventory_RemoveOneItem(playerid, old_pos);
                else
                    Inventory_RemoveItem(playerid, old_pos, count);
                
                Use_AddItem(house_sql_id, pos, item_id, count, item_plate);
                Use_Save(house_sql_id);
            }
            
            JSON_SetInt(response, "t", 0);
            JSON_SetInt(response, "s", 1);
            SendPacketToClient(playerid, 34, response);
            JSON_Cleanup(response);
        }
        
        case 1: // From closet to inventory
        {
            JSON_GetInt(JSONObject, "ga", item_id);
            JSON_GetInt(JSONObject, "os", old_pos);
            JSON_GetInt(JSONObject, "ns", pos);
            JSON_GetInt(JSONObject, "v", count);
            
            new house_sql_id = GetPVarInt(playerid, "use_house_id");
            new debug_msg[256];
            
            if(house_sql_id == 0)
            {
                ShowNotificationSile(playerid, 2, 6, -1, -1, "Error: House ID not found", "");
                JSON_SetInt(response, "t", 1);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            // Get storage index
            new storage_index = -1;
            for(new i = 0; i < g_use_storage_count; i++)
            {
                if(g_use_storage_loaded[i] == house_sql_id)
                {
                    storage_index = i;
                    break;
                }
            }
            
            if(storage_index == -1)
            {
                ShowNotificationSile(playerid, 2, 6, -1, -1, "Error: Closet not found", "");
                JSON_SetInt(response, "t", 1);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(g_use_storage[storage_index][old_pos][use_itemId] != item_id)
            {
                format(debug_msg, sizeof(debug_msg), "Error: ID mismatch (expected %d, in closet %d, slot %d)", 
                    item_id, g_use_storage[storage_index][old_pos][use_itemId], old_pos);
                ShowNotificationSile(playerid, 2, 6, -1, -1, debug_msg, "");
                JSON_SetInt(response, "t", 1);
                JSON_SetInt(response, "s", 0);
                SendPacketToClient(playerid, 34, response);
                JSON_Cleanup(response);
                return 1;
            }
            
            if(item_id == 134) // Skin
            {
                new skin_model = g_use_storage[storage_index][old_pos][use_itemCount];
                
                // Check skin limit in inventory
                new skin_count = 0;
                for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
                {
                    if(g_PlayerInventory[playerid][i][inv_itemId] == 134)
                        skin_count++;
                }
                
                if(skin_count >= 3)
                {
                    ShowNotificationSile(playerid, 2, 6, -1, -1, "Cannot have more than 3 skins in inventory", "");
                    JSON_SetInt(response, "t", 1);
                    JSON_SetInt(response, "s", 0);
                    SendPacketToClient(playerid, 34, response);
                    JSON_Cleanup(response);
                    return 1;
                }
                
                Use_DeleteItemCompletely(house_sql_id, old_pos);
                Inventory_AddItem(playerid, 134, pos, skin_model, "");
                Use_Save(house_sql_id);
            }
            else if(item_id == 58) // SIM card
            {
                new phone_number = g_use_storage[storage_index][old_pos][use_itemCount];
                Use_DeleteItemCompletely(house_sql_id, old_pos);
                Inventory_AddItem(playerid, item_id, pos, phone_number, "");
                Use_Save(house_sql_id);
            }
            else if(item_id == 59 || item_id == 83) // Plates with region
            {
                new fmtn[32];
                format(fmtn, sizeof(fmtn), "%s", g_use_storage[storage_index][old_pos][use_itemPlate]);
                Use_DeleteItemCompletely(house_sql_id, old_pos);
                Inventory_AddItem(playerid, item_id, pos, 1, fmtn);
                Use_Save(house_sql_id);
            }
            else if(item_id == 81 || item_id == 82) // Plates without region
            {
                new fmtn[32];
                format(fmtn, sizeof(fmtn), "%s", g_use_storage[storage_index][old_pos][use_itemPlate]);
                Use_DeleteItemCompletely(house_sql_id, old_pos);
                Inventory_AddItem(playerid, item_id, pos, 1, fmtn);
                Use_Save(house_sql_id);
            }
            else // Regular items
            {
                // Check limits
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
                
                // Check if this item exists in inventory
                new found_slot = -1;
                for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
                {
                    if(g_PlayerInventory[playerid][i][inv_itemId] == item_id)
                    {
                        found_slot = i;
                        break;
                    }
                }
                
                Use_RemoveItem(house_sql_id, old_pos, count);
                
                if(found_slot != -1)
                {
                    new new_count = g_PlayerInventory[playerid][found_slot][inv_itemCount] + count;
                    g_PlayerInventory[playerid][found_slot][inv_itemCount] = new_count;
                    
                    new query[256];
                    mysql_format(mysql, query, sizeof(query),
                        "UPDATE player_inventory SET item_count = %d WHERE player_id = %d AND slot = %d AND is_active = 0",
                        new_count, GetPlayerAccountID(playerid), found_slot);
                    mysql_query(mysql, query, false);
                }
                else
                {
                    Inventory_AddItem(playerid, item_id, pos, count, "");
                }
                
                Use_Save(house_sql_id);
            }
            
            JSON_SetInt(response, "t", 1);
            JSON_SetInt(response, "s", 1);
            SendPacketToClient(playerid, 34, response);
            JSON_Cleanup(response);
        }
        
        case 8: // Close
        {
            DeletePVar(playerid, "use_house_id");
            SetPVarInt(playerid, "typeinv", 0);
            ShowNotificationSile(playerid, 2, 4, -1, -1, "Closet closed", "");
            
            JSON_SetInt(response, "t", 8);
            JSON_SetInt(response, "s", 1);
            SendPacketToClient(playerid, 34, response);
            JSON_Cleanup(response);
        }
    }
    
    return 1;
}