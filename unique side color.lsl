// Apply unique bright color on each side (not 50 shade of gray)

vector index_to_3d(integer index, integer max) 
{
    return <
            index % max, 
            llFloor((float)index / (float)max) % max, 
            llFloor((float)index / (float)(max * max))
           >;
}

default 
{
    state_entry() 
    {
        integer root_link = !!llGetLinkNumber();
        integer link;
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)OBJECT_PRIM_COUNT), 0) + link;

        integer side;
        integer sides;
        integer total_sides;
        
        for(link = root_link; link < links; ++link)
            total_sides += llGetLinkNumberOfSides(link);

        integer root = llCeil(llPow(total_sides, 0.33333333333333333333333333333333));
        float div = 1.0 / (float)root;

        list colors;
        integer index;
        for(side = 0; side < total_sides; ++side) 
            colors += index_to_3d(++index, root) * div;

        for(link = root_link; link < links; ++link) 
        {
            for(side = 0, sides = llGetLinkNumberOfSides(link); side < sides; ++side) 
            {
                index = (integer)llFrand(llGetListLength(colors));
                llSetLinkPrimitiveParamsFast(link, [PRIM_COLOR, side, llList2Vector(colors, index), 1]);
                colors = llDeleteSubList(colors, index, index);
            }
        }

        llRemoveInventory(llGetScriptName());
    }
}