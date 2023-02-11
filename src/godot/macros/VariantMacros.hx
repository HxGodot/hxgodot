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
            @:from inline public static function fromCppInt64(_x:cpp.Int64):Variant
                return _buildVariant(GDExtensionVariantType.INT, _x);
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
            @:from inline public static function fromGDString(_x:godot.variant.GDString):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.STRING, _x.native_ptr()) : null;
            }
            @:to inline public function toGDString():godot.variant.GDString ${_convertTo(GDExtensionVariantType.STRING, macro : godot.variant.GDString, macro new godot.variant.GDString())}

            @:from inline public static function fromString(_x:String):Variant
                return fromGDString((_x:GDString));
            @:to inline public function toString():String
                return (toGDString():String);

            // ARRAY
            @:from inline static function fromGDArray(_x:godot.variant.GDArray):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toGDArray():godot.variant.GDArray ${_convertTo(GDExtensionVariantType.ARRAY, macro : godot.variant.GDArray, macro new godot.variant.GDArray())}

            // Vector2
            @:from inline static function fromVector2(_x:godot.variant.Vector2):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.VECTOR2, _x.native_ptr()) : null;
            }
            @:to inline public function toVector2():godot.variant.Vector2 ${_convertToCustom(GDExtensionVariantType.VECTOR2, macro : godot.variant.Vector2, macro new godot.variant.Vector2(), macro cpp.NativeArray.address(res, 0))}

            // Vector2i
            @:from inline static function fromVector2i(_x:godot.variant.Vector2i):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.VECTOR2I, _x.native_ptr()) : null;
            }
            @:to inline public function toVector2i():godot.variant.Vector2i ${_convertToCustom(GDExtensionVariantType.VECTOR2I, macro : godot.variant.Vector2i, macro new godot.variant.Vector2i(), macro cpp.NativeArray.address(res, 0))}
            
            // Vector3
            @:from inline static function fromVector3(_x:godot.variant.Vector3):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.VECTOR3, _x.native_ptr()) : null;
            }
            @:to inline public function toVector3():godot.variant.Vector3 ${_convertToCustom(GDExtensionVariantType.VECTOR3, macro : godot.variant.Vector3, macro new godot.variant.Vector3(), macro cpp.NativeArray.address(res, 0))}

            // Vector3i
            @:from inline static function fromVector3i(_x:godot.variant.Vector3i):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.VECTOR3I, _x.native_ptr()) : null;
            }
            @:to inline public function toVector3i():godot.variant.Vector3i ${_convertToCustom(GDExtensionVariantType.VECTOR3I, macro : godot.variant.Vector3i, macro new godot.variant.Vector3i(), macro cpp.NativeArray.address(res, 0))}

            // Vector4
            @:from inline static function fromVector4(_x:godot.variant.Vector4):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.VECTOR4, _x.native_ptr()) : null;
            }
            @:to inline public function toVector4():godot.variant.Vector4 ${_convertToCustom(GDExtensionVariantType.VECTOR4, macro : godot.variant.Vector4, macro new godot.variant.Vector4(), macro cpp.NativeArray.address(res, 0))}

            // Vector4i
            @:from inline static function fromVector4i(_x:godot.variant.Vector4i):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.VECTOR4I, _x.native_ptr()) : null;
            }
            @:to inline public function toVector4i():godot.variant.Vector4i ${_convertToCustom(GDExtensionVariantType.VECTOR4I, macro : godot.variant.Vector4i, macro new godot.variant.Vector4i(), macro cpp.NativeArray.address(res, 0))}

            // Transform2D
            @:from inline static function fromTransform2D(_x:godot.variant.Transform2D):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.TRANSFORM2D, _x.native_ptr()) : null;
            }
            @:to inline public function toTransform2D():godot.variant.Transform2D ${_convertTo(GDExtensionVariantType.TRANSFORM2D, macro : godot.variant.Transform2D, macro new godot.variant.Transform2D())}
            
            // AABB
            @:from inline static function fromAABB(_x:godot.variant.AABB):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.AABB, _x.native_ptr()) : null;
            }
            @:to inline public function toAABB():godot.variant.AABB ${_convertTo(GDExtensionVariantType.AABB, macro : godot.variant.AABB, macro new godot.variant.AABB())}
            
            // Basis
            @:from inline static function fromBasis(_x:godot.variant.Basis):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.BASIS, _x.native_ptr()) : null;
            }
            @:to inline public function toBasis():godot.variant.Basis ${_convertTo(GDExtensionVariantType.BASIS, macro : godot.variant.Basis, macro new godot.variant.Basis())}
            
            // Transform3D
            @:from inline static function fromTransform3D(_x:godot.variant.Transform3D):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.TRANSFORM3D, _x.native_ptr()) : null;
            }
            @:to inline public function toTransform3D():godot.variant.Transform3D ${_convertTo(GDExtensionVariantType.TRANSFORM3D, macro : godot.variant.Transform3D, macro new godot.variant.Transform3D())}
            
            // StringName
            @:from inline static function fromStringName(_x:godot.variant.StringName):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.STRING_NAME, _x.native_ptr()) : null;
            }
            @:to inline public function toStringName():godot.variant.StringName ${_convertTo(GDExtensionVariantType.STRING_NAME, macro : godot.variant.StringName, macro new godot.variant.StringName())}
            
            // NodePath
            @:from inline static function fromNodePath(_x:godot.variant.NodePath):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.NODE_PATH, _x.native_ptr()) : null;
            }
            @:to inline public function toNodePath():godot.variant.NodePath ${_convertTo(GDExtensionVariantType.NODE_PATH, macro : godot.variant.NodePath, macro new godot.variant.NodePath())}
            
            // RID
            @:from inline static function fromRID(_x:godot.variant.RID):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.RID, _x.native_ptr()) : null;
            }
            @:to inline public function toRID():godot.variant.RID ${_convertTo(GDExtensionVariantType.RID, macro : godot.variant.RID, macro new godot.variant.RID())}

            // Object
            @:from inline static function fromObject(_x:godot.Object):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariantObject(GDExtensionVariantType.OBJECT, _x.native_ptr()) : null;
            }
            @:to inline public function toObject():godot.Object ${_convertToObject(GDExtensionVariantType.OBJECT, macro : godot.Object, macro new godot.Object())}

            // Callable
            @:from inline static function fromCallable(_x:godot.variant.Callable):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.CALLABLE, _x.native_ptr()) : null;
            }
            @:to inline public function toCallable():godot.variant.Callable ${_convertTo(GDExtensionVariantType.CALLABLE, macro : godot.variant.Callable, macro new godot.variant.Callable())}

            // Signal
            @:from inline static function fromSignal(_x:godot.variant.Signal):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.SIGNAL, _x.native_ptr()) : null;
            }
            @:to inline public function toSignal():godot.variant.Signal ${_convertTo(GDExtensionVariantType.SIGNAL, macro : godot.variant.Signal, macro new godot.variant.Signal())}

            // Dictionary
            @:from inline static function fromDictionary(_x:godot.variant.Dictionary):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.DICTIONARY, _x.native_ptr()) : null;
            }
            @:to inline public function toDictionary():godot.variant.Dictionary ${_convertTo(GDExtensionVariantType.DICTIONARY, macro : godot.variant.Dictionary, macro new godot.variant.Dictionary())}

            // PackedByteArray
            @:from inline static function fromPackedByteArray(_x:godot.variant.PackedByteArray):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_BYTE_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedByteArray():godot.variant.PackedByteArray ${_convertTo(GDExtensionVariantType.PACKED_BYTE_ARRAY, macro : godot.variant.PackedByteArray, macro new godot.variant.PackedByteArray())}

            // PackedInt32Array
            @:from inline static function fromPackedInt32Array(_x:godot.variant.PackedInt32Array):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_INT32_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedInt32Array():godot.variant.PackedInt32Array ${_convertTo(GDExtensionVariantType.PACKED_INT32_ARRAY, macro : godot.variant.PackedInt32Array, macro new godot.variant.PackedInt32Array())}

            // PackedInt64Array
            @:from inline static function fromPackedInt64Array(_x:godot.variant.PackedInt64Array):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_INT64_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedInt64Array():godot.variant.PackedInt64Array ${_convertTo(GDExtensionVariantType.PACKED_INT64_ARRAY, macro : godot.variant.PackedInt64Array, macro new godot.variant.PackedInt64Array())}
            
            // PackedFloat32Array
            @:from inline static function fromPackedFloat32Array(_x:godot.variant.PackedFloat32Array):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_FLOAT32_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedFloat32Array():godot.variant.PackedFloat32Array ${_convertTo(GDExtensionVariantType.PACKED_FLOAT32_ARRAY, macro : godot.variant.PackedFloat32Array, macro new godot.variant.PackedFloat32Array())}

            // PackedFloat64Array
            @:from inline static function fromPackedFloat64Array(_x:godot.variant.PackedFloat64Array):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_FLOAT64_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedFloat64Array():godot.variant.PackedFloat64Array ${_convertTo(GDExtensionVariantType.PACKED_FLOAT64_ARRAY, macro : godot.variant.PackedFloat64Array, macro new godot.variant.PackedFloat64Array())}

            // PackedStringArray
            @:from inline static function fromPackedStringArray(_x:godot.variant.PackedStringArray):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_STRING_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedStringArray():godot.variant.PackedStringArray ${_convertTo(GDExtensionVariantType.PACKED_STRING_ARRAY, macro : godot.variant.PackedStringArray, macro new godot.variant.PackedStringArray())}

            // PackedVector2Array
            @:from inline static function fromPackedVector2Array(_x:godot.variant.PackedVector2Array):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_VECTOR2_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedVector2Array():godot.variant.PackedVector2Array ${_convertTo(GDExtensionVariantType.PACKED_VECTOR2_ARRAY, macro : godot.variant.PackedVector2Array, macro new godot.variant.PackedVector2Array())}

            // PackedVector3Array
            @:from inline static function fromPackedVector3Array(_x:godot.variant.PackedVector3Array):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_VECTOR3_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedVector3Array():godot.variant.PackedVector3Array ${_convertTo(GDExtensionVariantType.PACKED_VECTOR3_ARRAY, macro : godot.variant.PackedVector3Array, macro new godot.variant.PackedVector3Array())}

            // PackedColorArray
            @:from inline static function fromPackedColorArray(_x:godot.variant.PackedColorArray):Variant {
                return (untyped __cpp__('{0}.mPtr != nullptr', _x)) ?
                    _buildVariant2(GDExtensionVariantType.PACKED_COLOR_ARRAY, _x.native_ptr()) : null;
            }
            @:to inline public function toPackedColorArray():godot.variant.PackedColorArray ${_convertTo(GDExtensionVariantType.PACKED_COLOR_ARRAY, macro : godot.variant.PackedColorArray, macro new godot.variant.PackedColorArray())}
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
            } else if ($v{_extType} == GDExtensionVariantType.STRING) {
                godot.Types.GodotNativeInterface.variant_stringify(this.native_ptr(), resPtr);
            } else {
                trace("Cannot cast "+ __Variant.getGDExtensionVariantTypeString(type) + " to " + __Variant.getGDExtensionVariantTypeString($v{_extType}), true);
            }
            return res;
        };
    }

    static function _convertToObject(_extType, _type, _defaultValue) {
        var identBindings = '&::godot::Object_obj::___binding_callbacks';
        return macro {
            var type = this.getVariantType();
            var res = null;
            if (__Variant._canConvert(type, $v{_extType})) {
                var constructor = __Variant.to_type_constructor.get($v{_extType});
                var retOriginal:godot.Types.VoidPtr = untyped __cpp__('nullptr');
                var _hx__ret:godot.Types.VoidPtr = untyped __cpp__('&{0}', retOriginal);

                untyped __cpp__('((GDExtensionTypeFromVariantConstructorFunc){0})({1}, {2});',
                    constructor,
                    _hx__ret,
                    this.native_ptr()
                );

                if (retOriginal != null) { // a variant with type Object can be NIL
                    var obj = godot.Types.GodotNativeInterface.object_get_instance_binding(
                        retOriginal, 
                        untyped __cpp__("godot::internal::token"), 
                        untyped __cpp__($v{identBindings})
                    );
                    res = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                        obj
                    );
                }
            } else {
                trace("Cannot cast "+ __Variant.getGDExtensionVariantTypeString(type) + " to " + __Variant.getGDExtensionVariantTypeString($v{_extType}), true);
            }
            return res;
        };
    }
}

#end