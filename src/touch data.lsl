
#define OWNER_ONLY
//#define GROUP_ONLY

#if defined(OWNER_ONLY) && defined(GROUP_ONLY)
    #error OWNER_ONLY and GROUP_ONLY are defined, comment one\n
#endif

integer gi_deeded;

string short_float(float value, integer dec) {
    float div = llPow(10, dec);
    string snumb = (string)(llRound(value * div) / div);
    @trim_label;
    if (llGetSubString(snumb, -1, -1) == "0") {
        snumb = llDeleteSubString(snumb, -1, -1);
        jump trim_label;
    }
    if(llGetSubString(snumb, -1, -1) == ".") snumb = (string)((integer)snumb);
    return snumb;
}

string short_vector(vector value, integer dec) {
    return "<" + short_float(value.x, dec) + ", " + short_float(value.y, dec) + ", " + short_float(value.z, dec) + ">";
}

string onoff(integer i) {
    if (i) return "on";
    return "off";
}

default {

    state_entry() {
        string group = llList2Key(llGetObjectDetails(llGetKey(), [OBJECT_GROUP]), 0);
        gi_deeded = (group == llGetOwner());

#ifdef GROUP_ONLY 
        if (group == NULL_KEY) {
            llOwnerSay("Script compile for group only but no group are set.\nSet a group and add this script again.");
            llRemoveInventory(llGetScriptName());
        }
#endif
    }

    touch_start( integer num_detected ) {
        string user_id = llDetectedKey(0);

#ifdef GROUP_ONLY
        if (!llSameGroup(user_id)) return;
#else
        if (gi_deeded && !llSameGroup(user_id)) return;
#ifdef OWNER_ONLY
        else if (user_id != llGetOwner()) return;
#endif
#endif

        integer link = llDetectedLinkNumber(0);
        integer side = llDetectedTouchFace(0);

        string out = "\n=========================\nTouch Link: " + (string)link + ", Name: " + llGetLinkName(link);

        if (~side)
        {
            out += ", Side: " + (string)side;

            vector st = llDetectedTouchST(0);
            vector uv = llDetectedTouchUV(0);

            if(st != TOUCH_INVALID_TEXCOORD) 
                out += "\nST: " + short_vector(st, 4);
            else 
                out += ", Invalide ST data";
            
            if(uv != TOUCH_INVALID_TEXCOORD) 
                out += ", UV: " + short_vector(uv, 4);
            else 
                out += ", Invalide UV data";

            list data = llGetLinkPrimitiveParams(link, [
                PRIM_FULLBRIGHT, side, 
                PRIM_COLOR, side, 
                PRIM_GLOW, side, 
                PRIM_TEXGEN, side, 
                PRIM_ALPHA_MODE, side, 
                PRIM_BUMP_SHINY, side, 
                PRIM_TEXTURE, side, 
                PRIM_NORMAL, side, 
                PRIM_SPECULAR, side
            ]);

            out +=  "\nColor: " + short_vector(llList2Vector(data, 1), 3) + 
                    ", Alpha: " + short_float(llList2Float(data, 2), 2) + 
                    ", Glow: " + short_float(llList2Float(data, 3), 2) +
                    ", Fullbrigth: " + onoff(llList2Integer(data, 0));
            

            list modes = ["None", "Blending", "Mask", "Emissive"];
            integer mode = llList2Integer(data, 5);
            out +=  "\nMapping: " + llList2String(["Default", "Planar"], llList2Integer(data, 4)) + 
                    ", Alpha Mode: " +  llList2String(modes, mode);

            if (mode == PRIM_ALPHA_MODE_MASK)
                out +=  "Mask: " + llList2String(data, 6);

            float rot = llList2Float(data, 12);
            out +=  "\nTexture Scale: "+ short_vector(llList2Vector(data, 10), 5) + 
                    ", Offset: " + short_vector(llList2Vector(data, 11), 5) + 
                    ", Rotation: " + short_float(rot, 6) + 
                    " (" + short_float(rot * RAD_TO_DEG, 2) + " deg)"; 

            rot = llList2Float(data, 16);
            out +=  "\nNormal Scale: "+ short_vector(llList2Vector(data, 14), 5) + 
                    ", Offset: " + short_vector(llList2Vector(data, 15), 5) + 
                    ", Rotation: " + short_float(rot, 6) + 
                    " (" + short_float(rot * RAD_TO_DEG, 2) + " deg)";

            if (llList2Integer(data, 7)) {
                list shiny = ["none", "Low", "Medium", "High"];
                list bump = ["none", "Bright", "Dark", "Wood", "Bark", "Brick", "Checker", "Concrete", "Tile", "Stone",
                            "Disks", "Gravel", "Blobs", "Siding", "Largetile", "Stuco", "Suction", "Weave"];
                out +=  "\nShininess: "+ llList2String(shiny, llList2Integer(data, 7)) + 
                        ", Bump: " + llList2String(bump, llList2Integer(data, 8));
            }
            else {
                rot = llList2Float(data, 20);
                out +=  "\nSpecular Scale: "+ short_vector(llList2Vector(data, 18), 5) + 
                        ", Offset: " + short_vector(llList2Vector(data, 19), 5) + 
                        ", Rotation: " + short_float(rot, 6) + 
                        " (" + short_float(rot * RAD_TO_DEG, 2) + " deg)" + 
                        "\n\t\t\t  Color: " + short_vector(llList2Vector(data, 21), 3) +  
                        ", Glossiness: " + llList2String(data, 22) + 
                        ", Environment: " + llList2String(data, 23);
            }
        }
        else 
            out += ", Invalide Face data";

        llRegionSayTo(user_id, 0, out + "\n==============================");
    }
}

