
/*
    What:
    Drop this script in a link-set to set all child's name a small and unique name id. 

    How:
    1: Compile in inventory.
    2: Drag and drop in a linkset.

    ✅ deeded | ✅ optimized | ✅ shared | ✅ self delete
    ✅ attachment | ✅ rezzed | ✅ link-set | ❌ single object
*/

string g_ = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
string _(integer Pop) {
    integer a = Pop % 52;
    integer b = llFloor((float)Pop * 0.019230769230769232) % 52;
    return llGetSubString(g_, a, a) + llGetSubString(g_, b, b);
}
default  {
    state_entry() {
        integer link = !!llGetLinkNumber();
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)30), 0) + link;
        list names = (list)"";
        integer index;
         @ link_label;
         {
            string name = llGetLinkName(link);
             @ name_label;
             {
                if (llStringLength(name) > 2 | ~llListFindList(names, (list)name)) {
                    name = _(++index);
                    jump name_label;
                }
                llSetLinkPrimitiveParamsFast(link, [27, name]);
                names += name;
            }
        }
        if (++link < links)jump link_label;
        llWhisper(0, "Done");
        llRemoveInventory(llGetScriptName());
    }
}