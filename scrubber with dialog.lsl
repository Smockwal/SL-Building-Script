#define BUTTON_ALL "ALL"

#define MENU_TEXT "TEXT"
#define MENU_FLAG "FLAG"
#define MENU_SIT "SIT"
#define MENU_VISUAL "VISUAL"
#define MENU_SOUND "SOUND"
#define MENU_MISC "MISC"

// text
#define BUTTON_OVER "OVER TEXT"
#define BUTTON_TOUCH "TOUCH TEXT"
#define BUTTON_SIT "SIT TEXT"

// flag
#define BUTTON_VEHICLE "VEHICLE"
#define BUTTON_VOLUME "VOLUME"
#define BUTTON_CHARRACTER "CHARRACTER"
#define BUTTON_PHYSIC "PHYSIC"
#define BUTTON_ACTION "ACTION"

// sit
#define BUTTON_TARGET "TARGET"
#define BUTTON_CAMERA "CAMERA"
#define BUTTON_MOUSELOOK "MOUSELOOK"
#define BUTTON_SCRIPTED "SCRIPTED"

// visual
#define BUTTON_PARTICLE "PARTICLE"
#define BUTTON_KEYFRAMES "KEYFRAMES"
#define BUTTON_OMEGA "OMEGA"
#define BUTTON_ANIMATION "ANIMATION"
#define BUTTON_TEXTURE "TEXTURE"
#define BUTTON_MOVE "MOVE"

// sound
#define BUTTON_STOP "STOP"
#define BUTTON_COLLISION "COLLISION"

// misc
#define BUTTON_PIN "PIN"
#define BUTTON_DROP "DROP"
#define BUTTON_DAMAGE "DAMAGE"
#define BUTTON_RLV "RLV"

#define DIALOG_OPEN "__OPEN__"

list gl_buttons_main = [
    BUTTON_ALL, MENU_TEXT, MENU_FLAG, 
    MENU_SIT, MENU_VISUAL, MENU_SOUND, 
    MENU_MISC
];

list gl_buttons_text = [
    BUTTON_OVER, BUTTON_TOUCH, BUTTON_SIT
];

list gl_buttons_flag = [
    BUTTON_VEHICLE, BUTTON_VOLUME, BUTTON_CHARRACTER,
    BUTTON_PHYSIC, BUTTON_ACTION
];

list gl_buttons_sit = [
    BUTTON_TARGET, BUTTON_CAMERA, BUTTON_MOUSELOOK,
    BUTTON_SCRIPTED
];

list gl_buttons_visual = [
    BUTTON_PARTICLE, BUTTON_KEYFRAMES, BUTTON_OMEGA,
    BUTTON_ANIMATION, BUTTON_TEXTURE, BUTTON_MOVE
];

list gl_buttons_sound = [
    BUTTON_STOP, BUTTON_COLLISION
];

list gl_buttons_misc = [
    BUTTON_PIN, BUTTON_DROP, BUTTON_DAMAGE,
    BUTTON_RLV
];

integer gi_channel;

dialog(string message)
{
    list buttons;
    string text;
    if (message == DIALOG_OPEN)
    {
        text = "\n\nMain menu.\n\n";
        buttons = gl_buttons_main;
    }
    else if (message == MENU_TEXT)
    {
        text = "\n\nText menu.\n\n";
        buttons = gl_buttons_text;
    }
    else if (message == MENU_FLAG)
    {
        text = "\n\nFlag menu.\n\n";
        buttons = gl_buttons_flag;
    }
    else if (message == MENU_SIT)
    {
        text = "\n\nSit menu.\n\n";
        buttons = gl_buttons_sit;
    }
    else if (message == MENU_VISUAL)
    {
        text = "\n\nVisual menu.\n\n";
        buttons = gl_buttons_visual;
    }
    else if (message == MENU_SOUND)
    {
        text = "\n\nSound menu.\n\n";
        buttons = gl_buttons_sound;
    }
    else if (message == MENU_MISC)
    {
        text = "\n\nMisc menu.\n\n";
        buttons = gl_buttons_misc;
    }
    else 
        return;

    while(llGetListLength(buttons) % 3) buttons += "-";
    buttons = llList2List(buttons, 9, 11) + llList2List(buttons, 6, 8) + 
              llList2List(buttons, 3, 5) + llList2List(buttons, 0, 2);
    llDialog(llGetOwner(), text, buttons, gi_channel);
    llSetTimerEvent(3600);
}

default 
{
    state_entry()
    {
        string owner = llGetOwner();
        gi_channel = -(1000000 + (integer)llFrand(200000000));
        llListen(gi_channel, llKey2Name(owner), owner, "");
        dialog(DIALOG_OPEN);
    }

    on_rez( integer start_param)
    {
        state done;
    }

    timer()
    {
        state done;
    }

    touch_start( integer num_detected )
    {
        if (llDetectedKey(0) == llGetOwner())
            dialog(DIALOG_OPEN);
    }

    listen( integer channel, string name, key id, string message )
    {
        integer do_all;
        if (message == BUTTON_ALL)
        {
            do_all = TRUE;
        }
        else if (~llListFindList(gl_buttons_main, (list)message))
        {
            dialog(message);
            return;
        }

        
        list params;

        // text
        if (message == BUTTON_OVER || do_all)
            params += [PRIM_LINK_TARGET, LINK_SET, PRIM_TEXT, "", ZERO_VECTOR, 0];
        
        if (message == BUTTON_TOUCH || do_all)
            llSetTouchText("");
        
        if (message == BUTTON_SIT || do_all)
            llSetSitText("");

        // flag
        if (message == BUTTON_VEHICLE || do_all)
        {
            llSetVehicleType(VEHICLE_TYPE_NONE);
			llSetForce(ZERO_VECTOR, FALSE);
			llSetTorque(ZERO_VECTOR, FALSE);
			llSetBuoyancy(0.0);
        }

        if (message == BUTTON_VOLUME || do_all)
            llVolumeDetect(FALSE);

        if (message == BUTTON_CHARRACTER || do_all)
            llDeleteCharacter();

        if (message == BUTTON_PHYSIC || do_all)
        {
            llSetVelocity(ZERO_VECTOR, FALSE);
			llSetAngularVelocity( ZERO_VECTOR, FALSE);
            params += [PRIM_LINK_TARGET, !!llGetLinkNumber(), PRIM_PHYSICS, FALSE];
        }

        if (message == BUTTON_ACTION || do_all)
            llSetClickAction(CLICK_ACTION_DISABLED);
        

        // sit
        if (message == BUTTON_TARGET || do_all)
            params += [PRIM_LINK_TARGET, LINK_SET, PRIM_SIT_TARGET, FALSE, ZERO_VECTOR, ZERO_ROTATION];

        if (message == BUTTON_CAMERA || do_all)
            llSetLinkCamera(LINK_SET, ZERO_VECTOR, ZERO_VECTOR);

        if (message == BUTTON_MOUSELOOK || do_all)
            llForceMouselook(FALSE);

        if (message == BUTTON_SCRIPTED || do_all)
            params += [PRIM_LINK_TARGET, LINK_SET, PRIM_ALLOW_UNSIT, TRUE, PRIM_SCRIPTED_SIT_ONLY, FALSE];

        // visual
        if (message == BUTTON_PARTICLE || do_all)
        {
            llLinkParticleSystem(LINK_SET, [PSYS_PART_FLAGS, 0]);
            llLinkParticleSystem(LINK_SET, []);
        }

        if (message == BUTTON_KEYFRAMES || do_all)
        {
            llSetKeyframedMotion([],[KFM_COMMAND, KFM_CMD_STOP]);
		    llSetKeyframedMotion([],[]);
        }

        if (message == BUTTON_OMEGA || do_all)
            params += [PRIM_LINK_TARGET, LINK_SET, PRIM_OMEGA, ZERO_VECTOR, 0, 0];

        if (message == BUTTON_ANIMATION || do_all)
        {
            list animations = llGetObjectAnimationNames();
            integer len = llGetListLength(animations);
            while(len)
                llStopObjectAnimation(llList2String(animations, --len));
        }

        if (message == BUTTON_TEXTURE || do_all)
            llSetLinkTextureAnim(LINK_SET, FALSE , ALL_SIDES, 1, 1, 0, 0, 0.0 );

        if (message == BUTTON_MOVE || do_all)
        {
            llStopMoveToTarget();
            integer it;
            while (it < 8) 
                llTargetRemove(it++);
        }
        
        // sound
        if (message == BUTTON_STOP || do_all)
            llStopSound();

        if (message == BUTTON_COLLISION || do_all)
        {
            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)OBJECT_PRIM_COUNT), 0) + link;
            for (; link < links; ++link) 
            {
                integer material = llList2Integer(llGetLinkPrimitiveParams(link, (list)PRIM_MATERIAL), 0);
                params += [PRIM_LINK_TARGET, link, PRIM_MATERIAL, material];
            }
        }

        // misc
        if (message == BUTTON_PIN || do_all)
            llSetRemoteScriptAccessPin(0);

        if (message == BUTTON_DROP || do_all)
            llAllowInventoryDrop(FALSE);

        if (message == BUTTON_DAMAGE || do_all)
            llSetDamage(0);

        if (message == BUTTON_RLV || do_all)
            llOwnerSay("@Clear");
            
        if (params) 
            llSetLinkPrimitiveParamsFast(LINK_THIS, params);

        if (!do_all)
            dialog(DIALOG_OPEN);
        else 
            state done;
    }

}

state done 
{
    state_entry()
    {
        llSetTimerEvent(0);
        llSetClickAction(CLICK_ACTION_NONE);
        llRemoveInventory(llGetScriptName());
    }
}
