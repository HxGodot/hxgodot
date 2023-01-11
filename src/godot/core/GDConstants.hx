package godot.core;

import godot.Types;

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

    inline public static function MIN(m_a:GDExtensionFloat, m_b:GDExtensionFloat) {
        return m_a < m_b ? m_a : m_b;
    }
    
    inline public static function MAX(m_a:GDExtensionFloat, m_b:GDExtensionFloat) {
        return m_a > m_b ? m_a : m_b;
    }
    
    inline public static function SIGN(m_v:GDExtensionFloat):GDExtensionFloat {
        return m_v == 0 ? 0.0 : (m_v < 0 ? -1.0 : 1.0);
    }
    inline public static function CLAMP(m_a:GDExtensionFloat, m_min:GDExtensionFloat, m_max:GDExtensionFloat):GDExtensionFloat {
        return m_a < m_min ? m_min : (m_a > m_max ? m_max : m_a);
    }
}