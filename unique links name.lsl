// Give each link a unique name

list gl_names = [];

default 
{
    state_entry()
    {
        integer link = !!llGetLinkNumber();
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)OBJECT_PRIM_COUNT), 0) + link;

        for (;link < links; ++link)
        {
            
            string name = llGetLinkName(link);
            string new_name = name;

            if (~llListFindList(gl_names, (list)name))
            {
                integer numb = 1;
                if (~llSubStringIndex(name, " "))
                {
                    list data = llParseString2List(name, (list)" ", []);
                    string last = llList2String(data, -1);
                    while (last == (string)((integer)last))
                    {
                        data = llDeleteSubList(data, -1, -1);
                        last = llList2String(data, -1);
                    }

                    if (data)
                        name = llDumpList2String(data, " ");
                    else 
                        name = "Object";
                }

                new_name = name + " " + (string)numb;
                while (~llListFindList(gl_names, (list)new_name))
                    new_name = name + " " + (string)(++numb);

                llSetLinkPrimitiveParamsFast(link, (list)PRIM_NAME + new_name);
            }
            
            gl_names += new_name;    
        }

        llWhisper(0, "Done");
        llRemoveInventory(llGetScriptName());
    }
}