float gf_factor = 1;
integer gi_hand;
integer gi_deeded;

dialog(key user, integer channel)
{
    list buttons = [
        "·Done·", "·Close·", "·Reset·",
        "-1%", "-5%", "-10%",
        "+1%", "+5%", "+10%"
    ];

    llDialog(user, ".", buttons, channel);
    llSetTimerEvent(300);
}

default 
{
    state_entry() {
        key group = llList2Key(llGetObjectDetails(llGetKey(), [OBJECT_GROUP]), 0);
        gi_deeded = (group == llGetOwner());
    }

    on_rez( integer start_param)
    {
        state clean;
    }

    touch_start( integer num_detected )
    {
        key user_id = llDetectedKey(0);

        if (gi_deeded && !llSameGroup(user_id)) return;
        else if (user_id != llGetOwner()) return;

        if (gi_hand) llListenRemove(gi_hand);
        integer chan = -(1000000 + (integer)llFrand(200000000));
        gi_hand = llListen(chan, llKey2Name(user_id), user_id, "");
        
        dialog(user_id, chan);
    }

    listen( integer channel, string name, key id, string message )
    {
        if (gi_deeded && !llSameGroup(id)) return;
        else if (id != llGetOwner()) return;

        float factor;
        if (message == "·Done·")
            state clean;
        else if (message == "·Close·")
        {
            llListenControl(gi_hand, FALSE);
            return;
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

        if (factor < llGetMaxScaleFactor() && factor > llGetMinScaleFactor()) 
        {
            if (llScaleByFactor(factor)) 
                gf_factor *= factor;
        }

        dialog(id, channel);
    }

    timer()
    {
        llListenControl(gi_hand, FALSE);
    }

    changed( integer change )
    {
        if (change & CHANGED_OWNER) {
            key group = llList2Key(llGetObjectDetails(llGetKey(), [OBJECT_GROUP]), 0);
            gi_deeded = (group == llGetOwner());
        }
    }
}

state clean 
{
    state_entry()
    {
        llRemoveInventory(llGetScriptName());
    }
}