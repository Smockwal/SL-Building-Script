
#include "header.lsl"

integer gi_flag;
#define TARGET_SET 0x1

//#define bool(x) !!(x)

//#define JSON_COLOR "col"

string gs_target;
string gs_base_id;
integer gi_channel;

integer gi_pos_target_id;
integer gi_rot_target_id;

vector gv_pos;
rotation gr_rot;

integer gi_numb;
integer gi_link;

float gf_touch_time;

set_target(integer on) {
    gi_flag = (gi_flag & ~TARGET_SET) | (-bool(on) & TARGET_SET);

    llTargetRemove(gi_pos_target_id);
    llRotTargetRemove(gi_rot_target_id);

    if (on) {
        gi_pos_target_id = llTarget(llGetPos(), VALUE_THRESHOLD);
        gi_rot_target_id = llRotTarget(llGetRot(), VALUE_THRESHOLD);
    }
    else 
        gi_pos_target_id = gi_rot_target_id = 0;
}

default {
    state_entry() {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_NAME, WIDGET_INV_NAME,
            PRIM_TYPE, PRIM_TYPE_CYLINDER, PRIM_HOLE_DEFAULT, <0,1,0>, 0, <0,0,0>, <1,1,0>, <0,0,0>,
            PRIM_TEXTURE, ALL_SIDES, "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d", <1,1,0>, <0,0,0>, 0,
            PRIM_SIZE, <0.03, 0.03, 2.5>,
            PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
            PRIM_GLOW, ALL_SIDES, 0.25
        ]);
    }

    on_rez( integer start_param) {
        if(start_param) {
            gs_base_id = llList2String(llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]), 0);

            gi_numb = llList2Integer(llGetObjectDetails(gs_base_id, [OBJECT_PRIM_COUNT]), 0);
            gi_link = (gi_numb > 1);

            llSetLinkPrimitiveParamsFast(LINK_THIS, [
                PRIM_COLOR, ALL_SIDES, (<((start_param >> 16) & 0xFF), ((start_param >> 8) & 0xFF), (start_param & 0xFF)> / 255.0), 1,
                PRIM_TEXT, (string)gi_link, <0,1,0>, 1
            ]);

            gi_channel = 0xFFFF + ((start_param >> 24) & 0xFF);
            //llOwnerSay("channel: " + (string)gi_channel);
            llListen(gi_channel, llKey2Name(gs_base_id), gs_base_id, "");

            llRegionSayTo(gs_base_id, gi_channel, llJsonSetValue("", [CHAT_CMD_ACTION], CHAT_CMD_LOGGIN));

            gv_pos = llGetPos();
            gr_rot = llGetRot();
            set_target(TRUE);
        }
    }

    not_at_target() {
        if (gi_flag & TARGET_SET) {
            set_target(FALSE);
            llMessageLinked(LINK_THIS, gi_flag & TARGET_SET, "", "");
        }
    }

    not_at_rot_target() {
        if (gi_flag & TARGET_SET) {
            set_target(FALSE);
            llMessageLinked(LINK_THIS, gi_flag & TARGET_SET, "", "");
        }
    }

    link_message( integer sender_num, integer num, string str, key id ) {
        
        if (num)
            return;

        vector pos = llGetPos();
        rotation rot = llGetRot();
        if (pos != gv_pos || rot != gr_rot) {
            llRegionSayTo(gs_base_id, gi_channel, llJsonSetValue("", [CHAT_CMD_ACTION], CHAT_CMD_UPDATE));
            gv_pos = pos;
            gr_rot = rot;
            llMessageLinked(LINK_THIS, gi_flag & TARGET_SET, "", "");
        }
        else
            set_target(TRUE);
    }

    touch_start( integer num_detected ) {
        gf_touch_time = llGetTime();
    }

    touch_end( integer num_detected ) {
        if ((llGetAndResetTime() - gf_touch_time) < 1) {
            if ((gi_numb + (gi_numb > 1)) <= ++gi_link)
                gi_link = (gi_numb > 1);

            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXT, (string)gi_link, <0,1,0>, 1]);
        }
        else {
            string msg = "{\"" + CHAT_CMD_ACTION + "\":\"" + CHAT_CMD_TELL + "\",\"" + CHAT_CMD_LINK + "\":\"" + (string)gi_link + "\"}";
            llRegionSayTo(gs_base_id, gi_channel, msg);
        }
    }

    listen( integer channel, string name, key id, string message ) {
        if (id != gs_base_id) return;
        string act = llJsonGetValue(message, [CHAT_CMD_ACTION]);

        if (act == CHAT_CMD_DIE) {
            llDie();
        } else if (act == CHAT_CMD_COLOR) {
            llSetColor((vector)llJsonGetValue(message, [CHAT_CMD_COLOR]), ALL_SIDES);
        }
    }
}
