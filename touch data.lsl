/*
    What:
    Add this script to an object/linkset and touch the object to get information about the touched side.

    How:
    1: Compile in inventory.
    2: Drag and drop in a linkset.
    3: Touch the object to print the information in local chat.

    ✅ deeded | ✅ optimized | ❌ shared | ✅ self delete
    ✅ attachment | ✅ rezzed | ✅ link-set | ✅ single object
*/

integer gb;
string _(vector g_, integer ga) {
    return "<" + a(g_.x, ga) + ", " + a(g_.y, ga) + ", " + a(g_.z, ga) + ">";
}
string a(float g_, integer ga) {
    float div = llPow(10, ga);
    string snumb = (string)(llRound(g_ * div) / div);
     @ trim_label;
    if (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == "0") {
        snumb = llDeleteSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF);
        jump trim_label;
    }
    if (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == ".") snumb = (string)((integer)snumb);
    return snumb;
}
string b(integer g_) {
    if (g_)return "on";
    return "off";
}
default  {
    state_entry() {
        string group = llList2Key(llGetObjectDetails(llGetKey(), (list)7), 0);
        gb = (group == llGetOwner());
    }
    touch_start(integer g_) {
        string user_id = llDetectedKey(0);
        if (gb && !llSameGroup(user_id))return ;
        else if (user_id != llGetOwner())return ;
        integer link = llDetectedLinkNumber(0);
        integer side = llDetectedTouchFace(0);
        string out = "\n=========================\nTouch Link: " + (string)link + ", Name: " + llGetLinkName(link);
        if (~side) {
            out += ", Side: " + (string)side;
            vector st = llDetectedTouchST(0);
            vector uv = llDetectedTouchUV(0);
            if (st != <0xFFFFFFFF, 0xFFFFFFFF, 0>) out += "\nST: " + _(st, 4);
            else out += ", Invalide ST data";
            if (uv != <0xFFFFFFFF, 0xFFFFFFFF, 0>) out += ", UV: " + _(uv, 4);
            else out += ", Invalide UV data";
            list data = llGetLinkPrimitiveParams(link, [20, side, 18, side, 25, side, 22, side, 38, side, 19, side, 17, side, 37, side, 36, side]);
            out += "\nColor: " + _(llList2Vector(data, 1), 3) + ", Alpha: " + a(llList2Float(data, 2), 2) + ", Glow: " + a(llList2Float(data, 3), 2) + ", fullbrigth: " + b(llList2Integer(data, 0));
            list modes = ["None", "Blending", "Mask", "Emissive"];
            integer mode = llList2Integer(data, 5);
            out += "\nMapping: " + llList2String(["Default", "Planar"], llList2Integer(data, 4)) + ", Alpha Mode: " + llList2String(modes, mode);
            if (mode == 2) out += "Mask: " + llList2String(data, 6);
            float rot = llList2Float(data, 12);
            out += "\nTexture Scale: " + _(llList2Vector(data, 10), 5) + ", Offset: " + _(llList2Vector(data, 11), 5) + ", Rotation: " + a(rot, 6) + " (" + a(rot * 57.29577950000000186037141, 2) + " deg)";
            rot = llList2Float(data, 16);
            out += "\nNormal Scale: " + _(llList2Vector(data, 14), 5) + ", Offset: " + _(llList2Vector(data, 15), 5) + ", Rotation: " + a(rot, 6) + " (" + a(rot * 57.29577950000000186037141, 2) + " deg)";
            if (llList2Integer(data, 7)) {
                list shiny = ["none", "Low", "Medium", "High"];
                list bump = ["none", "Bright", "Dark", "Wood", "Bark", "Brick", "Checker", "Concrete", "Tile", "Stone", "Disks", "Gravel", "Blobs", "Siding", "Largetile", "Stuco", "Suction", "Weave"];
                out += "\nShininess: " + llList2String(shiny, llList2Integer(data, 7)) + ", Bump: " + llList2String(bump, llList2Integer(data, 8));
            }
            else  {
                rot = llList2Float(data, 20);
                out += "\nSpecular Scale: " + _(llList2Vector(data, 18), 5) + ", Offset: " + _(llList2Vector(data, 19), 5) + ", Rotation: " + a(rot, 6) + " (" + a(rot * 57.29577950000000186037141, 2) + " deg)\n\t\t\t  Color: " + _(llList2Vector(data, 21), 3) + ", Glossiness: " + llList2String(data, 22) + ", Environment: " + llList2String(data, 23);
            }
        }
        else out += ", Invalide Face data";
        llRegionSayTo(user_id, 0, out + "\n==============================");
    }
}

