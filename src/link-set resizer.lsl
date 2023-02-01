
#define LSD_KEY "linkset_size"

float gf_factor = 1;
integer gi_chan;
integer gi_hand;
string gs_pass;
integer gi_deeded;

string float2mm(float value) {
    string snumb = (string)((float)llRound(value * 1000.0) / 1000.0);
    @trim_label;
    if (llGetSubString(snumb, -1, -1) == "0") {
        snumb = llDeleteSubString(snumb, -1, -1);
        jump trim_label;
    }
    if (llGetSubString(snumb, -1, -1) == ".") return (string)((integer)snumb);
    if (!llSubStringIndex(snumb, "0.")) snumb = llDeleteSubString(snumb, 0, 0);
    if (!llSubStringIndex(snumb, "-0.")) snumb = llDeleteSubString(snumb, 1, 1);
    return snumb;
}

string vec2mm(vector value) {
    return float2mm(value.x) + "," + float2mm(value.y) + "," + float2mm(value.z);
}

dialog(string user, integer channel) {
    list buttons = [
        "·Done·", "·Close·", "·Reset·",
        "-1%", "-5%", "-10%",
        "+1%", "+5%", "+10%",
        "·Restore·", "-", "-"
    ];

    llDialog(user, ".", buttons, channel);
    llSetTimerEvent(300);
}

default {

    state_entry() {

        list obj_data = llGetObjectDetails(llGetKey(), [OBJECT_GROUP, OBJECT_PRIM_COUNT]);
        gi_deeded = (llList2Key(obj_data, 0) == llGetOwner());
        gs_pass = llGetInventoryCreator(llGetScriptName());

        if (llLinksetDataFindKeys(LSD_KEY, 0, 1) == []) {

            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(obj_data, 1);
            string jdata;

            @link_label;
            {
                list params = llGetLinkPrimitiveParams(link, [PRIM_POS_LOCAL, PRIM_SIZE]);
                string sid = (string)link;
                jdata = llJsonSetValue(jdata, [("s" + sid)], vec2mm(llList2Vector(params, 1)));
                if (link > 1)
                    jdata = llJsonSetValue(jdata, [("p" + sid)], vec2mm(llList2Vector(params, 0)));
            }
            if (++link <= links) jump link_label;

            llLinksetDataWriteProtected(LSD_KEY, jdata, gs_pass);
        }

        gi_chan = -(1000000 + (integer)llFrand(200000000));
        gi_hand = llListen(gi_chan, "", "", "");
        llListenControl(gi_hand, FALSE);

    }
    
    on_rez( integer start_param) {
        state clean;
    }

    touch_start( integer num_detected ) {
        key user_id = llDetectedKey(0);

        if (gi_deeded && !llSameGroup(user_id)) return;
        else if (user_id != llGetOwner()) return;

        llListenControl(gi_hand, TRUE);
        dialog(user_id, gi_chan);
    }

    listen( integer channel, string name, key id, string message ) {
        float factor;

        if (message == "·Done·")
            state clean;
        else if (message == "·Close·") {
            llListenControl(gi_hand, FALSE);
            return;
        }
        else if (message == "·Restore·") {
            
            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(llGetObjectDetails(llGetKey(), [OBJECT_PRIM_COUNT]), 0);
            string jdata = llLinksetDataReadProtected(LSD_KEY, gs_pass);

            @link_label;
            {
                string sid = (string)link;
                list params = [PRIM_SIZE, (vector)("<" + llJsonGetValue(jdata, [("s" + sid)]) + ">")];
                if (link > 1) params += [PRIM_POS_LOCAL, (vector)("<" + llJsonGetValue(jdata, [("p" + sid)]) + ">")];
                llSetLinkPrimitiveParamsFast(link, params);
            }
            if (++link <= links) jump link_label;
            gf_factor = 1;
        }
        else if (message == "·Reset·")
            factor = 1.0 / gf_factor;
        else if (message == "+1%")
            factor = 1.01;
        else if (message == "+5%")
            factor = 1.05;
        else if (message == "+10%")
            factor = 1.1;
        else if (message == "-1%")
            factor = 0.99;
        else if (message == "-5%")
            factor = 0.95;
        else if (message == "-10%")
            factor = 0.9;

        if (factor < llGetMaxScaleFactor() && factor > llGetMinScaleFactor()) {
            if (llScaleByFactor(factor)) gf_factor *= factor;
        }

        dialog(id, channel);
    }

    timer() {
        llListenControl(gi_hand, FALSE);
    }
}

state clean {
    state_entry() {
        llRemoveInventory(llGetScriptName());
    }
}

