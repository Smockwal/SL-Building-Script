

string uid (integer index) 
{
    string alph = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    integer a = index % 52;
    integer b = llFloor((float)index / 52.0) % 52;
    return  llGetSubString(alph, a, a) + llGetSubString(alph, b, b);
}

default
{
    state_entry()
    {
        integer link = !!llGetLinkNumber();
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)OBJECT_PRIM_COUNT), 0) + link;

        list names = [""];
        integer index;
        for (++link; link < links; ++link)
        {
            string name = llGetLinkName(link);
            if (llStringLength(name) > 2 || ~llListFindList(names, (list)name))
            {
                do {
                    name = uid(++index);
                } while (~llListFindList(names, (list)name));
                llSetLinkPrimitiveParamsFast(link, [PRIM_NAME, name]);
            }
            names += name;
        }

        llWhisper(0, "Done");
        llRemoveInventory(llGetScriptName());
    }
}