/*
    What:
    Add this script to an linkset to give each link a unique name following the same rule as object inventory.

    How:
    1: Compile in inventory.
    2: Drag and drop in a linkset.

    ✅ deeded | ✅ optimized | ✅ shared | ✅ self delete
    ✅ attachment | ✅ rezzed | ✅ link-set | ❌ single object
*/

list Pop;
default  {
    state_entry() {
        integer link = !!llGetLinkNumber();
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)30), 0) + link;
         @ link_label;
         {
            string curr_name = llGetLinkName(link);
            string cut_name;
            string new_name = curr_name;
            integer numb;
             @ name_label;
            if (~llListFindList(Pop, (list)new_name)) {
                if (cut_name == "") {
                    list data = llParseString2List(curr_name, (list)" ", []);
                    integer trim_index;
                     @ trim_name;
                    --trim_index;
                    if (llList2String(data, trim_index) == (string)llList2Integer(data, trim_index))jump trim_name;
                    cut_name = llDumpList2String(llList2List(data, 0, trim_index), " ");
                    if (cut_name == "") cut_name = "Object";
                    new_name = cut_name;
                    jump name_label;
                }
                new_name = llDumpList2String([cut_name, ++numb], " ");
                jump name_label;
            }
            llSetLinkPrimitiveParamsFast(link, [27, new_name]);
            Pop += new_name;
        }
        if (++link < links)jump link_label;
        llWhisper(0, "Done");
        llRemoveInventory(llGetScriptName());
    }
}

