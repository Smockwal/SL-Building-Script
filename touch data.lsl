
string short_float(float value)
{
    string snumb = (string)((integer)(value * 1000.0) / 1000.0);
    while(llGetSubString(snumb, -1, -1) == "0") snumb = llDeleteSubString(snumb, -1, -1);
    if(llGetSubString(snumb, -1, -1) == ".") snumb = (string)((integer)snumb);
    return snumb;
}

string short_vector(vector value)
{
    return "<" + short_float(value.x) + ", " + short_float(value.y) + ", " + short_float(value.z) + ">";
}

default
{
    touch_start( integer num_detected )
    {
        integer link = llDetectedLinkNumber(0);
        integer side = llDetectedTouchFace(0);

        string out = "\n=========================\nTouch Link: " + (string)link + ", Name: " + llGetLinkName(link);
        if (~side)
        {
            out += ", Side: " + (string)side;

            vector st = llDetectedTouchST(0);
            vector uv = llDetectedTouchUV(0);

            if(st != TOUCH_INVALID_TEXCOORD) 
                out += "\nST: " + short_vector(st);
            else 
                out += ", Invalide ST data";
            
            if(uv != TOUCH_INVALID_TEXCOORD) 
                out += ", UV: " + short_vector(uv);
            else 
                out += ", Invalide UV data";

            list data = llGetLinkPrimitiveParams(link, [PRIM_COLOR, side, PRIM_TEXTURE, side]);
            out +=  "\nColor: " + short_vector(llList2Vector(data, 0)) + 
                    ", Alpha: " + short_float(llList2Float(data, 1));
            
            float rot = llList2Float(data, 5);
            out +=  "\nTexture Scale: "+ short_vector(llList2Vector(data, 3)) + 
                    ", Offset: " + short_vector(llList2Vector(data, 4)) + 
                    ", Rotation: " + short_float(rot) + 
                    " (" + short_float(rot * RAD_TO_DEG) + " deg)";
        }
        else 
            out += ", Invalide Face data";

        llRegionSayTo(llDetectedKey(0), 0, out + "\n==============================");

    }
}
