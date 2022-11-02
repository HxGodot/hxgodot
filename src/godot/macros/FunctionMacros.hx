package godot.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import godot.macros.TypeMacros;

using StringTools;

enum FunctionBindType {
    CONSTRUCTOR(index:Int);
    DESTRUCTOR;
    METHOD;
    STATIC_METHOD;
    OPERATOR;
    PROPERTY_SET;
    PROPERTY_GET;
    INDEX_SET;
    INDEX_GET;
    VIRTUAL_METHOD;
}

@:structInit
class ClassContext {
    public var name:String;
    @:optional public var abstractName:String;
    public var type:Int;
    public var typePath:TypePath;
    @:optional public var hasDestructor:Bool;
}

@:structInit
class FunctionArgument {
    public var name:String;
    public var type:TypePath;
    @:optional public var defaultValue:Dynamic;
}

@:structInit
class FunctionBind {
    public var clazz:ClassContext;
    public var name:String;
    public var type:FunctionBindType;
    public var returnType:TypePath;
    public var access:Array<Access>;
    public var arguments:Array<FunctionArgument>;
    public var macros:{
        field:Field,
        fieldSetter:String,
        ?extra:Dynamic
    };
}

class FunctionMacros {
    //
    public static function buildConstructorWithAbstract(
        _bind:FunctionBind,
        _index:Int, 
        _fields:Array<Field>, 
        _abstractFields:Array<Field>) 
    {   
        // preprocess the arguments
        var argExprs = [];
        var conCallArgs = [];
        for (i in 0..._bind.arguments.length) {
            var a = _bind.arguments[i];
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});            
            if (TypeMacros.isTypeNative(a.type.name))
                conCallArgs.push({type: '(const GDNativeTypePtr)&', name: argName});
            else
                conCallArgs.push({type: '(const GDNativeTypePtr)', name: '${argName}.native_ptr()'});
        }
        var vArgs = _assembleCallArgs(conCallArgs);

        // add static factory function to class
        var exprs = [];
        if (conCallArgs.length > 0) {
            exprs.push(macro {
                ${vArgs};
                untyped __cpp__('((GDNativePtrConstructor){0})({1}, (const GDNativeTypePtr*)call_args.data());', 
                    $i{"_"+_bind.name},
                    inst.native_ptr()
                );
            });
        } else {
            exprs.push(macro {
                untyped __cpp__('((GDNativePtrConstructor){0})({1}, nullptr);', 
                    $i{"_"+_bind.name},
                    inst.native_ptr()
                );
            });
        }

        // add static factory function to class
        var tpath = _bind.clazz.typePath;
        var destr = _bind.clazz.hasDestructor ? 
            macro cpp.vm.Gc.setFinalizer(inst, cpp.Callable.fromStaticFunction(_destruct)) : macro {};
        _fields.push({
            name: _bind.name,
            access: _bind.access,
            meta: [{name: ':noCompletion', pos: Context.currentPos()}],
            pos: Context.currentPos(),
            kind: FFun({
                args: argExprs,
                expr: macro {
                    var inst = new $tpath();
                    $destr;

                    $b{exprs};

                    return inst;
                },
                params: [],
                ret: TPath(_bind.returnType)
            })
        });

        // forward constructor to abstracts
        if (_index == 0) { // create the plain new constructor
            _abstractFields.push({
                name: "new",
                access: [AInline, APublic],
                pos: Context.currentPos(),
                kind: FFun({
                    args: [],
                    expr: Context.parse('{ this = ${_bind.clazz.name}.${_bind.name}(); }', Context.currentPos()),
                    params: [],
                    ret: TPath(_bind.returnType)
                })
            });
        } else { // create a custom constructor with proper argument forwarding
            var conName = _bind.name;
            var conCallArgs = [];
            
            if (_bind.arguments.length > 0) {
                // apply some basic naming scheme that takes the argument names/types into account
                if (_bind.arguments.length == 1) {
                    conName = "from" + _bind.arguments[0].type.name;
                    conCallArgs.push(_bind.arguments[0].name);
                } else {
                    var tokens = ["from"];
                    for (a in _bind.arguments) {
                        var n = a.name.split("_");
                        tokens.push(n[0].substr(0, 1).toUpperCase() + n[0].substr(1));
                        conCallArgs.push(a.name);
                    }
                    conName = tokens.join("");
                }
            }

            _abstractFields.push({
                name: conName,
                access: [AInline, APublic, AStatic],
                pos: Context.currentPos(),
                kind: FFun({
                    args: argExprs,
                    expr: Context.parse('{ return ${_bind.clazz.name}.${_bind.name}(${conCallArgs.join(",")}); }', Context.currentPos()),
                    params: [],
                    ret: TPath(_bind.returnType)
                })
            });
        }
    }

    // 
    public static function buildDestructor(_bind:FunctionBind, _fields:Array<Field>) {
        _fields.push({
            name: '_destruct',
            access: [AInline, APrivate, AStatic],
            pos: Context.currentPos(),
            meta: [{name: ':noCompletion', pos: Context.currentPos()}],
            kind: FFun({
                args: [{name: '_this', type: TPath(_bind.clazz.typePath)}],
                expr: macro { 
                    untyped __cpp__('((GDNativePtrDestructor){0})({1})', _destructor, _this.native_ptr());
                },
                params: [],
                ret: TPath(_bind.returnType)
            })
        });

        // add an accessible killer function
        _fields.push({
            name: 'destruct',
            access: [AInline, APublic, AStatic],
            pos: Context.currentPos(),
            kind: FFun({
                args: [{name: '_this', type: TPath(_bind.clazz.typePath)}],
                expr: macro {
                    _destruct(_this);
                },
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }

    // 
    public static function buildBuiltInMethod(_bind:FunctionBind, _fields:Array<Field>) {
        var mname = '_method_${_bind.name}';

        // preprocess the arguments
        var argExprs = [];
        var conCallArgs = [];
        for (a in _bind.arguments) {
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});            
            if (TypeMacros.isTypeNative(a.type.name))
                conCallArgs.push({type: '(const GDNativeTypePtr)&', name: argName});
            else
                conCallArgs.push({type: '(const GDNativeTypePtr)', name: '${argName}.native_ptr()'});
        }
        var vArgs = _assembleCallArgs(conCallArgs);

        // now build the function body
        var body = null;
        if (_bind.returnType.name == "Void") {
            var exprs = [];
            if (conCallArgs.length > 0) {
                exprs.push(macro {
                    ${vArgs};
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})({1}, (const GDNativeTypePtr*)call_args.data(), nullptr, {2});', 
                        $i{mname},
                        this.native_ptr(),
                        $v{conCallArgs.length}
                    );
                });
            } else {
                exprs.push(macro {
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})({1}, nullptr, nullptr, 0);', 
                        $i{mname},
                        this.native_ptr()
                    );
                });
            }
            body = macro {
                $b{exprs};
            };
        } else {            
            var typePath = TPath(_bind.returnType);
            var defaultValue = TypeMacros.getNativeTypeDefaultValue(_bind.returnType.name);
            var exprs = [];
            if (conCallArgs.length > 0) {
                exprs.push(macro {
                    ${vArgs};
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})({1}, (const GDNativeTypePtr*)call_args.data(), (GDNativeTypePtr){2}, {3});', 
                        $i{mname},
                        this.native_ptr(),
                        ret,
                        $v{conCallArgs.length}
                    );
                });
            } else {
                exprs.push(macro {
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})({1}, nullptr, (GDNativeTypePtr){2}, 0);', 
                        $i{mname},
                        this.native_ptr(),
                        ret
                    );
                });
            }

            if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                // a native return type
                body = macro {
                    var ret2:$typePath = $v{defaultValue};
                    var ret = cpp.Native.addressOf(ret2);
                    $b{exprs};
                    return ret2;
                };
            } else {
                // // we have a managed return type, create it properly
                var typePath = _bind.returnType;
                body = macro {
                    var ret2 = new $typePath();
                    var ret = ret2.native_ptr();
                    $b{exprs};
                    return ret2;
                };
            }
        }
        _fields.push({
            name: _bind.name,
            access: _bind.access,
            pos: Context.currentPos(),
            kind: FFun({
                args: argExprs,
                expr: body,
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }

    // 
    public static function buildBuiltInStaticMethod(_bind:FunctionBind, _fields:Array<Field>, _abstractFields:Array<Field>) {
        var mname = '_method_${_bind.name}';

        // preprocess the arguments
        var argExprs = [];
        var conCallArgs = [];
        for (a in _bind.arguments) {
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});            
            if (TypeMacros.isTypeNative(a.type.name))
                conCallArgs.push({type: '(const GDNativeTypePtr)&', name: argName});
            else
                conCallArgs.push({type: '(const GDNativeTypePtr)', name: '${argName}.native_ptr()'});
        }
        var vArgs = _assembleCallArgs(conCallArgs);

        // now build the function body
        var body = null;
        if (_bind.returnType.name == "Void") {
            var exprs = [];
            if (conCallArgs.length > 0) {
                exprs.push(macro {
                    ${vArgs};
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})(nullptr, (const GDNativeTypePtr*)call_args.data(), nullptr, {1});', 
                        $i{mname},
                        $v{conCallArgs.length}
                    );
                });
            } else {
                exprs.push(macro {
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})(nullptr, nullptr, nullptr, 0);', 
                        $i{mname}
                    );
                });
            }
            body = macro {
                $b{exprs};
            };
        } else {
            var typePath = TPath(_bind.returnType);
            var defaultValue = TypeMacros.getNativeTypeDefaultValue(_bind.returnType.name);
            var exprs = [];
            if (conCallArgs.length > 0) {
                exprs.push(macro {
                    ${vArgs};
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})(nullptr, (const GDNativeTypePtr*)call_args.data(), (GDNativeTypePtr){1}, {2});', 
                        $i{mname},
                        ret,
                        $v{conCallArgs.length}
                    );
                });
            } else {
                exprs.push(macro {
                    untyped __cpp__('((GDNativePtrBuiltInMethod){0})(nullptr, nullptr, (GDNativeTypePtr){1}, 0);', 
                        $i{mname},
                        ret
                    );
                });
            }

            if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                // a native return type
                body = macro {
                    var ret2:$typePath = $v{defaultValue};
                    var ret = cpp.Native.addressOf(ret2);
                    $b{exprs};
                    return ret2;
                };
            } else {
                // // we have a managed return type, create it properly
                var typePath = _bind.returnType;
                body = macro {
                    var ret2 = new $typePath();
                    var ret = ret2.native_ptr();
                    $b{exprs};
                    return ret2;
                };
            }
        }
        _fields.push({
            name: _bind.name,
            access: _bind.access,
            pos: Context.currentPos(),
            kind: FFun({
                args: argExprs,
                expr: body,
                params: [],
                ret: TPath(_bind.returnType)
            })
        });

        // forward static fields to abstract
        var callArgs = [for (a in _bind.arguments) a.name];
        _abstractFields.push({
            name: _bind.name,
            access: [AInline, APublic, AStatic],
            pos: Context.currentPos(),
            kind: FFun({
                args: argExprs,
                expr: Context.parse('{ return ${_bind.clazz.name}.${_bind.name}(${callArgs.join(",")}); }', Context.currentPos()),
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }

    // 
    public static function buildBuiltInPropertyMethod(_bind:FunctionBind, _fields:Array<Field>) {
        var mname = '_${_bind.name}';

        // preprocess the arguments
        var argExprs = [];
        for (a in _bind.arguments) {
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});
        }

        // now either build a getter or setter body
        var body = null;
        var typePath = TPath(_bind.returnType);
        var defaultValue = TypeMacros.getNativeTypeDefaultValue(_bind.returnType.name);
        if (_bind.type == FunctionBindType.PROPERTY_GET) { // Getter
            var exprs = [macro {
                untyped __cpp__('((GDNativePtrGetter){0})({1}, (const GDNativeTypePtr){2});', 
                    $i{mname},
                    this.native_ptr(),
                    ret
                );
            }];

            // TODO: we need to support managed types for return types here
            
            if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                // a native return type
                body = macro {
                    var ret2:$typePath = $v{defaultValue};
                    var ret = cpp.Native.addressOf(ret2);
                    $b{exprs};
                    return ret2;
                };
            } else {
                // // we have a managed return type, create it properly
                var typePath = _bind.returnType;
                body = macro {
                    var ret2 = new $typePath();
                    var ret = ret2.native_ptr();
                    $b{exprs};
                    return ret2;
                };
            }
        } else { // Setter
            var aName = _bind.arguments[0].name;
            var exprs = [macro {
                untyped __cpp__('((GDNativePtrSetter){0})({1}, (GDNativeTypePtr){2});', 
                    $i{mname},
                    this.native_ptr(),
                    arg
                );
            }];
            if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                // a native return type
                body = macro {
                    var arg = cpp.Native.addressOf($i{aName});
                    $b{exprs};
                    return $i{aName};
                };
            } else {
                // // we have a managed return type, create it properly
                var typePath = _bind.returnType;
                body = macro {
                    var arg = $i{aName}.native_ptr();
                    $b{exprs};
                    return $i{aName};
                };
            }
        }

        // add the field
        _fields.push({
            name: _bind.name,
            access: _bind.access,
            pos: Context.currentPos(),
            meta: [{name: ':noCompletion', pos: Context.currentPos()}],
            kind: FFun({
                args: argExprs,
                expr: body,
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }

    public static function buildOperatorOverload(_bind:FunctionBind, _abstractFields:Array<Field>) {
        var oname = '${_bind.clazz.name}._${_bind.name}';

        // preprocess the arguments
        var argExprs = [];
        var conCallArgs = [];
        for (a in _bind.arguments) {
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});
            if (TypeMacros.isTypeNative(a.type.name))
                conCallArgs.push('untyped __cpp__("(const GDNativeTypePtr)& {0}", ${argName})');
            else
                conCallArgs.push('untyped __cpp__("(const GDNativeTypePtr){0}", ${argName}.native_ptr())');
        }

        // now assemble the operator body
        var body = null;
        var typePath = TPath(_bind.returnType);
        var defaultValue = TypeMacros.getNativeTypeDefaultValue(_bind.returnType.name);

        // TODO: this will break, if there are unary operators!
        if (conCallArgs.length < 2)
            Context.fatalError('UNSUPPORTED UNARY OPERATOR FOUND! ${_bind.name}', Context.currentPos());

        var left = Context.parse(conCallArgs[0], Context.currentPos());
        var right = Context.parse(conCallArgs[1], Context.currentPos());

        var exprs = [macro {
            untyped __cpp__('((GDNativePtrOperatorEvaluator){0})({1}, {2}, {3});', 
                $i{oname},
                $left,
                $right,
                ret
            );
        }];

        // deal with the return type
        if (TypeMacros.isTypeNative(_bind.returnType.name)) {
            // a native return type
            body = macro {
                var ret2:$typePath = $v{defaultValue};
                var ret = cpp.Native.addressOf(ret2);
                $b{exprs};
                return ret2;
            };
        } else {
            // // we have a managed return type, create it properly
            var typePath = _bind.returnType;
            body = macro {
                var ret2 = new $typePath();
                var ret = ret2.native_ptr();
                $b{exprs};
                return ret2;
            };
        }

        // now add the field to the abstract
        _abstractFields.push({
            name: _bind.name,
            access: _bind.access,
            pos: Context.currentPos(),
            meta: [{name: ':op', params:[Context.parse('A ${_bind.macros.extra} B', Context.currentPos())], pos: Context.currentPos()}],
            kind: FFun({
                args: argExprs,
                expr: body,
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }

    //
    public static function buildIndexing(_bind:FunctionBind, _abstractFields:Array<Field>) {
        var mname = '${_bind.clazz.name}._${_bind.name}';

        // preprocess the arguments
        var argExprs = [];
        var conCallArgs = [];
        for (a in _bind.arguments) {
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});
        }

        var body = null;
        var typePath = TPath(_bind.returnType);
        var defaultValue = TypeMacros.getNativeTypeDefaultValue(_bind.returnType.name);

        if (_bind.type == FunctionBindType.INDEX_GET) {
            var index = _bind.arguments[0].name;
            var exprs = [macro {
                untyped __cpp__('((GDNativePtrIndexedGetter){0})({1}, {2}, (GDNativeTypePtr){3});', 
                    $i{mname},
                    this.native_ptr(),
                    $i{index},
                    ret
                );
            }];

            if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                // a native return type
                body = macro {
                    var ret2:$typePath = $v{defaultValue};
                    var ret = cpp.Native.addressOf(ret2);
                    $b{exprs};
                    return ret2;
                };
            } else {
                // // we have a managed return type, create it properly
                var typePath = _bind.returnType;
                body = macro {
                    var ret2 = new $typePath();
                    var ret = ret2.native_ptr();
                    $b{exprs};
                    return ret2;
                };
            }
        } else {
            var index = _bind.arguments[0].name;
            var aName = _bind.arguments[1].name;
            var exprs = [macro {
                untyped __cpp__('((GDNativePtrIndexedSetter){0})({1}, {2}, (const GDNativeTypePtr){3});', 
                    $i{mname},
                    this.native_ptr(),
                    $i{index},
                    arg
                );
            }];

            if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                // a native return type
                body = macro {
                    var arg = cpp.Native.addressOf($i{aName});
                    $b{exprs};
                    return $i{aName};
                };
            } else {
                // // we have a managed return type, create it properly
                var typePath = _bind.returnType;
                body = macro {
                    var arg = $i{aName}.native_ptr();
                    $b{exprs};
                    return $i{aName};
                };
            }
        }

        // now add the field to the abstract
        _abstractFields.push({
            name: _bind.name,
            access: _bind.access,
            pos: Context.currentPos(),
            meta: [{name: ':op', params:[Context.parse('[]', Context.currentPos())], pos: Context.currentPos()}],
            kind: FFun({
                args: argExprs,
                expr: body,
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }

    // 
    public static function buildMethod(_bind:FunctionBind, _fields:Array<Field>) {
        var mname = '_method_${_bind.name}';
        // preprocess the arguments
        var argExprs = [];
        var conCallArgs = [];
        for (a in _bind.arguments) {
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});            
            if (TypeMacros.isTypeNative(a.type.name))
                conCallArgs.push({type: '(const GDNativeTypePtr)&', name: argName});
            else
                conCallArgs.push({type: '(const GDNativeTypePtr)', name: '${argName}.native_ptr()'});
        }
        var vArgs = _assembleCallArgs(conCallArgs);

        // now build the function body
        var body = null;
        if (_bind.returnType.name == "Void") {
            var exprs = [];
            if (conCallArgs.length > 0) {
                switch (_bind.type) {
                    case FunctionBindType.VIRTUAL_METHOD: {}
                    default: {
                        exprs.push(macro {
                            ${vArgs};
                            untyped __cpp__('godot::internal::gdn_interface->object_method_bind_ptrcall({0}, {1}, (const GDNativeTypePtr*)call_args.data(), nullptr)', $i{mname}, this.native_ptr());
                        });
                    }
                }
                
            } else {
                switch (_bind.type) {
                    case FunctionBindType.VIRTUAL_METHOD: {}
                    default: {
                        exprs.push(macro {
                            untyped __cpp__('godot::internal::gdn_interface->object_method_bind_ptrcall({0}, {1}, nullptr, nullptr)', $i{mname}, this.native_ptr());
                        });
                    }
                }
            }
            body = macro {
                $b{exprs};
            };
        } else {            
            var typePath = TPath(_bind.returnType);
            var defaultValue = TypeMacros.getNativeTypeDefaultValue(_bind.returnType.name);
            var exprs = [];
            if (conCallArgs.length > 0) {
                switch (_bind.type) {
                    case FunctionBindType.VIRTUAL_METHOD: {}
                    default: {
                        exprs.push(macro {
                            ${vArgs};
                            untyped __cpp__('godot::internal::gdn_interface->object_method_bind_ptrcall({0}, {1}, (const GDNativeTypePtr*)call_args.data(), {2})', $i{mname}, this.native_ptr(), ret);
                        });
                    }
                }
            } else {
                switch (_bind.type) {
                    case FunctionBindType.VIRTUAL_METHOD: {}
                    default: {
                        exprs.push(macro {
                            untyped __cpp__('godot::internal::gdn_interface->object_method_bind_ptrcall({0}, {1}, nullptr, {2})', $i{mname}, this.native_ptr(), ret);
                        });
                    }
                }
            }

            if (_bind.type == FunctionBindType.VIRTUAL_METHOD) {
                if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                    // a native return type
                    body = macro {
                        return $v{defaultValue};
                    };
                } else {
                    // // we have a managed return type, create it properly
                    body = macro {
                        return null;
                    };
                }
            } else {
                if (TypeMacros.isTypeNative(_bind.returnType.name)) {
                    // a native return type
                    body = macro {
                        var ret2:$typePath = $v{defaultValue};
                        var ret = cpp.Native.addressOf(ret2);
                        $b{exprs};
                        return ret2;
                    };
                } else {
                    // // we have a managed return type, create it properly
                    body = _assembleReturn(_bind, exprs);
                }
            }
        }
        _fields.push({
            name: _bind.name,
            access: _bind.access,
            pos: Context.currentPos(),
            kind: FFun({
                args: argExprs,
                expr: body,
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }

    /*
    public static function buildPropertyMethod(_bind:FunctionBind, _fields:Array<Field>) {
        var mname = '_${_bind.name}';

        // preprocess the arguments
        var argExprs = [];
        for (a in _bind.arguments) {
            var argName = '${a.name}';
            argExprs.push({name:argName, type:TPath(a.type)});
        }

        // now either build a getter or setter body
        var body = null;
        var typePath = TPath(_bind.returnType);
        var defaultValue = TypeMacros.getNativeTypeDefaultValue(_bind.returnType.name);
        if (_bind.type == FunctionBindType.PROPERTY_GET) { // Getter
            
            if (_bind.macros.extra.index > -1) {
                body = macro {
                    return cast $i{_bind.macros.extra.getter}($v{_bind.macros.extra.index});
                };
            } else {
                body = macro {
                    return cast $i{_bind.macros.extra.getter}();
                };
            }
           
        } else { // Setter
            var aName = _bind.arguments[0].name;

            body = macro {
                $i{_bind.macros.extra.setter}(cast $i{aName});
                return $i{aName};
            };
        }

        // add the field
        _fields.push({
            name: _bind.name,
            access: _bind.access,
            pos: Context.currentPos(),
            meta: [{name: ':noCompletion', pos: Context.currentPos()}],
            kind: FFun({
                args: argExprs,
                expr: body,
                params: [],
                ret: TPath(_bind.returnType)
            })
        });
    }
    */

    // utils
    static function _assembleCallArgs(_conCallArgs:Array<Dynamic>) {
        // wtf is even happening? Well, we assemble a std::array in using several untyped __cpp__ calls to allow for proper typing...
        var tmp = [];
        var vals = [];
        for (i in 0..._conCallArgs.length) {
            tmp.push('${_conCallArgs[i].type}{$i}');
            vals.push('${_conCallArgs[i].name}');
        }
        var sArgs = 'std::array<const GDNativeTypePtr, ${_conCallArgs.length}> call_args = { ${tmp.join(",")} }';
        var tmp2 = 'untyped __cpp__("$sArgs", ${vals.length > 0 ? vals.join(",") : null})';
        return Context.parse(tmp2, Context.currentPos());
    }

    static function _assembleReturn(_bind:FunctionBind, _exprs:Array<haxe.macro.Expr>):haxe.macro.Expr {
        // // we have a managed return type, create it properly
        var typePath = _bind.returnType;        
        var body = null;
        var identBindings = '&${typePath.name}_obj::___binding_callbacks';
        var ctType = TPath(typePath);
        
        if (typePath.pack.length == 1 && typePath.pack[0] == "godot") {
            body = macro {
                // managed types need a pointer indirection
                var retOriginal:godot.Types.VoidPtr = untyped __cpp__('nullptr');
                var ret:godot.Types.VoidPtr = untyped __cpp__('&{0}', retOriginal);
                $b{_exprs};

                var obj = godot.Types.GodotNativeInterface.object_get_instance_binding(
                    retOriginal, 
                    untyped __cpp__("godot::internal::token"), 
                    untyped __cpp__($v{identBindings})
                );

                var instance:$ctType = untyped __cpp__(
                    $v{"(::godot::"+typePath.name+"((::godot::"+typePath.name+"_obj*){0}))"}, // TODO: this is a little hacky!
                    obj
                );

                // important! we need to track the original godot instance
                instance.__owner = retOriginal;

                return cast instance;
            };
        } else {
            body = macro {
                var ret2 = new $typePath();
                var ret = ret2.native_ptr();
                $b{_exprs};
                return ret2;
            };
        }

        return body;        
    }
}