package godot.macros;

import godot.Types;

class TypeMacros {

    public static function getTypeName(_t:String) {
        return switch(_t) {
            case "Nil": "Void";
            case "bool": "Bool";
            case "int": "cpp.Int64";
            case "float": "Float";
            // case "Vector2":
            // case "Vector2i":
            // case "Rect2":
            // case "Rect2i":
            // case "Vector3":
            // case "Vector3i":
            // case "Transform2D":
            // case "Plane":
            // case "Quaternion":
            // case "AABB":
            // case "Basis":
            // case "Transform3D":
            // case "Color":
            // case "StringName":
            // case "NodePath":
            // case "RID":
            // case "Callable":
            // case "Signal":
            // case "Dictionary":
            // case "PackedByteArray":
            // case "PackedInt32Array":
            // case "PackedInt64Array":
            // case "PackedFloat32Array":
            // case "PackedFloat64Array":
            // case "PackedStringArray":
            // case "PackedVector2Array":
            // case "PackedVector3Array":
            // case "PackedColorArray":
            case "String": "GDString";
            case "Array": "GDArray";
            default: _t;
        };
    }

    public static function isTypeNative(_type:String) {
        return switch(_type) {
            case "Void", "Bool", "Float", "cpp.Int64": true;
            default: false;
        }
    }

    public static function getNativeTypeDefaultValue(_type:String):Dynamic {
        return switch(_type) {
            case "Bool": false;
            case "Float": 0.0;
            case "cpp.Int64": 0;
            default: false;
        }
    }

    public static function isTypeAllowed(_type:String):Bool {
        return switch (_type) {
            case //"Nil",
                //"bool",
                //"int",
                //"float",
                "Vector2",
                "Vector2i",
                "Rect2",
                "Rect2i",
                //"Vector3",
                "Vector3i",
                //"Transform2D",
                "Plane",
                "Quaternion",
                //"AABB",
                //"Basis",
                //"Transform3D",
                "Object", // wtf
                "Color": false;
            default: true; 
        };
    }

    public static function getOpName(_type:GDNativeVariantOperator):String {
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
            default: true;
        }
    }

    public static function getOpHaxe(_type:GDNativeVariantOperator):String {
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
}