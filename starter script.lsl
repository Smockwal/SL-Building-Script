// To use in FS inventory into new prim.
default
{
    state_entry()
    {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [ 
            PRIM_TEXTURE, ALL_SIDES, "451ce5e2-0b31-8ac2-6a06-7c9aec7ce24b", <1, 1, 0>, <0, 0, 0>, 0,
            PRIM_NORMAL, ALL_SIDES, "04870cc4-f5bd-0ead-2419-9272b372f1df", <1, 1, 0>, <0, 0, 0>, 0,
            PRIM_SPECULAR, ALL_SIDES, "acb83321-5e2a-cbb7-8b20-5aa6c58f3b5d", <1, 1, 0>, <0, 0, 0>, 0, <1, 1, 1>, 51, 0
        ]);

        llRemoveInventory(llGetScriptName());
    }
}