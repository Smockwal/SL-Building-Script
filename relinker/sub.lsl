string gs_root_key;
string gs_owner_id;
integer gi_root_link;
integer gi_links_numb;
integer gi_chat_handle;
finalize() {
    llWhisper(0, "Removing sub script.");
    llRemoveInventory(llGetScriptName());
    llSleep(3000);
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
        if (perm & 0x80) {
            integer channel = (0x80000000 | (integer)("0x" + gs_owner_id)) + 333;
            gi_chat_handle = llListen(channel, "", "", "d");
            llRegionSay(channel, "b");
        }
    }
    listen(integer channel, string name, key id, string message) {
        if (llGetOwner() != llGetOwnerKey(id))return ;
        if (message == "d") {
            llBreakAllLinks();
            llRegionSayTo(id, channel, "d");
            finalize();
        }
    }
}