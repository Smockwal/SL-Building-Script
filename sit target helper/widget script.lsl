string g_;
integer Library;
integer Pop;
integer UThread;
integer System;
list LslLibrary;
integer ResumeVoid;
float IsSaveDue;
integer IsRestoring;
integer edefaultrez;
_(integer llDie) {
    ResumeVoid = (ResumeVoid & 0xFFFFFFFE) | ( - !!llDie & 1);
    llTargetRemove(IsRestoring);
    llRotTargetRemove(edefaultrez);
    if (llDie) {
        IsRestoring = llTarget(llList2Vector(LslLibrary, 0), 0.001);
        edefaultrez = llRotTarget(llList2Rot(LslLibrary, 1), 0.001);
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
            Library = llList2Integer(llGetObjectDetails(g_, (list)30), 0);
            Pop = UThread = (Library > 1);
            llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [18, 0xFFFFFFFF, (<((llDie >> 16) & 255), ((llDie >> 8) & 255), (llDie & 255)> * 0.00392156862745098), 1, 26, (string)Pop, <0, 1, 0>, 1]);
            System = 65535 + ((llDie >> 24) & 255);
            llListen(System, llKey2Name(g_), g_, "");
            llRegionSayTo(g_, System, "{\"f\":\"k\"}");
            LslLibrary = llGetLinkPrimitiveParams(0xFFFFFFFC, [6, 8]);
            _(1);
        }
    }
    not_at_target() {
        if (ResumeVoid & 1) {
            _(0);
            llMessageLinked(0xFFFFFFFC, ResumeVoid & 1, "", "");
        }
    }
    not_at_rot_target() {
        if (ResumeVoid & 1) {
            _(0);
            llMessageLinked(0xFFFFFFFC, ResumeVoid & 1, "", "");
        }
    }
    link_message(integer llDie, integer llListen, string llGetKey, key llTarget) {
        if (llListen)return ;
        list prim_data = llGetLinkPrimitiveParams(0xFFFFFFFC, [6, 8]);
        if (llListFindList(LslLibrary, prim_data) & 0x80000000) {
            llRegionSayTo(g_, System, "{\"f\":\"j\"}");
            LslLibrary = prim_data;
            llMessageLinked(0xFFFFFFFC, ResumeVoid & 1, "", "");
        }
        else _(1);
    }
    touch_start(integer llDie) {
        IsSaveDue = llGetTime();
    }
    touch_end(integer llDie) {
        if ((llGetAndResetTime() - IsSaveDue) < 1) {
            if ((Library + UThread) <= ++Pop) Pop = UThread;
            llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [26, (string)Pop, <0, 1, 0>, 1]);
        }
        else llRegionSayTo(g_, System, "{\"f\":\"i\",\"l\":\"" + (string)Pop + "\"}");
    }
    listen(integer llDie, string llListen, key llGetKey, string llTarget) {
        if (llGetKey != g_)return ;
        string act = llJsonGetValue(llTarget, (list)"f");
        if (act == "h") llDie();
        else if (act == "g") llSetColor((vector)llJsonGetValue(llTarget, (list)"g"), 0xFFFFFFFF);
    }
}
