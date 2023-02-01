
string alph = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

string uid (integer index) 
{
    integer a = index % 52;
    integer b = llFloor((float)index / 52.0) % 52;
    return  llGetSubString(alph, a, a) + llGetSubString(alph, b, b);
}

default
{
    state_entry()
    {
        integer link = !!llGetLinkNumber();
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), [OBJECT_PRIM_COUNT]), 0) + link;

        list names = [""];
        integer index;

        @link_label;
        {
            string name = llGetLinkName(link);
            @name_label;
            {
                if (llStringLength(name) > 2 || ~llListFindList(names, [name])) {
                    name = uid(++index);
                    jump name_label;
                }

                llSetLinkPrimitiveParamsFast(link, [PRIM_NAME, name]);
                names += name;
            }
        }
        if (++link < links) jump link_label;


        llWhisper(0, "Done");
        llRemoveInventory(llGetScriptName());
    }
}