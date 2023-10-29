import cpp.link.StaticRegexp;
import cpp.link.StaticStd;
import cpp.link.StaticZlib;

import godot.Types;
import godot.variant.Variant;

@:buildXml("<files id='haxe'>
        <compilerflag value='-I${haxelib:hxgodot}/src'/>
        <compilerflag value='-I../bindings'/>
        <file name='${haxelib:hxgodot}/src/hxcpp_ext/Dynamic2.cpp'/>
        <file name='${haxelib:hxgodot}/src/godot_cpp/godot.cpp'/>
        <file name='${haxelib:hxgodot}/src/utils/RootedObject.cpp'/>
        <file name='${haxelib:hxgodot}/src/hxcpp_ext/hxgodot_api.cpp'/>
    </files>")
class HxGodot {

    static var engineClasses:Array<Dynamic> = [];
    static var extensions:Array<Dynamic> = [];

    static function main() {
        // setup constructors
        __Variant.__initBindings();

        // use https://github.com/jasononeil/compiletime to embed all found extensionclasses and use rtti to register them
        // TODO: the compile-time lib should prolly be replaced with something lightweight in the long run
        var builtins = CompileTime.getAllClasses(godot.variant.IBuiltIn);
        for (t in builtins) {
            if (Reflect.hasField(t, "__init_builtin_constructors")) // built-in class constructors and shit
                Reflect.field(t, "__init_builtin_constructors")();
        }
        for (t in builtins) {
            if (Reflect.hasField(t, "__init_builtin_bindings")) // built-in class bindings
                Reflect.field(t, "__init_builtin_bindings")();
        }

        // now override the trace function for error handling and GDUtils prints
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            if (infos.customParams != null) {
                // TODO: Sucks, but lets do this for now
                var stack = haxe.CallStack.toString(haxe.CallStack.callStack());
                var lines = stack.split("\n");
                lines.reverse();
                lines.pop();
                lines.unshift(Std.string(v));
                GodotNativeInterface.print_error(lines.join('\n'), infos.className+":"+infos.methodName, infos.fileName, infos.lineNumber, true);
            } else {
                //GodotNativeInterface.print_warning(Std.string(v), infos.className+":"+infos.methodName, infos.fileName, infos.lineNumber);
                var msg = infos.fileName+":"+infos.lineNumber+": "+ Std.string(v);
                GDUtils.print((msg:godot.variant.GDString));
            }
        }

        // sort all classes depending on their inheritance depth, this way everything registers in order
        var tmp = Lambda.array(CompileTime.getAllClasses(godot.Wrapped));
        haxe.ds.ArraySort.sort(tmp, function(_a:Dynamic, _b:Dynamic) {
            var a = Reflect.field(_a, "__inheritance_depth");
            var b = Reflect.field(_b, "__inheritance_depth");
            if (a > b) return 1;
            else if (a < b) return -1;
            return 0;
        });

        // now init the binding classes and register the extension classes

        for (t in tmp) {
            if (Reflect.hasField(t, "__init_engine_bindings"))
                engineClasses.push(t);

            if (Reflect.hasField(t, "__registerClass"))
                extensions.push(t);
        }
        
        function _init(_tmp:Array<Dynamic>) {
            for (t in _tmp) {
                if (Reflect.hasField(t, "__init_engine_bindings")) // engine class bindings
                    Reflect.field(t, "__init_engine_bindings")();

                if (Reflect.hasField(t, "__init_constant_bindings")) // class constants bindings
                    Reflect.field(t, "__init_constant_bindings")();

                if (Reflect.hasField(t, "__registerClass")) // extension class bindings
                    Reflect.field(t, "__registerClass")();

                if (Reflect.hasField(t, "__static_init")) // extension static initialization
                    Reflect.field(t, "__static_init")();

                if (Reflect.hasField(t, "__registerSingleton")) // extension singleton initialization
                    Reflect.field(t, "__registerSingleton")();
            }
        }

        _init(engineClasses);

        // print a fancy banner message
        var bannerMsg = new StringBuf();
        bannerMsg.add('\n[b][color=FFA500]Hx[/color][color=6495ED]Godot[/color] (${GDUtils.HXGODOT_VERSION})[/b]\n');
        bannerMsg.add('${builtins.length} builtins / ${tmp.length} classes available\n');
        #if scriptable
        bannerMsg.add('(CPPIA host-mode enabled)\n');
        #end
        GDUtils.print_rich(bannerMsg.toString());

        _init(extensions);

        #if scriptable
        //cpp.cppia.Host.runFile("bin/hxgodot.cppia");
        #end
    }

    public static function shutdown() {

        function _deinit(_tmp:Array<Dynamic>) {
            // now null / release all the godot stuff we have in our classes
            for (t in _tmp) {
                if (Reflect.hasField(t, "__unregisterSingleton")) // extension singleton initialization
                    Reflect.field(t, "__unregisterSingleton")();

                if (Reflect.hasField(t, "__static_deinit"))
                    Reflect.field(t, "__static_deinit")();

                if (Reflect.hasField(t, "__registerClass")) {
                    var cname:godot.variant.StringName = Reflect.field(t, "__class_name");
                    godot.Types.GodotNativeInterface.classdb_unregister_extension_class(
                        untyped __cpp__("godot::internal::library"),
                        cname.native_ptr()
                    );
                }
                
                if (Reflect.hasField(t, "__deinit_constant_bindings"))
                    Reflect.field(t, "__deinit_constant_bindings")();
            }
        }

        // sort all classes depending on their inheritance depth, this way everything unregisters in order
        haxe.ds.ArraySort.sort(extensions, function(_a:Dynamic, _b:Dynamic) {
            var a = Reflect.field(_a, "__inheritance_depth");
            var b = Reflect.field(_b, "__inheritance_depth");
            if (a < b) return 1;
            else if (a > b) return -1;
            return 0;
        });

        // cleanup extension objects
        _deinit(extensions);
        cpp.NativeGc.run(true);

        // cleanup engine objects
        _deinit(engineClasses);
        cpp.NativeGc.run(true);
            
    }

    // utilities
    static var gcCycle = 0.0;
    public static function runGc(_dt:Float) {
        var ran = false;
        if (gcCycle > 1) {
            trace("running GC");
            cpp.NativeGc.run(true);
            gcCycle = 0;
            ran = true;
        }
        gcCycle += _dt;
        return ran;
    }

    inline public static function setFinalizer(_inst:Any, _cb:cpp.Callable<Dynamic->Void>) {
        #if !cppia
        cpp.vm.Gc.setFinalizer(_inst, _cb);
        #end
    }

    public static function getExceptionStackString(_e:Dynamic) {
        var msg = [_e.value];
        for (s in cast(_e.__nativeStack, Array<Dynamic>)) {
            var tokens = s.split("::");
            var cls = tokens[0];
            var func = tokens[1];
            var file = tokens[2];
            var line = tokens[3];
            msg.push('Called from $cls.$func ($file:$line)');
        }
        return msg.join("\n");
    }
}