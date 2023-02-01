
list gl_names = [];

default  {
    state_entry() {
        integer link = !!llGetLinkNumber();
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), [OBJECT_PRIM_COUNT]), 0) + link;

        @link_label;
        {
            string curr_name = llGetLinkName(link);
            string cut_name;
            string new_name = curr_name;
            integer numb;

            @name_label;
            if (~llListFindList(gl_names, [new_name])) {
                if (cut_name == "") {
                    list data = llParseString2List(curr_name, [" "], []);
                    
                    integer trim_index;

                    @trim_name;
                    --trim_index;
                    if (llList2String(data, trim_index) == (string)llList2Integer(data, trim_index))
                        jump trim_name;
                        
                        
                    cut_name = llDumpList2String(llList2List(data, 0, trim_index), " ");
                    if (cut_name == "") cut_name = "Object";

                    new_name = cut_name;
                    jump name_label;
                }

                
                new_name = llDumpList2String([cut_name, ++numb], " ");
                jump name_label;
            }

            llSetLinkPrimitiveParamsFast(link, [PRIM_NAME, new_name]); 
            gl_names += new_name;
        }
        if (++link < links) jump link_label;

        llWhisper(0, "Done");
        llRemoveInventory(llGetScriptName());
    }
}

