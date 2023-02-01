
#define DIFFUSE_OFFSET 0
#define NORMAL_OFFSET 4
#define SPECULAR_OFFSET 8

#define DIFFUSE_MAP "d732ed9d-4215-bfb4-6dab-e4a729e4d27f"
#define NORMAL_MAP "04870cc4-f5bd-0ead-2419-9272b372f1df"
#define SPECULAR_MAP "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d"

default {

    state_entry() {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_SIZE, <0.1, 0.1 * 8, 0.1>,
            PRIM_COLOR, ALL_SIDES, <1,1,1>, 1,
            PRIM_TEXTURE, ALL_SIDES, DIFFUSE_MAP, <1,1,0>, <0,0,0>, 0,
            PRIM_NORMAL, ALL_SIDES, NORMAL_MAP, <1,1,0>, <0,0,0>, 0,
            PRIM_SPECULAR, ALL_SIDES, SPECULAR_MAP, <1,1,0>, <0,0,0>, 0, <1,1,1>, 0, 0
        ]);
    }
    
    on_rez(integer start_par) {
        integer att = llGetAttached();
        if (att < ATTACH_HUD_CENTER_2 || att > ATTACH_HUD_BOTTOM_RIGHT) {
            llOwnerSay("HUD must be attach on HUD.");
            if (att) llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
            else llDie();
        }
    }

    attach(key id) {
        if (id) {
            llSetLinkPrimitiveParamsFast(LINK_THIS, [
                PRIM_COLOR, ALL_SIDES, <1,1,1>, 1,
                PRIM_TEXTURE, ALL_SIDES, DIFFUSE_MAP, <1,1,0>, <0,0,0>, 0,
                PRIM_NORMAL, ALL_SIDES, NORMAL_MAP, <1,1,0>, <0,0,0>, 0,
                PRIM_SPECULAR, ALL_SIDES, SPECULAR_MAP, <1,1,0>, <0,0,0>, 0, <1,1,1>, 0, 0
            ]);
        }
    }

    run_time_permissions(integer perm) {
        llDetachFromAvatar();
    }

    touch_start(integer num_detected) {
        integer side = llDetectedTouchFace(0);
        list data = llGetLinkPrimitiveParams(llDetectedLinkNumber(0), [
            PRIM_TEXTURE, side, 
            PRIM_NORMAL, side, 
            PRIM_SPECULAR, side
        ]);

        string msg;
        
        string diffuse = llList2String(data, DIFFUSE_OFFSET);
        if (diffuse != DIFFUSE_MAP)
            msg += "\nDiffuse: " + diffuse;

        string normal = llList2String(data, NORMAL_OFFSET);
        if (normal != NORMAL_MAP)
            msg += "\nNormal: " + normal;

        string specular = llList2String(data, SPECULAR_OFFSET);
        if (specular != SPECULAR_MAP)
            msg += "\nSpecular: " + specular;

        if (msg == "") msg = "Apply a local texture first.";

        llRegionSayTo(llDetectedKey(0), PUBLIC_CHANNEL, msg);
    }

}
