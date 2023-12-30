package godot.variant;

import godot.Types;
import godot.core.GDMath;

#if cpp
using cpp.NativeArray;
#end

typedef __Color = Array<GDExtensionFloat>;

@:forward
abstract Color(__Color) from __Color to __Color {
    inline public function new(?_r:GDExtensionFloat=0, ?_g:GDExtensionFloat=0, ?_b:GDExtensionFloat=0, ?_a:GDExtensionFloat=1):Color this = _alloc(_r, _g, _b, _a);

    inline private static function _alloc(_r:GDExtensionFloat, _g:GDExtensionFloat, _b:GDExtensionFloat, _a:GDExtensionFloat):__Color
        return [_r, _g, _b, _a];

    inline public function native_ptr():GDExtensionTypePtr {
        #if !macro
        return cast cpp.NativeArray.getBase(this).getBase();
        #else
        return 0;
        #end
    }

    inline static public function fromColor(p_c:Color):Color {
        return new Color(p_c.r, p_c.g, p_c.b, 1.0);
    }

    inline static public function fromColorAlpha(p_c:Color, p_a:GDExtensionFloat):Color {
        return new Color(p_c.r, p_c.g, p_c.b, p_a);
    }

    static public function fromHTMLString(p_code:String):Color {
        if (html_is_valid(p_code)) {
            return html(p_code);
        } else {
            var c = new Color();
            return c.named(p_code);
        }
    }

    @:from static public function fromInt(p_code:Int):Color {
        return Color.hex(p_code);
    }

    static public function fromHTMLStringAlpha(p_code:String, p_a:GDExtensionFloat):Color {
        var c:Color = fromHTMLString(p_code);
        c.a = p_a;
        return c;
    }

    public var r(get, set):GDExtensionFloat;
    inline function get_r() return this[0];
    inline function set_r(_v:GDExtensionFloat) {this[0] = _v; return _v;}

    public var g(get, set):GDExtensionFloat;
    inline function get_g() return this[1];
    inline function set_g(_v:GDExtensionFloat) {this[1] = _v; return _v;}

    public var b(get, set):GDExtensionFloat;
    inline function get_b() return this[2];
    inline function set_b(_v:GDExtensionFloat) {this[2] = _v; return _v;}

    public var a(get, set):GDExtensionFloat;
    inline function get_a() return this[3];
    inline function set_a(_v:GDExtensionFloat) {this[3] = _v; return _v;}

    @:arrayAccess
    inline public function get(_i:Int) return this[_i];

    @:arrayAccess
    inline public function setAt(_i:Int, _v:GDExtensionFloat):Void
        this[_i] = _v;

    inline public function copy():Color
        return new Color(this[0], this[1], this[2], this[3]);

    public function get_luminance():Float {
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    public function lerp(p_to:Color, p_weight:GDExtensionFloat):Color {
        var res:Color = copy();
        res.r = GDMath.lerp(res.r, p_to.r, p_weight);
        res.g = GDMath.lerp(res.g, p_to.g, p_weight);
        res.b = GDMath.lerp(res.b, p_to.b, p_weight);
        res.a = GDMath.lerp(res.a, p_to.a, p_weight);
        return res;
    }

    public function darkened(p_amount:Float):Color {
        var res:Color = copy();
        res.r = res.r * (1.0 - p_amount);
        res.g = res.g * (1.0 - p_amount);
        res.b = res.b * (1.0 - p_amount);
        return res;
    }

    public function lightened(p_amount:Float):Color {
        var res:Color = copy();
        res.r = res.r + (1.0 - res.r) * p_amount;
        res.g = res.g + (1.0 - res.g) * p_amount;
        res.b = res.b + (1.0 - res.b) * p_amount;
        return res;
    }

    public function to_rgbe9995():Int {
        var pow2to9:Float = 512.0;
        var B:Float = 15.0;
        var N:Float = 9.0;

        var sharedexp:Float = 65408.000; // Result of: ((pow2to9 - 1.0) / pow2to9) * powf(2.0, 31.0 - 15.0)

        var cRed:Float = MAX(0.0, 1.0);//MAX(0.0, MIN(sharedexp, r));
        var cGreen:Float = MAX(0.0, MIN(sharedexp, g));
        var cBlue:Float = MAX(0.0, MIN(sharedexp, b));

        var cMax:Float = MAX(cRed, MAX(cGreen, cBlue));

        var expp:Float = MAX(-B - 1.0, Math.floor(Math.log(cMax) / Math_LN2)) + 1.0 + B;

        var sMax:Float = Math.floor((cMax / Math.pow(2.0, expp - B - N)) + 0.5);

        var exps:Float = expp + 1.0;

        if (0.0 <= sMax && sMax < pow2to9) {
            exps = expp;
        }

        var sRed:Float = Math.floor((cRed / Math.pow(2.0, exps - B - N)) + 0.5);
        var sGreen:Float = Math.floor((cGreen / Math.pow(2.0, exps - B - N)) + 0.5);
        var sBlue:Float = Math.floor((cBlue / Math.pow(2.0, exps - B - N)) + 0.5);

        return ((Std.int(sRed)) & 0x1FF) | (((Std.int(sGreen)) & 0x1FF) << 9) | (((Std.int(sBlue)) & 0x1FF) << 18) | (((Std.int(exps)) & 0x1F) << 27);
    }

    public function blend(p_over:Color):Color {
        var res:Color = new Color();
        var sa:Float = 1.0 - p_over.a;
        res.a = a * sa + p_over.a;
        if (res.a == 0) {
            return new Color(0, 0, 0, 0);
        } else {
            res.r = (r * a * sa + p_over.r * p_over.a) / res.a;
            res.g = (g * a * sa + p_over.g * p_over.a) / res.a;
            res.b = (b * a * sa + p_over.b * p_over.a) / res.a;
        }
        return res;
    }

    public function srgb_to_linear():Color {
        return new Color(
                r < 0.04045 ? r * (1.0 / 12.92) : Math.pow((r + 0.055) * (1.0 / (1.0 + 0.055)), 2.4),
                g < 0.04045 ? g * (1.0 / 12.92) : Math.pow((g + 0.055) * (1.0 / (1.0 + 0.055)), 2.4),
                b < 0.04045 ? b * (1.0 / 12.92) : Math.pow((b + 0.055) * (1.0 / (1.0 + 0.055)), 2.4),
                a);
    }
    public function linear_to_srgb():Color {
        return new Color(
                r < 0.0031308 ? 12.92 * r : (1.0 + 0.055) * Math.pow(r, 1.0 / 2.4) - 0.055,
                g < 0.0031308 ? 12.92 * g : (1.0 + 0.055) * Math.pow(g, 1.0 / 2.4) - 0.055,
                b < 0.0031308 ? 12.92 * b : (1.0 + 0.055) * Math.pow(b, 1.0 / 2.4) - 0.055, a);
    }

    // For the binder.
    public var r8(get, set):Int;
    inline public function set_r8(r8:Int):Int { r = (CLAMP(r8, 0, 255) / 255.0); return r8; }
    inline public function get_r8() { return Std.int(CLAMP(Math.round(r * 255.0), 0.0, 255.0)); }
    public var g8(get, set):Int;
    inline public function set_g8(g8:Int):Int { g = (CLAMP(g8, 0, 255) / 255.0); return g8; }
    inline public function get_g8() { return Std.int(CLAMP(Math.round(g * 255.0), 0.0, 255.0)); }
    public var b8(get, set):Int;
    inline public function set_b8(b8:Int):Int { b = (CLAMP(b8, 0, 255) / 255.0); return b8; }
    inline public function get_b8() { return Std.int(CLAMP(Math.round(b * 255.0), 0.0, 255.0)); }
    public var a8(get, set):Int;
    inline public function set_a8(a8:Int):Int { a = (CLAMP(a8, 0, 255) / 255.0); return a8; }
    inline public function get_a8() { return Std.int(CLAMP(Math.round(a * 255.0), 0.0, 255.0)); }

    public var h(get, set):Float;
    inline public function set_h(p_h:Float) { set_hsv(p_h, get_s(), get_v(), a); return h; }
    public var s(get, set):Float;
    inline public function set_s(p_s:Float) { set_hsv(get_h(), p_s, get_v(), a); return s; }
    public var v(get, set):Float;
    inline public function set_v(p_v:Float) { set_hsv(get_h(), get_s(), p_v, a); return v; }
    inline public function set_ok_hsl_h(p_h:Float) { set_ok_hsl(p_h, get_ok_hsl_s(), get_ok_hsl_l(), a); return p_h; }
    inline public function set_ok_hsl_s(p_s:Float) { set_ok_hsl(get_ok_hsl_h(), p_s, get_ok_hsl_l(), a); return p_s; }
    inline public function set_ok_hsl_l(p_l:Float) { set_ok_hsl(get_ok_hsl_h(), get_ok_hsl_s(), p_l, a); return p_l; }

    // /**
    //  * RGBAruct parameters.
    //  * Alpha is not optional as otherwise we can't bind the RGB version for scripting.
    //  */
    // public  Color(p_r:GDExtensionFloat, p_g:GDExtensionFloat, p_b:GDExtensionFloat, p_a:GDExtensionFloat) {
    // 	r = p_r;
    // 	g = p_g;
    // 	b = p_b;
    // 	a = p_a;
    // }

    // /**
    //  * RGBruct parameters.
    //  */
    // inline Color(Float p_r, Float p_g, Float p_b) {
    // 	r = p_r;
    // 	g = p_g;
    // 	b = p_b;
    // 	a = 1.0;
    // }

    // /**
    //  * Construct a Color from another Color, but with the specified alpha value.
    //  */
    // inline Color(p_c:Color, Float p_a) {
    // 	r = p_c.r;
    // 	g = p_c.g;
    // 	b = p_c.b;
    // 	a = p_a;
    // }

    // Color(p_code:String) {
    // 	if (html_is_valid(p_code)) {
    // 		copy() = html(p_code);
    // 	} else {
    // 		copy() = named(p_code);
    // 	}
    // }

    // Color(p_code:String, Float p_a) {
    // 	copy() = Color(p_code);
    // 	a = p_a;
    // }

    public function to_argb32():UInt {
        var c:UInt = Math.round(a * 255.0);
        c <<= 8;
        c |= Math.round(r * 255.0);
        c <<= 8;
        c |= Math.round(g * 255.0);
        c <<= 8;
        c |= Math.round(b * 255.0);

        return c;
    }

    public function to_abgr32():UInt {
        var c:UInt = Math.round(a * 255.0);
        c <<= 8;
        c |= Math.round(b * 255.0);
        c <<= 8;
        c |= Math.round(g * 255.0);
        c <<= 8;
        c |= Math.round(r * 255.0);

        return c;
    }

    public function to_rgba32():UInt {
        var c:UInt = Math.round(r * 255.0);
        c <<= 8;
        c |= Math.round(g * 255.0);
        c <<= 8;
        c |= Math.round(b * 255.0);
        c <<= 8;
        c |= Math.round(a * 255.0);

        return c;
    }

    public function to_abgr64():haxe.Int64 {
        var c:haxe.Int64 = Math.round(a * 65535.0);
        c <<= 16;
        c |= Math.round(b * 65535.0);
        c <<= 16;
        c |= Math.round(g * 65535.0);
        c <<= 16;
        c |= Math.round(r * 65535.0);

        return c;
    }

    public function to_argb64():haxe.Int64 {
        var c:haxe.Int64 = Math.round(a * 65535.0);
        c <<= 16;
        c |= Math.round(r * 65535.0);
        c <<= 16;
        c |= Math.round(g * 65535.0);
        c <<= 16;
        c |= Math.round(b * 65535.0);

        return c;
    }

    public function to_rgba64():haxe.Int64 {
        var c:haxe.Int64 = Math.round(r * 65535.0);
        c <<= 16;
        c |= Math.round(g * 65535.0);
        c <<= 16;
        c |= Math.round(b * 65535.0);
        c <<= 16;
        c |= Math.round(a * 65535.0);

        return c;
    }

    public function _to_hex(p_val:GDExtensionFloat):String {
        var v:Float = Math.round(p_val * 255.0);
        v = CLAMP(v, 0, 255);
        var ret:String;
        ret = StringTools.hex(Std.int(v),2);

        // for (i in 0..2) {
        // 	c[2] = { 0, 0 };
        // 	var lv:Int = v & 0xF;
        // 	if (lv < 10) {
        // 		c[0] = '0' + lv;
        // 	} else {
        // 		c[0] = 'a' + lv - 10;
        // 	}

        // 	v >>= 4;
        // 	var cs = String.fromCharCode(c);
        // 	ret = cs + ret;
        // }

        return ret;
    }

    public function to_html(p_alpha:Bool):String {
        var txt:String;
        txt = _to_hex(r);
        txt += _to_hex(g);
        txt += _to_hex(b);
        if (p_alpha) {
            txt += _to_hex(a);
        }
        return txt;
    }

    public function get_h():GDExtensionFloat {
        var min:Float = MIN(r, g);
        min = MIN(min, b);
        var max:Float = MAX(r, g);
        max = MAX(max, b);

        var delta:Float = max - min;

        if (delta == 0.0) {
            return 0.0;
        }

        var h:Float;
        if (r == max) {
            h = (g - b) / delta; // between yellow & magenta
        } else if (g == max) {
            h = 2 + (b - r) / delta; // between cyan & yellow
        } else {
            h = 4 + (r - g) / delta; // between magenta & cyan
        }

        h /= 6.0;
        if (h < 0.0) {
            h += 1.0;
        }

        return h;
    }

    public function get_s():GDExtensionFloat {
        var min:GDExtensionFloat = MIN(r, g);
        min = MIN(min, b);
        var max:GDExtensionFloat = MAX(r, g);
        max = MAX(max, b);

        var delta:Float = max - min;

        return (max != 0.0) ? (delta / max) : 0.0;
    }

    public function get_v():GDExtensionFloat {
        var max:GDExtensionFloat = MAX(r, g);
        max = MAX(max, b);
        return max;
    }

    public function set_hsv(p_h:GDExtensionFloat, p_s:GDExtensionFloat, p_v:GDExtensionFloat, p_alpha:GDExtensionFloat):Void {
        var i:Int;
        var f:Float, p:Float, q:Float, t:Float;
        a = p_alpha;

        if (p_s == 0.0) {
            // Achromatic (grey)
            r = g = b = p_v;
            return;
        }

        p_h *= 6.0;
        p_h = GDMath.fmod(p_h, 6);
        i = Math.floor(p_h);

        f = cast p_h - i;
        p = p_v * (1.0 - p_s);
        q = p_v * (1.0 - p_s * f);
        t = p_v * (1.0 - p_s * (1.0 - f));

        switch (i) {
            case 0: // Red is the dominant color
                r = p_v;
                g = t;
                b = p;
            case 1: // Green is the dominant color
                r = q;
                g = p_v;
                b = p;
            case 2:
                r = p;
                g = p_v;
                b = t;
            case 3: // Blue is the dominant color
                r = p;
                g = q;
                b = p_v;
            case 4:
                r = t;
                g = p;
                b = p_v;
            default: // (5) Red is the dominant color
                r = p_v;
                g = p;
                b = q;
        }
    }

    public function set_ok_hsl(p_h:Float, p_s:Float, p_l:Float, p_alpha:Float):Void {
        // ok_color::HSL hsl;
        // hsl.h = p_h;
        // hsl.s = p_s;
        // hsl.l = p_l;
        // ok_color new_ok_color;
        // ok_color::RGB rgb = new_ok_color.okhsl_to_srgb(hsl);
        // Color c = Color(rgb.r, rgb.g, rgb.b, p_alpha).clamp();
        // r = c.r;
        // g = c.g;
        // b = c.b;
        // a = c.a;
    }

    public function is_equal_approx(p_color:Color):Bool {
        return GDMath.is_equal_approx(r, p_color.r) && GDMath.is_equal_approx(g, p_color.g) && GDMath.is_equal_approx(b, p_color.b) && GDMath.is_equal_approx(a, p_color.a);
    }

    public function clamp(p_min:Color, p_max:Color):Color {
        return new Color(
                CLAMP(r, p_min.r, p_max.r),
                CLAMP(g, p_min.g, p_max.g),
                CLAMP(b, p_min.b, p_max.b),
                CLAMP(a, p_min.a, p_max.a));
    }

    public function invert():Void {
        r = 1.0 - r;
        g = 1.0 - g;
        b = 1.0 - b;
    }

    static public function hex(p_hex:Int):Color {
        var a:Float = (p_hex & 0xFF) / 255.0;
        p_hex >>= 8;
        var b:Float = (p_hex & 0xFF) / 255.0;
        p_hex >>= 8;
        var g:Float = (p_hex & 0xFF) / 255.0;
        p_hex >>= 8;
        var r:Float = (p_hex & 0xFF) / 255.0;

        return new Color(r, g, b, a);
    }

    static public function hex64(p_hex:haxe.Int64):Color {
        var a:Float = haxe.Int64.toInt(p_hex & 0xFFFF) / 65535.0;
        p_hex >>= 16;
        var b:Float = haxe.Int64.toInt(p_hex & 0xFFFF) / 65535.0;
        p_hex >>= 16;
        var g:Float = haxe.Int64.toInt(p_hex & 0xFFFF) / 65535.0;
        p_hex >>= 16;
        var r:Float = haxe.Int64.toInt(p_hex & 0xFFFF) / 65535.0;

        return new Color(r, g, b, a);
    }

    static function _parse_col4(p_str:String, p_ofs:Int):Int {
        var character = p_str.substr(p_ofs,1).charCodeAt(0);

        if (character >= '0'.code && character <= '9'.code) {
            return character - '0'.code;
        } else if (character >= 'a'.code && character <= 'f'.code) {
            return character + (10 - 'a'.code);
        } else if (character >= 'A'.code && character <= 'F'.code) {
            return character + (10 - 'A'.code);
        }
        return -1;
    }

    static function _parse_col8(p_str:String, p_ofs:Int):Int {
        return _parse_col4(p_str, p_ofs) * 16 + _parse_col4(p_str, p_ofs + 1);
    }

    public function inverted():Color {
        var c:Color = copy();
        c.invert();
        return c;
    }

    static public function html(p_rgba:String):Color {
        var color:String = p_rgba;
        if (color.length == 0) {
            return new Color();
        }
        if (color.substr(0, 1) == '#') {
            color = color.substr(1);
        }

        // If enabled, use 1 hex digit per channel instead of 2.
        // Other sizes aren't in the HTML/CSS spec but we could add them if desired.
        var is_shorthand = color.length < 5;
        var alpha = false;

        if (color.length == 8) {
            alpha = true;
        } else if (color.length == 6) {
            alpha = false;
        } else if (color.length == 4) {
            alpha = true;
        } else if (color.length == 3) {
            alpha = false;
        } else {
            ERR_FAIL_V_MSG(new Color(), "Invalid color code: " + p_rgba + ". col=" + color+" len="+color.length);
        }

        var r:Float, g:Float, b:Float, a:Float = 1.0;
        if (is_shorthand) {
            r = _parse_col4(color, 0) / 15.0;
            g = _parse_col4(color, 1) / 15.0;
            b = _parse_col4(color, 2) / 15.0;
            if (alpha) {
                a = _parse_col4(color, 3) / 15.0;
            }
        } else {
            r = _parse_col8(color, 0) / 255.0;
            g = _parse_col8(color, 2) / 255.0;
            b = _parse_col8(color, 4) / 255.0;
            if (alpha) {
                a = _parse_col8(color, 6) / 255.0;
            }
        }
        ERR_FAIL_COND_V_MSG(r < 0.0, new Color(), "Invalid color code: " + p_rgba + ".");
        ERR_FAIL_COND_V_MSG(g < 0.0, new Color(), "Invalid color code: " + p_rgba + ".");
        ERR_FAIL_COND_V_MSG(b < 0.0, new Color(), "Invalid color code: " + p_rgba + ".");
        ERR_FAIL_COND_V_MSG(a < 0.0, new Color(), "Invalid color code: " + p_rgba + ".");

        return new Color(r, g, b, a);
    }

    static public function html_is_valid(p_color:String):Bool {
        var color:String = p_color;

        if (color.length == 0) {
            return false;
        }
        if (color.substr(0, 1) == '#') {
            color = color.substr(1);
        }

        // Check if the amount of hex digits is valid.
        var len = color.length;
        if (!(len == 3 || len == 4 || len == 6 || len == 8)) {
            return false;
        }

        // Check if each hex digit is valid.
        for (i in 0...len) {
            if (_parse_col4(color, i) == -1) {
                return false;
            }
        }

        return true;
    }

    // public function named(p_name:String):Color {
    // 	var idx = find_named_color(p_name);
    // 	if (idx == -1) {
    // 		ERR_FAIL_V_MSG(Color(), "Invalid color name: " + p_name + ".");
    // 		return new Color();
    // 	}
    // 	return named_colors[idx].color;
    // }

    public function named(p_name:String, p_default:Color = null):Color {
        var idx = find_named_color(p_name);
        if (idx == -1) {
            return p_default == null ? new Color() : p_default;
        }
        return named_colors[idx].color;
    }

    public function find_named_color(p_name:String):Int {
        var name = p_name;
        // Normalize name
        name = StringTools.replace(name, " ", "");
        name = StringTools.replace(name, "-", "");
        name = StringTools.replace(name, "_", "");
        name = StringTools.replace(name, "'", "");
        name = StringTools.replace(name, ".", "");
        name = name.toUpperCase();

        var idx = 0;
        while (named_colors[idx] != null) {
            if (name == StringTools.replace(named_colors[idx].name, "_", "")) {
                return idx;
            }
            idx++;
        }

        return -1;
    }

    public function get_named_color_count():Int {
        return named_colors.length;
        // var idx = 0;
        // while (named_colors[idx].name != null) {
        // 	idx++;
        // }
        // return idx;
    }

    public function get_named_color_name(p_idx:Int):String {
        ERR_FAIL_INDEX_V(p_idx, get_named_color_count(), "");
        return named_colors[p_idx].name;
    }

    public function get_named_color(p_idx:Int):Color {
        ERR_FAIL_INDEX_V(p_idx, get_named_color_count(), new Color());
        return named_colors[p_idx].color;
    }

    // For a version that errors on invalid values instead of returning
    // a default color, use the Color(String)ructor instead.
    static public function from_string(p_string:String, p_default:Color):Color {
        if (html_is_valid(p_string)) {
            return html(p_string);
        } else {
            var c:Color = new Color();
            return c.named(p_string, p_default);
        }
    }

    static public function from_hsv(p_h:Float, p_s:Float, p_v:Float, p_alpha:Float):Color {
        var c:Color = new Color();
        c.set_hsv(p_h, p_s, p_v, p_alpha);
        return c;
    }

    static public function from_rgbe9995(p_rgbe:Int):Color {
        var r:Float = p_rgbe & 0x1ff;
        var g:Float = (p_rgbe >> 9) & 0x1ff;
        var b:Float = (p_rgbe >> 18) & 0x1ff;
        var e:Float = (p_rgbe >> 27);
        var m:Float = Math.pow(2.0, e - 15.0 - 9.0);

        var rd:Float = r * m;
        var gd:Float = g * m;
        var bd:Float = b * m;

        return new Color(rd, gd, bd, 1.0);
    }

    static public function from_ok_hsl(p_h:Float, p_s:Float, p_l:Float, p_alpha:Float):Color {
        var c:Color = new Color();
        c.set_ok_hsl(p_h, p_s, p_l, p_alpha);
        return c;
    }

    public function get_ok_hsl_h():Float {
        // ok_color::RGB rgb;
        // rgb.r = r;
        // rgb.g = g;
        // rgb.b = b;
        // ok_color new_ok_color;
        // ok_color::HSL ok_hsl = new_ok_color.srgb_to_okhsl(rgb);
        // if (Math::is_nan(ok_hsl.h)) {
        // 	return 0.0;
        // }
        // return CLAMP(ok_hsl.h, 0.0, 1.0);
        return 0;
    }

    public function get_ok_hsl_s():Float {
        // ok_color::RGB rgb;
        // rgb.r = r;
        // rgb.g = g;
        // rgb.b = b;
        // ok_color new_ok_color;
        // ok_color::HSL ok_hsl = new_ok_color.srgb_to_okhsl(rgb);
        // if (Math::is_nan(ok_hsl.s)) {
        // 	return 0.0;
        // }
        // return CLAMP(ok_hsl.s, 0.0, 1.0);
        return 0;
    }

    public function get_ok_hsl_l():Float {
        // ok_color::RGB rgb;
        // rgb.r = r;
        // rgb.g = g;
        // rgb.b = b;
        // ok_color new_ok_color;
        // ok_color::HSL ok_hsl = new_ok_color.srgb_to_okhsl(rgb);
        // if (Math::is_nan(ok_hsl.l)) {
        // 	return 0.0;
        // }
        // return CLAMP(ok_hsl.l, 0.0, 1.0);
        return 0;
    }

    @:to public function toString():String {
        return "(" + DP(r, 4) + ", " + DP(g, 4) + ", " + DP(b, 4) + ", " + DP(a, 4) + ")";
    }

    @:op(A == B)
    inline public static function eq(lhs:Color, rhs:Color):Bool {
        return lhs[0] == rhs[0] &&  lhs[1] == rhs[1] &&  lhs[2] == rhs[2] &&  lhs[3] == rhs[3];
    }

    @:op(A != B)
    inline public static function neq(lhs:Color, rhs:Color):Bool {
        return lhs[0] != rhs[0] ||  lhs[1] != rhs[1] ||  lhs[2] != rhs[2] ||  lhs[3] != rhs[3];
    }

    @:op(A * B)
    inline public static function mult(lhs:Color, rhs:Color):Color {
        var res = new Color(0,0,0,0);
        res[0] = lhs[0] * rhs[0];
        res[1] = lhs[1] * rhs[1];
        res[2] = lhs[2] * rhs[2];
        res[3] = lhs[3] * rhs[3];
        return res;
    }

    @:op(A *= B)
    inline public static function multIn(lhs:Color, rhs:Color):Color {
        lhs[0] *= rhs[0];
        lhs[1] *= rhs[1];
        lhs[2] *= rhs[2];
        lhs[3] *= rhs[3];
        return lhs;
    }

    @:op(A / B)
    inline public static function divide(lhs:Color, rhs:Color):Color {
        var res = new Color(0,0,0,0);
        res[0] = lhs[0] / rhs[0];
        res[1] = lhs[1] / rhs[1];
        res[2] = lhs[2] / rhs[2];
        res[3] = lhs[3] / rhs[3];
        return res;
    }

    @:op(A /= B)
    inline public static function divideIn(lhs:Color, rhs:Color):Color {
        lhs[0] /= rhs[0];
        lhs[1] /= rhs[1];
        lhs[2] /= rhs[2];
        lhs[3] /= rhs[3];
        return lhs;
    }

    @:op(A * B)
    inline public static function multScalar(lhs:Color, scalar:GDExtensionFloat):Color {
        var res = new Color(0,0,0,0);
        res[0] = lhs[0] * scalar;
        res[1] = lhs[1] * scalar;
        res[2] = lhs[2] * scalar;
        res[3] = lhs[3] * scalar;
        return res;
    }

    @:op(A *= B)
    inline public static function multInScalar(lhs:Color, scalar:GDExtensionFloat):Color {
        lhs[0] *= scalar;
        lhs[1] *= scalar;
        lhs[2] *= scalar;
        lhs[3] *= scalar;
        return lhs;
    }

    @:op(A / B)
    inline public static function divideScalar(lhs:Color, scalar:GDExtensionFloat):Color {
        var res = new Color(0,0,0,0);
        res[0] = lhs[0] / scalar;
        res[1] = lhs[1] / scalar;
        res[2] = lhs[2] / scalar;
        res[3] = lhs[3] / scalar;
        return res;
    }

    @:op(A /= B)
    inline public static function divideInScalar(lhs:Color, scalar:GDExtensionFloat):Color {
        lhs[0] /= scalar;
        lhs[1] /= scalar;
        lhs[2] /= scalar;
        lhs[3] /= scalar;
        return lhs;
    }

    @:op(A + B)
    inline public static function add(lhs:Color, rhs:Color):Color {
        var res = new Color(0,0,0,0);
        res[0] = lhs[0] + rhs[0];
        res[1] = lhs[1] + rhs[1];
        res[2] = lhs[2] + rhs[2];
        res[3] = lhs[3] + rhs[3];
        return res;
    }

    @:op(A += B)
    inline public static function addIn(lhs:Color, rhs:Color):Color {
        lhs[0] += rhs[0];
        lhs[1] += rhs[1];
        lhs[2] += rhs[2];
        lhs[3] += rhs[3];
        return lhs;
    }

    @:op(A - B)
    inline public static function subtract(lhs:Color, rhs:Color):Color {
        var res = new Color(0,0,0,0);
        res[0] = lhs[0] - rhs[0];
        res[1] = lhs[1] - rhs[1];
        res[2] = lhs[2] - rhs[2];
        res[3] = lhs[3] - rhs[3];
        return res;
    }

    @:op(A -= B)
    inline public static function subtractIn(lhs:Color, rhs:Color):Color {
        lhs[0] -= rhs[0];
        lhs[1] -= rhs[1];
        lhs[2] -= rhs[2];
        lhs[3] -= rhs[3];
        return lhs;
    }

    public static var ALICE_BLUE = Color.hex(0xF0F8FFFF );
    public static var ANTIQUE_WHITE = Color.hex(0xFAEBD7FF );
    public static var AQUA = Color.hex(0x00FFFFFF );
    public static var AQUAMARINE = Color.hex(0x7FFFD4FF );
    public static var AZURE = Color.hex(0xF0FFFFFF );
    public static var BEIGE = Color.hex(0xF5F5DCFF );
    public static var BISQUE = Color.hex(0xFFE4C4FF );
    public static var BLACK = Color.hex(0x000000FF );
    public static var BLANCHED_ALMOND = Color.hex(0xFFEBCDFF );
    public static var BLUE = Color.hex(0x0000FFFF );
    public static var BLUE_VIOLET = Color.hex(0x8A2BE2FF );
    public static var BROWN = Color.hex(0xA52A2AFF );
    public static var BURLYWOOD = Color.hex(0xDEB887FF );
    public static var CADET_BLUE = Color.hex(0x5F9EA0FF );
    public static var CHARTREUSE = Color.hex(0x7FFF00FF );
    public static var CHOCOLATE = Color.hex(0xD2691EFF );
    public static var CORAL = Color.hex(0xFF7F50FF );
    public static var CORNFLOWER_BLUE = Color.hex(0x6495EDFF );
    public static var CORNSILK = Color.hex(0xFFF8DCFF );
    public static var CRIMSON = Color.hex(0xDC143CFF );
    public static var CYAN = Color.hex(0x00FFFFFF );
    public static var DARK_BLUE = Color.hex(0x00008BFF );
    public static var DARK_CYAN = Color.hex(0x008B8BFF );
    public static var DARK_GOLDENROD = Color.hex(0xB8860BFF );
    public static var DARK_GRAY = Color.hex(0xA9A9A9FF );
    public static var DARK_GREEN = Color.hex(0x006400FF );
    public static var DARK_KHAKI = Color.hex(0xBDB76BFF );
    public static var DARK_MAGENTA = Color.hex(0x8B008BFF );
    public static var DARK_OLIVE_GREEN = Color.hex(0x556B2FFF );
    public static var DARK_ORANGE = Color.hex(0xFF8C00FF );
    public static var DARK_ORCHID = Color.hex(0x9932CCFF );
    public static var DARK_RED = Color.hex(0x8B0000FF );
    public static var DARK_SALMON = Color.hex(0xE9967AFF );
    public static var DARK_SEA_GREEN = Color.hex(0x8FBC8FFF );
    public static var DARK_SLATE_BLUE = Color.hex(0x483D8BFF );
    public static var DARK_SLATE_GRAY = Color.hex(0x2F4F4FFF );
    public static var DARK_TURQUOISE = Color.hex(0x00CED1FF );
    public static var DARK_VIOLET = Color.hex(0x9400D3FF );
    public static var DEEP_PINK = Color.hex(0xFF1493FF );
    public static var DEEP_SKY_BLUE = Color.hex(0x00BFFFFF );
    public static var DIM_GRAY = Color.hex(0x696969FF );
    public static var DODGER_BLUE = Color.hex(0x1E90FFFF );
    public static var FIREBRICK = Color.hex(0xB22222FF );
    public static var FLORAL_WHITE = Color.hex(0xFFFAF0FF );
    public static var FOREST_GREEN = Color.hex(0x228B22FF );
    public static var FUCHSIA = Color.hex(0xFF00FFFF );
    public static var GAINSBORO = Color.hex(0xDCDCDCFF );
    public static var GHOST_WHITE = Color.hex(0xF8F8FFFF );
    public static var GOLD = Color.hex(0xFFD700FF );
    public static var GOLDENROD = Color.hex(0xDAA520FF );
    public static var GRAY = Color.hex(0xBEBEBEFF );
    public static var GREEN = Color.hex(0x00FF00FF );
    public static var GREEN_YELLOW = Color.hex(0xADFF2FFF );
    public static var HONEYDEW = Color.hex(0xF0FFF0FF );
    public static var HOT_PINK = Color.hex(0xFF69B4FF );
    public static var INDIAN_RED = Color.hex(0xCD5C5CFF );
    public static var INDIGO = Color.hex(0x4B0082FF );
    public static var IVORY = Color.hex(0xFFFFF0FF );
    public static var KHAKI = Color.hex(0xF0E68CFF );
    public static var LAVENDER = Color.hex(0xE6E6FAFF );
    public static var LAVENDER_BLUSH = Color.hex(0xFFF0F5FF );
    public static var LAWN_GREEN = Color.hex(0x7CFC00FF );
    public static var LEMON_CHIFFON = Color.hex(0xFFFACDFF );
    public static var LIGHT_BLUE = Color.hex(0xADD8E6FF );
    public static var LIGHT_CORAL = Color.hex(0xF08080FF );
    public static var LIGHT_CYAN = Color.hex(0xE0FFFFFF );
    public static var LIGHT_GOLDENROD = Color.hex(0xFAFAD2FF );
    public static var LIGHT_GRAY = Color.hex(0xD3D3D3FF );
    public static var LIGHT_GREEN = Color.hex(0x90EE90FF );
    public static var LIGHT_PINK = Color.hex(0xFFB6C1FF );
    public static var LIGHT_SALMON = Color.hex(0xFFA07AFF );
    public static var LIGHT_SEA_GREEN = Color.hex(0x20B2AAFF );
    public static var LIGHT_SKY_BLUE = Color.hex(0x87CEFAFF );
    public static var LIGHT_SLATE_GRAY = Color.hex(0x778899FF );
    public static var LIGHT_STEEL_BLUE = Color.hex(0xB0C4DEFF );
    public static var LIGHT_YELLOW = Color.hex(0xFFFFE0FF );
    public static var LIME = Color.hex(0x00FF00FF );
    public static var LIME_GREEN = Color.hex(0x32CD32FF );
    public static var LINEN = Color.hex(0xFAF0E6FF );
    public static var MAGENTA = Color.hex(0xFF00FFFF );
    public static var MAROON = Color.hex(0xB03060FF );
    public static var MEDIUM_AQUAMARINE = Color.hex(0x66CDAAFF );
    public static var MEDIUM_BLUE = Color.hex(0x0000CDFF );
    public static var MEDIUM_ORCHID = Color.hex(0xBA55D3FF );
    public static var MEDIUM_PURPLE = Color.hex(0x9370DBFF );
    public static var MEDIUM_SEA_GREEN = Color.hex(0x3CB371FF );
    public static var MEDIUM_SLATE_BLUE = Color.hex(0x7B68EEFF );
    public static var MEDIUM_SPRING_GREEN = Color.hex(0x00FA9AFF );
    public static var MEDIUM_TURQUOISE = Color.hex(0x48D1CCFF );
    public static var MEDIUM_VIOLET_RED = Color.hex(0xC71585FF );
    public static var MIDNIGHT_BLUE = Color.hex(0x191970FF );
    public static var MINT_CREAM = Color.hex(0xF5FFFAFF );
    public static var MISTY_ROSE = Color.hex(0xFFE4E1FF );
    public static var MOCCASIN = Color.hex(0xFFE4B5FF );
    public static var NAVAJO_WHITE = Color.hex(0xFFDEADFF );
    public static var NAVY_BLUE = Color.hex(0x000080FF );
    public static var OLD_LACE = Color.hex(0xFDF5E6FF );
    public static var OLIVE = Color.hex(0x808000FF );
    public static var OLIVE_DRAB = Color.hex(0x6B8E23FF );
    public static var ORANGE = Color.hex(0xFFA500FF );
    public static var ORANGE_RED = Color.hex(0xFF4500FF );
    public static var ORCHID = Color.hex(0xDA70D6FF );
    public static var PALE_GOLDENROD = Color.hex(0xEEE8AAFF );
    public static var PALE_GREEN = Color.hex(0x98FB98FF );
    public static var PALE_TURQUOISE = Color.hex(0xAFEEEEFF );
    public static var PALE_VIOLET_RED = Color.hex(0xDB7093FF );
    public static var PAPAYA_WHIP = Color.hex(0xFFEFD5FF );
    public static var PEACH_PUFF = Color.hex(0xFFDAB9FF );
    public static var PERU = Color.hex(0xCD853FFF );
    public static var PINK = Color.hex(0xFFC0CBFF );
    public static var PLUM = Color.hex(0xDDA0DDFF );
    public static var POWDER_BLUE = Color.hex(0xB0E0E6FF );
    public static var PURPLE = Color.hex(0xA020F0FF );
    public static var REBECCA_PURPLE = Color.hex(0x663399FF );
    public static var RED = Color.hex(0xFF0000FF );
    public static var ROSY_BROWN = Color.hex(0xBC8F8FFF );
    public static var ROYAL_BLUE = Color.hex(0x4169E1FF );
    public static var SADDLE_BROWN = Color.hex(0x8B4513FF );
    public static var SALMON = Color.hex(0xFA8072FF );
    public static var SANDY_BROWN = Color.hex(0xF4A460FF );
    public static var SEA_GREEN = Color.hex(0x2E8B57FF );
    public static var SEASHELL = Color.hex(0xFFF5EEFF );
    public static var SIENNA = Color.hex(0xA0522DFF );
    public static var SILVER = Color.hex(0xC0C0C0FF );
    public static var SKY_BLUE = Color.hex(0x87CEEBFF );
    public static var SLATE_BLUE = Color.hex(0x6A5ACDFF );
    public static var SLATE_GRAY = Color.hex(0x708090FF );
    public static var SNOW = Color.hex(0xFFFAFAFF );
    public static var SPRING_GREEN = Color.hex(0x00FF7FFF );
    public static var STEEL_BLUE = Color.hex(0x4682B4FF );
    public static var TAN = Color.hex(0xD2B48CFF );
    public static var TEAL = Color.hex(0x008080FF );
    public static var THISTLE = Color.hex(0xD8BFD8FF );
    public static var TOMATO = Color.hex(0xFF6347FF );
    public static var TRANSPARENT = Color.hex(0xFFFFFF00 );
    public static var TURQUOISE = Color.hex(0x40E0D0FF );
    public static var VIOLET = Color.hex(0xEE82EEFF );
    public static var WEB_GRAY = Color.hex(0x808080FF );
    public static var WEB_GREEN = Color.hex(0x008000FF );
    public static var WEB_MAROON = Color.hex(0x800000FF );
    public static var WEB_PURPLE = Color.hex(0x800080FF );
    public static var WHEAT = Color.hex(0xF5DEB3FF );
    public static var WHITE = Color.hex(0xFFFFFFFF );
    public static var WHITE_SMOKE = Color.hex(0xF5F5F5FF );
    public static var YELLOW = Color.hex(0xFFFF00FF );
    public static var YELLOW_GREEN = Color.hex(0x9ACD32FF );
}