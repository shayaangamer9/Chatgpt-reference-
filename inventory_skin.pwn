// File: inventory_skin.pwn
#define DIALOG_INVENTORY_MAIN       1788
#define DIALOG_MYSKINS_LIST         1789
#define DIALOG_MYSKINS_ACTIONS      1790
#define DIALOG_MYACCS_LIST          1791
#define DIALOG_MYACCS_ACTIONS       1792

#define DIALOG_EDITACS_MAIN         1793
#define DIALOG_EDITACS_PARAMS       1794
#define DIALOG_EDITACS_ACTIONS      1795
#define DIALOG_EDITACS_INPUT        1796
#define DIALOG_EDITACS_BONE         1797
#define DIALOG_EDITACS_SUBPARAMS    1798

#define MAX_PLAYER_SKINS            100
#define MAX_PLAYER_ACCESSORIES      100

#define DIALOG_EDITACS_NEW_MAIN         1799
#define DIALOG_EDITACS_NEW_ACTIONS      1800

#define MAX_PLAYER_PLATES 10
#define DIALOG_MYPLATES_LIST 1801
#define DIALOG_MYPLATES_ACTIONS 1802
#define DIALOG_MYPLATES_DELETE_CONFIRM 1803

enum E_PLAYER_SKIN_DATA
{
    skindb_id,
    skindb_game_id,
    skindb_in_use
}

enum E_PLAYER_ACC_DATA
{
    accdb_id,
    accdb_model,
    accdb_bone,
    Float:accdb_x,
    Float:accdb_y,
    Float:accdb_z,
    Float:accdb_rot_x,
    Float:accdb_rot_y,
    Float:accdb_rot_z,
    Float:accdb_scale_x,
    Float:accdb_scale_y,
    Float:accdb_scale_z,
    accdb_in_use
}

enum E_ACCS_DATA
{
    accModel,
    accBone,
    Float:accX,
    Float:accY,
    Float:accZ,
    Float:accRotX,
    Float:accRotY,
    Float:accRotZ,
    Float:accScaleX,
    Float:accScaleY,
    Float:accScaleZ
}

enum E_PLAYER_PLATE_DATA
{
    plate_sql_id,
    plate_country,
    plate_text[32],
    plate_region[8]
}

new PlayerSkinsData[MAX_PLAYERS][MAX_PLAYER_SKINS][E_PLAYER_SKIN_DATA];
new PlayerSkinsCount[MAX_PLAYERS];

new PlayerAccsData[MAX_PLAYERS][MAX_PLAYER_ACCESSORIES][E_PLAYER_ACC_DATA];
new PlayerAccsCount[MAX_PLAYERS];

new Float:gPlayerTempAccData[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][11];

new PlayerPlatesData[MAX_PLAYERS][MAX_PLAYER_PLATES][E_PLAYER_PLATE_DATA];
new PlayerPlatesCount[MAX_PLAYERS];

new AccsData[][E_ACCS_DATA] = {
    {4196, 1, 0.049998, -0.280000, 0.000000, 10.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {5374, 1, 0.149999, -0.170000, -0.019999, 0.000000, 90.000000, -175.000000, 1.000000, 1.000000, 1.000000},
    {4199, 1, 0.079999, -0.129999, 0.000000, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {14574, 1, 0.049999, -0.280000, 0.000000, 10.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {18377, 2, 0.089999, 0.049999, -0.009999, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {18392, 2, 0.089999, 0.049999, -0.009999, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {14593, 1, -0.069999, -0.119999, -0.009999, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {7369, 6, 0.240000, 0.000000, 0.000000, 0.000000, -90.000000, -100.000000, 1.000000, 1.000000, 1.000000},
    {4197, 2, 0.119999, 0.049999, 0.000000, 0.000000, 85.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {5383, 2, 0.219999, -0.029999, -0.049999, 0.000000, 85.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {1747, 2, 0.159999, 0.000000, -0.009999, 45.000000, 95.000000, -225.000000, 1.000000, 1.000000, 1.000000},
    {1729, 17, -0.089999, 0.049998, 0.000000, 105.000000, 60.000000, 90.000000, 1.000000, 1.000000, 1.000000},
    {5378, 7, 0.099999, 0.029999, -0.069999, 5.000000, -90.000000, -5.000000, 1.000000, 1.000000, 1.000000},
    {18409, 2, 0.089999, 0.049999, -0.009999, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {5384, 6, 0.240000, 0.000000, 0.000000, 0.000000, -90.000000, -100.000000, 1.000000, 1.000000, 1.000000},
    {13740, 6, 0.240000, 0.000000, 0.000000, 0.000000, -90.000000, -100.000000, 1.000000, 1.000000, 1.000000},
    {13736, 2, 0.189999, -0.029999, -0.069999, 0.000000, 85.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {13744, 2, 0.189999, -0.029999, -0.069999, 0.000000, 85.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {18502, 2, 0.119999, 0.049999, 0.000000, 0.000000, 85.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {18504, 2, 0.119999, 0.049999, 0.000000, 0.000000, 85.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {18503, 2, 0.119999, 0.049999, 0.000000, 0.000000, 85.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {916, 1, -0.17, -0.029998, -0.079998, -30.0, 75.0, -155.0, 1.000000, 1.000000, 1.000000},
    {1783, 2, 0.20, 0.019999, 0.000000, 168.800003, 92.389999, 7.489999, 1.000000, 1.000000, 1.000000},
    {18396, 2, 0.039998, -0.029998, -0.009998, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {18576, 15, -0.09999, 0.000000, 0.000000, 180.000000, -90.000000, 20.000000, 1.000000, 1.000000, 1.000000},
    {18403, 2, 0.059999, 0.000000, 0.000000, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {14575, 1, 0.159999, -0.070000, 0.000000, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {907, 1, 0.069999, -0.039999, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000},
    {7368, 6, 0.240000, 0.000000, 0.000000, 0.000000, -90.000000, -100.000000, 1.000000, 1.000000, 1.000000},
    {7367, 6, 0.240000, 0.000000, 0.000000, 0.000000, -90.000000, -100.000000, 1.000000, 1.000000, 1.000000},
    {4198, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4200, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4201, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4203, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4204, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4205, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4206, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4207, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {4208, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15134, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15135, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15136, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15137, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15138, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15139, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15140, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15141, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15142, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15143, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15144, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15145, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15146, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15147, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15149, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15150, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {15151, 2, 0.08999, 0.121109, -0.010001, 0.0, 450.0, 0.0, 1.0, 1.0, 1.0},
    {15152, 2, 0.08999, 0.121109, -0.010001, 0.0, 450.0, 0.0, 1.0, 1.0, 1.0},
    {15153, 2, 0.08999, 0.121109, -0.010001, 0.0, 450.0, 0.0, 1.0, 1.0, 1.0},
    {18513, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {18509, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {18414, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {18500, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0},
    {18501, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0}
};

new const AccsNames[][] = {
    "Butterfly wings", "Sparrow skull", "Jetpack", "Demon wings", "Heart glasses",
    "Glasses lights", "Caramel wings", "Black case", "Bee mask", "Pirate hat bp",
    "New Year Hello kitty 1", "New Year scarf", "Pirate king sword", "Snowflake glasses", "Pirate lantern",
    "Gradient case", "Wreath", "Butterflies", "Troll mask", "Troll with wig",
    "Alien", "Sports bag Supreme", "Snowman mask", "Gnome hat with beard", "Helicopter",
    "Tiger mask", "Angel wings", "LV backpack", "Case (2)", "Leather case",
    "Maple crown", "Maple bag", "Broom", "Backpack with vegetables", "School backpack",
    "Sunflower hat", "Black umbrella", "Umbrella with leaves", "Pink umbrella", "Alien backpack",
    "Witch hat (black)", "Witch hat (dark)", "Witch hat (gray)", "Star hat", "Red witch hat",
    "Witch hat (purple)", "Witch hat (green)", "Iron scythe", "Metal scythe", "Glowing red mask",
    "Maniac mask", "Crying mask", "Scary mask", "Broom (halloween)", "FnaF backpack",
    "Host mask", "Glowing blue mask", "Glowing purple mask", "King crown", "Makita case",
    "Straight warning glasses", "Clown mask", "Clown mask 2"
};

stock GetSkinNameByGameId(game_id)
{
    new name[128];

    switch(game_id)
    {
        case 2: format(name, sizeof name, "Ricardo Milos");
        case 5: format(name, sizeof name, "Famous blogger");
        case 10: format(name, sizeof name, "Bunny girl");
        case 22: format(name, sizeof name, "Soviet soldier M");
        case 23: format(name, sizeof name, "Soviet soldier F");
        case 24: format(name, sizeof name, "Father Frost");
        case 48: format(name, sizeof name, "Prisoner M");
        case 49: format(name, sizeof name, "Player 001");
        case 53: format(name, sizeof name, "Player 067");
        case 57: format(name, sizeof name, "Famous expert");
        case 62: format(name, sizeof name, "Dark lord");
        case 63: format(name, sizeof name, "Prisoner F");
        case 86: format(name, sizeof name, "Beerosaurus");
        case 88: format(name, sizeof name, "Blue Father Frost");
        case 89: format(name, sizeof name, "Home alone boy");
        case 92: format(name, sizeof name, "Girl on skates");
        case 95: format(name, sizeof name, "Meksu broadcasts");
        case 99: format(name, sizeof name, "Man on skates");
        case 106: format(name, sizeof name, "Famous blogger");
        case 108: format(name, sizeof name, "Famous blogger");
        case 109: format(name, sizeof name, "Famous blogger");
        case 110: format(name, sizeof name, "Famous blogger");
        case 122: format(name, sizeof name, "Branded clothing BR");
        case 129: format(name, sizeof name, "Hatter");
        case 130: format(name, sizeof name, "Santa Claus");
        case 160: format(name, sizeof name, "Player 456");
        case 162: format(name, sizeof name, "Famous footballer");
        case 165: format(name, sizeof name, "Elon Musk");
        case 166: format(name, sizeof name, "Famous blogger");
        case 174: format(name, sizeof name, "Danya Milokhin");
        case 175: format(name, sizeof name, "Scream");
        case 196: format(name, sizeof name, "Snow Maiden");
        case 197: format(name, sizeof name, "Bunny girl");
        case 199: format(name, sizeof name, "Clown girl");
        case 200: format(name, sizeof name, "Famous streamer");
        case 202: format(name, sizeof name, "Famous rapper");
        case 204: format(name, sizeof name, "Famous gamer");
        case 208: format(name, sizeof name, "Scary friend");
        case 210: format(name, sizeof name, "Famous footballer");
        case 220: format(name, sizeof name, "Professor-mage");
        case 224: format(name, sizeof name, "Beerosaurus");
        case 225: format(name, sizeof name, "Anime-chan");
        case 229: format(name, sizeof name, "Famous blogger");
        case 231: format(name, sizeof name, "Witch D");
        case 232: format(name, sizeof name, "Beauty");
        case 234: format(name, sizeof name, "Chairman");
        case 235: format(name, sizeof name, "Famous blogger");
        case 236: format(name, sizeof name, "Dealer");
        case 243: format(name, sizeof name, "Snow Maiden");
        case 245: format(name, sizeof name, "Snow Maiden");
        case 249: format(name, sizeof name, "President");
        case 252: format(name, sizeof name, "Igla");
        case 262: format(name, sizeof name, "Killer");
        case 264: format(name, sizeof name, "Evil clown");
        case 266: format(name, sizeof name, "Skeleton");
        case 267: format(name, sizeof name, "James Bond");
        case 269: format(name, sizeof name, "Handsome");
        case 270: format(name, sizeof name, "Mukhanov Kirill");
        case 283: format(name, sizeof name, "Aristocrat");
        case 298: format(name, sizeof name, "Lady");
        case 301: format(name, sizeof name, "Ivan Blogger");
        case 302: format(name, sizeof name, "Blogger");
        case 310: format(name, sizeof name, "Sasha bandit");
        case 311: format(name, sizeof name, "Bandit boxer");
        case 5323: format(name, sizeof name, "Vurdalak");
        case 5325: format(name, sizeof name, "New Year penguin");
        case 5326: format(name, sizeof name, "Snowman");
        case 5362: format(name, sizeof name, "Duchesse");
        case 5365: format(name, sizeof name, "Maniac");
        case 5367: format(name, sizeof name, "Maniac Myers");
        case 6780: format(name, sizeof name, "Elegant lady");
        case 6832: format(name, sizeof name, "Blogger Enzo");
        case 6871: format(name, sizeof name, "Maslennikov");
        case 6872: format(name, sizeof name, "INSTASAMKA");
        case 6892: format(name, sizeof name, "Catwoman");
        case 6893: format(name, sizeof name, "Hot man");
        case 6894: format(name, sizeof name, "Poseidon");
        case 6895: format(name, sizeof name, "Company employee");
        case 6896: format(name, sizeof name, "Business Lady");
        case 11917: format(name, sizeof name, "Homie");
        case 11933: format(name, sizeof name, "Alisher");
        case 11934: format(name, sizeof name, "Fat Alisher");
        case 11935: format(name, sizeof name, "Cop");
        case 11944: format(name, sizeof name, "Danya Milokhin");
        case 11947: format(name, sizeof name, "Meister");
        case 11948: format(name, sizeof name, "Rider");
        case 11951: format(name, sizeof name, "Wizard magician");
        case 11953: format(name, sizeof name, "Castle guard");
        case 11956: format(name, sizeof name, "Alyonushka");
        case 11957: format(name, sizeof name, "Healer");
        case 11958: format(name, sizeof name, "Killer bee");
        case 11959: format(name, sizeof name, "Biker");
        case 11961: format(name, sizeof name, "Fisherwoman");
        case 11962: format(name, sizeof name, "Fisherman");
        case 12291: format(name, sizeof name, "Soldier girl");
        case 12293: format(name, sizeof name, "Emelya");
        case 14386: format(name, sizeof name, "Velvet hinges");
        case 14388: format(name, sizeof name, "Special velvet hinges");
        case 18606: format(name, sizeof name, "Pozzi");
        case 18620: format(name, sizeof name, "Bandit BEE");
        case 18621: format(name, sizeof name, "Bandit TT");
        case 18623: format(name, sizeof name, "Stylish bandit");
        case 18624: format(name, sizeof name, "Smooth bandit");
        case 18625: format(name, sizeof name, "Bandit DIMOOOON");
        case 18626: format(name, sizeof name, "Bandit frame");
        case 18628: format(name, sizeof name, "Asian bandit");
        case 19262: format(name, sizeof name, "Dangerous man");
        case 19273: format(name, sizeof name, "Granny Nyura");
        default: format(name, sizeof name, "Skin %d", game_id);
    }

    return name;
}

CMD:inventory(playerid)
{
    ShowInventoryMainMenu(playerid);
    return 1;
}

/*CMD:inv(playerid)
{
    return callcmd::inventory(playerid, "");
}*/

stock ShowInventoryMainMenu(playerid)
{
    new dialog_text[512];

    strcat(dialog_text, "{FAD201}number\t{FAD201}category\t{FAD201}button description\n");
    strcat(dialog_text, "{FFFFFF}1\t{FF5C5C}My skins\t{FFFFFF}View skins\n");
    strcat(dialog_text, "{FFFFFF}2\t{FFFFFF}My accessories\t{FFFFFF}View accessories\n");
    strcat(dialog_text, "{FFFFFF}3\t{FFFFFF}My license plates\t{FFFFFF}View license plates\n");

    ShowPlayerDialog(playerid, DIALOG_INVENTORY_MAIN, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Inventory {FFFFFF}| Select the inventory menu you need",
        dialog_text,
        "Select", "Cancel"
    );

    return 1;
}

CMD:myskins(playerid)
{
    LoadPlayerSkins(playerid);
    return 1;
}

stock LoadPlayerSkins(playerid)
{
    new query[256];
    mysql_format(mysql, query, sizeof query,
        "SELECT id, game_id, use_skin FROM inventory_skins WHERE owner_skin=%d ORDER BY use_skin DESC, id ASC",
        GetPlayerAccountID(playerid));
    new Cache:result = mysql_query(mysql, query, true);

    new rows = cache_num_rows();

    if(!rows)
    {
        cache_delete(result);
        ShowNotificationSile(playerid, 2, 6, 0, 0, "Your inventory is empty", "Buy skins in the donate shop");
        CheckDefaultSkin(playerid);
        return 1;
    }

    PlayerSkinsCount[playerid] = 0;

    new temp_str[32];
    for(new i = 0; i < rows && i < MAX_PLAYER_SKINS; i++)
    {
        cache_get_field_content(i, "id", temp_str);
        PlayerSkinsData[playerid][i][skindb_id] = strval(temp_str);

        cache_get_field_content(i, "game_id", temp_str);
        PlayerSkinsData[playerid][i][skindb_game_id] = strval(temp_str);

        cache_get_field_content(i, "use_skin", temp_str);
        PlayerSkinsData[playerid][i][skindb_in_use] = strval(temp_str);

        PlayerSkinsCount[playerid]++;
    }

    cache_delete(result);
    ShowPlayerSkinsDialog(playerid);
    return 1;
}

stock ShowPlayerSkinsDialog(playerid)
{
    new dialog_text[2048];

    strcat(dialog_text, "{FAD201}number\t{FAD201}character image\t{FAD201}status\n");

    for(new i = 0; i < PlayerSkinsCount[playerid]; i++)
    {
        new game_id = PlayerSkinsData[playerid][i][skindb_game_id];
        new in_use = PlayerSkinsData[playerid][i][skindb_in_use];
        new skin_name[128];

        format(skin_name, sizeof skin_name, "%s", GetSkinNameByGameId(game_id));

        strcat(dialog_text, "{FFFFFF}");

        new temp[16];
        valstr(temp, i + 1);
        strcat(dialog_text, temp);
        strcat(dialog_text, "\t");

        strcat(dialog_text, skin_name);
        strcat(dialog_text, " {999999}(ID: ");
        valstr(temp, game_id);
        strcat(dialog_text, temp);
        strcat(dialog_text, ")\t");

        if(in_use) strcat(dialog_text, "{FF0000}[ in use ]");
        else strcat(dialog_text, "{66CC00}[ in stock ]");

        strcat(dialog_text, "\n");
    }

    ShowPlayerDialog(playerid, DIALOG_MYSKINS_LIST, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Inventory {FFFFFF}| Select a skin for your character",
        dialog_text,
        "Select", "Back"
    );

    return 1;
}

stock ShowSkinActionsDialog(playerid, listitem)
{
    if(listitem < 0 || listitem >= PlayerSkinsCount[playerid]) return 0;

    SetPVarInt(playerid, "selected_skin_listitem", listitem);

    new game_id = PlayerSkinsData[playerid][listitem][skindb_game_id];
    new in_use = PlayerSkinsData[playerid][listitem][skindb_in_use];

    new dialog_text[512];

    format(dialog_text, sizeof dialog_text,
        "{FAD201}number\t{FAD201}action\t{FAD201}description\n"\
        "{FFFFFF}1.\t%s\t{999999}Use this image\n"\
        "{FFFFFF}2.\t{FF0000}Remove\t{999999}Delete from inventory",
        in_use ? "{999999}Apply" : "{66CC00}Apply"
    );

    ShowPlayerDialog(playerid, DIALOG_MYSKINS_ACTIONS, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Inventory {FFFFFF}| Character skin management",
        dialog_text,
        "Select", "Back"
    );

    return 1;
}

CMD:myaccs(playerid)
{
    LoadPlayerAccessories(playerid);
    return 1;
}

stock LoadPlayerAccessories(playerid)
{
    new account_id = GetPlayerAccountID(playerid);

    if(account_id <= 0)
    {
        printf("[ERROR] LoadPlayerAccessories: Invalid account_id for playerid=%d", playerid);
        return 0;
    }

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "SELECT id, modelid, bone, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, scale_x, scale_y, scale_z, in_use FROM inventory_accessories WHERE account_id=%d ORDER BY in_use DESC, id ASC",
        account_id);

    PlayerAccsCount[playerid] = 0;
    for(new i = 0; i < MAX_PLAYER_ACCESSORIES; i++)
    {
        PlayerAccsData[playerid][i][accdb_id] = 0;
        PlayerAccsData[playerid][i][accdb_model] = 0;
        PlayerAccsData[playerid][i][accdb_in_use] = 0;
    }

    new Cache:result = mysql_query(mysql, query, true);

    new rows = cache_num_rows();

    if(!rows)
    {
        cache_delete(result);
        ShowNotificationSile(playerid, 2, 6, 0, 0, "You have no accessories", "Buy them in the donate shop");
        return 1;
    }

    PlayerAccsCount[playerid] = 0;

    new temp_str[32];
    for(new i = 0; i < rows && i < MAX_PLAYER_ACCESSORIES; i++)
    {
        cache_get_field_content(i, "id", temp_str);
        PlayerAccsData[playerid][i][accdb_id] = strval(temp_str);

        cache_get_field_content(i, "modelid", temp_str);
        PlayerAccsData[playerid][i][accdb_model] = strval(temp_str);

        cache_get_field_content(i, "bone", temp_str);
        PlayerAccsData[playerid][i][accdb_bone] = strval(temp_str);

        cache_get_field_content(i, "pos_x", temp_str);
        PlayerAccsData[playerid][i][accdb_x] = floatstr(temp_str);

        cache_get_field_content(i, "pos_y", temp_str);
        PlayerAccsData[playerid][i][accdb_y] = floatstr(temp_str);

        cache_get_field_content(i, "pos_z", temp_str);
        PlayerAccsData[playerid][i][accdb_z] = floatstr(temp_str);

        cache_get_field_content(i, "rot_x", temp_str);
        PlayerAccsData[playerid][i][accdb_rot_x] = floatstr(temp_str);

        cache_get_field_content(i, "rot_y", temp_str);
        PlayerAccsData[playerid][i][accdb_rot_y] = floatstr(temp_str);

        cache_get_field_content(i, "rot_z", temp_str);
        PlayerAccsData[playerid][i][accdb_rot_z] = floatstr(temp_str);

        cache_get_field_content(i, "scale_x", temp_str);
        PlayerAccsData[playerid][i][accdb_scale_x] = floatstr(temp_str);

        cache_get_field_content(i, "scale_y", temp_str);
        PlayerAccsData[playerid][i][accdb_scale_y] = floatstr(temp_str);

        cache_get_field_content(i, "scale_z", temp_str);
        PlayerAccsData[playerid][i][accdb_scale_z] = floatstr(temp_str);

        cache_get_field_content(i, "in_use", temp_str);
        PlayerAccsData[playerid][i][accdb_in_use] = strval(temp_str);

        PlayerAccsCount[playerid]++;
    }

    cache_delete(result);

    ShowPlayerAccsDialog(playerid);
    return 1;
}

stock GetAccessoryNameByModelId(modelid)
{
    new name[64] = "Unknown item";

    for(new i = 0; i < sizeof(AccsData); i++)
    {
        if(AccsData[i][accModel] == modelid)
        {
            if(i < sizeof(AccsNames))
            {
                format(name, sizeof name, "%s", AccsNames[i]);
            }
            break;
        }
    }

    return name;
}

stock ShowPlayerAccsDialog(playerid)
{
    new dialog_text[2048];

    strcat(dialog_text, "{FAD201}number\t{FAD201}name\t{FAD201}status\n");

    for(new i = 0; i < PlayerAccsCount[playerid]; i++)
    {
        new model = PlayerAccsData[playerid][i][accdb_model];
        new in_use = PlayerAccsData[playerid][i][accdb_in_use];

        new acc_name[64];
        format(acc_name, sizeof acc_name, "%s", GetAccessoryNameByModelId(model));

        strcat(dialog_text, "{FFFFFF}");

        new temp[16];
        valstr(temp, i + 1);
        strcat(dialog_text, temp);
        strcat(dialog_text, "\t");

        strcat(dialog_text, acc_name);
        strcat(dialog_text, " {999999}(ID: ");
        valstr(temp, model);
        strcat(dialog_text, temp);
        strcat(dialog_text, ")\t");

        if(in_use) strcat(dialog_text, "{FF0000}[ in use ]");
        else strcat(dialog_text, "{66CC00}[ in stock ]");

        strcat(dialog_text, "\n");
    }

    ShowPlayerDialog(playerid, DIALOG_MYACCS_LIST, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Inventory {FFFFFF}| Select an accessory",
        dialog_text,
        "Select", "Back"
    );

    return 1;
}

stock ShowAccActionsDialog(playerid, listitem)
{
    if(listitem < 0 || listitem >= PlayerAccsCount[playerid]) return 0;

    SetPVarInt(playerid, "selected_acc_listitem", listitem);

    new in_use = PlayerAccsData[playerid][listitem][accdb_in_use];

    new dialog_text[512];

    format(dialog_text, sizeof dialog_text,
        "{FAD201}number\t{FAD201}action\t{FAD201}description\n"\
        "{FFFFFF}1.\t%s\t{999999}Use/remove item\n"\
        "{FFFFFF}2.\t{FAD201}Edit\t{999999}Adjust position\n"\
        "{FFFFFF}3.\t{FF0000}Remove\t{999999}Delete from inventory",
        in_use ? "{FF0000}Remove" : "{66CC00}Wear"
    );

    ShowPlayerDialog(playerid, DIALOG_MYACCS_ACTIONS, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Inventory {FFFFFF}| Accessory management",
        dialog_text,
        "Select", "Back"
    );

    return 1;
}

stock GivePlayerOwnableSkin(playerid, skinid)
{
    new query[256];

    mysql_format(mysql, query, sizeof query,
        "SELECT id FROM inventory_skins WHERE owner_skin=%d AND game_id=%d LIMIT 1",
        GetPlayerAccountID(playerid), skinid);
    new Cache:result = mysql_query(mysql, query, true);

    new rows = cache_num_rows();
    cache_delete(result);

    if(rows > 0)
    {
        ShowNotificationSile(playerid, 2, 6, 0, 0, "You already have this skin", "Open /inventory");
        return 0;
    }

    mysql_format(mysql, query, sizeof query,
        "INSERT INTO inventory_skins (owner_skin, game_id, use_skin) VALUES (%d, %d, 0)",
        GetPlayerAccountID(playerid), skinid);
    mysql_query(mysql, query, false);

    new error = mysql_errno();

    if(error == 0)
    {
        ShowNotificationSile(playerid, 3, 6, 0, 0, "Skin added to inventory!", "Open /inventory");
        return 1;
    }
    else
    {
        new err_msg[128];
        format(err_msg, sizeof err_msg, "Failed to save skin (E:%d)", error);
        ShowNotificationSile(playerid, 0, 6, 0, 0, err_msg, " ");
        return 0;
    }
}

stock GivePlayerOwnableAccessory(playerid, modelid)
{
    new query[512];

    mysql_format(mysql, query, sizeof query,
        "SELECT id FROM inventory_accessories WHERE account_id=%d AND modelid=%d LIMIT 1",
        GetPlayerAccountID(playerid), modelid);
    new Cache:result = mysql_query(mysql, query, true);

    new rows = cache_num_rows();
    cache_delete(result);

    if(rows > 0)
    {
        ShowNotificationSile(playerid, 2, 6, 0, 0, "You already have this accessory", "Open /inventory");
        return 0;
    }

    new acc_index = -1;
    for(new i = 0; i < sizeof(AccsData); i++)
    {
        if(AccsData[i][accModel] == modelid)
        {
            acc_index = i;
            break;
        }
    }

    if(acc_index != -1)
    {
        mysql_format(mysql, query, sizeof query,
            "INSERT INTO inventory_accessories (account_id, modelid, bone, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, scale_x, scale_y, scale_z, in_use, slot) "\
            "VALUES (%d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, 0, -1)",
            GetPlayerAccountID(playerid),
            modelid,
            AccsData[acc_index][accBone],
            AccsData[acc_index][accX], AccsData[acc_index][accY], AccsData[acc_index][accZ],
            AccsData[acc_index][accRotX], AccsData[acc_index][accRotY], AccsData[acc_index][accRotZ],
            AccsData[acc_index][accScaleX], AccsData[acc_index][accScaleY], AccsData[acc_index][accScaleZ]
        );
    }
    else
    {
        mysql_format(mysql, query, sizeof query,
            "INSERT INTO inventory_accessories (account_id, modelid, bone, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, scale_x, scale_y, scale_z, in_use, slot) "\
            "VALUES (%d, %d, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, -1)",
            GetPlayerAccountID(playerid),
            modelid
        );
    }

    mysql_query(mysql, query, false);

    new error = mysql_errno();

    if(error == 0)
    {
        ShowNotificationSile(playerid, 3, 6, 0, 0, "Accessory added!", "Open /inventory");
        return 1;
    }
    else
    {
        new err_msg[128];
        format(err_msg, sizeof err_msg, "Failed to save accessory (E:%d)", error);
        ShowNotificationSile(playerid, 0, 6, 0, 0, err_msg, " ");
        return 0;
    }
}

stock GetAccsIndexByModelId(modelid)
{
    for(new i = 0; i < sizeof(AccsData); i++)
    {
        if(AccsData[i][accModel] == modelid)
        {
            return i;
        }
    }
    return -1;
}

stock CheckDefaultSkin(playerid)
{
    new query[256], Cache:result;
    mysql_format(mysql, query, sizeof query,
        "SELECT id FROM inventory_skins WHERE owner_skin=%d LIMIT 1",
        GetPlayerAccountID(playerid));
    result = mysql_query(mysql, query, true);

    new rows = cache_num_rows();
    cache_delete(result);

    if(!rows)
    {
        new current_skin = GetPlayerSkinEx(playerid);
        mysql_format(mysql, query, sizeof query,
            "INSERT INTO inventory_skins (owner_skin, game_id, use_skin) VALUES (%d, %d, 1)",
            GetPlayerAccountID(playerid), current_skin);
        mysql_query(mysql, query, false);

        ShowNotificationSile(playerid, 3, 6, 0, 0, "Starting skin added", "Open /inventory");
        return 1;
    }
    return 0;
}

stock RemoveAllAccessories(playerid)
{
    for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
    {
        if(IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            RemovePlayerAttachedObject(playerid, i);
        }
    }

    new query[256];
    format(query, sizeof(query), "UPDATE inventory_accessories SET in_use=0 WHERE account_id=%d", GetPlayerAccountID(playerid));
    mysql_query(mysql, query);
}

forward OnLoadPlayerAccessories(playerid);
public OnLoadPlayerAccessories(playerid)
{
    new rows, fields;
    cache_get_data(rows, fields, mysql);

    if(rows)
    {
        new str_val[32];
        new loaded_count = 0;

        for(new i = 0; i < rows; i++)
        {
            new slot, modelid, bone, in_use;
            new Float:pos_x, Float:pos_y, Float:pos_z;
            new Float:rot_x, Float:rot_y, Float:rot_z;
            new Float:scale_x, Float:scale_y, Float:scale_z;

            cache_get_field_content(i, "slot", str_val, mysql, sizeof(str_val));
            slot = strval(str_val);

            cache_get_field_content(i, "modelid", str_val, mysql, sizeof(str_val));
            modelid = strval(str_val);

            cache_get_field_content(i, "bone", str_val, mysql, sizeof(str_val));
            bone = strval(str_val);

            cache_get_field_content(i, "pos_x", str_val, mysql, sizeof(str_val));
            pos_x = floatstr(str_val);

            cache_get_field_content(i, "pos_y", str_val, mysql, sizeof(str_val));
            pos_y = floatstr(str_val);

            cache_get_field_content(i, "pos_z", str_val, mysql, sizeof(str_val));
            pos_z = floatstr(str_val);

            cache_get_field_content(i, "rot_x", str_val, mysql, sizeof(str_val));
            rot_x = floatstr(str_val);

            cache_get_field_content(i, "rot_y", str_val, mysql, sizeof(str_val));
            rot_y = floatstr(str_val);

            cache_get_field_content(i, "rot_z", str_val, mysql, sizeof(str_val));
            rot_z = floatstr(str_val);

            cache_get_field_content(i, "scale_x", str_val, mysql, sizeof(str_val));
            scale_x = floatstr(str_val);

            cache_get_field_content(i, "scale_y", str_val, mysql, sizeof(str_val));
            scale_y = floatstr(str_val);

            cache_get_field_content(i, "scale_z", str_val, mysql, sizeof(str_val));
            scale_z = floatstr(str_val);

            cache_get_field_content(i, "in_use", str_val, mysql, sizeof(str_val));
            in_use = strval(str_val);

            if(in_use && slot >= 0 && slot < MAX_PLAYER_ATTACHED_OBJECTS)
            {
                SetPlayerAttachedObject(playerid, slot, modelid, bone,
                    pos_x, pos_y, pos_z,
                    rot_x, rot_y, rot_z,
                    scale_x, scale_y, scale_z
                );

                gPlayerTempAccData[playerid][slot][0] = float(modelid);
                gPlayerTempAccData[playerid][slot][1] = float(bone);
                gPlayerTempAccData[playerid][slot][2] = pos_x;
                gPlayerTempAccData[playerid][slot][3] = pos_y;
                gPlayerTempAccData[playerid][slot][4] = pos_z;
                gPlayerTempAccData[playerid][slot][5] = rot_x;
                gPlayerTempAccData[playerid][slot][6] = rot_y;
                gPlayerTempAccData[playerid][slot][7] = rot_z;
                gPlayerTempAccData[playerid][slot][8] = scale_x;
                gPlayerTempAccData[playerid][slot][9] = scale_y;
                gPlayerTempAccData[playerid][slot][10] = scale_z;

                loaded_count++;
            }
        }
    }
}

CMD:editacs(playerid)
{
    new count = 0;
    for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
    {
        if(IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            count++;
        }
    }

    if(count == 0)
    {
        ShowNotificationSile(playerid, 2, 6, 0, 0, "No accessories", "Wear an accessory via /inventory");
        return 1;
    }

    ShowEditAcsMainDialog(playerid);
    return 1;
}

stock ShowEditAcsBoneDialog(playerid)
{
    new dialog_text[512];

    strcat(dialog_text, "{FAD201}bone number\t{FAD201}body part name\n");
    strcat(dialog_text, "{FFFFFF}1\tSpine (center back)\n");
    strcat(dialog_text, "{FFFFFF}2\tHead (top)\n");
    strcat(dialog_text, "{FFFFFF}3\tLeft arm (shoulder)\n");
    strcat(dialog_text, "{FFFFFF}4\tRight arm (shoulder)\n");
    strcat(dialog_text, "{FFFFFF}5\tLeft arm (wrist)\n");
    strcat(dialog_text, "{FFFFFF}6\tRight arm (wrist)\n");
    strcat(dialog_text, "{FFFFFF}7\tLeft thigh (leg)\n");
    strcat(dialog_text, "{FFFFFF}8\tRight thigh (leg)\n");
    strcat(dialog_text, "{FFFFFF}9\tLeft leg (foot)\n");
    strcat(dialog_text, "{FFFFFF}10\tRight leg (foot)\n");

    ShowPlayerDialog(playerid, DIALOG_EDITACS_BONE, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Accessory editor {FFFFFF}| Select bone for attachment",
        dialog_text,
        "Apply", "Back"
    );
}

stock ShowEditAcsMainDialog(playerid)
{
    new dialog_text[1024];
    new acc_name[64];

    strcat(dialog_text, "{FAD201}slot\t{FAD201}accessory name\t{FAD201}attached bone\n");

    for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
    {
        if(IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            new modelid = floatround(gPlayerTempAccData[playerid][i][0]);
            new bone = floatround(gPlayerTempAccData[playerid][i][1]);

            format(acc_name, sizeof acc_name, "%s", GetAccessoryNameByModelId(modelid));

            format(dialog_text, sizeof dialog_text, "%s{FFFFFF}%d\t%s\t{999999}%s\n",
                dialog_text, i, acc_name, GetBoneName(bone));
        }
    }

    ShowPlayerDialog(playerid, DIALOG_EDITACS_MAIN, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Accessory editor {FFFFFF}| Select item to configure",
        dialog_text,
        "Select", "Close"
    );
}

stock ShowEditAcsParamsDialog(playerid, slot)
{
    if(!IsPlayerAttachedObjectSlotUsed(playerid, slot))
    {
        SendClientMessage(playerid, -1, "{FF0000}Error: slot not in use");
        return 0;
    }

    SetPVarInt(playerid, "editing_acc_slot", slot);

    new modelid = floatround(gPlayerTempAccData[playerid][slot][0]);
    new bone = floatround(gPlayerTempAccData[playerid][slot][1]);
    new acc_name[64];
    format(acc_name, sizeof acc_name, "%s", GetAccessoryNameByModelId(modelid));

    new dialog_text[1024];

    format(dialog_text, sizeof dialog_text,
        "{FAD201}parameter setting\t{FAD201}parameter info\n"\
        "Position\t{FAD201}X:%.2f Y:%.2f Z:%.2f\n"\
        "Rotation\t{FAD201}X:%.1f Y:%.1f Z:%.1f\n"\
        "Scale\t{FAD201}X:%.2f Y:%.2f Z:%.2f\n"\
        "{66CC00}Change attachment bone\t{999999}Current: %s\n"\
        "{FF9900}Save changes\t{999999}Write to database\n"\
        "{FF0000}Reset settings\t{999999}Restore defaults",
        gPlayerTempAccData[playerid][slot][2],
        gPlayerTempAccData[playerid][slot][3],
        gPlayerTempAccData[playerid][slot][4],
        gPlayerTempAccData[playerid][slot][5],
        gPlayerTempAccData[playerid][slot][6],
        gPlayerTempAccData[playerid][slot][7],
        gPlayerTempAccData[playerid][slot][8],
        gPlayerTempAccData[playerid][slot][9],
        gPlayerTempAccData[playerid][slot][10],
        GetBoneName(bone)
    );

    new header[128];
    format(header, sizeof header, "{FAD201}Accessory editor {FFFFFF}| %s | Bone: %s", acc_name, GetBoneName(bone));

    ShowPlayerDialog(playerid, DIALOG_EDITACS_PARAMS, DIALOG_STYLE_TABLIST_HEADERS,
        header,
        dialog_text,
        "Change", "Back"
    );

    return 1;
}

stock ShowEditAcsActionsDialog(playerid, param_index)
{
    new slot = GetPVarInt(playerid, "editing_acc_slot");

    new param_names[][] = {
        "Position X", "Position Y", "Position Z",
        "Rotation X", "Rotation Y", "Rotation Z",
        "Scale X", "Scale Y", "Scale Z"
    };

    SetPVarInt(playerid, "editing_param", param_index);

    new dialog_text[512];
    new header[128];

    new value_str[32];
    format(value_str, sizeof value_str, "%.3f", gPlayerTempAccData[playerid][slot][param_index + 2]);

    format(header, sizeof header,
        "{FAD201}Changing parameter {FFFFFF}| %s | Current value: %s",
        param_names[param_index],
        value_str
    );

    format(dialog_text, sizeof dialog_text,
        "{FAD201}available action\t{FAD201}action description\n"\
        "{66CC00}Increase value\t{FFFFFF}Add +0.1\n"\
        "{FF0000}Decrease value\t{FFFFFF}Subtract -0.1\n"\
        "{FAD201}Exact value\t{999999}Enter manually"
    );

    ShowPlayerDialog(playerid, DIALOG_EDITACS_ACTIONS, DIALOG_STYLE_TABLIST_HEADERS,
        header,
        dialog_text,
        "Apply", "Back"
    );
}

stock ShowEditAcsSubParamsDialog(playerid, group)
{
    new slot = GetPVarInt(playerid, "editing_acc_slot");
    new dialog_text[512];
    new header[128];

    SetPVarInt(playerid, "edit_group", group);

    switch(group)
    {
        case 0:
        {
            format(header, sizeof header, "{FAD201}Parameter editor {FFFFFF}| Adjust accessory position");

            format(dialog_text, sizeof dialog_text,
                "{FAD201}parameter name\t{FAD201}current value\n"\
                "Position on X axis\t{FAD201}%f\n"\
                "Position on Y axis\t{FAD201}%f\n"\
                "Position on Z axis\t{FAD201}%f",
                gPlayerTempAccData[playerid][slot][2],
                gPlayerTempAccData[playerid][slot][3],
                gPlayerTempAccData[playerid][slot][4]
            );
        }
        case 1:
        {
            format(header, sizeof header, "{FAD201}Parameter editor {FFFFFF}| Adjust accessory rotation");

            format(dialog_text, sizeof dialog_text,
                "{FAD201}parameter name\t{FAD201}current value\n"\
                "Rotation on X axis\t{FAD201}%f\n"\
                "Rotation on Y axis\t{FAD201}%f\n"\
                "Rotation on Z axis\t{FAD201}%f",
                gPlayerTempAccData[playerid][slot][5],
                gPlayerTempAccData[playerid][slot][6],
                gPlayerTempAccData[playerid][slot][7]
            );
        }
        case 2:
        {
            format(header, sizeof header, "{FAD201}Parameter editor {FFFFFF}| Adjust accessory scale");

            format(dialog_text, sizeof dialog_text,
                "{FAD201}parameter name\t{FAD201}current value\n"\
                "Scale on X axis\t{FAD201}%f\n"\
                "Scale on Y axis\t{FAD201}%f\n"\
                "Scale on Z axis\t{FAD201}%f",
                gPlayerTempAccData[playerid][slot][8],
                gPlayerTempAccData[playerid][slot][9],
                gPlayerTempAccData[playerid][slot][10]
            );
        }
    }

    ShowPlayerDialog(playerid, DIALOG_EDITACS_SUBPARAMS, DIALOG_STYLE_TABLIST_HEADERS,
        header,
        dialog_text,
        "Select", "Back"
    );
}

stock ShowEditAcsDialogNew(playerid)
{
    new dialog_text[512];

    format(dialog_text, sizeof dialog_text,
        "{FAD201}parameter\t{FAD201}value\n"\
        "Left/Right\t{FFFFFF}%.3f\n"\
        "Up/Down\t{FFFFFF}%.3f\n"\
        "Away/Toward\t{FFFFFF}%.3f\n"\
        "Rotation X\t{FFFFFF}%.1f\n"\
        "Rotation Y\t{FFFFFF}%.1f\n"\
        "Rotation Z\t{FFFFFF}%.1f\n"\
        "Scale\t{FFFFFF}%.2f\n"\
        "{66CC00}Save changes\t{999999}To database\n"\
        "{FF0000}Exit\t{999999}Without saving",
        GetPVarFloat(playerid, "edit_z"),
        GetPVarFloat(playerid, "edit_x"),
        GetPVarFloat(playerid, "edit_y"),
        GetPVarFloat(playerid, "edit_rX"),
        GetPVarFloat(playerid, "edit_rY"),
        GetPVarFloat(playerid, "edit_rZ"),
        GetPVarFloat(playerid, "edit_scaleX")
    );

    ShowPlayerDialog(playerid, DIALOG_EDITACS_NEW_MAIN, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Accessory editor {FFFFFF}| Select parameter",
        dialog_text,
        "Change", "Close"
    );
}

stock ShowEditAcsActionsDialogNew(playerid, param_type)
{
    new param_names[][] = {
        "Left/Right", "Up/Down", "Away/Toward",
        "Rotation X", "Rotation Y", "Rotation Z", "Scale"
    };

    new Float:current_value;

    switch(param_type)
    {
        case 0: current_value = GetPVarFloat(playerid, "edit_z");
        case 1: current_value = GetPVarFloat(playerid, "edit_x");
        case 2: current_value = GetPVarFloat(playerid, "edit_y");
        case 3: current_value = GetPVarFloat(playerid, "edit_rX");
        case 4: current_value = GetPVarFloat(playerid, "edit_rY");
        case 5: current_value = GetPVarFloat(playerid, "edit_rZ");
        case 6: current_value = GetPVarFloat(playerid, "edit_scaleX");
    }

    SetPVarInt(playerid, "edit_param_type", param_type);

    new dialog_text[256], header[128];

    format(header, sizeof header, "{FAD201}Editor {FFFFFF}| %s | Value: %.3f", param_names[param_type], current_value);

    format(dialog_text, sizeof dialog_text,
        "{FAD201}action\t{FAD201}change\n"\
        "{66CC00}Increase\t{FFFFFF}+\n"\
        "{FF0000}Decrease\t{FFFFFF}-"
    );

    ShowPlayerDialog(playerid, DIALOG_EDITACS_NEW_ACTIONS, DIALOG_STYLE_TABLIST_HEADERS,
        header,
        dialog_text,
        "Apply", "Back"
    );
}

stock UpdateAccessoryNew(playerid)
{
    new slot = GetPVarInt(playerid, "edit_acc_slot");

    gPlayerTempAccData[playerid][slot][2] = GetPVarFloat(playerid, "edit_x");
    gPlayerTempAccData[playerid][slot][3] = GetPVarFloat(playerid, "edit_y");
    gPlayerTempAccData[playerid][slot][4] = GetPVarFloat(playerid, "edit_z");
    gPlayerTempAccData[playerid][slot][5] = GetPVarFloat(playerid, "edit_rX");
    gPlayerTempAccData[playerid][slot][6] = GetPVarFloat(playerid, "edit_rY");
    gPlayerTempAccData[playerid][slot][7] = GetPVarFloat(playerid, "edit_rZ");
    gPlayerTempAccData[playerid][slot][8] = GetPVarFloat(playerid, "edit_scaleX");
    gPlayerTempAccData[playerid][slot][9] = GetPVarFloat(playerid, "edit_scaleY");
    gPlayerTempAccData[playerid][slot][10] = GetPVarFloat(playerid, "edit_scaleZ");

    RemovePlayerAttachedObject(playerid, slot);

    SetPlayerAttachedObject(
        playerid,
        slot,
        floatround(gPlayerTempAccData[playerid][slot][0]),
        floatround(gPlayerTempAccData[playerid][slot][1]),
        gPlayerTempAccData[playerid][slot][2],
        gPlayerTempAccData[playerid][slot][3],
        gPlayerTempAccData[playerid][slot][4],
        gPlayerTempAccData[playerid][slot][5],
        gPlayerTempAccData[playerid][slot][6],
        gPlayerTempAccData[playerid][slot][7],
        gPlayerTempAccData[playerid][slot][8],
        gPlayerTempAccData[playerid][slot][9],
        gPlayerTempAccData[playerid][slot][10]
    );
}

stock SaveAccessoryNew(playerid)
{
    new db_id = GetPVarInt(playerid, "edit_acc_db_id");
    new slot = GetPVarInt(playerid, "edit_acc_slot");

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "UPDATE inventory_accessories SET \
        pos_x=%f, pos_y=%f, pos_z=%f, \
        rot_x=%f, rot_y=%f, rot_z=%f, \
        scale_x=%f, scale_y=%f, scale_z=%f \
        WHERE id=%d",
        GetPVarFloat(playerid, "edit_x"),
        GetPVarFloat(playerid, "edit_y"),
        GetPVarFloat(playerid, "edit_z"),
        GetPVarFloat(playerid, "edit_rX"),
        GetPVarFloat(playerid, "edit_rY"),
        GetPVarFloat(playerid, "edit_rZ"),
        GetPVarFloat(playerid, "edit_scaleX"),
        GetPVarFloat(playerid, "edit_scaleY"),
        GetPVarFloat(playerid, "edit_scaleZ"),
        db_id
    );

    mysql_query(mysql, query, false);

    DeletePVar(playerid, "edit_acc_db_id");
    DeletePVar(playerid, "edit_acc_slot");
    DeletePVar(playerid, "edit_acc_modelid");
    DeletePVar(playerid, "edit_acc_bone");
    DeletePVar(playerid, "edit_x");
    DeletePVar(playerid, "edit_y");
    DeletePVar(playerid, "edit_z");
    DeletePVar(playerid, "edit_rX");
    DeletePVar(playerid, "edit_rY");
    DeletePVar(playerid, "edit_rZ");
    DeletePVar(playerid, "edit_scaleX");
    DeletePVar(playerid, "edit_scaleY");
    DeletePVar(playerid, "edit_scaleZ");
    DeletePVar(playerid, "edit_param_type");

    SendClientMessage(playerid, -1, "{66CC00}Accessory settings saved!");
}

stock LoadPlayerPlates(playerid)
{
    printf("[PLATES DEBUG] ===== LOAD PLAYER PLATES START =====");
    printf("[PLATES DEBUG] LoadPlayerPlates for player %d (account: %d)", playerid, GetPlayerAccountID(playerid));

    // Clear old data before loading
    printf("[PLATES DEBUG] Clearing old plates data for player %d", playerid);
    for(new i = 0; i < MAX_PLAYER_PLATES; i++)
    {
        PlayerPlatesData[playerid][i][plate_sql_id] = 0;
        PlayerPlatesData[playerid][i][plate_country] = 0;
        PlayerPlatesData[playerid][i][plate_text][0] = '\0';
        PlayerPlatesData[playerid][i][plate_region][0] = '\0';
    }
    PlayerPlatesCount[playerid] = 0;
    printf("[PLATES DEBUG] Old data cleared");

    new query[256];
    mysql_format(mysql, query, sizeof query,
        "SELECT id, country, plate_text, region FROM inventory_plates WHERE owner_id=%d ORDER BY id ASC",
        GetPlayerAccountID(playerid));

    printf("[PLATES DEBUG] Load query: %s", query);

    new Cache:result = mysql_query(mysql, query, true);
    printf("[PLATES DEBUG] Query executed, result handle: %d", _:result);

    new rows = cache_num_rows();
    printf("[PLATES DEBUG] Found %d plates in database for player %d", rows, playerid);

    if(!rows)
    {
        printf("[PLATES DEBUG] No plates found, count set to 0");
        cache_delete(result);
        printf("[PLATES DEBUG] Cache deleted");
        printf("[PLATES DEBUG] ===== LOAD PLAYER PLATES END (NO PLATES) =====");
        return 1;
    }

    printf("[PLATES DEBUG] Starting to load %d plates (MAX_PLAYER_PLATES: %d)", rows, MAX_PLAYER_PLATES);

    PlayerPlatesCount[playerid] = 0;

    for(new i = 0; i < rows && i < MAX_PLAYER_PLATES; i++)
    {
        printf("[PLATES DEBUG] Loading plate %d/%d", i+1, rows);

        new plate_id = cache_get_field_content_int(i, "id");
        PlayerPlatesData[playerid][i][plate_sql_id] = plate_id;
        printf("[PLATES DEBUG]   - SQL_ID: %d", plate_id);

        new country = cache_get_field_content_int(i, "country");
        PlayerPlatesData[playerid][i][plate_country] = country;
        printf("[PLATES DEBUG]   - country: %d", country);

        cache_get_field_content(i, "plate_text", PlayerPlatesData[playerid][i][plate_text], mysql, 32);
        printf("[PLATES DEBUG]   - plate_text: '%s'", PlayerPlatesData[playerid][i][plate_text]);

        cache_get_field_content(i, "region", PlayerPlatesData[playerid][i][plate_region], mysql, 8);
        printf("[PLATES DEBUG]   - region: '%s'", PlayerPlatesData[playerid][i][plate_region]);

        PlayerPlatesCount[playerid]++;
        printf("[PLATES DEBUG]   - loaded, total count now: %d", PlayerPlatesCount[playerid]);
    }

    printf("[PLATES DEBUG] Total plates loaded: %d", PlayerPlatesCount[playerid]);
    printf("[PLATES DEBUG] Cache will now be deleted");

    cache_delete(result);
    printf("[PLATES DEBUG] Cache deleted");

    printf("[PLATES DEBUG] ===== LOAD PLAYER PLATES END =====");
    return 1;
}

stock ShowPlayerPlatesDialog(playerid)
{
    printf("[PLATES DEBUG] ===== SHOW PLAYER PLATES DIALOG =====");
    printf("[PLATES DEBUG] ShowPlayerPlatesDialog for player %d", playerid);
    printf("[PLATES DEBUG] PlayerPlatesCount[playerid]: %d", PlayerPlatesCount[playerid]);

    new dialog_text[2048];
    dialog_text[0] = '\0';

    strcat(dialog_text, "{FAD201}¹\t{FAD201}License plate\t{FAD201}Country\n");

    for(new i = 0; i < PlayerPlatesCount[playerid]; i++)
    {
        printf("[PLATES DEBUG] Adding plate %d to dialog:", i);
        printf("[PLATES DEBUG]   - SQL_ID: %d", PlayerPlatesData[playerid][i][plate_sql_id]);
        printf("[PLATES DEBUG]   - text: '%s'", PlayerPlatesData[playerid][i][plate_text]);
        printf("[PLATES DEBUG]   - region: '%s'", PlayerPlatesData[playerid][i][plate_region]);
        printf("[PLATES DEBUG]   - country: %d", PlayerPlatesData[playerid][i][plate_country]);

        strcat(dialog_text, "{FFFFFF}");

        new temp[16];
        valstr(temp, i + 1);
        strcat(dialog_text, temp);
        strcat(dialog_text, "\t");

        new plate_display[32];
        new country_name[16];
        new country = PlayerPlatesData[playerid][i][plate_country];

        switch(country)
        {
            case 0: country_name = "RU";
            case 1: country_name = "UA";
            case 2: country_name = "BY";
            case 3: country_name = "KZ";
            default: country_name = "??";
        }

        if(country == 0 || country == 3)
        {
            format(plate_display, sizeof plate_display, "%s[%s]",
                PlayerPlatesData[playerid][i][plate_text],
                PlayerPlatesData[playerid][i][plate_region]);
        }
        else
        {
            format(plate_display, sizeof plate_display, "%s",
                PlayerPlatesData[playerid][i][plate_text]);
        }

        strcat(dialog_text, plate_display);
        strcat(dialog_text, "\t");
        strcat(dialog_text, country_name);
        strcat(dialog_text, "\n");
    }

    printf("[PLATES DEBUG] Dialog text built, length: %d", strlen(dialog_text));
    printf("[PLATES DEBUG] Showing dialog DIALOG_MYPLATES_LIST (ID: %d)", DIALOG_MYPLATES_LIST);

    ShowPlayerDialog(playerid, DIALOG_MYPLATES_LIST, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Plate inventory | Select a plate to install on the vehicle",
        dialog_text,
        "Select", "Back"
    );

    printf("[PLATES DEBUG] ShowPlayerDialog called");
    printf("[PLATES DEBUG] ===== SHOW PLAYER PLATES DIALOG END =====");

    return 1;
}

stock ShowPlateActionsDialog(playerid, listitem)
{
    if(listitem < 0 || listitem >= PlayerPlatesCount[playerid]) return 0;

    SetPVarInt(playerid, "selected_plate_listitem", listitem);

    new country = PlayerPlatesData[playerid][listitem][plate_country];
    new country_name[8];

    switch(country)
    {
        case 0: country_name = "RU";
        case 1: country_name = "UA";
        case 2: country_name = "BY";
        case 3: country_name = "KZ";
        default: country_name = "??";
    }

    new dialog_text[512];
    format(dialog_text, sizeof dialog_text,
        "{FAD201}¹\t{FAD201}Action\t{FAD201}Description\n"\
        "{FFFFFF}1.\t{66CC00}Install\t{999999}Install this plate (%s) on current vehicle\n"\
        "{FFFFFF}2.\t{FF0000}Delete\t{999999}Permanently delete plate from inventory",
        country_name
    );

    ShowPlayerDialog(playerid, DIALOG_MYPLATES_ACTIONS, DIALOG_STYLE_TABLIST_HEADERS,
        "{FAD201}Plate inventory | Plate management",
        dialog_text,
        "Select", "Back"
    );

    return 1;
}

stock IsPlateOnVehicle(playerid)
{
    printf("[PLATES DEBUG] IsPlateOnVehicle called for player %d", playerid);

    new vehicleid = GetPlayerOwnableCar(playerid);
    printf("[PLATES DEBUG] IsPlateOnVehicle - vehicleid: %d", vehicleid);

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        printf("[PLATES DEBUG] IsPlateOnVehicle - no ownable vehicle");
        return 0;
    }

    new index = GetVehicleData(vehicleid, V_ACTION_ID);
    printf("[PLATES DEBUG] IsPlateOnVehicle - vehicle data index: %d", index);

    if(index == -1)
    {
        printf("[PLATES DEBUG] IsPlateOnVehicle - invalid vehicle data index");
        return 0;
    }

    printf("[PLATES DEBUG] IsPlateOnVehicle - OC_NUMBER_TYPE: %d, OC_NUMBER: '%s'",
           g_ownable_car[index][OC_NUMBER_TYPE], g_ownable_car[index][OC_NUMBER]);

    if(g_ownable_car[index][OC_NUMBER_TYPE] != 0)
    {
        printf("[PLATES DEBUG] IsPlateOnVehicle - TRUE (has plates)");
        return 1;
    }

    printf("[PLATES DEBUG] IsPlateOnVehicle - FALSE (no plates)");
    return 0;
}

stock GetCurrentVehiclePlate(playerid, plate_text[], plate_region[], &number_type)
{
    new vehicleid = GetPlayerOwnableCar(playerid);

    if(vehicleid == INVALID_VEHICLE_ID)
        return 0;

    new index = GetVehicleData(vehicleid, V_ACTION_ID);

    if(index == -1)
        return 0;

    strcpy(plate_text, g_ownable_car[index][OC_NUMBER], 16);
    strcpy(plate_region, g_ownable_car[index][OC_REGION], 4);
    number_type = g_ownable_car[index][OC_NUMBER_TYPE];

    return 1;
}

stock ApplyPlateToVehicle(playerid, listitem)
{
    printf("[PLATES DEBUG] ========== APPLY PLATE START ==========");
    printf("[PLATES DEBUG] ApplyPlateToVehicle - playerid: %d, listitem: %d", playerid, listitem);
    printf("[PLATES DEBUG] PlayerPlatesCount[playerid]: %d", PlayerPlatesCount[playerid]);

    if(listitem < 0 || listitem >= PlayerPlatesCount[playerid])
    {
        printf("[PLATES ERROR] ApplyPlateToVehicle: listitem %d out of range (count: %d)", listitem, PlayerPlatesCount[playerid]);
        return 0;
    }

    // Save plate data to local variables BEFORE any changes
    new plate_db_id = PlayerPlatesData[playerid][listitem][plate_sql_id];
    new plate_text_value[32], region_value[8];
    new original_number_type = PlayerPlatesData[playerid][listitem][plate_country];

    strcpy(plate_text_value, PlayerPlatesData[playerid][listitem][plate_text]);
    strcpy(region_value, PlayerPlatesData[playerid][listitem][plate_region]);

    printf("[PLATES DEBUG] plate_db_id: %d", plate_db_id);
    printf("[PLATES DEBUG] Original plate data - text: '%s', region: '%s', country: %d",
           plate_text_value, region_value, original_number_type);

    if(plate_db_id <= 0)
    {
        printf("[PLATES ERROR] ApplyPlateToVehicle: invalid plate_sql_id: %d", plate_db_id);
        return 0;
    }

    new vehicleid = GetPlayerOwnableCar(playerid);
    printf("[PLATES DEBUG] vehicleid from GetPlayerOwnableCar: %d", vehicleid);

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        printf("[PLATES DEBUG] No ownable vehicle nearby");
        SendClientMessage(playerid, 0x999999FF, "You don't have your own vehicle nearby");
        return 0;
    }

    new Float: x, Float: y, Float: z;
    GetVehiclePos(vehicleid, x, y, z);
    printf("[PLATES DEBUG] Vehicle position: %.2f, %.2f, %.2f", x, y, z);

    if(!IsPlayerInRangeOfPoint(playerid, 10.0, x, y, z))
    {
        printf("[PLATES DEBUG] Player not near vehicle (distance > 10.0)");
        SendClientMessage(playerid, 0x999999FF, "You must be near the vehicle");
        return 0;
    }

    printf("[PLATES DEBUG] Checking IsPlateOnVehicle...");
    if(IsPlateOnVehicle(playerid))
    {
        printf("[PLATES DEBUG] IsPlateOnVehicle returned TRUE - vehicle already has plates");
        ShowNotificationSile(playerid, 2, 7, -1, -1, "Your vehicle already has plates.", "");
        return 0;
    }
    printf("[PLATES DEBUG] IsPlateOnVehicle returned FALSE - vehicle has no plates");

    new number_type = original_number_type;

    if(number_type == 0)
        number_type = 1;
    else if(number_type == 1)
        number_type = 2;
    else if(number_type == 2)
        number_type = 3;
    else if(number_type == 3)
        number_type = 4;

    printf("[PLATES DEBUG] ApplyPlateToVehicle - plate_sql_id: %d, number_type: %d -> %d",
           plate_db_id, original_number_type, number_type);

    new index = GetVehicleData(vehicleid, V_ACTION_ID);
    printf("[PLATES DEBUG] Vehicle data index: %d", index);

    if(index == -1)
    {
        printf("[PLATES ERROR] GetVehicleData returned -1 for vehicle %d", vehicleid);
        SendClientMessage(playerid, 0x999999FF, "Error getting vehicle data");
        return 0;
    }

    printf("[PLATES DEBUG] Current vehicle data - number: '%s', region: '%s', number_type: %d",
           g_ownable_car[index][OC_NUMBER], g_ownable_car[index][OC_REGION], g_ownable_car[index][OC_NUMBER_TYPE]);

    SetVehicleNumberPlateEx(vehicleid, number_type, plate_text_value, region_value);
    printf("[PLATES DEBUG] SetVehicleNumberPlateEx called");

    strcpy(g_ownable_car[index][OC_NUMBER], plate_text_value);
    strcpy(g_ownable_car[index][OC_REGION], region_value);
    g_ownable_car[index][OC_NUMBER_TYPE] = number_type;

    printf("[PLATES DEBUG] Updated vehicle data - number: '%s', region: '%s', number_type: %d",
           g_ownable_car[index][OC_NUMBER], g_ownable_car[index][OC_REGION], g_ownable_car[index][OC_NUMBER_TYPE]);

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "UPDATE ownable_cars SET number='%s', region='%s', number_type='%d' WHERE id=%d LIMIT 1",
        plate_text_value, region_value, number_type, GetOwnableCarData(index, OC_SQL_ID));

    printf("[PLATES DEBUG] Update car SQL: %s", query);
    mysql_query(mysql, query, false);

    new mysql_error = mysql_errno(mysql);
    if(mysql_error != 0)
    {
        printf("[PLATES ERROR] MySQL error %d when updating car", mysql_error);
    }

    mysql_format(mysql, query, sizeof query,
        "DELETE FROM inventory_plates WHERE id = %d", plate_db_id);

    printf("[PLATES DEBUG] Delete from inventory SQL: %s", query);
    mysql_query(mysql, query, false);

    mysql_error = mysql_errno(mysql);
    if(mysql_error != 0)
    {
        printf("[PLATES ERROR] MySQL error %d when deleting from inventory", mysql_error);
    }

    printf("[PLATES DEBUG] Calling LoadPlayerPlates...");
    LoadPlayerPlates(playerid);
    printf("[PLATES DEBUG] Player plates reloaded, new count: %d", PlayerPlatesCount[playerid]);

    // IMPORTANT: Don't show dialog here! Only notification
    // Dialog will close automatically after selection, no need to show new one

    ApplyAnimationEx(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0, 1);
    ShowNotificationSile(playerid, 3, 7, -1, -1, "You successfully installed the license plate.");

    printf("[PLATES DEBUG] ========== APPLY PLATE SUCCESS ==========");
    return 1;
}

stock DeletePlateFromInventory(playerid, listitem)
{
    if(listitem < 0 || listitem >= PlayerPlatesCount[playerid])
    {
        printf("[PLATES ERROR] DeletePlateFromInventory: listitem %d out of range (count: %d)", listitem, PlayerPlatesCount[playerid]);
        return 0;
    }

    new plate_db_id = PlayerPlatesData[playerid][listitem][plate_sql_id];

    printf("[PLATES DEBUG] DeletePlateFromInventory - playerid: %d, listitem: %d, plate_sql_id: %d",
           playerid, listitem, plate_db_id);

    if(plate_db_id <= 0)
    {
        printf("[PLATES ERROR] DeletePlateFromInventory: invalid plate_sql_id: %d", plate_db_id);
        return 0;
    }

    new plate_text_value[32], region_value[8];

    strcpy(plate_text_value, PlayerPlatesData[playerid][listitem][plate_text]);
    strcpy(region_value, PlayerPlatesData[playerid][listitem][plate_region]);

    printf("[PLATES DEBUG] Deleting plate: '%s' [%s] with SQL ID: %d",
           plate_text_value, region_value, plate_db_id);

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "DELETE FROM inventory_plates WHERE id = %d", plate_db_id);

    printf("[PLATES DEBUG] SQL Query: %s", query);

    mysql_query(mysql, query, false);

    if(mysql_errno(mysql) != 0)
    {
        printf("[PLATES ERROR] MySQL error %d", mysql_errno(mysql));
        SendClientMessage(playerid, 0xFF0000FF, "Database error when deleting");
        return 0;
    }

    LoadPlayerPlates(playerid);

    new fmt_text[144];
    format(fmt_text, sizeof fmt_text, "Plate \"%s %s\" removed from inventory",
           plate_text_value, region_value);
    SendClientMessage(playerid, 0x999999FF, fmt_text);

    if(PlayerPlatesCount[playerid] > 0)
        ShowPlayerPlatesDialog(playerid);
    else
        ShowNotificationSile(playerid, 2, 6, 0, 0, "Inventory empty", "Buy plates in the shop");

    return 1;
}

stock RemovePlateFromVehicle(playerid)
{
    new vehicleid = GetPlayerOwnableCar(playerid);

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(playerid, 0x999999FF, "Error");
        return 0;
    }

    new Float: x, Float: y, Float: z;
    GetVehiclePos(vehicleid, x, y, z);

    if(!IsPlayerInRangeOfPoint(playerid, 10.0, x, y, z))
    {
        SendClientMessage(playerid, 0x999999FF, "You must be near the vehicle");
        return 0;
    }

    if(!IsPlateOnVehicle(playerid))
    {
        SendClientMessage(playerid, -1, "The vehicle has no plates.");
        return 0;
    }

    new index = GetVehicleData(vehicleid, V_ACTION_ID);

    if(index == -1)
    {
        SendClientMessage(playerid, 0x999999FF, "Error getting vehicle data");
        return 0;
    }

    new plate_text_value[16], region_value[4];
    new current_type = g_ownable_car[index][OC_NUMBER_TYPE];
    new inventory_type = current_type;

    if(current_type == 4)
        inventory_type = 83;
    else if(current_type == 3)
        inventory_type = 82;
    else if(current_type == 2)
        inventory_type = 81;
    else if(current_type == 1)
        inventory_type = 59;

    strcpy(plate_text_value, g_ownable_car[index][OC_NUMBER], 16);
    strcpy(region_value, g_ownable_car[index][OC_REGION], 4);

    printf("[PLATES DEBUG] RemovePlateFromVehicle - plate: '%s' [%s], current_type: %d -> inventory_type: %d",
           plate_text_value, region_value, current_type, inventory_type);

           new joinpl[256];
           JoinPlate(plate_text_value, region_value, joinpl, sizeof(joinpl))
    new freeSlot = Inventory_GetFreeSlot(playerid);
    if(freeSlot == -1)
    {
        ShowNotificationSile(playerid, 2, 7, -1, -1, "No free space in inventory!", "");
        return 0;
    }
    Inventory_AddItem(playerid, inventory_type, freeSlot, 1, joinpl);

    SaveInventoryItem(playerid, freeSlot);



    SetVehicleNumberPlateEx(vehicleid, 0, "------", "000");

    format(g_ownable_car[index][OC_NUMBER], 7, "none");
    format(g_ownable_car[index][OC_REGION], 4, "--");
    g_ownable_car[index][OC_NUMBER_TYPE] = 0;

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "UPDATE ownable_cars SET number='none', region='--', number_type='0' WHERE id='%d' LIMIT 1",
        GetOwnableCarData(index, OC_SQL_ID));

    printf("[PLATES DEBUG] Update car SQL: %s", query);
    mysql_query(mysql, query, false);

    if(mysql_errno(mysql) != 0)
    {
        printf("[PLATES ERROR] MySQL error %d when updating car", mysql_errno(mysql));
    }

    ApplyAnimationEx(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0, 1);

    SendClientMessage(playerid, -1, "You successfully removed the license plates, they are now in your inventory.");

    return 1;
}

/*stock strcpy(dest[], source[], maxlength = sizeof(dest))
{
    new i;
    while(i < maxlength - 1 && source[i] != EOS)
    {
        dest[i] = source[i];
        i++;
    }
    dest[i] = EOS;
    return i;
}*/
stock strcpy(dest[], const source[], len = sizeof(dest))
{
    dest[0] = 0;
    strcat(dest, source, len);
}
CMD:checkplates(playerid)
{
    new vehicleid = GetPlayerOwnableCar(playerid);

    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(playerid, -1, "You don't have your own vehicle nearby");
        return 1;
    }

    new index = GetVehicleData(vehicleid, V_ACTION_ID);

    if(index == -1)
    {
        SendClientMessage(playerid, -1, "Error getting vehicle data");
        return 1;
    }

    new msg[256];
    format(msg, sizeof msg, "Vehicle: number='%s', region='%s', type=%d",
           g_ownable_car[index][OC_NUMBER],
           g_ownable_car[index][OC_REGION],
           g_ownable_car[index][OC_NUMBER_TYPE]);
    SendClientMessage(playerid, -1, msg);

    format(msg, sizeof msg, "Has plates: %s", IsPlateOnVehicle(playerid) ? "YES" : "NO");
    SendClientMessage(playerid, -1, msg);

    return 1;
}

   	 
        case 1:
        {
            new type;
            JSON_GetInt(JSONObject, "t", type);

            switch(type)
            {
                case 0:
                {
                    if(gPlayerPlatePrice[playerid] == 0)
                    {
                        new Node:price_response = JSON_Object(
                    "t", JSON_Int(0),
                    "p", JSON_Int(100000),
                    "pr", JSON_Int(30000)
                );
                    }
                    else
                    {
                        new Node:price_response = JSON_Object(
                    "t", JSON_Int(0),
                    "p", JSON_Int(1750),
                    "pr", JSON_Int(500)
                );
                    }
                }
                case 1:
                {
               	if(gPlayerPlatePrice[playerid] == 0)
                    {
                        new Node:price_response = JSON_Object(
                    "t", JSON_Int(0),
                    "p", JSON_Int(100000),
                    "pr", JSON_Int(30000)
                );
                    }
                    else
                    {
                        new Node:price_response = JSON_Object(
                    "t", JSON_Int(0),
                    "p", JSON_Int(1750),
                    "pr", JSON_Int(500)
                );
                    }
                    new country;
                    JSON_GetInt(JSONObject, "c", country);

                    gPlayerCountry[playerid] = country;

                    new bool:found_free = false;
                    new attempts = 0;

                    while(!found_free && attempts < 50)
                    {
                        GenerateRandomPlate(country, gPlayerPlate[playerid], sizeof(gPlayerPlate[]));
                        GenerateRandomRegion(country, gPlayerRegion[playerid], sizeof(gPlayerRegion[]));

                        new query_check[512];
                        new Cache:result_check;
                        new rows;

                        mysql_format(mysql, query_check, sizeof query_check,
                            "SELECT COUNT(*) as total FROM inventory_plates WHERE plate_text = '%s' AND region = '%s'",
                            gPlayerPlate[playerid], gPlayerRegion[playerid]);

                        result_check = mysql_query(mysql, query_check, true);
                        rows = cache_num_rows();

                        if(rows > 0)
                        {
                            new total = cache_get_field_content_int(0, "total");
                            cache_delete(result_check);

                            if(total > 0)
                            {
                                attempts++;
                                continue;
                            }
                        }
                        else cache_delete(result_check);

                        mysql_format(mysql, query_check, sizeof query_check,
                            "SELECT COUNT(*) as total FROM ownable_cars WHERE number = '%s' AND region = '%s'",
                            gPlayerPlate[playerid], gPlayerRegion[playerid]);

                        result_check = mysql_query(mysql, query_check, true);
                        rows = cache_num_rows();

                        if(rows > 0)
                        {
                            new total = cache_get_field_content_int(0, "total");
                            cache_delete(result_check);

                            if(total > 0)
                            {
                                attempts++;
                                continue;
                            }
                        }
                        else cache_delete(result_check);

                        found_free = true;
                    }

                    if(!found_free)
                    {
                        SendHint(playerid, "Error: failed to generate a free plate");
                        GenerateRandomPlate(country, gPlayerPlate[playerid], sizeof(gPlayerPlate[]));
                        GenerateRandomRegion(country, gPlayerRegion[playerid], sizeof(gPlayerRegion[]));
                    }

                    SendPlateInfo(playerid, gPlayerPlate[playerid], gPlayerRegion[playerid]);

                    printf("[PLATES] Player %d selected country %d, plate: %s [%s] (free: %s)",
                           playerid, country, gPlayerPlate[playerid], gPlayerRegion[playerid],
                           found_free ? "yes" : "no");
                }

                case 2:
                {
                    new country = gPlayerCountry[playerid];
                    if(country == -1) country = 0;

                    if(GetPlayerMoneyEx(playerid) < 50000)
                    {
                        SendHint(playerid, "Insufficient funds! Need 50,000 rub.");
                        return 0;
                    }

                    new bool:found_free = false;
                    new attempts = 0;
                    new old_plate[32], old_region[8];

                    strcpy(old_plate, gPlayerPlate[playerid], 32);
                    strcpy(old_region, gPlayerRegion[playerid], 8);

                    while(!found_free && attempts < 50)
                    {
                        GenerateRandomPlate(country, gPlayerPlate[playerid], sizeof(gPlayerPlate[]));
                        GenerateRandomRegion(country, gPlayerRegion[playerid], sizeof(gPlayerRegion[]));

                        new query_check[512];
                        new Cache:result_check;
                        new rows;

                        mysql_format(mysql, query_check, sizeof query_check,
                            "SELECT COUNT(*) as total FROM inventory_plates WHERE plate_text = '%s' AND region = '%s'",
                            gPlayerPlate[playerid], gPlayerRegion[playerid]);

                        result_check = mysql_query(mysql, query_check, true);
                        rows = cache_num_rows();

                        if(rows > 0)
                        {
                            new total = cache_get_field_content_int(0, "total");
                            cache_delete(result_check);

                            if(total > 0)
                            {
                                attempts++;
                                continue;
                            }
                        }
                        else cache_delete(result_check);

                        mysql_format(mysql, query_check, sizeof query_check,
                            "SELECT COUNT(*) as total FROM ownable_cars WHERE number = '%s' AND region = '%s'",
                            gPlayerPlate[playerid], gPlayerRegion[playerid]);

                        result_check = mysql_query(mysql, query_check, true);
                        rows = cache_num_rows();

                        if(rows > 0)
                        {
                            new total = cache_get_field_content_int(0, "total");
                            cache_delete(result_check);

                            if(total > 0)
                            {
                                attempts++;
                                continue;
                            }
                        }
                        else cache_delete(result_check);

                        found_free = true;
                    }

                    if(!found_free)
                    {
                        strcpy(gPlayerPlate[playerid], old_plate, 32);
                        strcpy(gPlayerRegion[playerid], old_region, 8);
                        SendHint(playerid, "Failed to find a free plate, try later");
                        return 0;
                    }

                    GivePlayerMoney(playerid, -50000);

                    SendPlateInfo(playerid, gPlayerPlate[playerid], gPlayerRegion[playerid]);

                    printf("[PLATES] Player %d refreshed plate: %s [%s]",
                           playerid, gPlayerPlate[playerid], gPlayerRegion[playerid]);
                }

                case 3:
                {
                    new plate[32], region[8];
                    JSON_GetString(JSONObject, "p", plate, sizeof(plate));
                    JSON_GetString(JSONObject, "r", region, sizeof(region));

                    if(strlen(plate) == 0)
                    {
                        SendHint(playerid, "Error: plate not entered");
                        return 0;
                    }

                    new country = gPlayerCountry[playerid];
                    if(country == -1) country = 0;

                    if(strlen(region) == 0)
                    {
                        GenerateRandomRegion(country, region, sizeof(region));
                    }

                    new query_check[512];
                    new Cache:result_check;
                    new rows;
                    new bool:plate_exists = false;

                    mysql_format(mysql, query_check, sizeof query_check,
                        "SELECT COUNT(*) as total FROM inventory_plates WHERE plate_text = '%s' AND region = '%s'",
                        plate, region);

                    result_check = mysql_query(mysql, query_check, true);
                    rows = cache_num_rows();

                    if(rows > 0)
                    {
                        new total = cache_get_field_content_int(0, "total");
                        cache_delete(result_check);

                        if(total > 0)
                        {
                            SendHint(playerid, "This plate is already taken!");
                            printf("[PLATES] Player %d attempted to buy existing plate: %s [%s] (found in inventory_plates)",
                                   playerid, plate, region);
                            plate_exists = true;
                        }
                    }
                    else cache_delete(result_check);

                    if(!plate_exists)
                    {
                        mysql_format(mysql, query_check, sizeof query_check,
                            "SELECT COUNT(*) as total FROM ownable_cars WHERE number = '%s' AND region = '%s'",
                            plate, region);

                        result_check = mysql_query(mysql, query_check, true);
                        rows = cache_num_rows();

                        if(rows > 0)
                        {
                            new total = cache_get_field_content_int(0, "total");
                            cache_delete(result_check);

                            if(total > 0)
                            {
                                SendHint(playerid, "This plate is already taken!");
                                printf("[PLATES] Player %d attempted to buy existing plate: %s [%s] (found on ownable_cars)",
                                       playerid, plate, region);
                                plate_exists = true;
                            }
                        }
                        else cache_delete(result_check);
                    }

                    if(plate_exists) return 0;

                    if(GetPlayerMoneyEx(playerid) < 250000)
                    {
                        SendHint(playerid, "Insufficient funds! Need 250,000 rub.");
                        return 0;
                    }

                    GivePlayerMoney(playerid, -250000);

                    printf("[PLATES] Player %d buying plate: country=%d, plate='%s', region='%s'",
                           playerid, country, plate, region);

                    strcpy(gPlayerPlate[playerid], plate, 32);
                    strcpy(gPlayerRegion[playerid], region, 8);

                    new owner_id = GetPlayerAccountID(playerid);

                    if(owner_id == 0) return 0;

                    if(PlayerPlatesCount[playerid] >= MAX_PLAYER_PLATES)
                    {
                        SendClientMessage(playerid, 0xFF4500FF, "{FF4500}You have too many plates in inventory");
                        return 0;
                    }

                    mysql_query(mysql, "SET NAMES 'cp1251'", false);

                    new query[512];
                    mysql_format(mysql, query, sizeof query,
                        "INSERT INTO inventory_plates (owner_id, country, plate_text, region, date_added) VALUES (%d, %d, '%s', '%s', NOW())",
                        owner_id, country, plate, region);

                    mysql_query(mysql, query, false);

                    new plate_db_id = cache_insert_id();

                    new slot = PlayerPlatesCount[playerid];
                    PlayerPlatesData[playerid][slot][plate_db_id] = plate_db_id;
                    PlayerPlatesData[playerid][slot][plate_country] = country;

                    format(PlayerPlatesData[playerid][slot][plate_text], 32, "%s", plate);
                    format(PlayerPlatesData[playerid][slot][plate_region], 8, "%s", region);

                    PlayerPlatesCount[playerid]++;

                    SendHint(playerid, "Plate successfully purchased!");

                    SendPlateInfo(playerid, plate, region);

                    printf("[PLATES] Player %d purchased plate: %s [%s]",
                           playerid, plate, region);
                }

                case 4:
                {
                    new country, plate[32], region[8];
                    JSON_GetInt(JSONObject, "c", country);
                    JSON_GetString(JSONObject, "p", plate, sizeof(plate));
                    JSON_GetString(JSONObject, "r", region, sizeof(region));

                    gPlayerCountry[playerid] = country;
                    strcpy(gPlayerPlate[playerid], plate, 32);
                    strcpy(gPlayerRegion[playerid], region, 8);

                    SendPlateInfo(playerid, plate, region);

                    printf("[PLATES] Player %d manual entry: %s [%s]",
                           playerid, plate, region);
                }
            }
            return 0;
        }