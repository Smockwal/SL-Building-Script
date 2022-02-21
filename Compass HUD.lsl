/* 
Drop this script in a cylinder prim and attach it to your HUD (HUD Bottom) 
Please dont go around with a building tool HUD attach for fun.
I made a quick access menu you can use to add/remove this when needed.
*/

#define DIFFUSE "3e84869b-14b7-36ba-ab22-1dbcc1fa5163"

integer gi_on;
float gf_last;
float gf_scale = 0.15915494309189533576888376337251;

default 
{
    on_rez( integer start_param)
    {
        gi_on = FALSE;
    }

    attach( key id )
    {

        if (id) 
        {
            integer att = llGetAttached();
            integer perm = PERMISSION_ATTACH;
            if (att == ATTACH_HUD_BOTTOM)
            {
                float zpos = llGetLocalPos() * <0, 0, 1>;
                if (zpos <= 0.05) zpos = 0.05;

                llSetLinkPrimitiveParamsFast(LINK_THIS, [
                    PRIM_POS_LOCAL, <0, 0, zpos>,  
                    PRIM_ROTATION, ZERO_ROTATION,
                    PRIM_SIZE, <0.5, 0.4, 0.05>
                ]);
                
                perm = PERMISSION_TRACK_CAMERA;
                gi_on = TRUE;
            }
            else 
                llOwnerSay("Compass must be attach on \"HUD Bottom\".");
            llRequestPermissions(id, perm);
        }
    }

    run_time_permissions( integer perm )
    {
        if (perm & PERMISSION_TRACK_CAMERA)
            llMessageLinked(LINK_THIS, gi_on, "", "");
        
        if (perm & PERMISSION_ATTACH)
            llDetachFromAvatar();
    }

    touch_start( integer num_detected )
    {
        if (llDetectedKey(0) == llGetOwner()) 
        {
            gi_on = !gi_on;
            llMessageLinked(LINK_THIS, gi_on, "", "");
        }
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        if (!num) return;

        float angle = llRot2Euler(llGetCameraRot()) * <0, 0, 1>;
        if(gf_last != angle) 
        {
            llSetLinkPrimitiveParamsFast(LINK_THIS, [
                PRIM_TEXTURE, 1, DIFFUSE, <1, 1, 0>, <-(angle * gf_scale), 0, 0>, 0
            ]);
            gf_last = angle;
        }

        llMessageLinked(LINK_THIS, gi_on, "", "");
    }
}
