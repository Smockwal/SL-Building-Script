string short_vector(vector value) {
    return "<" + short_float(value.x) + ", " + short_float(value.y) + ", " + short_float(value.z) + ">";
}
string short_float(float value) {
    string snumb = (string)((integer)(value * ((float)1000)) * 0.001);
    while (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == "0") snumb = llDeleteSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF);
    if (llGetSubString(snumb, 0xFFFFFFFF, 0xFFFFFFFF) == ".") snumb = (string)((integer)snumb);
    return snumb;
}
string onoff(integer i) {
    if (i)return "on";
    return "off";
}
default  {
    touch_start(integer num_detected) {
        integer link = llDetectedLinkNumber(0);
        integer side = llDetectedTouchFace(0);
        string out = "\n=========================\nTouch Link: " + (string)link + ", Name: " + llGetLinkName(link);
        if (~side) {
            out += ", Side: " + (string)side;
            vector st = llDetectedTouchST(0);
            vector uv = llDetectedTouchUV(0);
            if (st != <0xFFFFFFFF, 0xFFFFFFFF, 0>) out += "\nST: " + short_vector(st);
            else out += ", Invalide ST data";
            if (uv != <0xFFFFFFFF, 0xFFFFFFFF, 0>) out += ", UV: " + short_vector(uv);
            else out += ", Invalide UV data";
            list data = llGetLinkPrimitiveParams(link, [20, side, 18, side, 25, side, 22, side, 38, side, 19, side, 17, side, 37, side, 36, side]);
            out += "\nColor: " + short_vector(llList2Vector(data, 1)) + ", Alpha: " + short_float(llList2Float(data, 2)) + ", Glow: " + short_float(llList2Float(data, 3)) + ", fullbrigth: " + onoff(llList2Integer(data, 0));
            list modes = ["None", "Blending", "Mask", "Emissive"];
            integer mode = llList2Integer(data, 5);
            out += "\nMapping: " + llList2String(["Default", "Planar"], llList2Integer(data, 4)) + ", Alpha Mode: " + llList2String(modes, mode);
            if (mode == 2) out += "Mask: " + llList2String(data, 6);
            float rot = llList2Float(data, 12);
            out += "\nTexture Scale: " + short_vector(llList2Vector(data, 10)) + ", Offset: " + short_vector(llList2Vector(data, 11)) + ", Rotation: " + short_float(rot) + " (" + short_float(rot * 57.29577950000000186037141) + " deg)";
            rot = llList2Float(data, 16);
            out += "\nNormal Scale: " + short_vector(llList2Vector(data, 14)) + ", Offset: " + short_vector(llList2Vector(data, 15)) + ", Rotation: " + short_float(rot) + " (" + short_float(rot * 57.29577950000000186037141) + " deg)";
            if (llList2Integer(data, 7)) {
                list shiny = ["none", "Low", "Medium", "High"];
                list bump = ["none", "Bright", "Dark", "Wood", "Bark", "Brick", "Checker", "Concrete", "Tile", "Stone", "Disks", "Gravel", "Blobs", "Siding", "Largetile", "Stuco", "Suction", "Weave"];
                out += "\nShininess: " + llList2String(shiny, llList2Integer(data, 7)) + ", Bump: " + llList2String(bump, llList2Integer(data, 8));
            }
            else  {
                rot = llList2Float(data, 20);
                out += "\nSpecular Scale: " + short_vector(llList2Vector(data, 18)) + ", Offset: " + short_vector(llList2Vector(data, 19)) + ", Rotation: " + short_float(rot) + " (" + short_float(rot * 57.29577950000000186037141) + " deg)\n\t\t\t  Color: " + short_vector(llList2Vector(data, 21)) + ", Glossiness: " + llList2String(data, 22) + ", Environment: " + llList2String(data, 23);
            }
        }
        else out += ", Invalide Face data";
        llRegionSayTo(llDetectedKey(0), 0, out + "\n==============================");
    }
}