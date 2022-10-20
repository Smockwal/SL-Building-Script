
/* 
Drop this script in a cylinder prim and attach it to your HUD (HUD Bottom) 
Please dont go around with a building tool HUD attach for fun.
I made a quick access menu you can use to add/remove this when needed.
*/

integer gi_on;
float gf_last;
default  {
    on_rez(integer start_param) {
        gi_on = 0;
    }
    attach(key id) {
        if (id) {
            integer att = llGetAttached();
            integer perm = 0x20;
            if (att == 37) {
                float zpos = llGetLocalPos() * <0, 0, 1>;
                if (zpos <= 0.05) zpos = 0.05;
                llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [33, <0, 0, zpos>, 8, ((quaternion)""), 7, <0.5, 0.4, 0.05>]);
                perm = 0x400;
                gi_on = 1;
            }
            else llOwnerSay("Compass must be attach on \"HUD Bottom\".");
            llRequestPermissions(id, perm);
        }
    }
    run_time_permissions(integer perm) {
        if (perm & 0x400) llMessageLinked(0xFFFFFFFC, gi_on, "", "");
        if (perm & 0x20) llDetachFromAvatar();
    }
    touch_start(integer num_detected) {
        if (llDetectedKey(0) == llGetOwner()) {
            gi_on = !gi_on;
            llMessageLinked(0xFFFFFFFC, gi_on, "", "");
        }
    }
    link_message(integer sender_num, integer num, string str, key id) {
        if (!num)return ;
        float angle = llRot2Euler(llGetCameraRot()) * <0, 0, 1>;
        if (gf_last != angle) {
            llSetLinkPrimitiveParamsFast(0xFFFFFFFC, [17, 1, "3e84869b-14b7-36ba-ab22-1dbcc1fa5163", <1, 1, 0>, < - (angle * 0.15915494309189533576888376337251), 0, 0>, 0]);
            gf_last = angle;
        }
        llMessageLinked(0xFFFFFFFC, gi_on, "", "");
    }
}