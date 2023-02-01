default  {
    state_entry() {
        llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [
            7, <0.1, 0.8, 0.1>, 
            18, 0xFFFFFFFF, <1, 1, 1>, 1, 
            17, 0xFFFFFFFF, "d732ed9d-4215-bfb4-6dab-e4a729e4d27f", <1, 1, 0>, ((vector)""), 0, 
            37, 0xFFFFFFFF, "04870cc4-f5bd-0ead-2419-9272b372f1df", <1, 1, 0>, ((vector)""), 0, 
            36, 0xFFFFFFFF, "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d", <1, 1, 0>, ((vector)""), 0, <1, 1, 1>, 0, 0
        ]);
    }
    on_rez(integer start_par) {
        integer att = llGetAttached();
        if (att < 31 | att > 38) {
            llOwnerSay("HUD must be attach on HUD.");
            if (att) llRequestPermissions(llGetOwner(), 32);
            else llDie();
        }
    }
    attach(key id) {
        if (id) {
            llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [
                18, 0xFFFFFFFF, <1, 1, 1>, 1, 
                17, 0xFFFFFFFF, "d732ed9d-4215-bfb4-6dab-e4a729e4d27f", <1, 1, 0>, ((vector)""), 0, 
                37, 0xFFFFFFFF, "04870cc4-f5bd-0ead-2419-9272b372f1df", <1, 1, 0>, ((vector)""), 0, 
                36, 0xFFFFFFFF, "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d", <1, 1, 0>, ((vector)""), 0, <1, 1, 1>, 0, 0
            ]);
        }
    }
    run_time_permissions(integer perm) {
        llDetachFromAvatar();
    }
    touch_start(integer num_detected) {
        integer side = llDetectedTouchFace(0);
        list data = llGetLinkPrimitiveParams(llDetectedLinkNumber(0), [17, side, 37, side, 36, side]);
        string msg;
        string diffuse = llList2String(data, 0);
        if (diffuse != "d732ed9d-4215-bfb4-6dab-e4a729e4d27f") msg += "\nDiffuse: " + diffuse;
        string normal = llList2String(data, 4);
        if (normal != "04870cc4-f5bd-0ead-2419-9272b372f1df") msg += "\nNormal: " + normal;
        string specular = llList2String(data, 8);
        if (specular != "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d") msg += "\nSpecular: " + specular;
        if (msg == "") msg = "Apply a local texture first.";
        llRegionSayTo(llDetectedKey(0), 0, msg);
    }
}
