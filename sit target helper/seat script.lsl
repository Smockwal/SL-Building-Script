integer ge;
list gf;
vector a() {
    integer len = llGetListLength(gf);
    integer root = llCeil(llPow(len, 0.33333333333333333333333333333333));
    float div = ((float)1) / (float)root;
    vector result;
     @ color_label;
    if (len > 0) {
        vector color = <len % root, llFloor((float)len / root) % root, llFloor((float)len / (root * root))> * div;
        string widget = llJsonGetValue(llList2String(gf, --len), (list)"d");
        if (widget != "﷐") llRegionSayTo(widget, ge, "{\"f\":\"g\",\"g\":\"" + (string)color + "\"}");
        else result = color;
        jump color_label;
    }
    return result;
}
integer b(string ga) {
    integer len = llGetListLength(gf);
     @ search_label_001;
    if (len > 0) {
        if (~llSubStringIndex(llList2String(gf, --len), ga))return len;
        jump search_label_001;
    }
    return 0x80000000;
}
string c(vector ga, integer gb) {
    return "<" + f(ga.x, gb) + "," + f(ga.y, gb) + "," + f(ga.z, gb) + ">";
}
string d(quaternion ga, integer gb) {
    return "<" + f(ga.x, gb) + "," + f(ga.y, gb) + "," + f(ga.z, gb) + "," + f(ga.s, gb) + ">";
}
list e(integer ga, integer gb) {
    list data = llGetLinkPrimitiveParams(ga, [6, 8, 34, gb, 6, 8]);
    vector root_pos_rc = llGetRootPosition();
    quaternion root_rot_rc = llGetRootRotation();
    vector sitter_pos_oc = (llList2Vector(data, 2) - root_pos_rc) / root_rot_rc;
    quaternion sitter_rot_oc = llList2Rot(data, 3) / root_rot_rc;
    vector sitter_pos_lc = sitter_pos_oc;
    quaternion sitter_rot_lc = sitter_rot_oc;
    if (ga > 1) {
        vector seat_pos_oc = (llList2Vector(data, 0) - root_pos_rc) / root_rot_rc;
        quaternion seat_rot_oc = llList2Rot(data, 1) / root_rot_rc;
        sitter_pos_lc = (sitter_pos_oc - seat_pos_oc) / seat_rot_oc;
        sitter_rot_lc = sitter_rot_oc / seat_rot_oc;
    }
    sitter_pos_lc.z -= 0.35;
    return [sitter_pos_lc, sitter_rot_lc];
}
string f(float ga, integer gb) {
    float div = llPow(10, gb);
    string snumb = (string)(llRound(ga * div) / div);
    snumb = llGetSubString(snumb, 0, llSubStringIndex(snumb, ".") + gb);
    if (snumb == (string)((integer)snumb))return (string)((integer)snumb);
     @ trim_label;
    if (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == "0") {
        snumb = llDeleteSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF);
        jump trim_label;
    }
    if (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == ".")return llDeleteSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF);
    return snumb;
}
default  {
    state_entry() {
        llSetLinkPrimitiveParamsFast(0xFFFFFFFF, [40, 0, 39, 1]);
        ge = 65535 + (integer)llFrand(255);
        llListen(ge, "", "", "");
    }
    on_rez(integer ga) {
        state _;
    }
    changed(integer ga) {
        if (ga & 32) {
            integer sitter_numb = llList2Integer(llGetObjectDetails(llGetKey(), (list)38), 0);
            integer mem_len = llGetListLength(gf);
            if (sitter_numb > mem_len) {
                integer user_link = llGetNumberOfPrims();
                string user_id = llGetLinkKey(user_link);
                if (~llSubStringIndex((string)gf, user_id))return ;
                llSleep(0.5);
                list user_data = llGetLinkPrimitiveParams(user_link, [6, 8]);
                gf += ("{\"b\":\"" + user_id + "\"}");
                vector color = a() * ((float)255);
                integer param = (((ge - 65535) & 255) << 24) | (((integer)color.x & 255) << 16) | (((integer)color.y & 255) << 8) | ((integer)color.z & 255);
                if (llGetInventoryType("_sitter_helper_widget_")) {
                    llRezObject("_sitter_helper_widget_", llList2Vector(user_data, 0), ((vector)""), llList2Rot(user_data, 1), param);
                }
            }
            else if (sitter_numb < mem_len) {
                string obj_root = llGetLinkKey(!!llGetLinkNumber());
                 @ search_label_002;
                if (mem_len > 0) {
                    string obj = llList2String(gf, --mem_len);
                    string user = llJsonGetValue(obj, (list)"b");
                    integer remove;
                    if (llGetObjectMass(user) == 0) remove = 1;
                    else  {
                        string user_root = llList2String(llGetObjectDetails(user, (list)18), 0);
                        if (user == user_root | user_root != obj_root) remove = 1;
                    }
                    if (remove) {
                        llRegionSayTo(llJsonGetValue(obj, (list)"d"), ge, llJsonSetValue("", (list)"f", "h"));
                        gf = llDeleteSubList(gf, mem_len, mem_len);
                    }
                    jump search_label_002;
                }
                if (sitter_numb) a();
            }
        }
    }
    listen(integer ga, string gb, key gc, string gd) {
        if (llJsonValueType(gd, []) == "﷑") {
            string act = llJsonGetValue(gd, (list)"f");
            list guild_data_rc = llGetObjectDetails(gc, [3, 4]);
            if (act == "k") {
                integer len = llGetListLength(gf);
                vector guild_pos_rc = llList2Vector(guild_data_rc, 0);
                 @ obj_label;
                if (len <= 0)return ;
                string obj = llList2String(gf, --len);
                if (llJsonGetValue(obj, (list)"d") != "﷐")jump obj_label;
                string user_id = llJsonGetValue(obj, (list)"b");
                integer user_link = llList2Integer(llGetObjectDetails(user_id, (list)46), 0);
                vector user_pos_rc = llList2Vector(llGetLinkPrimitiveParams(user_link, (list)6), 0);
                if (llVecDist(guild_pos_rc, user_pos_rc) > 0.001)jump obj_label;
                gf = llListReplaceList(gf, (list)llJsonSetValue(obj, (list)"d", gc), len, len);
            }
            else if (act == "j") {
                string user_id = llJsonGetValue(llList2String(gf, b(gc)), (list)"b");
                integer user_link = llList2Integer(llGetObjectDetails(user_id, (list)46), 0);
                quaternion root_rot_rc = llGetRootRotation();
                llSetLinkPrimitiveParamsFast(user_link, [33, (llList2Vector(guild_data_rc, 0) - llGetRootPosition()) / root_rot_rc, 29, llList2Rot(guild_data_rc, 1) / root_rot_rc]);
            }
            else if (act == "i") {
                string user_id = llJsonGetValue(llList2String(gf, b(gc)), (list)"b");
                integer user_link = llList2Integer(llGetObjectDetails(user_id, (list)46), 0);
                list user_loc_data = llGetLinkPrimitiveParams(user_link, [33, 29]);
                quaternion rot = llList2Rot(user_loc_data, 1);
                string msg = "\n" + llKey2Name(user_id) + " Raw Data:";
                msg += "\nPosition: " + c(llList2Vector(user_loc_data, 0), 3);
                msg += "\nRotation: " + d(rot, 6) + " (" + c(llRot2Euler(rot) * 57.29577950000000186037141, 2) + ")";
                integer link_target = (integer)llJsonGetValue(gd, (list)"l");
                list root_sit_target = e(link_target, user_link);
                msg += "\n\nSit Target For Link " + (string)link_target + ":";
                msg += "\n" + c(llList2Vector(root_sit_target, 0), 3) + ", " + d(llList2Rot(root_sit_target, 1), 6);
                llWhisper(0, msg);
                llSetLinkPrimitiveParamsFast(link_target, [41, 1] + root_sit_target);
            }
        }
    }
}
state _ {
    state_entry() {
        llRemoveInventory("_sitter_helper_widget_");
        llRemoveInventory(llGetScriptName());
    }
}
