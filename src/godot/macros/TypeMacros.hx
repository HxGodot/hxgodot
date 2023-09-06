package godot.macros;

#if macro

import godot.Types;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class TypeMacros {

    public static function getTypeName(_t:String) {
        return switch(_t) {
            case "Nil": "Void";
            case "bool": "Bool";
            case "void": "cpp.Void";
            case "int", "int64": "cpp.Int64";
            case "int32_t", "int32": "cpp.Int32";
            case "uint_t", "uint", "uint64": "cpp.UInt64";
            case "uint32_t", "uint32": "cpp.UInt32";
            case "uint16_t", "uint16": "cpp.UInt16";
            case "uint8_t", "uint8": "cpp.UInt8";
            case "int8_t", "int8": "cpp.Int8";
            case "int16_t", "int16": "cpp.Int16";
            case "real_t", "double", "float": "Float"; 
            //case "double": "Float";
            case "float32": "cpp.Float32";
            // case "AABB":
            // case "Basis":
            // case "Callable":
            // case "Color":
            // case "Dictionary":
            // case "NodePath":
            // case "PackedByteArray":
            // case "PackedColorArray":
            // case "PackedFloat32Array":
            // case "PackedFloat64Array":
            // case "PackedInt32Array":
            // case "PackedInt64Array":
            // case "PackedStringArray":
            // case "PackedVector2Array":
            // case "PackedVector3Array":
            // case "Plane":
            // case "Quaternion":
            // case "Rect2":
            // case "Rect2i":
            // case "RID":
            // case "Signal":
            // case "StringName":
            // case "Transform2D":
            // case "Transform3D":
            // case "Vector2":
            // case "Vector2i":
            // case "Vector3":
            // case "Vector3i":
            case "const void*": "godot.Types.VoidPtr";
            case "String": "GDString";
            case "Array": "GDArray";
            default: {
                var ret = _t;
                _t = _t.replace("const", "").trim();

                if (_t.endsWith("*")) {
                    var tmp = getTypeName(_t.substring(0, _t.length-1).trim());
                    var pack = getTypePackage(tmp).concat([tmp]);
                    ret = 'cpp.Pointer<${pack.join(".")}>';
                }

                ret = convertIfTypedArray(ret);

                ret;
            }
        };
    }

    public static function getTypePackage(_type:String) {
        var res = [];
        var type = GDExtensionVariantType.fromString(_type);
        if (!TypeMacros.isTypeNative(_type)) {
            if ((type == GDExtensionVariantType.NIL || type == GDExtensionVariantType.OBJECT) && 
                _type != "Variant") {                
                if (!StringTools.startsWith(_type, "cpp"))
                    res = ["godot"];
                else
                    res = [];
            }
            else 
                res = ["godot", "variant"];
        }        
        return res;
    }

    public static function isTypeNative(_type:String) {
        return switch(_type) {
            case "Void", "Nil", "bool", "Bool",
                "int", "int64", "cpp.Int64",
                "int32_t", "int32", "cpp.Int32",
                "uint_t", "uint", "uint64", "cpp.UInt64",
                "uint32_t", "uint32", "cpp.UInt32",
                "uint16_t", "uint16", "cpp.UInt16",
                "uint8_t", "uint8", "cpp.UInt8",
                "int8_t", "int8", "cpp.Int8",
                "int16_t", "int16", "cpp.Int16",
                "real_t", "float", "double", 
                "float_t", "double_t", "Float",
                "float32_t", "cpp.Float32", "cpp.Float64",
                "void", "const void*", "godot.Types.VoidPtr": true;

            default: false;
        }
    }

    public static function isEnumOrBitfield(_type:String) {
        return StringTools.startsWith(_type, "enum::") || StringTools.startsWith(_type, "bitfield::");
    }

    public static function getNativeTypeDefaultValue(_type:String):Dynamic {
        return switch(_type) {
            case "Bool": false;
            case "Float", "cpp.Float32", "cpp.Float64": 0.0;
            case "cpp.Int64", "cpp.Int32", "cpp.Int16", "cpp.Int8", 
                "cpp.UInt64", "cpp.UInt32", "cpp.UInt16", "cpp.UInt8": 0;
            default: null; // make the compiler complain here!
        }
    }

    public static function convertIfTypedArray(_type:String):String {
        // convert the godot typedarray to GDArray
        if (_type != null && StringTools.startsWith(_type, "typedarray"))
            return "GDArray";
        return _type;
    }

    public static function isTypeAllowed(_type:String):Bool {
        // this function is a development helper
        return switch (_type) {
            case //"Nil",
                //"bool",
                //"int",
                //"float",
                // "Color": false;
                // "Plane",
                // "Quaternion",
                // "Rect2",
                // "Rect2i",
                // "Vector2",
                // "Vector2i",
                // "Vector3i",
                // "Projection",

                //"PackedByteArray",
                //"PackedColorArray",
                //"PackedFloat32Array",
                //"PackedFloat64Array",
                //"PackedInt32Array",
                //"PackedInt64Array",
                //"PackedStringArray",
                //"PackedVector2Array",
                //"PackedVector3Array",

                "const uint8_t *" : false;  // TODO
                //"AABB",
                //"Basis",
                //"Object", // wtf
                //"SceneTree",
                //"Transform2D",
                //"Transform3D",
                //"Vector3",
            default: {
                if (_type != null) {
                    !StringTools.contains(_type, ",");
                }
                else
                    true;
            }
        };
    }

    public static function isObjectType(_t:String):Bool 
        return switch(_t) {
            case 'Pointer', 'VoidPtr', 'Bool', 'GDExtensionBool', 'Int', 'Int64', 
                 'GDExtensionInt', 'Float', 'GDExtensionFloat', 'GDString', 'Color', 
                 'Quaternion', 'Vector4', 'Vector2', 'Vector3', 'Vector2i', 'Vector3i', 
                 'Vector4i', "Rect2", "Rect2i", "AABB", "Basis", "Callable", "Dictionary", 
                 "GDArray", "NodePath", "PackedByteArray", "PackedColorArray", 
                 "PackedFloat32Array", "PackedFloat64Array", "PackedInt32Array", 
                 "PackedInt64Array", "PackedStringArray", "PackedVector2Array", 
                 "PackedVector3Array", "Projection", "RID", "Signal", "StringName", 
                 "Transform2D", "Transform3D", "Variant": false;
            default: true;
        };

    public static function isACustomBuiltIn(_type:String):Bool {
        // whitelist custom builtin implementations
        return switch (_type) {
            case
                //"AABB",
                //"Basis",
                "Color",
                "Plane",
                //"Rect2",
                //"Rect2i",
                "Quaternion",
                //"Transform2D",
                //"Transform3D",
                "Vector2",
                "Vector2i",
                "Vector3",
                "Vector3i",
                "Vector4",
                "Vector4i",

                // ATTENTION: the following ones need to be ignored. 
                // we dont implement them but rather map them to haxe
                // automagically
                "Nil",
                "bool",
                "int",
                "float": true;
            default: false;
        }
    }

    public static function getOpName(_type:GDExtensionVariantOperator):String {
        return switch (_type) {
            case EQUAL: "EQUAL";
            case NOT_EQUAL: "NOT_EQUAL";
            case LESS: "LESS";
            case LESS_EQUAL: "LESS_EQUAL";
            case GREATER: "GREATER";
            case GREATER_EQUAL: "GREATER_EQUAL";
            case ADD: "ADD";
            case SUBTRACT: "SUBTRACT";
            case MULTIPLY: "MULTIPLY";
            case DIVIDE: "DIVIDE";
            //case NEGATE: "NEGATE";
            //case POSITIVE: "POSITIVE";
            case MODULE: "MODULE";
            //case POWER: "POWER";
            case SHIFT_LEFT: "SHIFT_LEFT";
            case SHIFT_RIGHT: "SHIFT_RIGHT";
            case BIT_AND: "BIT_AND";
            case BIT_OR: "BIT_OR";
            case BIT_XOR: "BIT_XOR";
            //case BIT_NEGATE: "BIT_NEGATE";
            case AND: "AND";
            case OR: "OR";
            case XOR: "XOR";
            case NOT: "NOT";
            //case IN: "IN";
            default: null;
            //case MAX: "MAX";
        }
    }

    public static function isOpTypeAllowed(_type:String):Bool {
        return switch(_type) {
            case "Nil": false;
            case "Vector4i", "Vector4": false;
            default: true;
        }
    }

    public static function getOpHaxe(_type:GDExtensionVariantOperator):String {
        return switch (_type) {
            case EQUAL: "==";
            case NOT_EQUAL: "!=";
            case LESS: "<";
            case LESS_EQUAL: "<=";
            case GREATER: ">";
            case GREATER_EQUAL: ">=";
            case ADD: "+";
            case SUBTRACT: "-";
            case MULTIPLY: "*";
            case DIVIDE: "/";
            //case NEGATE: "NEGATE";
            //case POSITIVE: "POSITIVE";
            case MODULE: "%";
            //case POWER: "POWER";
            case SHIFT_LEFT: "<<";
            case SHIFT_RIGHT: ">>";
            case BIT_AND: "&";
            case BIT_OR: "|";
            case BIT_XOR: "^";
            //case BIT_NEGATE: "BIT_NEGATE";
            case AND: "&&";
            case OR: "||";
            //case XOR: "XOR";
            case NOT: "!";
            //case IN: "IN";
            default: null;
            //case MAX: "MAX";
        }
    }

    public static function fixCase(_str:String):String {
        /*
        if (_str.charAt(0) == "_") // ignore virtuals!
            return _str;
        else if (_str == "to_string")
            return _str;

        var res = "";
        var tokens = _str.split("_");
        if (tokens.length > 1) {
            res = tokens[0];
            for (i in 1...tokens.length) {
                var t = tokens[i];
                var first = t.charAt(0).toUpperCase();
                var rest = t.substr(1);
                res += first + rest;
            }
        } else
            res = _str;
        return res;
        */
        return _str;
    }
}

#end