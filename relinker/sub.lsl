
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

#define TIMER_MIN_TIME 0.022444
#define bool(x) !!(x)

string gs_owner_id;
string gs_root_key;
integer gi_root_link;
integer gi_links_numb;

integer gi_chat_handle;

finalize() 
{
	llWhisper(PUBLIC_CHANNEL, "Removing sub script.");
	llRemoveInventory(llGetScriptName());
	llSleep(3000);
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
        {
            integer channel = (0x80000000 | (integer)("0x" + gs_owner_id)) + 333;
            gi_chat_handle = llListen(channel, "", "", WORD_LINK);
            llRegionSay(channel, WORD_LOG);
        }
    }

    listen( integer channel, string name, key id, string message )
    {

        if (message == WORD_LINK)
        {
            llListenRemove(gi_chat_handle);
            gi_chat_handle = llListen(channel, llKey2Name(id), id, "");

            integer link = gi_root_link;
            vector root_pos = llGetRootPosition();

            for (;link < gi_links_numb; ++link)
            {
                string obj = llJsonSetValue("", (list)JSON_IDX, (string)link);
                obj = llJsonSetValue(obj, (list)JSON_UUID, (string)llGetLinkKey(link));

                vector loc_pos = root_pos;
                if (link > 1) 
                    loc_pos += llList2Vector(llGetLinkPrimitiveParams(link, (list)PRIM_POS_LOCAL), 0);

                

                llRegionSayTo(id, channel, llJsonSetValue(obj, (list)JSON_POS, (string)loc_pos));
                llSleep(TIMER_MIN_TIME);
            }
            
        }
        else if (message == WORD_BREAK)
        {
            llBreakAllLinks();
            llRegionSayTo(id, channel, WORD_BREAK);
            finalize();
        }
    }
}