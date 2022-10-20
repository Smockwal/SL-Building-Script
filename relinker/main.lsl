string gs_root_key;
string gs_owner_id;
integer gi_root_link;
integer gi_links_numb;
integer gi_sub_link_numb;
list gl_sub_list;
integer gi_chat_handle;
list gl_main_list;
finalize() {
    llWhisper(0, "Removing main script.");
    llRemoveInventory(llGetScriptName());
    llSleep(3000);
}
reset() {
    gi_sub_link_numb = 0;
    gl_sub_list = gl_main_list = [];
    integer link = gi_root_link;
    for (; link<gi_links_numb; ++link) 
        gl_main_list = gl_main_list + [link, (string)llGetLinkKey(link)];
    llListenRemove(gi_chat_handle);
    integer channel = (0x80000000 | (integer)("0x" + gs_owner_id)) + 333;
    gi_chat_handle = llListen(channel, "", "", "b");
}
relink() {
    gl_main_list = llListSort((gl_sub_list = []) + gl_sub_list, 2, 0) + llListSort((gl_main_list = []) + gl_main_list, 2, 0);
    gl_main_list = llList2ListStrided(llDeleteSubList(gl_main_list, 0, 0), 0, 0xFFFFFFFF, 2);
    integer it;
    integer len = llGetListLength(gl_main_list);
    for (; it<len; ++it) {
        string uuid = llList2String(gl_main_list, it);
        if (uuid != gs_root_key) llCreateLink(uuid, 1);
    }
    llWhisper(0, "Linkage done.");
    reset();
}
default  {
    state_entry() {
        gs_root_key = llGetKey();
        list data = llGetObjectDetails(gs_root_key, [6, 7, 30, 38, 19]);
        if (llList2Integer(data, 4)) {
            llWhisper(0, "Object attached, cant re-link attachment.");
            finalize();
        }
        gs_owner_id = llList2String(data, 0);
        if (gs_owner_id == llList2String(data, 1)) {
            llWhisper(0, "Object deeded, no one can grant permission.");
            finalize();
        }
        gi_root_link = !!(llGetLinkNumber());
        gi_links_numb = llList2Integer(data, 2) + gi_root_link;
        if (llList2Integer(data, 3)) {
            integer link = gi_links_numb;
            while (link >= gi_root_link) {
                key link_key = llGetLinkKey(link);
                if (link_key)
                    if (llGetAgentSize(link_key)) 
                        llUnSit(link_key);
                --link;
            }
        }
        llRequestPermissions(gs_owner_id, 0x80);
    }
    on_rez(integer start_param) {
        finalize();
    }
    run_time_permissions(integer perm) {
        if (perm & 0x80) reset();
    }
    listen(integer channel, string name, key id, string message) {
        if (message == "b") {
            list data = llGetObjectDetails(id, [6, 3, 30, 19]);
            string sub_owner_id = llList2String(data, 0);
            if (sub_owner_id != llGetOwner()) {
                llWhisper(0, "Sub object is own by diferent owner.");
                reset();
                return ;
            }
            if (llVecDist(llList2Vector(data, 1), llGetRootPosition()) >= 54) {
                llWhisper(0, "Sub object: (" + llKey2Name(id) + ") too far.");
                reset();
                return ;
            }
            gi_sub_link_numb = llList2Integer(data, 2);
            if ((gi_links_numb + gi_sub_link_numb) > 256) {
                llWhisper(0, "Sub object: (" + llKey2Name(id) + "), number of link exceeds the linkability limit.");
                reset();
                return ;
            }
            integer link = !!gi_sub_link_numb;
            for (; link<=gi_sub_link_numb; ++link) {
                string uuid = llGetObjectLinkKey(id, link);
                data = llGetObjectDetails(uuid, (list)3);
                if (llVecDist(llList2Vector(data, 0), llGetRootPosition()) >= 54) {
                    llWhisper(0, "Sub link object: (" + llKey2Name(uuid) + ") too far.");
                    reset();
                    return ;
                }
                gl_sub_list = gl_sub_list + [link, uuid];
            }
            llListenRemove(gi_chat_handle);
            gi_chat_handle = llListen(channel, llKey2Name(id), id, "d");
            llRegionSayTo(id, channel, "d");
            llBreakAllLinks();
        }
        else if (message == "d") 
            relink();
    }
}