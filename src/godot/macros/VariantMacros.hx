package godot.macros;

#if macro

import godot.Types;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import godot.macros.ArgumentMacros;
import godot.macros.PostInitMacros;
import haxe.macro.ComplexTypeTools;


class VariantMacros {
    macro static public function build():Array<haxe.macro.Field> {
        var cls = Context.getLocalClass();
        var fields = Context.getBuildFields();

        var cls = macro class {
            // BOOL
            @:from inline public static function fromBool(_x:Bool):Variant return _buildVariant(GDExtensionVariantType.BOOL, _x);
            @:to inline public function toBool():Bool ${_convertToNative(GDExtensionVariantType.BOOL, macro : Bool, macro false)}

            // INT
            @:from inline public static function fromInt64(_x:haxe.Int64):Variant
                return _buildVariant(GDExtensionVariantType.INT, _x);
            @:from inline public static function fromInt(_x:Int):Variant {
                var tmp = haxe.Int64.ofInt(_x);
                return _buildVariant(GDExtensionVariantType.INT, tmp);
            }
            @:to inline public function toInt():cpp.Int64 ${_convertToNative(GDExtensionVariantType.INT, macro : cpp.Int64, macro 0)}

            // FLOAT
            @:from inline public static function fromFloat(_x:Float):Variant
                return _buildVariant(GDExtensionVariantType.FLOAT, _x);
            @:to inline public function toFloat():Float ${_convertToNative(GDExtensionVariantType.FLOAT, macro : Float, macro 0.0)}

            // STRING
            @:from inline public static function fromGDString(_x:godot.variant.GDString):Variant
                return _buildVariant2(GDExtensionVariantType.STRING, _x.native_ptr());
            @:to inline public function toGDString():godot.variant.GDString ${_convertTo(GDExtensionVariantType.STRING, macro : godot.variant.GDString, macro new godot.variant.GDString())}

            @:from inline public static function fromString(_x:String):Variant
                return fromGDString((_x:GDString));
            @:to inline public function toString():String
                return (toGDString():String);

            // ARRAY
            @:from inline static function fromGDArray(_x:godot.variant.GDArray):Variant
                return _buildVariant2(GDExtensionVariantType.ARRAY, _x.native_ptr());

            // Vector2
            @:from inline static function fromVector2(_x:godot.variant.Vector2):Variant
                return _buildVariant2(GDExtensionVariantType.VECTOR2, _x.native_ptr());
            
            // Vector3
            @:from inline static function fromVector3(_x:godot.variant.Vector3):Variant
                return _buildVariant2(GDExtensionVariantType.VECTOR3, _x.native_ptr());
            @:to inline public function toVector3():godot.variant.Vector3 ${_convertToCustom(GDExtensionVariantType.VECTOR3, macro : godot.variant.Vector3, macro new godot.variant.Vector3(), macro cpp.NativeArray.address(res, 0))}

            // Transform2D
            @:from inline static function fromTransform2D(_x:godot.variant.Transform2D):Variant
                return _buildVariant2(GDExtensionVariantType.TRANSFORM2D, _x.native_ptr());
            
            // AABB
            @:from inline static function fromAABB(_x:godot.variant.AABB):Variant
                return _buildVariant2(GDExtensionVariantType.AABB, _x.native_ptr());
            
            // Basis
            @:from inline static function fromBasis(_x:godot.variant.Basis):Variant
                return _buildVariant2(GDExtensionVariantType.BASIS, _x.native_ptr());
            
            // Transform3D
            @:from inline static function fromTransform3D(_x:godot.variant.Transform3D):Variant
                return _buildVariant2(GDExtensionVariantType.TRANSFORM3D, _x.native_ptr());
            
            // StringName
            @:from inline static function fromStringName(_x:godot.variant.StringName):Variant
                return _buildVariant2(GDExtensionVariantType.STRING_NAME, _x.native_ptr());
            
            // NodePath
            @:from inline static function fromNodePath(_x:godot.variant.NodePath):Variant
                return _buildVariant2(GDExtensionVariantType.NODE_PATH, _x.native_ptr());
            
            // RID
            @:from inline static function fromRID(_x:godot.variant.RID):Variant
                return _buildVariant2(GDExtensionVariantType.RID, _x.native_ptr());

            // Object
            @:from inline static function fromObject(_x:godot.Object):Variant
                return _buildVariant2(GDExtensionVariantType.OBJECT, _x.native_ptr());
            @:to inline public function toObject():godot.Object ${_convertTo(GDExtensionVariantType.OBJECT, macro : godot.Object, macro Type.createEmptyInstance(godot.Object))}

            // Callable
            @:from inline static function fromCallable(_x:godot.variant.Callable):Variant
                return _buildVariant2(GDExtensionVariantType.CALLABLE, _x.native_ptr());
            @:to inline public function toCallable():godot.variant.Callable ${_convertTo(GDExtensionVariantType.CALLABLE, macro : godot.variant.Callable, macro new godot.variant.Callable())}

            // Signal
            @:from inline static function fromSignal(_x:godot.variant.Signal):Variant
                return _buildVariant2(GDExtensionVariantType.SIGNAL, _x.native_ptr());

            // Dictionary
            @:from inline static function fromDictionary(_x:godot.variant.Dictionary):Variant
                return _buildVariant2(GDExtensionVariantType.DICTIONARY, _x.native_ptr());

            // PackedByteArray
            @:from inline static function fromPackedByteArray(_x:godot.variant.PackedByteArray):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_BYTE_ARRAY, _x.native_ptr());

            // PackedInt32Array
            @:from inline static function fromPackedInt32Array(_x:godot.variant.PackedInt32Array):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_INT32_ARRAY, _x.native_ptr());

            // PackedInt64Array
            @:from inline static function fromPackedInt64Array(_x:godot.variant.PackedInt64Array):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_INT64_ARRAY, _x.native_ptr());
            
            // PackedFloat32Array
            @:from inline static function fromPackedFloat32Array(_x:godot.variant.PackedFloat32Array):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_FLOAT32_ARRAY, _x.native_ptr());
            @:to inline public function toPackedFloat32Array():godot.variant.PackedFloat32Array ${_convertTo(GDExtensionVariantType.PACKED_FLOAT32_ARRAY, macro : godot.variant.PackedFloat32Array, macro new godot.variant.PackedFloat32Array())}

            // PackedFloat64Array
            @:from inline static function fromPackedFloat64Array(_x:godot.variant.PackedFloat64Array):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_FLOAT64_ARRAY, _x.native_ptr());

            // PackedStringArray
            @:from inline static function fromPackedStringArray(_x:godot.variant.PackedStringArray):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_STRING_ARRAY, _x.native_ptr());

            // PackedVector2Array
            @:from inline static function fromPackedVector2Array(_x:godot.variant.PackedVector2Array):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_VECTOR2_ARRAY, _x.native_ptr());

            // PackedVector3Array
            @:from inline static function fromPackedVector3Array(_x:godot.variant.PackedVector3Array):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_VECTOR3_ARRAY, _x.native_ptr());

            // PackedColorArray
            @:from inline static function fromPackedColorArray(_x:godot.variant.PackedColorArray):Variant
                return _buildVariant2(GDExtensionVariantType.PACKED_COLOR_ARRAY, _x.native_ptr());
        };
        fields = fields.concat(cls.fields);
        return fields;
    }

    // use this for native types
    static function _convertToNative(_extType, _type, _defaultValue) {
        return macro {
            var type = this.getVariantType();
            var res:$_type = $_defaultValue;
            if (__Variant._canConvert(type, $v{_extType})) {
                var constructor = __Variant.to_type_constructor.get($v{_extType});
                untyped __cpp__('((GDExtensionTypeFromVariantConstructorFunc){0})({1}, {2});',
                    constructor,
                    cpp.Native.addressOf(res),
                    this.native_ptr()
                );
            } else  {
                trace("Cannot cast "+ __Variant.getGDExtensionVariantTypeString(type) + " to " + __Variant.getGDExtensionVariantTypeString($v{_extType}), true);
            }
            return res;
        };
    }

    // use this for our custom built-ins
    static function _convertToCustom(_extType, _type, _defaultValue, _resPtr) {
        return macro {
            var type = this.getVariantType();
            var res:$_type = $_defaultValue;
            var resPtr = $_resPtr;
            if (__Variant._canConvert(type, $v{_extType})) {
                var constructor = __Variant.to_type_constructor.get($v{_extType});
                untyped __cpp__('((GDExtensionTypeFromVariantConstructorFunc){0})({1}, {2});',
                    constructor,
                    resPtr,
                    this.native_ptr()
                );
            } else  {
                trace("Cannot cast "+ __Variant.getGDExtensionVariantTypeString(type) + " to " + __Variant.getGDExtensionVariantTypeString($v{_extType}), true);
            }
            return res;
        };
    }

    // use this for all normal binding classes 
    static function _convertTo(_extType, _type, _defaultValue) {
        return macro {
            var type = this.getVariantType();
            var res:$_type = $_defaultValue;
            var resPtr:godot.Types.GDExtensionTypePtr = res.native_ptr();
            if (__Variant._canConvert(type, $v{_extType})) {
                var constructor = __Variant.to_type_constructor.get($v{_extType});
                untyped __cpp__('((GDExtensionTypeFromVariantConstructorFunc){0})({1}, {2});',
                    constructor,
                    resPtr,
                    this.native_ptr()
                );
            } else  {
                trace("Cannot cast "+ __Variant.getGDExtensionVariantTypeString(type) + " to " + __Variant.getGDExtensionVariantTypeString($v{_extType}), true);
            }
            return res;
        };
    }
}

#end