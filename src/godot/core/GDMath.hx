package godot.core;

import godot.Types;

class GDMath {  
    inline public static function fmod(a:GDExtensionFloat, b:GDExtensionFloat):GDExtensionFloat { return a % b; }
    
    // Ported from header

    inline public static function fposmod(p_x:GDExtensionFloat, p_y:GDExtensionFloat):GDExtensionFloat {
        var value = fmod(p_x, p_y);
        if (((value < 0) && (p_y > 0)) || ((value > 0) && (p_y < 0))) {
            value += p_y;
        }
        value += 0.0;
        return value;
    }
    
    inline public static function fposmodp(p_x:GDExtensionFloat, p_y:GDExtensionFloat):GDExtensionFloat {
        var value = fmod(p_x, p_y);
        if (value < 0) {
            value += p_y;
        }
        value += 0.0;
        return value;
    }

    inline public static function posmod(p_x:Int, p_y:Int):Int {
        var value = p_x % p_y;
        if (((value < 0) && (p_y > 0)) || ((value > 0) && (p_y < 0))) {
            value += p_y;
        }
        return value;
    }

    inline public static function deg_to_rad(p_y:GDExtensionFloat):GDExtensionFloat { return p_y * (Math.PI / 180.0); }

    inline public static function rad_to_deg(p_y:GDExtensionFloat):GDExtensionFloat { return p_y * (180.0 / Math.PI); }

    inline public static function lerp(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_weight:GDExtensionFloat):GDExtensionFloat { return p_from + (p_to - p_from) * p_weight; }

    inline public static function cubic_interpolate(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_pre:GDExtensionFloat, p_post:GDExtensionFloat, p_weight:GDExtensionFloat):GDExtensionFloat {
        return 0.5 *
                ((p_from * 2.0) +
                        (-p_pre + p_to) * p_weight +
                        (2.0 * p_pre - 5.0 * p_from + 4.0 * p_to - p_post) * (p_weight * p_weight) +
                        (-p_pre + 3.0 * p_from - 3.0 * p_to + p_post) * (p_weight * p_weight * p_weight));
    }

    inline public static function cubic_interpolate_angle(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_pre:GDExtensionFloat, p_post:GDExtensionFloat, p_weight:GDExtensionFloat):GDExtensionFloat {
        var from_rot = fmod(p_from, Math_TAU);

        var pre_diff = fmod(p_pre - from_rot, Math_TAU);
        var pre_rot = from_rot + fmod(2.0 * pre_diff, Math_TAU) - pre_diff;

        var to_diff = fmod(p_to - from_rot, Math_TAU);
        var to_rot = from_rot + fmod(2.0 * to_diff, Math_TAU) - to_diff;

        var post_diff = fmod(p_post - to_rot, Math_TAU);
        var post_rot = to_rot + fmod(2.0 * post_diff, Math_TAU) - post_diff;

        return cubic_interpolate(from_rot, to_rot, pre_rot, post_rot, p_weight);
    }

    inline public static function cubic_interpolate_in_time(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_pre:GDExtensionFloat, p_post:GDExtensionFloat, p_weight:GDExtensionFloat,
            p_to_t:GDExtensionFloat, p_pre_t:GDExtensionFloat, p_post_t:GDExtensionFloat):GDExtensionFloat {
        /* Barry-Goldman method */
        var t = lerp(0.0, p_to_t, p_weight);
        var a1 = lerp(p_pre, p_from, p_pre_t == 0 ? 0.0 : (t - p_pre_t) / -p_pre_t);
        var a2 = lerp(p_from, p_to, p_to_t == 0 ? 0.5 : t / p_to_t);
        var a3 = lerp(p_to, p_post, p_post_t - p_to_t == 0 ? 1.0 : (t - p_to_t) / (p_post_t - p_to_t));
        var b1 = lerp(a1, a2, p_to_t - p_pre_t == 0 ? 0.0 : (t - p_pre_t) / (p_to_t - p_pre_t));
        var b2 = lerp(a2, a3, p_post_t == 0 ? 1.0 : t / p_post_t);
        return lerp(b1, b2, p_to_t == 0 ? 0.5 : t / p_to_t);
    }

    inline public static function cubic_interpolate_angle_in_time(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_pre:GDExtensionFloat, p_post:GDExtensionFloat, p_weight:GDExtensionFloat,
            p_to_t:GDExtensionFloat, p_pre_t:GDExtensionFloat, p_post_t:GDExtensionFloat):GDExtensionFloat {
        var from_rot = fmod(p_from, Math_TAU);

        var pre_diff = fmod(p_pre - from_rot, Math_TAU);
        var pre_rot = from_rot + fmod(2.0 * pre_diff, Math_TAU) - pre_diff;

        var to_diff = fmod(p_to - from_rot, Math_TAU);
        var to_rot = from_rot + fmod(2.0 * to_diff, Math_TAU) - to_diff;

        var post_diff = fmod(p_post - to_rot, Math_TAU);
        var post_rot = to_rot + fmod(2.0 * post_diff, Math_TAU) - post_diff;

        return cubic_interpolate_in_time(from_rot, to_rot, pre_rot, post_rot, p_weight, p_to_t, p_pre_t, p_post_t);
    }

    inline public static function bezier_interpolate(p_start:GDExtensionFloat, p_control_1:GDExtensionFloat, p_control_2:GDExtensionFloat, p_end:GDExtensionFloat, p_t:GDExtensionFloat):GDExtensionFloat {
        /* Formula from Wikipedia article on Bezier curves. */
        var omt = (1.0 - p_t);
        var omt2 = omt * omt;
        var omt3 = omt2 * omt;
        var t2 = p_t * p_t;
        var t3 = t2 * p_t;

        return p_start * omt3 + p_control_1 * omt2 * p_t * 3.0 + p_control_2 * omt * t2 * 3.0 + p_end * t3;
    }

    inline public static function bezier_derivative(p_start:GDExtensionFloat, p_control_1:GDExtensionFloat, p_control_2:GDExtensionFloat, p_end:GDExtensionFloat, p_t:GDExtensionFloat):GDExtensionFloat {
        /* Formula from Wikipedia article on Bezier curves. */
        var omt = (1.0 - p_t);
        var omt2 = omt * omt;
        var t2 = p_t * p_t;

        var d = (p_control_1 - p_start) * 3.0 * omt2 + (p_control_2 - p_control_1) * 6.0 * omt * p_t + (p_end - p_control_2) * 3.0 * t2;
        return d;
    }

    inline public static function lerp_angle(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_weight:GDExtensionFloat):GDExtensionFloat {
        var difference = fmod(p_to - p_from, Math_TAU);
        var distance = fmod(2.0 * difference, Math_TAU) - difference;
        return p_from + distance * p_weight;
    }

    inline public static function inverse_lerp(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_value:GDExtensionFloat):GDExtensionFloat {
        return (p_value - p_from) / (p_to - p_from);
    }

    inline public static function remap(p_value:GDExtensionFloat, p_istart:GDExtensionFloat, p_istop:GDExtensionFloat, p_ostart:GDExtensionFloat, p_ostop:GDExtensionFloat):GDExtensionFloat {
        return lerp(p_ostart, p_ostop, inverse_lerp(p_istart, p_istop, p_value));
    }

    inline public static function smoothstep(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_s:GDExtensionFloat):GDExtensionFloat {
        if (is_equal_approx(p_from, p_to)) {
            return p_from;
        }
        var s = CLAMP((p_s - p_from) / (p_to - p_from), 0.0, 1.0);
        return s * s * (3.0 - 2.0 * s);
    }

    inline public static function move_toward(p_from:GDExtensionFloat, p_to:GDExtensionFloat, p_delta:GDExtensionFloat):GDExtensionFloat {
        return Math.abs(p_to - p_from) <= p_delta ? p_to : p_from + SIGN(p_to - p_from) * p_delta;
    }

    inline public static function linear_to_db(p_linear:GDExtensionFloat):GDExtensionFloat {
        return Math.log(p_linear) * 8.6858896380650365530225783783321;
    }

    inline public static function db_to_linear(p_db:GDExtensionFloat):GDExtensionFloat {
        return Math.exp(p_db * 0.11512925464970228420089957273422);
    }

    inline public static function wrapi(value:Int, min:Int, max:Int):Int {
        var range = max - min;
        return range == 0 ? min : min + ((((value - min) % range) + range) % range);
    }

    inline public static function wrapf(value:GDExtensionFloat, min:GDExtensionFloat, max:GDExtensionFloat):GDExtensionFloat {
        var range = max - min;
        var result = is_zero_approx(range) ? min : value - (range * Math.floor((value - min) / range));
        if (is_equal_approx(result, max)) {
            return min;
        }
        return result;
    }

    inline public static function fract(value:GDExtensionFloat):GDExtensionFloat {
        return value - Math.floor(value);
    }
    
    inline public static function pingpong(value:GDExtensionFloat, length:GDExtensionFloat):GDExtensionFloat {
        return (length != 0.0) ? Math.abs(fract((value - length) / (length * 2.0)) * length * 2.0 - length) : 0.0;
    }

    inline public static function is_equal_approx(a, b, tolerance = 0.0):Bool {
        // Check for exact equality first, required to handle "infinity" values.
        if (a == b) {
            return true;
        }
        if (tolerance==0.0) {
            tolerance = CMP_EPSILON * Math.abs(a);
            if (tolerance < CMP_EPSILON) {
                tolerance = CMP_EPSILON;
            }
        }
            
        // Then check for approximate equality.
        return Math.abs(a - b) < tolerance;
    }

    inline public static function is_zero_approx(s):Bool {
        return Math.abs(s) < CMP_EPSILON;
    }


    inline public static function is_finite(s):Bool {
        return s != Math.POSITIVE_INFINITY && s != Math.NEGATIVE_INFINITY;
    }
    
    // Ported from CPP

    inline public static function snapped(p_value:GDExtensionFloat, p_step:GDExtensionFloat):GDExtensionFloat {
        if (p_step != 0) {
            p_value = Math.floor(p_value / p_step + 0.5) * p_step;
        }
        return p_value;
    }
    
    
}