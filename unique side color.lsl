/*
    What:
    Drop this script in a linkset/Object to set a unique and random color on each side.

    How:
    1: Compile in inventory.
    2: Drag and drop in a linkset.

    ✅ deeded | ✅ optimized | ✅ shared | ✅ self delete
    ✅ attachment | ✅ rezzed | ✅ link-set | ✅ single object
*/

vector _(integer g_, integer Pop) {
    return <g_ % Pop, llFloor((float)g_ / (float)Pop) % Pop, llFloor((float)g_ / (float)(Pop * Pop))>;
}
default  {
    state_entry() {
        integer root_link = !!llGetLinkNumber();
        integer link = root_link;
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)30), 0) + link;
        integer side;
        integer sides;
        integer total_sides;
        for (link=root_link; link<links; ++link) total_sides += llGetLinkNumberOfSides(link);
        integer root = llCeil(llPow(total_sides, 0.33333333333333333333333333333333));
        float div = ((float)1) / (float)root;
        list colors;
        integer index;
        for (side=0; side<total_sides; ++side) colors += _(++index, root) * div;
        for (link=root_link; link<links; ++link) {
            for (side=0, sides=llGetLinkNumberOfSides(link); side<sides; ++side) {
                index = (integer)llFrand(llGetListLength(colors));
                llSetLinkPrimitiveParamsFast(link, [18, side, llList2Vector(colors, index), 1]);
                colors = llDeleteSubList(colors, index, index);
            }
        }
        llRemoveInventory(llGetScriptName());
    }
}

