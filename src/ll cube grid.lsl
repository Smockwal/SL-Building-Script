
#define DIFFUSE "950b4f00-a1f7-ddad-a8ae-3582c5f77134"
#define COLOR <0.502, 0.502, 0.502>

integer gi_target_id;

default 
{
    state_entry()
    {
        llSetTimerEvent(1);
    }

    not_at_target()
    {
        if (gi_target_id) 
        {
            llTargetRemove(gi_target_id);
            gi_target_id = 0;
            llSetTimerEvent(1);
        }
    }

    timer()
    {
        integer root_link = !!llGetLinkNumber();
        list data = llGetObjectDetails(llGetLinkKey(root_link), [OBJECT_SELECT_COUNT]);
        if (!llList2Integer(data, 0))
        {
            llSetTimerEvent(0);

            vector scale = llList2Vector(llGetLinkPrimitiveParams(root_link, [PRIM_SIZE]), 0); 
            vector tsc = scale * 0.1;

            vector pos = llGetRootPosition();
            pos = <llRound(pos.x), llRound(pos.y), llRound(pos.z) - (scale.z * 0.5)>;

            float ground = llGround(ZERO_VECTOR); 
            while (pos.z < ground)
                pos.z += 1; 

            while (!llSetRegionPos(pos));
            llSetLinkPrimitiveParams(root_link, [
                PRIM_POSITION, pos,
                PRIM_ROTATION, ZERO_ROTATION,
                PRIM_COLOR, ALL_SIDES, COLOR, 1,
                PRIM_FULLBRIGHT, ALL_SIDES, 1,
                PRIM_TEXTURE, 0, DIFFUSE, <tsc.x, tsc.y, 0>, ZERO_VECTOR, 0,
                PRIM_TEXTURE, 1, DIFFUSE, <tsc.x, tsc.z, 0>, ZERO_VECTOR, 0,
                PRIM_TEXTURE, 2, DIFFUSE, <tsc.y, tsc.z, 0>, ZERO_VECTOR, 0,
                PRIM_TEXTURE, 3, DIFFUSE, <tsc.x, tsc.z, 0>, ZERO_VECTOR, 0,
                PRIM_TEXTURE, 4, DIFFUSE, <tsc.y, tsc.z, 0>, ZERO_VECTOR, 0,
                PRIM_TEXTURE, 5, DIFFUSE, <tsc.x, tsc.y, 0>, ZERO_VECTOR, 0
            ]);
            
            llTargetRemove(gi_target_id);
            gi_target_id = llTarget(llGetRootPosition(), 0.01);
        }
    }

    changed( integer change )
    {
        if (change & CHANGED_SCALE)
            llSetTimerEvent(1);
    }
}
