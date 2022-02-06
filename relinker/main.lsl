
#define LINKABILITY_MAX_DIST 54
#define LINKABILITY_MAX_LINK 256

#define WORD_LOG "log"
#define WORD_LINK "link"
#define WORD_BREAK "break"

#define JSON_ACTION "act"
#define JSON_INFO "info"
#define JSON_LINK "link"
#define JSON_NUMB "numb"
#define JSON_UUID "uuid"
#define JSON_IDX "idx"
#define JSON_POS "pos"

#define bool(x) !!(x)

string gs_owner_id;
string gs_root_key;
integer gi_root_link;
integer gi_links_numb;

list gl_main_list;
list gl_sub_list;
integer gi_sub_link_numb;

integer gi_chat_handle;

finalize() 
{
	llWhisper(PUBLIC_CHANNEL, "Removing main script.");
	llRemoveInventory(llGetScriptName());
	llSleep(3000);
}

reset()
{
    gi_sub_link_numb = 0;
    gl_sub_list = gl_main_list = [];

    integer link = gi_root_link;
    for (;link < gi_links_numb; ++link)
        gl_main_list = gl_main_list + [link, (string)llGetLinkKey(link)];

    llListenRemove(gi_chat_handle);
    integer channel = (0x80000000 | (integer)("0x" + gs_owner_id)) + 333;
    gi_chat_handle = llListen(channel, "", "", WORD_LOG);
}

relink()
{
    gl_main_list =  llListSort((gl_sub_list = []) + gl_sub_list, 2, FALSE) + 
                    llListSort((gl_main_list = []) + gl_main_list, 2, FALSE);

    gl_main_list = llList2ListStrided(llDeleteSubList(gl_main_list, 0, 0), 0, -1, 2);

    integer it;
    integer len = llGetListLength(gl_main_list);
    for (;it < len; ++it)
    {
        string uuid = llList2String(gl_main_list, it);
        if(uuid != gs_root_key) llCreateLink(uuid, TRUE);
    }

    llWhisper(PUBLIC_CHANNEL, "Linkage done.");
    reset();
}


default 
{
    state_entry()
    {
        gs_root_key = llGetKey();
        list data = llGetObjectDetails(gs_root_key, [
        /* 0 */ OBJECT_OWNER,
        /* 1 */ OBJECT_GROUP, 
        /* 2 */ OBJECT_PRIM_COUNT, 
        /* 3 */ OBJECT_SIT_COUNT, 
        /* 4 */ OBJECT_ATTACHED_POINT
        ]);

        if (llList2Integer(data, 4)) 
        {
            llWhisper(PUBLIC_CHANNEL, "Object attached, cant re-link attachment.");
            finalize();
        }

        gs_owner_id = llList2String(data, 0);
        if (gs_owner_id == llList2String(data, 1))
        {
            llWhisper(PUBLIC_CHANNEL, "Object deeded, no one can grant permission.");
            finalize();
        }

        gi_root_link = bool(llGetLinkNumber());
        gi_links_numb = llList2Integer(data, 2) + gi_root_link;

        if (llList2Integer(data, 3)) 
        {
            integer link = gi_links_numb;
            while (link >= gi_root_link) 
            {
                key link_key = llGetLinkKey(link);
                if (link_key)
                    if (llGetAgentSize(link_key))
                        llUnSit(link_key);

                --link;
            }
        }

        llRequestPermissions(gs_owner_id, PERMISSION_CHANGE_LINKS);
    }

    on_rez( integer start_param)
    {
        finalize();
    }

    run_time_permissions( integer perm )
    {
        if (perm & PERMISSION_CHANGE_LINKS) 
            reset();
    }

    listen( integer channel, string name, key id, string message )
    {
        if (message == WORD_LOG) 
        {
            list data = llGetObjectDetails(id, [
            /* 0 */ OBJECT_OWNER,
            /* 1 */ OBJECT_POS,
            /* 2 */ OBJECT_PRIM_COUNT,
            /* 3 */ OBJECT_ATTACHED_POINT
            ]);

            string sub_owner_id = llList2String(data, 0);
            if (sub_owner_id != llGetOwner())
            {
                llWhisper(PUBLIC_CHANNEL, "Sub object is own by diferent owner.");
                reset();
                return;
            }

            if (llVecDist(llList2Vector(data, 1), llGetRootPosition()) >= LINKABILITY_MAX_DIST)
            {
                llWhisper(PUBLIC_CHANNEL, "Sub object: (" + llKey2Name(id) + ") too far.");
                reset();
                return;
            }

            gi_sub_link_numb = llList2Integer(data, 2);
            if ((gi_links_numb + gi_sub_link_numb) > LINKABILITY_MAX_LINK)
            {
                llWhisper(PUBLIC_CHANNEL, "Sub object: (" + llKey2Name(id) + "), number of link exceeds the linkability limit.");
                reset();
                return;
            }

            llListenRemove(gi_chat_handle);
            gi_chat_handle = llListen(channel, llKey2Name(id), id, "");
            llRegionSayTo(id, channel, JSON_LINK);

        } 
        else if (message == WORD_BREAK)
            relink();
        else if (llJsonValueType(message, []) == JSON_OBJECT)
        {
            // {idx:5,key:"46c790d5-ff1e-4c90-a7aa-9a1b7f7fc3b4",pos:"<1,2,3>"}

            string uuid = llJsonGetValue(message, (list)JSON_UUID);
            vector pos = (vector)llJsonGetValue(message, (list)JSON_POS);

            if (llVecDist(pos, llGetRootPosition()) >= LINKABILITY_MAX_DIST)
            {
                llWhisper(PUBLIC_CHANNEL, "Sub object: (" + llKey2Name(uuid) + ") too far.");
                reset();
                return;
            }

            gl_sub_list = gl_sub_list + [ llJsonGetValue(message, (list)JSON_IDX), uuid];

            if (llGetListLength(gl_sub_list) == (gi_sub_link_numb << 1))
            {
                llRegionSayTo(id, channel, WORD_BREAK);
                llBreakAllLinks();
            }

        }
    }
}