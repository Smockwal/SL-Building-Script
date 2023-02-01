
// Uncomment the next line when link sound function will be available
//#define LINK_SOUND_UPDATE


#define BUTTON_ALL "ALL"
#define BUTTON_DONE "DONE"

#define MENU_TEXT "TEXT"
#define MENU_FLAG "FLAG"
#define MENU_SIT "SIT"
#define MENU_VISUAL "VISUAL"
#define MENU_SOUND "SOUND"
#define MENU_LSD "LSD"
#define MENU_MISC "MISC"

// text
#define BUTTON_OVER "OVER TEXT"
#define BUTTON_TOUCH "TOUCH TEXT"
#define BUTTON_SIT "SIT TEXT"
#define BUTTON_NAME "NAME"
#define BUTTON_DESC "DESCRIPTION"

// flag
#define BUTTON_VEHICLE "VEHICLE"
#define BUTTON_DETECTION "DETECTION"
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
#ifdef LINK_SOUND_UPDATE
    #define BUTTON_VOLUME "VOLUME"
    #define BUTTON_RADIUS "RADIUS"
    #define BUTTON_QUEUEING "QUEUEING"
#endif
#define BUTTON_COLLISION "COLLISION"

// linkset data
#define BUTTON_UNPROTECTED "SAFE"
#define BUTTON_PROTECTED "UNSAFE"

// misc
#define BUTTON_PIN "PIN"
#define BUTTON_DROP "DROP"
#define BUTTON_DAMAGE "DAMAGE"
#define BUTTON_RLV "RLV"

#define DIALOG_OPEN "__OPEN__"

list gl_buttons_main = [
    BUTTON_ALL, MENU_TEXT, MENU_FLAG, 
    MENU_SIT, MENU_VISUAL, MENU_SOUND, 
    MENU_LSD, MENU_MISC, BUTTON_DONE
];

#define gl_buttons_text [ \
    BUTTON_OVER, BUTTON_TOUCH, BUTTON_SIT, \
    BUTTON_NAME, BUTTON_DESC \
]

#define gl_buttons_flag [ \
    BUTTON_VEHICLE, BUTTON_DETECTION, BUTTON_CHARRACTER, \
    BUTTON_PHYSIC, BUTTON_ACTION \
]

#define gl_buttons_sit [ \
    BUTTON_TARGET, BUTTON_CAMERA, BUTTON_MOUSELOOK, \
    BUTTON_SCRIPTED \
]

#define gl_buttons_visual [ \
    BUTTON_PARTICLE, BUTTON_KEYFRAMES, BUTTON_OMEGA, \
    BUTTON_ANIMATION, BUTTON_TEXTURE, BUTTON_MOVE \
]

#ifdef LINK_SOUND_UPDATE
    #define gl_buttons_sound [ \
        BUTTON_STOP, BUTTON_VOLUME, BUTTON_RADIUS, \
        BUTTON_QUEUEING, BUTTON_COLLISION \
    ]
#else
    #define gl_buttons_sound [ \
        BUTTON_STOP, BUTTON_COLLISION \
    ]
#endif



#define gl_buttons_lsd [ \
    BUTTON_UNPROTECTED, BUTTON_PROTECTED \
]

#define gl_buttons_misc [ \
    BUTTON_PIN, BUTTON_DROP, BUTTON_DAMAGE, \
    BUTTON_RLV \
]

integer gi_channel;
integer gi_deeded;

dialog(string user, string message)
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
    else if (message == MENU_LSD)
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

    @dialog_dash_label;
    if (llGetListLength(buttons) % 3) {
        buttons += "-";
        jump dialog_dash_label;
    }
    buttons = llList2List(buttons, 9, 11) + llList2List(buttons, 6, 8) + 
              llList2List(buttons, 3, 5) + llList2List(buttons, 0, 2);
    llDialog(user, text, buttons, gi_channel);
    llSetTimerEvent(3600);
}

default 
{
    state_entry()
    {
        key group = llList2Key(llGetObjectDetails(llGetKey(), [OBJECT_GROUP]), 0);
        gi_deeded = (group == llGetOwner());

        gi_channel = -(1000000 + (integer)llFrand(200000000));
        llListen(gi_channel, "", "", "");
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
        key user_id = llDetectedKey(0);

        if (gi_deeded && !llSameGroup(user_id)) return;
        else if (user_id != llGetOwner()) return;

        dialog(user_id, DIALOG_OPEN);
    }

    listen( integer channel, string name, key id, string message )
    {

        if (gi_deeded && !llSameGroup(id)) return;
        else if (id != llGetOwner()) return;

        integer do_all;
        if (message == BUTTON_ALL) {
            do_all = TRUE;
        }
        else if (message == BUTTON_DONE) {
            state done;
        }
        else if (message == "-") {
            dialog(id, DIALOG_OPEN);
            return;
        }
        else if (~llListFindList(gl_buttons_main, (list)message)) {
            dialog(id, message);
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

        if (message == BUTTON_NAME || do_all)
            params += [PRIM_LINK_TARGET, LINK_SET, PRIM_NAME, "Object"];

        if (message == BUTTON_DESC || do_all)
            params += [PRIM_LINK_TARGET, LINK_SET, PRIM_DESC, ""];

        // flag
        if (message == BUTTON_VEHICLE || do_all)
        {
            llSetVehicleType(VEHICLE_TYPE_NONE);
			llSetForce(ZERO_VECTOR, FALSE);
			llSetTorque(ZERO_VECTOR, FALSE);
			llSetBuoyancy(0.0);
        }

        if (message == BUTTON_DETECTION || do_all)
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
            list ani_list = llGetObjectAnimationNames();
            if (ani_list) {
                integer len = llGetListLength(ani_list);
                @animation_label;
                {
                    llStopObjectAnimation(llList2String(ani_list, --len));
                }
                if (~len) jump animation_label;
            }
        }

        if (message == BUTTON_TEXTURE || do_all)
            llSetLinkTextureAnim(LINK_SET, FALSE , ALL_SIDES, 1, 1, 0, 0, 0.0 );

        if (message == BUTTON_MOVE || do_all)
        {
            integer it = llTarget(llGetPos(), 1);

            @target_label; 
            {
                llTargetRemove(--it);
            }
            if (~it) jump target_label;
            llStopMoveToTarget();
        }
        
        // sound
        if (message == BUTTON_STOP || do_all)
#ifdef LINK_SOUND_UPDATE
            llLinkStopSound(LINK_SET);
#else 
            llStopSound();
#endif

        if (message == BUTTON_COLLISION || do_all)
        {
            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(llGetObjectDetails(llGetKey(), [OBJECT_PRIM_COUNT]), 0);

            @collision_label;
            {
                integer material = llList2Integer(llGetLinkPrimitiveParams(link, [PRIM_MATERIAL]), 0);
                params += [PRIM_LINK_TARGET, link, PRIM_MATERIAL, material];
            }
            if (++link <= links) jump collision_label;
        }

#ifdef LINK_SOUND_UPDATE
        if (message == BUTTON_VOLUME || do_all)
            llLinkAdjustSoundVolume(LINK_SET, 1);

        if (message == BUTTON_RADIUS || do_all)
            llLinkSetSoundRadius(LINK_SET, 0);
        
        if (message == BUTTON_QUEUEING || do_all)
            llLinkSetSoundQueueing(LINK_SET, FALSE);
#endif

        //lsd
        if (message == BUTTON_UNPROTECTED || do_all) {
            list keys = llLinksetDataListKeys(0, 0);
            integer len = llGetListLength(keys);
            @lsd_key_label;
            {
                string curr = llList2String(keys, --len);
                integer stat = llLinksetDataDelete(curr);
                if (stat == LINKSETDATA_EPROTECTED) curr += " is protected.";
                else if (stat == LINKSETDATA_OK) curr += " deleted.";
                llRegionSayTo(id, PUBLIC_CHANNEL, curr);
            }
            if (~len) jump lsd_key_label;
        }

        if (message == BUTTON_PROTECTED || do_all) {
            llLinksetDataReset();
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
            dialog(id, message);
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
