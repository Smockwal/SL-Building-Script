/*
    What:
    Drop this script in a link-set to apply a unique texture on each side of each link. 

    How:
    1: Compile in inventory.
    2: Drag and drop in a linkset.

    ✅ deeded | ✅ optimized | ✅ shared | ✅ self delete
    ✅ attachment | ✅ rezzed | ✅ link-set | ✅ single object
*/

list Pop = [
    "a2d42ba1-e896-5cb9-e1c5-647457d429d1", 
    "5785faf3-fc2b-a8c6-4919-d2d97bd5d20e", 
    "faff5649-f03b-4ce4-4d74-20936f304ebd", 
    "999810a6-dbfa-7bab-99fc-cd8c309ce8c3", 
    "1d58fab6-034c-4672-9681-d69ad12189ed", 
    "ddc4590f-619d-ac74-1e3e-fcd2e31abb00", 
    "077929be-b94e-771e-78a0-bf2a8ed4e2c1", 
    "d054768c-a57a-d08e-abf1-09192f767c63", 
    "e3da454b-0d45-168b-61b6-87e3153f9053", 
    "6669ec31-9ff0-549d-be14-24881d536c9e"
];

default  {
    state_entry() {
        integer link = !!llGetLinkNumber();
        integer links = llList2Integer(llGetObjectDetails(llGetKey(), (list)30), 0) + link;
        integer side;
        integer sides;
        list data;
         @ link_label;
         {
            side = 0;
            sides = llGetLinkNumberOfSides(link);
            data = llGetLinkPrimitiveParams(link, [17, 0xFFFFFFFF]);
             @ side_label;
             {
                llSetLinkPrimitiveParamsFast(link, [17, side, llList2String(Pop, side)] + llList2List(data, (side * 4) + 1, (side * 4) + 3));
            }
            if (++side < sides)jump side_label;
        }
        if (++link < links)jump link_label;

        llRemoveInventory(llGetScriptName());
    }
}

