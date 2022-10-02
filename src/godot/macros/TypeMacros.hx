package godot.macros;

class TypeMacros {

    public static function getTypeName(_t:String) {
        return switch(_t) {
            case "Nil": "Void";
            case "bool": "Bool";
            case "int": "Int";
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
            case "Void", "Bool", "Float", "Int": true;
            default: false;
        }
    }

    public static function getNativeTypeDefaultValue(_type:String):Dynamic {
        return switch(_type) {
            case "Bool": false;
            case "Float": 0.0;
            case "Int": 0;
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
}