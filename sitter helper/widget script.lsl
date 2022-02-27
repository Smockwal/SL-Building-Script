
// instruction in "seat script"

integer gi_flag;
#define TARGET_SET 0x1

#define bool(x) !!(x)

#define JSON_COLOR "col"

string gs_target;
string gs_base_id;
integer gi_channel;

integer gi_pos_target_id;
integer gi_rot_target_id;

vector gv_pos;
rotation gr_rot;

set_target(integer on)
{
    gi_flag = (gi_flag & ~TARGET_SET) | (-bool(on) & TARGET_SET);

    llTargetRemove(gi_pos_target_id);
    llRotTargetRemove(gi_rot_target_id);

    if (on)
    {
        gi_pos_target_id = llTarget(llGetPos(), 0.001);
        gi_rot_target_id = llRotTarget(llGetRot(), 0.001);
    }
    else 
        gi_pos_target_id = gi_rot_target_id = 0;
}

default 
{
    state_entry()
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_NAME, "Widget",
            PRIM_TYPE, PRIM_TYPE_CYLINDER, PRIM_HOLE_DEFAULT, <0,1,0>, 0, <0,0,0>, <1,1,0>, <0,0,0>,
            PRIM_TEXTURE, ALL_SIDES, "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d", <1,1,0>, <0,0,0>, 0,
            PRIM_SIZE, <0.03, 0.03, 2.5>,
            PRIM_FULLBRIGHT, ALL_SIDES, TRUE
        ]);
    }

    on_rez( integer start_param)
    {
        if(start_param)
        {
            gs_base_id = llList2String(llGetObjectDetails(llGetKey(), (list)OBJECT_REZZER_KEY), 0);

            vector color = < ((start_param >> 16) & 0xFF), ((start_param >> 8) & 0xFF), (start_param & 0xFF) >;
            llSetColor((color / 255.0), ALL_SIDES);

            gi_channel = 0xFFFF + ((start_param >> 24) & 0xFF);
            llListen(gi_channel, llKey2Name(gs_base_id), gs_base_id, "");

            llRegionSayTo(gs_base_id, gi_channel, "loggin");

            gv_pos = llGetPos();
            gr_rot = llGetRot();
            set_target(TRUE);
        }
    }

    not_at_target()
    {
        if (gi_flag & TARGET_SET)
        {
            set_target(FALSE);
            llMessageLinked(LINK_THIS, gi_flag & TARGET_SET, "", "");
        }
    }

    not_at_rot_target()
    {
        if (gi_flag & TARGET_SET)
        {
            set_target(FALSE);
            llMessageLinked(LINK_THIS, gi_flag & TARGET_SET, "", "");
        }
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        
        if (num)
            return;

        vector pos = llGetPos();
        rotation rot = llGetRot();
        if (pos != gv_pos || rot != gr_rot)
        {
            llRegionSayTo(gs_base_id, gi_channel, "update");
            gv_pos = pos;
            gr_rot = rot;
            llMessageLinked(LINK_THIS, gi_flag & TARGET_SET, "", "");
        }
        else
            set_target(TRUE);
    }

    touch_start( integer num_detected )
    {
        llRegionSayTo(gs_base_id, gi_channel, "tell");
    }

    listen( integer channel, string name, key id, string message )
    {
        if (message == "die")
            llDie();
        else if (llJsonValueType(message, []) == JSON_OBJECT)
        {
            if (llJsonValueType(message, (list)JSON_COLOR) == JSON_STRING)
                llSetColor((vector)llJsonGetValue(message, (list)JSON_COLOR), ALL_SIDES);
        }
    }
}
