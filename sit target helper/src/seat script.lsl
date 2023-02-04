
#include "header.lsl"

integer gi_channel;
list gl_mem;

#define SF(x, y) short_float(x, y)
string short_float(float value, integer dec) {
    float div = llPow(10, dec);
    string snumb = (string)(llRound(value * div) / div);
    snumb = llGetSubString(snumb, 0, llSubStringIndex(snumb, ".") + dec);
    if (snumb == (string)((integer)snumb)) return (string)((integer)snumb);
    @trim_label;
    if (llGetSubString(snumb, -1, -1) == "0") {
        snumb = llDeleteSubString(snumb, -1, -1);
        jump trim_label;
    }
    if (llGetSubString(snumb, -1, -1) == ".")
        return llDeleteSubString(snumb, -1, -1);
    return snumb;
}

#define SV(x, y) short_vec(x, y)
string short_vec(vector value, integer dec) {
    return "<" + SF(value.x, dec) + "," + SF(value.y, dec) + "," + SF(value.z, dec) + ">";
}

#define SR(x, y) short_rot(x, y)
string short_rot(quaternion value, integer dec) {
    return "<" + SF(value.x, dec) + "," + SF(value.y, dec) + "," + SF(value.z, dec) + "," + SF(value.s, dec) + ">";
}

list sit_target_for_link(integer seat_link, integer user_link) {
    list data = llGetLinkPrimitiveParams(seat_link, [
    /* 0 */	PRIM_POSITION, 
    /* 1 */	PRIM_ROTATION,

            PRIM_LINK_TARGET, user_link,
    /* 2 */	PRIM_POSITION, 
    /* 3 */	PRIM_ROTATION
    ]);

    vector root_pos_rc = llGetRootPosition();
    quaternion root_rot_rc = llGetRootRotation();

    vector sitter_pos_oc = (llList2Vector(data, 2) - root_pos_rc) / root_rot_rc;
    quaternion sitter_rot_oc = llList2Rot(data, 3) / root_rot_rc;

    vector sitter_pos_lc = sitter_pos_oc;
    quaternion sitter_rot_lc = sitter_rot_oc;

    if (seat_link > 1) {
        vector seat_pos_oc = (llList2Vector(data, 0) - root_pos_rc) / root_rot_rc;
        quaternion seat_rot_oc = llList2Rot(data, 1) / root_rot_rc;

        sitter_pos_lc = (sitter_pos_oc - seat_pos_oc) / seat_rot_oc;
        sitter_rot_lc = sitter_rot_oc / seat_rot_oc;
    }

    sitter_pos_lc.z -= 0.35;
    return [sitter_pos_lc, sitter_rot_lc];
}

vector update_color() {
    integer len = llGetListLength(gl_mem);
    integer root = llCeil(llPow(len, 0.33333333333333333333333333333333));
    float div = 1.0 / (float)root;
    
    vector result;
    @color_label;
    if (len > 0) {
        vector color = <len % root, llFloor((float)len / root) % root, llFloor((float)len / (root * root))> * div;
        string widget = llJsonGetValue(llList2String(gl_mem, --len), [JSON_WIDGET]);
        if (widget != JSON_INVALID) 
            llRegionSayTo(widget, gi_channel, "{\"" + CHAT_CMD_ACTION + "\":\"" + CHAT_CMD_COLOR + "\",\"" + CHAT_CMD_COLOR + "\":\"" + (string)color + "\"}");
        else result = color;
        jump color_label;
    }
    return result;
}

integer index_of(string uuid) {
    integer len = llGetListLength(gl_mem);
    @search_label_001;
    if (len > 0) {
        if (~llSubStringIndex(llList2String(gl_mem, --len), uuid)) 
            return len;
        jump search_label_001;
    }
    return 0x80000000;
}

default {
    state_entry() {
        llSetLinkPrimitiveParamsFast(LINK_SET, [            
            PRIM_SCRIPTED_SIT_ONLY, FALSE,
            PRIM_ALLOW_UNSIT, TRUE
        ]);

        gi_channel = 0xFFFF + (integer)llFrand(0xFF);
        //llOwnerSay("channel: " + (string)gi_channel);
        llListen(gi_channel, "", "", "");
    }
    
    on_rez( integer start_param) {
        state clear;
    }

    changed( integer change ) {
        if (change & CHANGED_LINK) {
            integer sitter_numb = llList2Integer(llGetObjectDetails(llGetKey(), [OBJECT_SIT_COUNT]), 0);
            integer mem_len = llGetListLength(gl_mem);

            if (sitter_numb > mem_len) {
                integer user_link = llGetNumberOfPrims();
                string user_id = llGetLinkKey(user_link);
                
                if (~llSubStringIndex((string)gl_mem, user_id))
                    return;

                llSleep(0.5);
                list user_data = llGetLinkPrimitiveParams(user_link, [PRIM_POSITION, PRIM_ROTATION]);
                
                gl_mem += ("{\"" + JSON_USER + "\":\"" + user_id + "\"}");

                vector color = update_color() * 255.0;
                //llOwnerSay("color: " + (string)color);

                integer param = (((gi_channel - 0xFFFF) & 0xFF) << 24) |
                                (((integer)color.x & 0xFF) << 16) |
                                (((integer)color.y & 0xFF) <<  8) |
                                ((integer)color.z & 0xFF);

                if (llGetInventoryType(WIDGET_INV_NAME)) {
                    //llOwnerSay("llRezObject(" + llList2CSV([WIDGET_INV_NAME, llList2Vector(sitter_data, 0), ZERO_VECTOR, llList2Rot(sitter_data, 1), param]) + ")");
                    llRezObject(WIDGET_INV_NAME, llList2Vector(user_data, 0), ZERO_VECTOR, llList2Rot(user_data, 1), param);
                }
                
            }
            else if (sitter_numb < mem_len) {
                string obj_root = llGetLinkKey(!!llGetLinkNumber());

                @search_label_002;
                if (mem_len > 0) {
                    string obj = llList2String(gl_mem, --mem_len);
                    string user = llJsonGetValue(obj, [JSON_USER]);
                    
                    integer remove;
                    if (llGetObjectMass(user) == 0) remove = TRUE;
                    else {
                        string user_root = llList2String(llGetObjectDetails(user, [OBJECT_ROOT]), 0);
                        if (user == user_root || user_root != obj_root) remove = TRUE;
                    } 

                    if (remove) {
                        llRegionSayTo(llJsonGetValue(obj, [JSON_WIDGET]), gi_channel, llJsonSetValue("", [CHAT_CMD_ACTION], CHAT_CMD_DIE));
                        gl_mem = llDeleteSubList(gl_mem, mem_len, mem_len);
                    }
                    jump search_label_002;
                }
                
                if (sitter_numb) 
                    update_color();
            }
        }
    }

    listen( integer channel, string name, key id, string message ) {
        //llOwnerSay(message);
        if (llJsonValueType(message, []) == JSON_OBJECT) {

            string act = llJsonGetValue(message, [CHAT_CMD_ACTION]);
            list guild_data_rc = llGetObjectDetails(id, [OBJECT_POS, OBJECT_ROT]);

            if (act == CHAT_CMD_LOGGIN) {

                integer len = llGetListLength(gl_mem);
                vector guild_pos_rc = llList2Vector(guild_data_rc, 0);

                @obj_label;
                if (len <= 0) return;

                string obj = llList2String(gl_mem, --len);
                if (llJsonGetValue(obj, [JSON_WIDGET]) != JSON_INVALID) jump obj_label;

                string user_id = llJsonGetValue(obj, [JSON_USER]);
                integer user_link = llList2Integer(llGetObjectDetails(user_id, [OBJECT_LINK_NUMBER]), 0);
                vector user_pos_rc = llList2Vector(llGetLinkPrimitiveParams(user_link, [PRIM_POSITION]), 0);
                
                if (llVecDist(guild_pos_rc, user_pos_rc) > VALUE_THRESHOLD) jump obj_label;
                gl_mem = llListReplaceList(gl_mem, [llJsonSetValue(obj, [JSON_WIDGET], id)], len, len);

            }
            else if (act == CHAT_CMD_UPDATE) {

                string user_id = llJsonGetValue(llList2String(gl_mem, index_of(id)), [JSON_USER]);
                integer user_link = llList2Integer(llGetObjectDetails(user_id, [OBJECT_LINK_NUMBER]), 0);

                quaternion root_rot_rc = llGetRootRotation();
                llSetLinkPrimitiveParamsFast(user_link, [
                    PRIM_POS_LOCAL, (llList2Vector(guild_data_rc, 0) - llGetRootPosition()) / root_rot_rc, 
                    PRIM_ROT_LOCAL, llList2Rot(guild_data_rc, 1) / root_rot_rc
                ]);

            }
            else if (act == CHAT_CMD_TELL) {

                string user_id = llJsonGetValue(llList2String(gl_mem, index_of(id)), [JSON_USER]);
                integer user_link = llList2Integer(llGetObjectDetails(user_id, [OBJECT_LINK_NUMBER]), 0);

                list user_loc_data = llGetLinkPrimitiveParams(user_link, [PRIM_POS_LOCAL, PRIM_ROT_LOCAL]);
                quaternion rot = llList2Rot(user_loc_data, 1);

                string msg = "\n" + llKey2Name(user_id) + " Raw Data:";
                msg += "\nPosition: " + SV(llList2Vector(user_loc_data, 0), 3);
                msg += "\nRotation: " + SR(rot, 6) + " (" + SV(llRot2Euler(rot) * RAD_TO_DEG, 2) + ")";

                integer link_target = (integer)llJsonGetValue(message, [CHAT_CMD_LINK]);
                list root_sit_target = sit_target_for_link(link_target, user_link);

                msg += "\n\nSit Target For Link " + (string)link_target + ":";
                msg += "\n" + SV(llList2Vector(root_sit_target, 0), 3) + ", " + SR(llList2Rot(root_sit_target, 1), 6);

                llWhisper(PUBLIC_CHANNEL, msg);

                llSetLinkPrimitiveParamsFast(link_target, [PRIM_SIT_TARGET, TRUE] + root_sit_target);

            }
        }
    }
    
}

state clear {
    state_entry() {
        llRemoveInventory(WIDGET_INV_NAME);
        llRemoveInventory(llGetScriptName());
    }
}
