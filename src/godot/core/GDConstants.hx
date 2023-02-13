package godot.core;

import godot.Types;
import godot.variant.Color;

typedef NamedColor = {
    var name:String;
    var color:Color;
};

class GDConstants { 
    inline public static var CMP_EPSILON = 0.00001;
    inline public static var CMP_EPSILON2 = (CMP_EPSILON * CMP_EPSILON);

    inline public static var CMP_NORMALIZE_TOLERANCE = 0.000001;
    inline public static var CMP_POINT_IN_PLANE_EPSILON = 0.00001;

    inline public static var Math_SQRT12 = 0.7071067811865475244008443621048490;
    inline public static var Math_SQRT2 = 1.4142135623730950488016887242;
    inline public static var Math_LN2 = 0.6931471805599453094172321215;
    inline public static var Math_TAU = 6.2831853071795864769252867666;
    inline public static var Math_PI = 3.1415926535897932384626433833;
    inline public static var Math_E = 2.7182818284590452353602874714;

    inline public static var UNIT_EPSILON = 0.001;

    inline public static var SIDE_LEFT = 0;
    inline public static var SIDE_TOP = 1;
    inline public static var SIDE_RIGHT = 2;
    inline public static var SIDE_BOTTOM = 3;

    inline public static var CORNER_TOP_LEFT = 0;
    inline public static var CORNER_TOP_RIGHT = 1;
    inline public static var CORNER_BOTTOM_RIGHT = 2;
    inline public static var CORNER_BOTTOM_LEFT = 3;

    inline public static var EULER_ORDER_XYZ = 0;
    inline public static var EULER_ORDER_XZY = 1;
    inline public static var EULER_ORDER_YXZ = 2;
    inline public static var EULER_ORDER_YZX = 3;
    inline public static var EULER_ORDER_ZXY = 4;
    inline public static var EULER_ORDER_ZYX = 5;
    
    inline public static var CLOCKWISE = 0;
    inline public static var COUNTERCLOCKWISE = 1;

    inline public static function MIN(m_a:GDExtensionFloat, m_b:GDExtensionFloat):GDExtensionFloat {
        return m_a < m_b ? m_a : m_b;
    }
    
    inline public static function MAX(m_a:GDExtensionFloat, m_b:GDExtensionFloat):GDExtensionFloat {
        return m_a > m_b ? m_a : m_b;
    }
    
    inline public static function SIGN(m_v:GDExtensionFloat):GDExtensionFloat {
        return m_v == 0 ? 0.0 : (m_v < 0 ? -1.0 : 1.0);
    }
    
    inline public static function CLAMP(m_a:GDExtensionFloat, m_min:GDExtensionFloat, m_max:GDExtensionFloat):GDExtensionFloat {
        return m_a < m_min ? m_min : (m_a > m_max ? m_max : m_a);
    }

    inline public static function ERR_PRINT(msg:String) {
        trace("ERR_FAIL_V_MSG: msg="+msg);
    }

    inline public static function ERR_FAIL_V_MSG(typ:Dynamic, msg:String) {
        trace("ERR_FAIL_V_MSG: typ="+Type.getClassName(Type.getClass(typ))+" msg="+msg);
    }

    inline public static function ERR_FAIL_COND_MSG(cond:Bool, msg:String) {
        if (cond)
            trace("ERR_FAIL_COND_MSG: msg="+msg);
    }

    inline public static function ERR_FAIL_COND_V_MSG(cond:Bool, typ:Dynamic, msg:String) {
        if (cond)
            trace("ERR_FAIL_COND_V_MSG: typ="+Type.getClassName(Type.getClass(typ))+" msg="+msg);
    }

    inline public static function ERR_FAIL_INDEX_V(idx:Int, count:Int, typ:Dynamic) {
        if (idx>count) trace("ERR_FAIL_INDEX_V: idx="+idx+" > count="+count+" typ="+Type.getClassName(Type.getClass(typ)));
    }

    inline public static function DP(v:Float, decPlaces:Int) {
        return Math.round( v * Math.pow(10,decPlaces)) / Math.pow(10,decPlaces);
    }

    inline public static function ABS(m_v:Dynamic) {
        return m_v < 0 ? -m_v : m_v;
    }

    inline public static function signbit(v:Float) {
        return v < 0;
    }

    public static var named_colors:Array<NamedColor> = [
        { name:"ALICE_BLUE", color: Color.ALICE_BLUE },
        { name:"ANTIQUE_WHITE", color: Color.ANTIQUE_WHITE },
        { name:"AQUA", color: Color.AQUA },
        { name:"AQUAMARINE", color: Color.AQUAMARINE },
        { name:"AZURE", color: Color.AZURE },
        { name:"BEIGE", color: Color.BEIGE },
        { name:"BISQUE", color: Color.BISQUE },
        { name:"BLACK", color: Color.BLACK },
        { name:"BLANCHED_ALMOND", color: Color.BLANCHED_ALMOND },
        { name:"BLUE", color: Color.BLUE },
        { name:"BLUE_VIOLET", color: Color.BLUE_VIOLET },
        { name:"BROWN", color: Color.BROWN },
        { name:"BURLYWOOD", color: Color.BURLYWOOD },
        { name:"CADET_BLUE", color: Color.CADET_BLUE },
        { name:"CHARTREUSE", color: Color.CHARTREUSE },
        { name:"CHOCOLATE", color: Color.CHOCOLATE },
        { name:"CORAL", color: Color.CORAL },
        { name:"CORNFLOWER_BLUE", color: Color.CORNFLOWER_BLUE },
        { name:"CORNSILK", color: Color.CORNSILK },
        { name:"CRIMSON", color: Color.CRIMSON },
        { name:"CYAN", color: Color.CYAN },
        { name:"DARK_BLUE", color: Color.DARK_BLUE },
        { name:"DARK_CYAN", color: Color.DARK_CYAN },
        { name:"DARK_GOLDENROD", color: Color.DARK_GOLDENROD },
        { name:"DARK_GRAY", color: Color.DARK_GRAY },
        { name:"DARK_GREEN", color: Color.DARK_GREEN },
        { name:"DARK_KHAKI", color: Color.DARK_KHAKI },
        { name:"DARK_MAGENTA", color: Color.DARK_MAGENTA },
        { name:"DARK_OLIVE_GREEN", color: Color.DARK_OLIVE_GREEN },
        { name:"DARK_ORANGE", color: Color.DARK_ORANGE },
        { name:"DARK_ORCHID", color: Color.DARK_ORCHID },
        { name:"DARK_RED", color: Color.DARK_RED },
        { name:"DARK_SALMON", color: Color.DARK_SALMON },
        { name:"DARK_SEA_GREEN", color: Color.DARK_SEA_GREEN },
        { name:"DARK_SLATE_BLUE", color: Color.DARK_SLATE_BLUE },
        { name:"DARK_SLATE_GRAY", color: Color.DARK_SLATE_GRAY },
        { name:"DARK_TURQUOISE", color: Color.DARK_TURQUOISE },
        { name:"DARK_VIOLET", color: Color.DARK_VIOLET },
        { name:"DEEP_PINK", color: Color.DEEP_PINK },
        { name:"DEEP_SKY_BLUE", color: Color.DEEP_SKY_BLUE },
        { name:"DIM_GRAY", color: Color.DIM_GRAY },
        { name:"DODGER_BLUE", color: Color.DODGER_BLUE },
        { name:"FIREBRICK", color: Color.FIREBRICK },
        { name:"FLORAL_WHITE", color: Color.FLORAL_WHITE },
        { name:"FOREST_GREEN", color: Color.FOREST_GREEN },
        { name:"FUCHSIA", color: Color.FUCHSIA },
        { name:"GAINSBORO", color: Color.GAINSBORO },
        { name:"GHOST_WHITE", color: Color.GHOST_WHITE },
        { name:"GOLD", color: Color.GOLD },
        { name:"GOLDENROD", color: Color.GOLDENROD },
        { name:"GRAY", color: Color.GRAY },
        { name:"GREEN", color: Color.GREEN },
        { name:"GREEN_YELLOW", color: Color.GREEN_YELLOW },
        { name:"HONEYDEW", color: Color.HONEYDEW },
        { name:"HOT_PINK", color: Color.HOT_PINK },
        { name:"INDIAN_RED", color: Color.INDIAN_RED },
        { name:"INDIGO", color: Color.INDIGO },
        { name:"IVORY", color: Color.IVORY },
        { name:"KHAKI", color: Color.KHAKI },
        { name:"LAVENDER", color: Color.LAVENDER },
        { name:"LAVENDER_BLUSH", color: Color.LAVENDER_BLUSH },
        { name:"LAWN_GREEN", color: Color.LAWN_GREEN },
        { name:"LEMON_CHIFFON", color: Color.LEMON_CHIFFON },
        { name:"LIGHT_BLUE", color: Color.LIGHT_BLUE },
        { name:"LIGHT_CORAL", color: Color.LIGHT_CORAL },
        { name:"LIGHT_CYAN", color: Color.LIGHT_CYAN },
        { name:"LIGHT_GOLDENROD", color: Color.LIGHT_GOLDENROD },
        { name:"LIGHT_GRAY", color: Color.LIGHT_GRAY },
        { name:"LIGHT_GREEN", color: Color.LIGHT_GREEN },
        { name:"LIGHT_PINK", color: Color.LIGHT_PINK },
        { name:"LIGHT_SALMON", color: Color.LIGHT_SALMON },
        { name:"LIGHT_SEA_GREEN", color: Color.LIGHT_SEA_GREEN },
        { name:"LIGHT_SKY_BLUE", color: Color.LIGHT_SKY_BLUE },
        { name:"LIGHT_SLATE_GRAY", color: Color.LIGHT_SLATE_GRAY },
        { name:"LIGHT_STEEL_BLUE", color: Color.LIGHT_STEEL_BLUE },
        { name:"LIGHT_YELLOW", color: Color.LIGHT_YELLOW },
        { name:"LIME", color: Color.LIME },
        { name:"LIME_GREEN", color: Color.LIME_GREEN },
        { name:"LINEN", color: Color.LINEN },
        { name:"MAGENTA", color: Color.MAGENTA },
        { name:"MAROON", color: Color.MAROON },
        { name:"MEDIUM_AQUAMARINE", color: Color.MEDIUM_AQUAMARINE },
        { name:"MEDIUM_BLUE", color: Color.MEDIUM_BLUE },
        { name:"MEDIUM_ORCHID", color: Color.MEDIUM_ORCHID },
        { name:"MEDIUM_PURPLE", color: Color.MEDIUM_PURPLE },
        { name:"MEDIUM_SEA_GREEN", color: Color.MEDIUM_SEA_GREEN },
        { name:"MEDIUM_SLATE_BLUE", color: Color.MEDIUM_SLATE_BLUE },
        { name:"MEDIUM_SPRING_GREEN", color: Color.MEDIUM_SPRING_GREEN },
        { name:"MEDIUM_TURQUOISE", color: Color.MEDIUM_TURQUOISE },
        { name:"MEDIUM_VIOLET_RED", color: Color.MEDIUM_VIOLET_RED },
        { name:"MIDNIGHT_BLUE", color: Color.MIDNIGHT_BLUE },
        { name:"MINT_CREAM", color: Color.MINT_CREAM },
        { name:"MISTY_ROSE", color: Color.MISTY_ROSE },
        { name:"MOCCASIN", color: Color.MOCCASIN },
        { name:"NAVAJO_WHITE", color: Color.NAVAJO_WHITE },
        { name:"NAVY_BLUE", color: Color.NAVY_BLUE },
        { name:"OLD_LACE", color: Color.OLD_LACE },
        { name:"OLIVE", color: Color.OLIVE },
        { name:"OLIVE_DRAB", color: Color.OLIVE_DRAB },
        { name:"ORANGE", color: Color.ORANGE },
        { name:"ORANGE_RED", color: Color.ORANGE_RED },
        { name:"ORCHID", color: Color.ORCHID },
        { name:"PALE_GOLDENROD", color: Color.PALE_GOLDENROD },
        { name:"PALE_GREEN", color: Color.PALE_GREEN },
        { name:"PALE_TURQUOISE", color: Color.PALE_TURQUOISE },
        { name:"PALE_VIOLET_RED", color: Color.PALE_VIOLET_RED },
        { name:"PAPAYA_WHIP", color: Color.PAPAYA_WHIP },
        { name:"PEACH_PUFF", color: Color.PEACH_PUFF },
        { name:"PERU", color: Color.PERU },
        { name:"PINK", color: Color.PINK },
        { name:"PLUM", color: Color.PLUM },
        { name:"POWDER_BLUE", color: Color.POWDER_BLUE },
        { name:"PURPLE", color: Color.PURPLE },
        { name:"REBECCA_PURPLE", color: Color.REBECCA_PURPLE },
        { name:"RED", color: Color.RED },
        { name:"ROSY_BROWN", color: Color.ROSY_BROWN },
        { name:"ROYAL_BLUE", color: Color.ROYAL_BLUE },
        { name:"SADDLE_BROWN", color: Color.SADDLE_BROWN },
        { name:"SALMON", color: Color.SALMON },
        { name:"SANDY_BROWN", color: Color.SANDY_BROWN },
        { name:"SEA_GREEN", color: Color.SEA_GREEN },
        { name:"SEASHELL", color: Color.SEASHELL },
        { name:"SIENNA", color: Color.SIENNA },
        { name:"SILVER", color: Color.SILVER },
        { name:"SKY_BLUE", color: Color.SKY_BLUE },
        { name:"SLATE_BLUE", color: Color.SLATE_BLUE },
        { name:"SLATE_GRAY", color: Color.SLATE_GRAY },
        { name:"SNOW", color: Color.SNOW },
        { name:"SPRING_GREEN", color: Color.SPRING_GREEN },
        { name:"STEEL_BLUE", color: Color.STEEL_BLUE },
        { name:"TAN", color: Color.TAN },
        { name:"TEAL", color: Color.TEAL },
        { name:"THISTLE", color: Color.THISTLE },
        { name:"TOMATO", color: Color.TOMATO },
        { name:"TRANSPARENT", color: Color.TRANSPARENT },
        { name:"TURQUOISE", color: Color.TURQUOISE },
        { name:"VIOLET", color: Color.VIOLET },
        { name:"WEB_GRAY", color: Color.WEB_GRAY },
        { name:"WEB_GREEN", color: Color.WEB_GREEN },
        { name:"WEB_MAROON", color: Color.WEB_MAROON },
        { name:"WEB_PURPLE", color: Color.WEB_PURPLE },
        { name:"WHEAT", color: Color.WHEAT },
        { name:"WHITE", color: Color.WHITE },
        { name:"WHITE_SMOKE", color: Color.WHITE_SMOKE },
        { name:"YELLOW", color: Color.YELLOW },
        { name:"YELLOW_GREEN", color: Color.YELLOW_GREEN }
    ];

}
