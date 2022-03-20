// === Building ===
// Make a prim.
// Drop the "widget script" in it.
// Take the prim.

// === Using ===
// Rez your object.
// Drop the widget and this script in it.
// Sit on your object.
// Adjust your position by editing the widget.
// Click your object to open a dialog.
// Select the slot number you want to edit.
// Select "SET" to set the sit-target.
// Click the widget to get data about sit-target and position data to use in script, like av sitter.

#define JSON_COLOR "col"

list gl_colors_value = 
[
    <0, 0.455, 0.851>,
    <1, 0.75, 0.793>,
    <0.694, 0.051, 0.788>,
    <1, 0.522, 0.106>,
    <0.180, 0.800, 0.251>,
    <1, 0.863, 0>,
    <1, 1, 1>,
    <0.067, 0.067, 0.067>
];
list gl_sitters_id = 
[
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY
];
list gl_guild_id = 
[
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY,
    NULL_KEY
];
list gl_queue;

integer gi_sitter_numb;
integer gi_channel;

string short_float(string value)
{
    if ((float)value == 0.0) return "0";
    while(llGetSubString(value, -1, -1) == "0") value = llDeleteSubString(value, -1, -1);
    return llDumpList2String(llParseStringKeepNulls(value, (list)"-0.", []), "-.");
}

string toMM(float value)
{
    if (value == 0.0) return "0";
    value = ((integer)(value * 1000.0)) * 0.001;
    if((integer)value == value) return (string)((integer)value);
    return short_float((string)value);
}

string vec2MM(vector value)
{
    return (string)["<", toMM(value.x), ", ", toMM(value.y), ", ", toMM(value.z), ">"];
}

string short_rot(rotation value)
{
    return (string)["<", short_float((string)value.x), ", ", short_float((string)value.y), 
            ", ", short_float((string)value.z), ", ", short_float((string)value.s), ">"];
}

integer sitter_link(string id)
{
    integer numb = llGetNumberOfPrims();
    while (numb)
    {
        if (llGetLinkKey(numb) == id)
            return numb;
        --numb;
    }
        
    return 666;
}

update_sitter(integer index)
{
    list guild_data_rc = llGetObjectDetails(
        llList2String(gl_guild_id, index), 
        [OBJECT_POS, OBJECT_ROT]
    );

    rotation root_rot_rc = llGetRootRotation();
    llSetLinkPrimitiveParamsFast(
        sitter_link(llList2String(gl_sitters_id, index)), [
        PRIM_POS_LOCAL, (llList2Vector(guild_data_rc, 0) - llGetRootPosition()) / root_rot_rc, 
        PRIM_ROT_LOCAL, llList2Rot(guild_data_rc, 1) / root_rot_rc
    ]);
}

list get_sitTarget_data(integer link, string av_id)
{
    list data = llGetLinkPrimitiveParams(link, [
    /* 0 */	PRIM_POSITION, 
    /* 1 */	PRIM_ROTATION,

            PRIM_LINK_TARGET, sitter_link(av_id),
    /* 2 */	PRIM_POSITION, 
    /* 3 */	PRIM_ROTATION,

            PRIM_LINK_TARGET, LINK_ROOT,
    /* 4 */	PRIM_POSITION, 
    /* 5 */	PRIM_ROTATION
    ]);

    vector root_pos_rc = llList2Vector(data, 4);
    rotation root_rot_rc = llList2Rot(data, 5);

    vector sitter_pos_oc = (llList2Vector(data, 2) - root_pos_rc) / root_rot_rc;
    rotation sitter_rot_oc = llList2Rot(data, 3) / root_rot_rc;

    vector sitter_pos_lc = sitter_pos_oc;
    rotation sitter_rot_lc = sitter_rot_oc;

    if (link > 1)
    {
        vector seat_pos_oc = (llList2Vector(data, 0) - root_pos_rc) / root_rot_rc;
        rotation seat_rot_oc = llList2Rot(data, 1) / root_rot_rc;

        sitter_pos_lc = (sitter_pos_oc - seat_pos_oc) / seat_rot_oc;
        sitter_rot_lc = sitter_rot_oc / seat_rot_oc;
    }

    sitter_pos_lc.z -= 0.35;
    return [sitter_pos_lc, sitter_rot_lc];
}

update_color()
{
    integer it;
    for (; it < 8; ++it)
    {
        if (llList2Key(gl_guild_id, it))
        {
            string color = vec2MM(llList2Vector(gl_colors_value, it));
            llRegionSayTo(llList2String(gl_guild_id, it), gi_channel, llJsonSetValue("", (list)JSON_COLOR, color));
        }
    }
}


default 
{
    state_entry()
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [            
            PRIM_SCRIPTED_SIT_ONLY, FALSE,
            PRIM_ALLOW_UNSIT, TRUE
        ]);

        gi_channel = 0xFFFF + (integer)llFrand(0xFF);
        llListen(gi_channel, "", "", "");
    }

    on_rez( integer start_param)
    {
        llRemoveInventory(llGetScriptName());
    }

    changed( integer change )
    {
        if (change & CHANGED_LINK)
        {
            list data = llGetObjectDetails(llGetKey(), [OBJECT_SIT_COUNT, OBJECT_PRIM_COUNT]);
            integer sitter_numb = llList2Integer(data, 0);

            if (sitter_numb > gi_sitter_numb)
            {
                integer sitter_link = llGetNumberOfPrims();
                string sitter_id = llGetLinkKey(sitter_link);
                if (~llListFindList(gl_sitters_id, (list)sitter_id))
                    return;
                
                string name = llGetInventoryName(INVENTORY_OBJECT, 0);
                if (name)
                {
                    integer index = llListFindList(gl_sitters_id, (list)NULL_KEY);
                    vector color = llList2Vector(gl_colors_value, index) * 255.0;
                    integer param = (((gi_channel - 0xFFFF) & 0xFF) << 24) |
                                    (((integer)color.x & 0xFF) << 16) |
                                    (((integer)color.y & 0xFF) <<  8) |
                                    ((integer)color.z & 0xFF);

                    llSleep(0.5);
                    list sitter_data = llGetLinkPrimitiveParams(sitter_link, [PRIM_POSITION, PRIM_ROTATION]);
                    llRezObject(name, llList2Vector(sitter_data, 0), ZERO_VECTOR, llList2Rot(sitter_data, 1), param);

                    gl_queue += sitter_id;
                }
            }
            else if (sitter_numb < gi_sitter_numb)
            {
                integer it;
                for (; it < 8; ++it)
                {
                    string sitter_id = llList2String(gl_sitters_id, it);
                    if (sitter_id != NULL_KEY)
                    {
                        if (~llGetAgentInfo(sitter_id) & AGENT_ON_OBJECT) 
                        {
                            llRegionSayTo(llList2String(gl_guild_id, it), gi_channel, "die");

                            gl_sitters_id = llListReplaceList(gl_sitters_id, (list)NULL_KEY, it, it);
                            gl_guild_id = llListReplaceList(gl_guild_id, (list)NULL_KEY, it, it);
                        }
                    }
                }   
            }
            update_color();
            gi_sitter_numb = sitter_numb;
        }
    }

    touch_start( integer num_detected )
    {
        string detected = llDetectedKey(0);
        string root_id = llList2String(llGetObjectDetails(detected, (list)OBJECT_ROOT), 0);
        if (root_id == llGetKey())
        {
            string text = "menu";
            list buttons = [
                "1", "2", "3", 
                "4", "5", "6", 
                "7", "8", "-",
                "SET", "UNSET", "DONE"
            ];

            llDialog(detected, text, llList2List(buttons, 9, 11) + llList2List(buttons, 6, 8) + 
                    llList2List(buttons, 3, 5) + llList2List(buttons, 0, 2), gi_channel);
        }
    }

    listen( integer channel, string name, key id, string message )
    {
        string uuid = id;

        integer index;
        if (llGetAgentSize(id)) 
            index = llListFindList(gl_sitters_id, (list)uuid);
        else 
            index = llListFindList(gl_guild_id, (list)uuid);

        integer link = (index + 1);

        string my_root_id = llGetLinkKey(!!llGetLinkNumber());
        if (llList2String(llGetObjectDetails(id, (list)OBJECT_ROOT), 0) == my_root_id)
        {
            if (message == "SET")
            {
                if (link > llGetObjectPrimCount(my_root_id))
                {
                    llRegionSayTo(id, 0, "No enough links for the number of sitter.");
                    return;
                }
                
                llSetLinkPrimitiveParamsFast(link, 
                    [PRIM_SIT_TARGET, TRUE] + get_sitTarget_data(link, uuid)
                );
            }
            else if (message == "UNSET") 
            {
                list data = llGetLinkPrimitiveParams(link, (list)PRIM_SIT_TARGET);
                llSetLinkPrimitiveParamsFast(link, 
                    [PRIM_SIT_TARGET, FALSE] + llList2List(data, 1, -1)
                );
            }
            else if (message == "DONE") 
            {
                integer len = 8;
                while (len)
                {
                    key guild_id = llList2Key(gl_guild_id, --len);
                    if (llGetObjectMass(guild_id))
                        llRegionSayTo(guild_id, gi_channel, "die");
                }

                llRemoveInventory("Widget");
                llRemoveInventory(llGetScriptName());
                return;
            }
            else if ((integer)message)
            {
                
                integer new_index = ((integer)message) - 1;
                integer old_index = index;

                string guild_id = llList2String(gl_guild_id, old_index);
                if (llList2String(gl_guild_id, new_index) == NULL_KEY)
                {
                    gl_guild_id = llListReplaceList(gl_guild_id, (list)NULL_KEY, old_index, old_index);
                    gl_guild_id = llListReplaceList(gl_guild_id, (list)guild_id, new_index, new_index);
                    
                    gl_sitters_id = llListReplaceList(gl_sitters_id, (list)NULL_KEY, old_index, old_index);
                    gl_sitters_id = llListReplaceList(gl_sitters_id, (list)uuid, new_index, new_index);

                    update_color();
                } 
                else 
                    llRegionSayTo(id, PUBLIC_CHANNEL, "Slot in use");
            }
        }

        
        if (message == "loggin")
        {

            integer numb = llGetObjectPrimCount(my_root_id);
            while (~--numb && index & 0x80000000)
                if (llAvatarOnLinkSitTarget(numb + 1))
                    index = numb;

            if (index & 0x80000000)
                index = llListFindList(gl_guild_id, (list)NULL_KEY);

            gl_guild_id = llListReplaceList(gl_guild_id, (list)uuid, index, index);
            gl_sitters_id = llListReplaceList(gl_sitters_id, llList2List(gl_queue, 0, 0), index, index);
            gl_queue = llDeleteSubList(gl_queue, 0, 0);

            update_sitter(index);
            update_color();
        }
        else if (message == "update")
        {
            update_sitter(index);
        }
        else if (message == "tell")
        {
            string sitter_id = llList2String(gl_sitters_id, index);

            integer sitter_link = sitter_link(sitter_id);

            list sitter_data = llGetLinkPrimitiveParams(sitter_link, [PRIM_POS_LOCAL, PRIM_ROT_LOCAL]);
            rotation rot = llList2Rot(sitter_data, 1);
            vector euler =  llRot2Euler(rot) * RAD_TO_DEG;

            list target_data = get_sitTarget_data(index + 1, sitter_id);
            
            llRegionSayTo(llGetOwner(), PUBLIC_CHANNEL,
                "\npos: " + vec2MM(llList2Vector(sitter_data, 0)) + ", " + short_rot(rot) + " (<" + 
                (string)llRound(euler.x) + ", " + (string)llRound(euler.y) + ", " + (string)llRound(euler.z) + ">)" +
                "\ntarget: " + vec2MM(llList2Vector(target_data, 0)) + ", " + short_rot(llList2Rot(target_data, 1))
            );

        }
    }
}
