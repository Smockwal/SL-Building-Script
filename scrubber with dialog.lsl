
/*
    What:
    The scrubber is a script to reset prim propriety, This version focuses on propriety that can't be set via the Edit menu.

    How:
    1: Compile in inventory.
    2: Drag and drop in a linkset.
    3: Touch the object to get a dialog.

    ✅ deeded | ✅ optimized | ❌ shared | ✅ self delete
    ✅ attachment | ✅ rezzed | ✅ link-set | ✅ single object
*/

integer Pop;
integer System;
list ga = ["ALL", "TEXT", "FLAG", "SIT", "VISUAL", "SOUND", "LSD", "MISC", "DONE"];
a(string Library, string UThread) {
    list buttons;
    string text;
    if (UThread == "__OPEN__") {
        text = "\n\nMain menu.\n\n";
        buttons = ga;
    }
    else if (UThread == "TEXT") {
        text = "\n\nText menu.\n\n";
        buttons = ["OVER TEXT", "TOUCH TEXT", "SIT TEXT", "NAME", "DESCRIPTION"];
    }
    else if (UThread == "FLAG") {
        text = "\n\nFlag menu.\n\n";
        buttons = ["VEHICLE", "DETECTION", "CHARRACTER", "PHYSIC", "ACTION"];
    }
    else if (UThread == "SIT") {
        text = "\n\nSit menu.\n\n";
        buttons = ["TARGET", "CAMERA", "MOUSELOOK", "SCRIPTED"];
    }
    else if (UThread == "VISUAL") {
        text = "\n\nVisual menu.\n\n";
        buttons = ["PARTICLE", "KEYFRAMES", "OMEGA", "ANIMATION", "TEXTURE", "MOVE"];
    }
    else if (UThread == "SOUND") {
        text = "\n\nSound menu.\n\n";
        buttons = ["STOP", "COLLISION"];
    }
    else if (UThread == "LSD") {
        text = "\n\nSound menu.\n\n";
        buttons = ["STOP", "COLLISION"];
    }
    else if (UThread == "MISC") {
        text = "\n\nMisc menu.\n\n";
        buttons = ["PIN", "DROP", "DAMAGE", "RLV"];
    }
    else return ;
     @ dialog_dash_label;
    if (llGetListLength(buttons) % 3) {
        buttons += "-";
        jump dialog_dash_label;
    }
    buttons = llList2List(buttons, 9, 11) + llList2List(buttons, 6, 8) + llList2List(buttons, 3, 5) + llList2List(buttons, 0, 2);
    llDialog(Library, text, buttons, System);
    llSetTimerEvent(3600);
}
default  {
    state_entry() {
        key group = llList2Key(llGetObjectDetails(llGetKey(), (list)7), 0);
        Pop = (group == llGetOwner());
        System =  - (1000000 + (integer)llFrand(200000000));
        llListen(System, "", "", "");
    }
    on_rez(integer Library) {
        state _;
    }
    timer() {
        state _;
    }
    touch_start(integer Library) {
        key user_id = llDetectedKey(0);
        if (Pop && !llSameGroup(user_id))return ;
        else if (user_id != llGetOwner())return ;
        a(user_id, "__OPEN__");
    }
    listen(integer Library, string UThread, key llFrand, string llGetKey) {
        if (Pop && !llSameGroup(llFrand))return ;
        else if (llFrand != llGetOwner())return ;
        integer do_all;
        if (llGetKey == "ALL") {
            do_all = 1;
        }
        else if (llGetKey == "DONE") {
            state _;
        }
        else if (llGetKey == "-") {
            a(llFrand, "__OPEN__");
            return ;
        }
        else if (~llListFindList(ga, (list)llGetKey)) {
            a(llFrand, llGetKey);
            return ;
        }
        list params;
        if (llGetKey == "OVER TEXT" | do_all) params += [34, 0xFFFFFFFF, 26, "", ((vector)""), 0];
        if (llGetKey == "TOUCH TEXT" | do_all) llSetTouchText("");
        if (llGetKey == "SIT TEXT" | do_all) llSetSitText("");
        if (llGetKey == "NAME" | do_all) params += [34, 0xFFFFFFFF, 27, "Object"];
        if (llGetKey == "DESCRIPTION" | do_all) params += [34, 0xFFFFFFFF, 28, ""];
        if (llGetKey == "VEHICLE" | do_all) {
            llSetVehicleType(0);
            llSetForce(((vector)""), 0);
            llSetTorque(((vector)""), 0);
            llSetBuoyancy(0);
        }
        if (llGetKey == "DETECTION" | do_all) llVolumeDetect(0);
        if (llGetKey == "CHARRACTER" | do_all) llDeleteCharacter();
        if (llGetKey == "PHYSIC" | do_all) {
            llSetVelocity(((vector)""), 0);
            llSetAngularVelocity(((vector)""), 0);
            params += [34, !!llGetLinkNumber(), 3, 0];
        }
        if (llGetKey == "ACTION" | do_all) llSetClickAction(8);
        if (llGetKey == "TARGET" | do_all) params += [34, 0xFFFFFFFF, 41, 0, ((vector)""), ((quaternion)"")];
        if (llGetKey == "CAMERA" | do_all) llSetLinkCamera(0xFFFFFFFF, ((vector)""), ((vector)""));
        if (llGetKey == "MOUSELOOK" | do_all) llForceMouselook(0);
        if (llGetKey == "SCRIPTED" | do_all) params += [34, 0xFFFFFFFF, 39, 1, 40, 0];
        if (llGetKey == "PARTICLE" | do_all) {
            llLinkParticleSystem(0xFFFFFFFF, [0, 0]);
            llLinkParticleSystem(0xFFFFFFFF, []);
        }
        if (llGetKey == "KEYFRAMES" | do_all) {
            llSetKeyframedMotion([], [0, 1]);
            llSetKeyframedMotion([], []);
        }
        if (llGetKey == "OMEGA" | do_all) params += [34, 0xFFFFFFFF, 32, ((vector)""), 0, 0];
        if (llGetKey == "ANIMATION" | do_all) {
            list ani_list = llGetObjectAnimationNames();
            if (ani_list) {
                integer len = llGetListLength(ani_list);
                 @ animation_label;
                 {
                    llStopObjectAnimation(llList2String(ani_list, --len));
                }
                if (~len)jump animation_label;
            }
        }
        if (llGetKey == "TEXTURE" | do_all) llSetLinkTextureAnim(0xFFFFFFFF, 0, 0xFFFFFFFF, 1, 1, 0, 0, 0);
        if (llGetKey == "MOVE" | do_all) {
            integer it = llTarget(llGetPos(), 1);
             @ target_label;
             {
                llTargetRemove(--it);
            }
            if (~it)jump target_label;
            llStopMoveToTarget();
        }
        if (llGetKey == "STOP" | do_all) llStopSound();
        if (llGetKey == "COLLISION" | do_all) {
            integer link = !!llGetLinkNumber();
            integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)30), 0);
             @ collision_label;
             {
                integer material = llList2Integer(llGetLinkPrimitiveParams(link, (list)2), 0);
                params += [34, link, 2, material];
            }
            if (++link <= links)jump collision_label;
        }
        if (llGetKey == "SAFE" | do_all) {
            list keys = llLinksetDataListKeys(0, 0);
            integer len = llGetListLength(keys);
             @ lsd_key_label;
             {
                string curr = llList2String(keys, --len);
                integer stat = llLinksetDataDelete(curr);
                if (stat == 3) curr += " is protected.";
                else if (!stat) curr += " deleted.";
                llRegionSayTo(llFrand, 0, curr);
            }
            if (~len)jump lsd_key_label;
        }
        if (llGetKey == "UNSAFE" | do_all) {
            llLinksetDataReset();
        }
        if (llGetKey == "PIN" | do_all) llSetRemoteScriptAccessPin(0);
        if (llGetKey == "DROP" | do_all) llAllowInventoryDrop(0);
        if (llGetKey == "DAMAGE" | do_all) llSetDamage(0);
        if (llGetKey == "RLV" | do_all) llOwnerSay("@Clear");
        if (params) llSetLinkPrimitiveParamsFast(0xFFFFFFFC, params);
        if (!do_all) a(llFrand, llGetKey);
        else state _;
    }
}
state _ {
    state_entry() {
        llSetTimerEvent(0);
        llSetClickAction(0);
        llRemoveInventory(llGetScriptName());
    }
}
