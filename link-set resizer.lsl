float gf_factor = 1;
integer gi_hand;


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
    on_rez( integer start_param)
    {
        state clean;
    }

    touch_start( integer num_detected )
    {
        key user_id = llDetectedKey(0);
        if (user_id == llGetOwner())
        {
            if (gi_hand) llListenRemove(gi_hand);
            integer chan = -(1000000 + (integer)llFrand(200000000));
            gi_hand = llListen(chan, llKey2Name(user_id), user_id, "");
            
            dialog(user_id, chan);
        }
    }

    listen( integer channel, string name, key id, string message )
    {
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
            integer success = llScaleByFactor(factor);
            if (success) 
                gf_factor *= factor;
        }

        dialog(id, channel);
    }

    timer()
    {
        llListenControl(gi_hand, FALSE);
    }
}

state clean 
{
    state_entry()
    {
        llRemoveInventory(llGetScriptName());
    }
}