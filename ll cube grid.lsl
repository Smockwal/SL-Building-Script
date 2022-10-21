 integer gi_target_id;
default  {
    state_entry() {
        llSetTimerEvent(1);
    }
    not_at_target() {
        if (gi_target_id) {
            llTargetRemove(gi_target_id);
            gi_target_id = 0;
            llSetTimerEvent(1);
        }
    }
    timer() {
        integer root_link = !!llGetLinkNumber();
        list data = llGetObjectDetails(llGetLinkKey(root_link), (list)37);
        if (!llList2Integer(data, 0)) {
            llSetTimerEvent(0);
            vector scale = llList2Vector(llGetLinkPrimitiveParams(root_link, (list)7), 0);
            vector tsc = scale * 0.1;
            vector pos = llGetRootPosition();
            pos = <llRound(pos.x), llRound(pos.y), llRound(pos.z) - (scale.z * 0.5)>;
            float ground = llGround(((vector)""));
            while (pos.z < ground) pos.z += 1;
            while (!llSetRegionPos(pos));
            llSetLinkPrimitiveParams(root_link, [6, pos, 8, ((quaternion)""), 18, 0xFFFFFFFF, <0.502, 0.502, 0.502>, 1, 20, 0xFFFFFFFF, 1, 17, 0, "950b4f00-a1f7-ddad-a8ae-3582c5f77134", <tsc.x, tsc.y, 0>, ((vector)""), 0, 17, 1, "950b4f00-a1f7-ddad-a8ae-3582c5f77134", <tsc.x, tsc.z, 0>, ((vector)""), 0, 17, 2, "950b4f00-a1f7-ddad-a8ae-3582c5f77134", <tsc.y, tsc.z, 0>, ((vector)""), 0, 17, 3, "950b4f00-a1f7-ddad-a8ae-3582c5f77134", <tsc.x, tsc.z, 0>, ((vector)""), 0, 17, 4, "950b4f00-a1f7-ddad-a8ae-3582c5f77134", <tsc.y, tsc.z, 0>, ((vector)""), 0, 17, 5, "950b4f00-a1f7-ddad-a8ae-3582c5f77134", <tsc.x, tsc.y, 0>, ((vector)""), 0]);
            llTargetRemove(gi_target_id);
            gi_target_id = llTarget(llGetRootPosition(), 0.01);
        }
    }
    changed(integer change) {
        if (change & 0x8) llSetTimerEvent(1);
    }
}