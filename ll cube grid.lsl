
#define DIFFUSE "950b4f00-a1f7-ddad-a8ae-3582c5f77134"

integer gi_root_link;
string gs_root_id;
integer gi_target_id;

set() 
{
    vector scale = llGetScale();
    vector tsc = scale * 0.05;

    vector pos = llGetRootPosition();
    pos = <llRound(pos.x), llRound(pos.y), llRound(pos.z) - (scale.z * 0.5)>;

    llSetLinkPrimitiveParamsFast(gi_root_link, [
        PRIM_POSITION, pos,
        PRIM_ROTATION, ZERO_ROTATION,
        PRIM_COLOR, ALL_SIDES, <1, 1, 1>, 1,
        PRIM_FULLBRIGHT, ALL_SIDES, 1,
        PRIM_TEXTURE, 0, DIFFUSE, <tsc.x, tsc.y, 0>, ZERO_VECTOR, 0,
        PRIM_TEXTURE, 1, DIFFUSE, <tsc.x, tsc.z, 0>, ZERO_VECTOR, 0,
        PRIM_TEXTURE, 2, DIFFUSE, <tsc.y, tsc.z, 0>, ZERO_VECTOR, 0,
        PRIM_TEXTURE, 3, DIFFUSE, <tsc.x, tsc.z, 0>, ZERO_VECTOR, 0,
        PRIM_TEXTURE, 4, DIFFUSE, <tsc.y, tsc.z, 0>, ZERO_VECTOR, 0,
        PRIM_TEXTURE, 5, DIFFUSE, <tsc.x, tsc.y, 0>, ZERO_VECTOR, 0
    ]);
    gi_target_id = llTarget(pos, 0);
}

default 
{
    state_entry()
    {
        gi_root_link = !!llGetLinkNumber();
        gs_root_id = llGetLinkKey(gi_root_link);
        set();
    }

    not_at_target()
    {
        llTargetRemove(gi_target_id);
        llSetTimerEvent(1);
    }

    timer()
    {
        list data = llGetObjectDetails(gs_root_id, (list)OBJECT_SELECT_COUNT);
        if (!llList2Integer(data, 0))
        {
            llSetTimerEvent(0);
            set();
        }
    }

    changed( integer change )
    {
        if (change & CHANGED_SCALE)
        {
            set();
        }

        if (change & CHANGED_LINK)
        {
            gi_root_link = !!llGetLinkNumber();
            gs_root_id = llGetLinkKey(gi_root_link);
        }
    }
}
