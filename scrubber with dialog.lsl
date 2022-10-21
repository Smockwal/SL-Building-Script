 integer gi_deeded;
integer gi_channel;
list gl_buttons_main = ["ALL", "TEXT", "FLAG", "SIT", "VISUAL", "SOUND", "MISC", "DONE"];
list gl_buttons_text = ["OVER TEXT", "TOUCH TEXT", "SIT TEXT", "NAME", "DESCRIPTION"];
list gl_buttons_flag = ["VEHICLE", "VOLUME", "CHARRACTER", "PHYSIC", "ACTION"];
list gl_buttons_sit = ["TARGET", "CAMERA", "MOUSELOOK", "SCRIPTED"];
list gl_buttons_visual = ["PARTICLE", "KEYFRAMES", "OMEGA", "ANIMATION", "TEXTURE", "MOVE"];
list gl_buttons_sound = ["STOP", "COLLISION"];
list gl_buttons_misc = ["PIN", "DROP", "DAMAGE", "RLV"];
dialog(string user, string message) {
    list buttons;
    string text;
    if (message == "__OPEN__") {
        text = "\n\nMain menu.\n\n";
        buttons = gl_buttons_main;
    }
    else if (message == "TEXT") {
        text = "\n\nText menu.\n\n";
        buttons = gl_buttons_text;
    }
    else if (message == "FLAG") {
        text = "\n\nFlag menu.\n\n";
        buttons = gl_buttons_flag;
    }
    else if (message == "SIT") {
        text = "\n\nSit menu.\n\n";
        buttons = gl_buttons_sit;
    }
    else if (message == "VISUAL") {
        text = "\n\nVisual menu.\n\n";
        buttons = gl_buttons_visual;
    }
    else if (message == "SOUND") {
        text = "\n\nSound menu.\n\n";
        buttons = gl_buttons_sound;
    }
    else if (message == "MISC") {
        text = "\n\nMisc menu.\n\n";
        buttons = gl_buttons_misc;
    }
    else return ;
    while (llGetListLength(buttons) % 3) buttons += "-";
    buttons = llList2List(buttons, 9, 11) + llList2List(buttons, 6, 8) + llList2List(buttons, 3, 5) + llList2List(buttons, 0, 2);
    llDialog(user, text, buttons, gi_channel);
    llSetTimerEvent(3600);
}
default  {
    state_entry() {
        key group = llList2Key(llGetObjectDetails(llGetKey(), (list)7), 0);
        gi_deeded = (group == llGetOwner());
        gi_channel =  - (1000000 + (integer)llFrand(200000000));
        llListen(gi_channel, "", "", "");
    }
    on_rez(integer start_param) {
        state done;
    }
    timer() {
        state done;
    }
    touch_start(integer num_detected) {
        key user_id = llDetectedKey(0);
        if (gi_deeded && !llSameGroup(user_id))return ;
        else if (user_id != llGetOwner())return ;
        dialog(user_id, "__OPEN__");
    }
    listen(integer channel, string name, key id, string message) {
        if (gi_deeded && !llSameGroup(id))return ;
        else if (id != llGetOwner())return ;
        integer do_all;
        if (message == "ALL") {
            do_all = 1;
        }
        else if (message == "DONE") {
            state done;
        }
        else if (~llListFindList(gl_buttons_main, (list)message)) {
            dialog(id, message);
            return ;
        }
        list params;
        if (message == "OVER TEXT" | do_all) params += [34, 0xFFFFFFFF, 26, "", ((vector)""), 0];
        if (message == "TOUCH TEXT" | do_all) llSetTouchText("");
        if (message == "SIT TEXT" | do_all) llSetSitText("");
        if (message == "NAME" | do_all) params += [34, 0xFFFFFFFF, 27, "Object"];
        if (message == "DESCRIPTION" | do_all) params += [34, 0xFFFFFFFF, 28, ""];
        if (message == "VEHICLE" | do_all) {
            llSetVehicleType(0);
            llSetForce(((vector)""), 0);
            llSetTorque(((vector)""), 0);
            llSetBuoyancy(0);
        }
        if (message == "VOLUME" | do_all) llVolumeDetect(0);
        if (message == "CHARRACTER" | do_all) llDeleteCharacter();
        if (message == "PHYSIC" | do_all) {
            llSetVelocity(((vector)""), 0);
            llSetAngularVelocity(((vector)""), 0);
            params += [34, !!llGetLinkNumber(), 3, 0];
        }
        if (message == "ACTION" | do_all) llSetClickAction(8);
        if (message == "TARGET" | do_all) params += [34, 0xFFFFFFFF, 41, 0, ((vector)""), ((quaternion)"")];
        if (message == "CAMERA" | do_all) llSetLinkCamera(0xFFFFFFFF, ((vector)""), ((vector)""));
        if (message == "MOUSELOOK" | do_all) llForceMouselook(0);
        if (message == "SCRIPTED" | do_all) params += [34, 0xFFFFFFFF, 39, 1, 40, 0];
        if (message == "PARTICLE" | do_all) {
            llLinkParticleSystem(0xFFFFFFFF, [0, 0]);
            llLinkParticleSystem(0xFFFFFFFF, []);
        }
        if (message == "KEYFRAMES" | do_all) {
            llSetKeyframedMotion([], [0, 1]);
            llSetKeyframedMotion([], []);
        }
        if (message == "OMEGA" | do_all) params += [34, 0xFFFFFFFF, 32, ((vector)""), 0, 0];
        if (message == "ANIMATION" | do_all) {
            list animations = llGetObjectAnimationNames();
            integer len = llGetListLength(animations);
            while (len) llStopObjectAnimation(llList2String(animations, --len));
        }
        if (message == "TEXTURE" | do_all) llSetLinkTextureAnim(0xFFFFFFFF, 0, 0xFFFFFFFF, 1, 1, 0, 0, 0);
        if (message == "MOVE" | do_all) {
            integer it = llTarget(llGetPos(), 1);
            while (~it) llTargetRemove(--it);
            llStopMoveToTarget();
        }
        if (message == "STOP" | do_all) llStopSound();
        if (message == "COLLISION" | do_all) {
            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)30), 0) + link;
            for (; link<links; ++link) {
                integer material = llList2Integer(llGetLinkPrimitiveParams(link, (list)2), 0);
                params += [34, link, 2, material];
            }
        }
        if (message == "PIN" | do_all) llSetRemoteScriptAccessPin(0);
        if (message == "DROP" | do_all) llAllowInventoryDrop(0);
        if (message == "DAMAGE" | do_all) llSetDamage(0);
        if (message == "RLV" | do_all) llOwnerSay("@Clear");
        if (params) llSetLinkPrimitiveParamsFast(0xFFFFFFFC, params);
        if (!do_all) dialog(id, message);
        else state done;
    }
}
state done {
    state_entry() {
        llSetTimerEvent(0);
        llSetClickAction(0);
        llRemoveInventory(llGetScriptName());
    }
}