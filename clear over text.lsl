default
{
    state_entry()
    {
        llSetLinkPrimitiveParamsFast(LINK_SET, [
            PRIM_TEXT, "", ZERO_VECTOR, 0
        ]);
        llRemoveInventory(llGetScriptName());
    }
}