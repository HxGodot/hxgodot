package godot.macros;

#if macro

import godot.Types;
import godot.variant.Vector3;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;

using haxe.macro.ExprTools;

class ArgumentMacros {
    static var ptrSize = Context.defined("HXCPP_M64") ? "int64_t" : "int32_t";

    public static function convert(_index:Int, _args:String, _type:haxe.macro.ComplexType) {
        return _convert(_index, 0, _args, _type);
    }

    public static function convertVariant(_index:Int, _args:String, _type:haxe.macro.ComplexType) {
        var type = ComplexTypeTools.toType(_type);
        var isWrappedGodotClass = Context.unify(type, Context.getType("godot.Wrapped"));
        
        function _default() {

            var identBindings = getIdentBindingCallbacks(type);

            var ret = isWrappedGodotClass ? macro {
                    var constructor = godot.variant.Variant.__Variant.to_type_constructor.get(godot.Types.GDExtensionVariantType.OBJECT);
                    var retOriginal:godot.Types.StarVoidPtr = untyped __cpp__('nullptr');
                    var _hx__ret:godot.Types.StarVoidPtr = untyped __cpp__('&{0}', retOriginal);
                    untyped __cpp__('((GDExtensionTypeFromVariantConstructorFunc){0})({1}, {2});',
                        (constructor:godot.Types.StarVoidPtr),
                        _hx__ret,
                        variant.native_ptr()
                    );
                    var obj = godot.Types.GodotNativeInterface.object_get_instance_binding(
                        retOriginal,
                        untyped __cpp__("godot::internal::token"), 
                        untyped __cpp__($v{identBindings})
                    );
                    res = untyped __cpp__(
                        $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                        obj.ptr
                    );
                } : 
                    macro res = (variant:$_type);

            return macro {
                var res:Dynamic = null;
                if ($i{_args} != null) {
                    var variant = new godot.variant.Variant();
                    var ptr:godot.Types.GDExtensionVariantPtr = untyped __cpp__('(uint8_t *)(*((({0} **){1})+{2}))', 
                        $i{ptrSize},
                        $i{_args}.ptr,
                        $v{_index}
                    );
                    variant.set_native_ptr(ptr);
                    $ret;
                } else
                    res;
            };
        }
        return switch(_type) {
            case TPath(_d):
                if (TypeMacros.isACustomBuiltIn(_d.name))
                    _convert(_index, 1, _args, _type);
                else
                    _default();                
            default: _default();
        };
    }    

    private static function _convert(_index:Int, _offset:Int, _args:String, _type:haxe.macro.ComplexType) {
        var typePath = switch(_type) {
            case TPath(_d): _d.name;
            default: "";
        };

        function _default() {
            var val = 'nullptr /* _convert: $_type */';
            return macro { untyped __cpp__($v{val}); };
        }
        inline function _create(_inst, _size) {
            return macro {
                var p = $_inst;
                (untyped __cpp__(
                    'memcpy({4}->opaque, (uint8_t *)(*((({0} **){1})+{2})+{3}), {5})',
                    $i{ptrSize},
                    $i{_args}.ptr,
                    $v{_index},
                    $v{_offset},
                    p,
                    $_size
                ));
                p;
            };
        }

        inline function _createObject(_inst, _size) {
            var identBindings = '&${typePath}_obj::___binding_callbacks';
            return macro {
                var retOriginal:godot.Types.StarVoidPtr = untyped __cpp__('nullptr');
                var obj = godot.Types.GodotNativeInterface.object_get_instance_binding(
                    retOriginal, 
                    untyped __cpp__("godot::internal::token"), 
                    untyped __cpp__($v{identBindings})
                );
                retOriginal;
            };
        }

        return _type != null ? switch(_type) {
            case TPath(_d):
                switch(_d.name) {
                    case 'Bool': macro { (untyped __cpp__('*(bool *)(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):Bool); }
                    case 'Int', 'Int64': macro { (untyped __cpp__('(int64_t)*(int32_t *)(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):Int); }
                    case 'Float': macro { (untyped __cpp__('*(double *)(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):Float); }
                    case 'GDString': macro {
                        var str = new GDString();
                        (untyped __cpp__(
                            'memcpy({4}->opaque, (uint8_t *)(*((({0} **){1})+{2})+{3}), {5})',
                            $i{ptrSize},
                            $i{_args}.ptr,
                            $v{_index},
                            $v{_offset},
                            str,
                            GDString.STRING_SIZE
                        ));
                        str;
                    }
                    case 'Vector2', 'Point2':
                        macro { 
                            var v:Array<godot.Types.GDExtensionFloat> = cpp.NativeArray.create(2);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):cpp.Star<godot.Types.GDExtensionFloat>),
                                untyped __cpp__('sizeof(float)*2')
                            );
                            v;
                        }; 
                    case 'Vector3':
                        macro { 
                            var v:Array<godot.Types.GDExtensionFloat> = cpp.NativeArray.create(3);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):cpp.Star<godot.Types.GDExtensionFloat>),
                                untyped __cpp__('sizeof(float)*3')
                            );
                            v;
                        };
                    case 'Color', 'Quaternion', 'Vector4':
                        macro { 
                            var v:Array<godot.Types.GDExtensionFloat> = cpp.NativeArray.create(4);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):cpp.Star<godot.Types.GDExtensionFloat>),
                                untyped __cpp__('sizeof(float)*4')
                            );
                            v;
                        };
                    case 'Vector2i':
                        macro { 
                            var v:Array<Int> = cpp.NativeArray.create(2);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):cpp.Star<Int>),
                                untyped __cpp__('sizeof(int)*2')
                            );
                            v;
                        };
                    case 'Vector3i':
                        macro { 
                            var v:Array<Int> = cpp.NativeArray.create(3);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):cpp.Star<Int>),
                                untyped __cpp__('sizeof(int)*3')
                            );
                            v;
                        };
                    case 'Vector4i':
                        macro { 
                            var v:Array<Int> = cpp.NativeArray.create(4);
                            var d = cpp.NativeArray.address(v, 0);
                            cpp.Native.memcpy(
                                d,
                                (untyped __cpp__('(*((({0} **){1})+{2})+{3})', $i{ptrSize}, $i{_args}.ptr, $v{_index}, $v{_offset}):cpp.Star<Int>),
                                untyped __cpp__('sizeof(int)*4')
                            );
                            v;
                        }; 
                    case 'AABB': _create(macro new godot.variant.AABB(), macro godot.variant.AABB.AABB_SIZE);
                    case 'Rect2': _create(macro new godot.variant.Rect2(), macro godot.variant.Rect2.RECT2_SIZE);
                    case 'Rect2i': _create(macro new godot.variant.Rect2i(), macro godot.variant.Rect2i.RECT2I_SIZE);
                    case 'Basis': _create(macro new godot.variant.Basis(), macro godot.variant.Basis.BASIS_SIZE);
                    case 'Callable': _create(macro new godot.variant.Callable(), macro godot.variant.Callable.CALLABLE_SIZE);
                    case 'Dictionary': _create(macro new godot.variant.Dictionary(), macro godot.variant.Dictionary.DICTIONARY_SIZE);
                    case 'GDArray': _create(macro new godot.variant.GDArray(), macro godot.variant.GDArray.ARRAY_SIZE);
                    case 'NodePath': _create(macro new godot.variant.NodePath(), macro godot.variant.NodePath.NODEPATH_SIZE);
                    case 'PackedByteArray': _create(macro new godot.variant.PackedByteArray(), macro godot.variant.PackedByteArray.PACKEDBYTEARRAY_SIZE);
                    case 'PackedColorArray': _create(macro new godot.variant.PackedColorArray(), macro godot.variant.PackedColorArray.PACKEDCOLORARRAY_SIZE);
                    case 'PackedFloat32Array': _create(macro new godot.variant.PackedFloat32Array(), macro godot.variant.PackedFloat32Array.PACKEDFLOAT32ARRAY_SIZE);
                    case 'PackedFloat64Array': _create(macro new godot.variant.PackedFloat64Array(), macro godot.variant.PackedFloat64Array.PACKEDFLOAT64ARRAY_SIZE);
                    case 'PackedInt32Array': _create(macro new godot.variant.PackedInt32Array(), macro godot.variant.PackedInt32Array.PACKEDINT32ARRAY_SIZE);
                    case 'PackedInt64Array': _create(macro new godot.variant.PackedInt64Array(), macro godot.variant.PackedInt64Array.PACKEDINT64ARRAY_SIZE);
                    case 'PackedStringArray': _create(macro new godot.variant.PackedStringArray(), macro godot.variant.PackedStringArray.PACKEDSTRINGARRAY_SIZE);
                    case 'PackedVector2Array': _create(macro new godot.variant.PackedVector2Array(), macro godot.variant.PackedVector2Array.PACKEDVECTOR2ARRAY_SIZE);
                    case 'PackedVector3Array': _create(macro new godot.variant.PackedVector3Array(), macro godot.variant.PackedVector3Array.PACKEDVECTOR3ARRAY_SIZE);
                    case 'Projection': _create(macro new godot.variant.Projection(), macro godot.variant.Projection.PROJECTION_SIZE);
                    case 'RID': _create(macro new godot.variant.RID(), macro godot.variant.RID.RID_SIZE);
                    case 'Object': _createObject(macro new godot.variant.Object(), macro godot.variant.OBJECT.OBJECT_SIZE);
                    case 'Signal': _create(macro new godot.variant.Signal(), macro godot.variant.Signal.SIGNAL_SIZE);
                    case 'StringName': _create(macro new godot.variant.StringName(), macro godot.variant.StringName.STRINGNAME_SIZE);
                    case 'Transform2D': _create(macro new godot.variant.Transform2D(), macro godot.variant.Transform2D.TRANSFORM2D_SIZE);
                    case 'Transform3D': _create(macro new godot.variant.Transform3D(), macro godot.variant.Transform3D.TRANSFORM3D_SIZE);

                    default: {
                        var ctType = Context.followWithAbstracts(haxe.macro.ComplexTypeTools.toType(_type));
                        var isRefCounted = switch (ctType) {
                            case TInst(_classType, _): _classType.get().meta.has(":gdRefCounted");
                            default: false;
                        }

                        var identBindings = getIdentBindingCallbacks(ctType);
                        macro {
                            // managed types need a pointer indirection
                            var retOriginal:godot.Types.StarVoidPtr = 
                                untyped __cpp__('(const GDExtensionObjectPtr)*(({0}**){1})[{2}]', $i{ptrSize}, $i{_args}.ptr, $v{_index});

                            var obj = godot.Types.GodotNativeInterface.object_get_instance_binding(
                                retOriginal, 
                                untyped __cpp__("godot::internal::token"), 
                                untyped __cpp__($v{identBindings})
                            );

                            var instance:$_type = untyped __cpp__(
                                    $v{"::godot::Wrapped( (hx::Object*)(((cpp::utils::RootedObject*){0})->getObject()) )"}, // TODO: this is a little hacky!
                                    obj.ptr
                                );

                            if ($v{isRefCounted} == true)
                                untyped instance.reference();

                            instance;
                        }
                    }
                }
            default: _default();
        } : _default();
    }

    public static function encode(_type:haxe.macro.ComplexType, _dest:String, _src:String) {
        function _default() {
            var val = 'nullptr /* encode: $_type */';
            return macro { untyped __cpp__($v{val}); };
        }

        inline function _encode(_size) {
            return macro untyped __cpp__('memcpy((void*){0}, (void*){1}, {2})', $i{_dest}.ptr, $i{_src}.native_ptr(), $_size);
        }

        return _type != null ? switch(_type) {
            case TPath(_d):
                switch(_d.name) {
                    case 'Bool': macro (untyped __cpp__('*((bool*){0}) = {1}', $i{_dest}.ptr, $i{_src}):Bool);
                    case 'Int': macro {
                        var tmp = haxe.Int64.ofInt($i{_src});
                        (untyped __cpp__('*((int64_t*){0}) = {1}', $i{_dest}.ptr, tmp):Int); 
                    }
                    case 'Int64': macro (untyped __cpp__('*((int64_t*){0}) = {1}', $i{_dest}.ptr, $i{_src}):haxe.Int64);
                    case 'Float': macro (untyped __cpp__('*((double*){0}) = {1}', $i{_dest}.ptr, $i{_src}):Float);
                    case 'GDString': macro untyped __cpp__('memcpy((void*){0}, (void*){1}, {2})', $i{_dest}.ptr, $i{_src}.native_ptr(), godot.variant.GDString.STRING_SIZE);
                    case 'Color', 'Quaternion', 'Vector4': macro untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(float)*4)', $i{_dest}.ptr, cpp.NativeArray.address($i{_src}, 0));
                    case 'Vector2': macro untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(float)*2)', $i{_dest}.ptr, cpp.NativeArray.address($i{_src}, 0));
                    case 'Vector3': macro untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(float)*3)', $i{_dest}.ptr, cpp.NativeArray.address($i{_src}, 0));
                    case 'Vector2i': macro untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(int)*2)', $i{_dest}.ptr, cpp.NativeArray.address($i{_src}, 0));
                    case 'Vector3i': macro untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(int)*3)', $i{_dest}.ptr, cpp.NativeArray.address($i{_src}, 0));
                    case 'Vector4i': macro untyped __cpp__('memcpy((void*){0}, (void*){1}, sizeof(int)*4)', $i{_dest}.ptr, cpp.NativeArray.address($i{_src}, 0));
                    case "Rect2": _encode(macro godot.variant.Rect2.RECT2_SIZE);
                    case "Rect2i": _encode(macro godot.variant.Rect2i.RECT2I_SIZE);
                    case "AABB": _encode(macro godot.variant.AABB.AABB_SIZE);
                    case "Basis": _encode(macro godot.variant.Basis.BASIS_SIZE);
                    case "Callable": _encode(macro godot.variant.Callable.CALLABLE_SIZE);
                    case "Dictionary": _encode(macro godot.variant.Dictionary.DICTIONARY_SIZE);
                    case "GDArray": _encode(macro godot.variant.GDArray.ARRAY_SIZE);
                    case "NodePath": _encode(macro godot.variant.NodePath.NODEPATH_SIZE);
                    case "PackedByteArray": _encode(macro godot.variant.PackedByteArray.PACKEDBYTEARRAY_SIZE);
                    case "PackedColorArray": _encode(macro godot.variant.PackedColorArray.PACKEDCOLORARRAY_SIZE);
                    case "PackedFloat32Array": _encode(macro godot.variant.PackedFloat32Array.PACKEDFLOAT32ARRAY_SIZE);
                    case "PackedFloat64Array": _encode(macro godot.variant.PackedFloat64Array.PACKEDFLOAT64ARRAY_SIZE);
                    case "PackedInt32Array": _encode(macro godot.variant.PackedInt32Array.PACKEDINT32ARRAY_SIZE);
                    case "PackedInt64Array": _encode(macro godot.variant.PackedInt64Array.PACKEDINT64ARRAY_SIZE);
                    case "PackedStringArray": _encode(macro godot.variant.PackedStringArray.PACKEDSTRINGARRAY_SIZE);
                    case "PackedVector2Array": _encode(macro godot.variant.PackedVector2Array.PACKEDVECTOR2ARRAY_SIZE);
                    case "PackedVector3Array": _encode(macro godot.variant.PackedVector3Array.PACKEDVECTOR3ARRAY_SIZE);
                    case "Projection": _encode(macro godot.variant.Projection.PROJECTION_SIZE);
                    case "RID": _encode(macro godot.variant.RID.RID_SIZE);
                    case "Object": _encode(macro godot.variant.OBJECT.OBJECT_SIZE);
                    case "Signal": _encode(macro godot.variant.Signal.SIGNAL_SIZE);
                    case "StringName": _encode(macro godot.variant.StringName.STRINGNAME_SIZE);
                    case "Transform2D": _encode(macro godot.variant.Transform2D.TRANSFORM2D_SIZE);
                    case "Transform3D": _encode(macro godot.variant.Transform3D.TRANSFORM3D_SIZE);
                    default: _default();
                }
            default: _default();
        } : _default();
    }

    inline public static function getIdentBindingCallbacks(_ctType:haxe.macro.Type):String {
        // assemble the cpp type for the identbinding so a proper typed instance can be created / mapped
        var tClassName = "";
        var path = switch(_ctType) {
            case TInst(_t, _): tClassName = _t.get().name; _t.get().pack;
            case TAbstract(_t, _): tClassName = _t.get().name; _t.get().pack;
            default: Context.fatalError('Error: ${_ctType} is not dealt with in ArgumentMacros. Please report this type so we can fix!', Context.currentPos()); null;
        }
        path.push(tClassName);

        return '&::${path.join("::")}_obj::___binding_callbacks';
    }

    public static function prepareArgumentDefaultValue(_argType:String, _defVal:String):String {
        if (_defVal.length == 0) // empty string, wtf
            _defVal = "\"\"";
        if (_argType == "cpp.Int64" && _defVal.length >= 10)
            _defVal = 'cast ($_defVal)';
        return _defVal;
    }

    public static function guardAgainstKeywords(_str:String):String {
        return switch(_str) {
            case    "in",
                    "operator",
                    "implements",
                    "extends",
                    "function",
                    "var",
                    "if",
                    "else",
                    "while",
                    "do",
                    "for",
                    "break",
                    "return",
                    "continue",
                    "switch",
                    "case",
                    "default",
                    "try",
                    "catch",
                    "new",
                    "throw",
                    "untyped",
                    "cast",
                    "macro",
                    "package",
                    "import",
                    "using",
                    "public",
                    "private",
                    "static",
                    "extern",
                    "dynamic",
                    "override",
                    "overload",
                    "class",
                    "interface",
                    "enum",
                    "abstract",
                    "typedef",
                    "final",
                    "inline",
                    "char": 'gd_$_str';
            default: _str;
        }
    }
}

#end