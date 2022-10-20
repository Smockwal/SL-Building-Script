#include "header.hls"

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
            gi_chat_handle = llListen(channel, "", "", WORD_BREAK);
            llRegionSay(channel, WORD_LOG);
        }
    }

    listen( integer channel, string name, key id, string message )
    {
        if (llGetOwner() != llGetOwnerKey(id)) return;
        
        if (message == WORD_BREAK)
        {
            llBreakAllLinks();
            llRegionSayTo(id, channel, WORD_BREAK);
            finalize();
        }
    }
}