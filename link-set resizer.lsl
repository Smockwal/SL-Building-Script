/*
    What:
    Add this script to an object/linkset and touch the object to get a dialog that will let you resize it.

    How:
    1: Compile in inventory.
    2: Drag and drop in a linkset.
    3: Touch the object to get a dialog.

    ✅ deeded | ✅ optimized | ❌ shared | ✅ self delete
    ✅ attachment | ✅ rezzed | ✅ link-set | ✅ single object
*/

integer System;
string ga;
integer Pop;
integer gc;
float gb = 1;
string a(vector Library) {
    return c(Library.x) + "," + c(Library.y) + "," + c(Library.z);
}
b(string Library, integer UThread) {
    list buttons = ["·Done·", "·Close·", "·Reset·", "-1%", "-5%", "-10%", "+1%", "+5%", "+10%", "·Restore·", "-", "-"];
    llDialog(Library, ".", buttons, UThread);
    llSetTimerEvent(300);
}
string c(float Library) {
    string snumb = (string)((float)llRound(Library * 1000) * 0.001);
     @ trim_label;
    if (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == "0") {
        snumb = llDeleteSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF);
        jump trim_label;
    }
    if (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == ".")return (string)((integer)snumb);
    if (!llSubStringIndex(snumb, "0.")) snumb = llDeleteSubString(snumb, 0, 0);
    if (!llSubStringIndex(snumb, "-0.")) snumb = llDeleteSubString(snumb, 1, 1);
    return snumb;
}
default  {
    state_entry() {
        list obj_data = llGetObjectDetails(llGetKey(), [7, 30]);
        System = (llList2Key(obj_data, 0) == llGetOwner());
        ga = llGetInventoryCreator(llGetScriptName());
        if (llLinksetDataFindKeys("linkset_size", 0, 1) == []) {
            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(obj_data, 1);
            string jdata;
             @ link_label;
             {
                list params = llGetLinkPrimitiveParams(link, [33, 7]);
                string sid = (string)link;
                jdata = llJsonSetValue(jdata, (list)("s" + sid), a(llList2Vector(params, 1)));
                if (link > 1) jdata = llJsonSetValue(jdata, (list)("p" + sid), a(llList2Vector(params, 0)));
            }
            if (++link <= links)jump link_label;
            llLinksetDataWriteProtected("linkset_size", jdata, ga);
        }
        Pop =  - (1000000 + (integer)llFrand(200000000));
        gc = llListen(Pop, "", "", "");
        llListenControl(gc, 0);
    }
    on_rez(integer Library) {
        state _;
    }
    touch_start(integer Library) {
        key user_id = llDetectedKey(0);
        if (System && !llSameGroup(user_id))return ;
        else if (user_id != llGetOwner())return ;
        llListenControl(gc, 1);
        b(user_id, Pop);
    }
    listen(integer Library, string UThread, key llFrand, string llRound) {
        float factor;
        if (llRound == "·Done·")state _;
        else if (llRound == "·Close·") {
            llListenControl(gc, 0);
            return ;
        }
        else if (llRound == "·Restore·") {
            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)30), 0);
            string jdata = llLinksetDataReadProtected("linkset_size", ga);
             @ link_label;
             {
                string sid = (string)link;
                list params = [7, (vector)("<" + llJsonGetValue(jdata, (list)("s" + sid)) + ">")];
                if (link > 1) params += [33, (vector)("<" + llJsonGetValue(jdata, (list)("p" + sid)) + ">")];
                llSetLinkPrimitiveParamsFast(link, params);
            }
            if (++link <= links)jump link_label;
            gb = 1;
        }
        else if (llRound == "·Reset·") factor = ((float)1) / gb;
        else if (llRound == "+1%") factor = 1.01;
        else if (llRound == "+5%") factor = 1.05;
        else if (llRound == "+10%") factor = 1.1;
        else if (llRound == "-1%") factor = 0.99;
        else if (llRound == "-5%") factor = 0.95;
        else if (llRound == "-10%") factor = 0.9;
        if (factor < llGetMaxScaleFactor() && factor > llGetMinScaleFactor()) {
            if (llScaleByFactor(factor)) gb *= factor;
        }
        b(llFrand, Library);
    }
    timer() {
        llListenControl(gc, 0);
    }
}
state _ {
    state_entry() {
        llRemoveInventory(llGetScriptName());
    }
}

