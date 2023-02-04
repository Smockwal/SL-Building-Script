string g_;
integer UThread;
integer System;
integer Pop;
vector LslLibrary;
quaternion ResumeVoid;
integer IsSaveDue;
float Library;
integer IsRestoring;
integer edefaultrez;
_(integer llDie) {
    IsSaveDue = (IsSaveDue & 0xFFFFFFFE) | ( - !!llDie & 1);
    llTargetRemove(IsRestoring);
    llRotTargetRemove(edefaultrez);
    if (llDie) {
        IsRestoring = llTarget(llGetPos(), 0.001);
        edefaultrez = llRotTarget(llGetRot(), 0.001);
    }
    else IsRestoring = edefaultrez = 0;
}
default  {
    state_entry() {
        llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [27, "_sitter_helper_widget_", 9, 1, 0, <0, 1, 0>, 0, ((vector)""), <1, 1, 0>, ((vector)""), 17, 0xFFFFFFFF, "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d", <1, 1, 0>, ((vector)""), 0, 7, <0.03, 0.03, 2.5>, 20, 0xFFFFFFFF, 1, 25, 0xFFFFFFFF, 0.25]);
    }
    on_rez(integer llDie) {
        if (llDie) {
            g_ = llList2String(llGetObjectDetails(llGetKey(), (list)32), 0);
            UThread = llList2Integer(llGetObjectDetails(g_, (list)30), 0);
            System = (UThread > 1);
            llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [18, 0xFFFFFFFF, (<((llDie >> 16) & 255), ((llDie >> 8) & 255), (llDie & 255)> * 0.00392156862745098), 1, 26, (string)System, <0, 1, 0>, 1]);
            Pop = 65535 + ((llDie >> 24) & 255);
            llListen(Pop, llKey2Name(g_), g_, "");
            llRegionSayTo(g_, Pop, llJsonSetValue("", (list)"f", "k"));
            LslLibrary = llGetPos();
            ResumeVoid = llGetRot();
            _(1);
        }
    }
    not_at_target() {
        if (IsSaveDue & 1) {
            _(0);
            llMessageLinked(0xFFFFFFFC, IsSaveDue & 1, "", "");
        }
    }
    not_at_rot_target() {
        if (IsSaveDue & 1) {
            _(0);
            llMessageLinked(0xFFFFFFFC, IsSaveDue & 1, "", "");
        }
    }
    link_message(integer llDie, integer llGetRot, string llGetPos, key llListen) {
        if (llGetRot)return ;
        vector pos = llGetPos();
        quaternion rot = llGetRot();
        if (pos != LslLibrary | rot != ResumeVoid) {
            llRegionSayTo(g_, Pop, llJsonSetValue("", (list)"f", "j"));
            LslLibrary = pos;
            ResumeVoid = rot;
            llMessageLinked(0xFFFFFFFC, IsSaveDue & 1, "", "");
        }
        else _(1);
    }
    touch_start(integer llDie) {
        Library = llGetTime();
    }
    touch_end(integer llDie) {
        if ((llGetAndResetTime() - Library) < 1) {
            if ((UThread + (UThread > 1)) <= ++System) System = (UThread > 1);
            llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [26, (string)System, <0, 1, 0>, 1]);
        }
        else  {
            string msg = "{\"f\":\"i\",\"l\":\"" + (string)System + "\"}";
            llRegionSayTo(g_, Pop, msg);
        }
    }
    listen(integer llDie, string llGetRot, key llGetPos, string llListen) {
        if (llGetPos != g_)return ;
        string act = llJsonGetValue(llListen, (list)"f");
        if (act == "h") {
            llDie();
        }
        else if (act == "g") {
            llSetColor((vector)llJsonGetValue(llListen, (list)"g"), 0xFFFFFFFF);
        }
    }
}
