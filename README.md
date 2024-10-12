> [!IMPORTANT]  
> This project is no longer maintained!
> This was an interesting experiment and journey which was in the end not able to live up to the vision I had in mind.
> In the end it was hard to justify the time and complexity required in relation to the factual outcome of a semi-working solution.
> Thanks!

---
![logo.png](https://hxgodot.github.io/logo2.png)

# HxGodot - A Haxe GDExtension for Godot 4

HxGodot combines Haxe's hxcpp target with Godot 4's GDExtension mechanism to supercharge the way you build games with Godot. Nodes are written in Haxe, bundled as a GDExtension and behave like any other Node in your scenes(attach scripts, signals, etc).

> **Warning** There might be crashes, pieces of the API not working or straight up missing. That being said, we appreciate you testing HxGodot in smaller projects. Feel free to get in touch in should you face issues or bugs.


## Getting started
### Prerequisites & Toolchain: 

HxGodot builds as a GdExtension DLL and therefore required the same build environment as Godot itself. Please refer to the official [Godot Documentation here](https://docs.godotengine.org/en/stable/contributing/development/compiling/index.html#building-for-target-platforms)

In summary:
- A Commandline shell of your choice. We assume a \*nix-based shell for all commands presented here.
- A C++ compiler, python and scons for your [target platform](https://docs.godotengine.org/en/stable/contributing/development/compiling/index.html#building-for-target-platforms) 
- [Haxe 4.3.1+](https://haxe.org/download/) Install Haxe and setup Haxe's package manager via `haxelib setup` 
- hxcpp 4.3.1+ Install hxcpp by running `haxelib install hxcpp`
- [CompileTime library](https://lib.haxe.org/p/compiletime) Install it by running `haxelib install compiletime`
- Godot 4.2.1+

### First time setup

When you are first starting out HxGodot is able to generate a simple example project for you. Let's go into a shell and do that:

1. Install hxgodot via `haxelib`:    
   ```bash 
   haxelib git hxgodot https://github.com/HxGodot/hxgodot.git
   ```
   
2. Create yourself a folder somewhere for the sample project we are about to generate and enter it: 
   ```bash 
   mkdir <sample_project> && cd <sample_project>
   ```
   
3. Now run the included cli-tool and and follow the instructions: 
   ```bash
   haxelib run hxgodot init
   ```
   
   ![image](https://github.com/HxGodot/hxgodot/assets/5015415/463fdc92-836e-47b3-892c-cde177c44bb1)

   Let's take a closer look at the folder's content, that we just generated for you:   
   ![image](https://github.com/HxGodot/hxgodot/assets/5015415/f8d5c3d6-60a5-45f1-ba33-6e667daff39e)
   
   - `bin`: Will contain the compiled gdextension binaries later
   - `bindings`: Will contain the generated Haxe bindings for Godot4's classes. Also holds a `log.txt` which contains reports about things that were ignored or could not be handled. Useful if you miss a function in Godot's API, here you will usually find the reason why.
   - `build.hxml`: this contains the build-instructions for Haxe when building the extension. Here you can add extra compiler defines for debugging or specify which Haxe code modules you want to include in your extension or which third party Haxe libraries to include. See the included comments.
   - `example.gdextension`: This is the extension-file Godot4 will use to load the correct binaries for your CPU architecture.
   - `project.godot`: Main Godot Project File. This file is the entry-point for Godot and includes a section to include loading our `example.gdextension` file
   - `SConstruct`: This is the SCONS build file. This what runs the build pipeline and assembles the binary of your choice.
   - `src`: This folder contains the sample's Haxe code. It holds basic examples of a few Godot nodes written in Haxe and runs a few tests & interactions. 
     >If you add more folders with Haxe-code to `src`, make sure you take a look at `build.hxml`. You need to let HxGodot know about which subfolders in `src` to include.


 4. Build the extension according to your platform's flavor:
    ```bash
    scons platform=<windows|linux|macos> target=<debug|release> arch=<x86_64|x86_32|arm64>
    ```
   
    Examples:
    - for Apple Silicon: `scons platform=macos arch=arm64`
    
 5. Open the sample-project in Godot4. Please be aware, that you might need to restart the editor after the first start for everything to setup correctly:
	 
    ![image](https://github.com/HxGodot/hxgodot/assets/5015415/91dc4eee-2045-4984-b43a-ed828b045843)
    Here you will find the scenetree with the custom Haxe nodes that are contained in the extension.
 
 6. You can now study the included Haxe code and play around with it. Just repeat Step 4 and restart Godot. 
    Feel free to modify this project or use it as a base for a more complex project.
    
    
    Speaking of a more complex project, you can also checkout our full sample game here: https://github.com/HxGodot/squash-the-creeps-3d-hxgodot

## Updating the HxGodot in an existing project

In cases where hxgodot was updated you dont need to recreate your existing project. In such cases you can follow the following steps:

1.  Update hxgodot via git
   ```bash
   haxelib git hxgodot https://github.com/HxGodot/hxgodot.git
   ```

2. Update your projects `SConstruct` file. This can be necessary when there have been changes/updates in the build pipeline
   ```bash
   haxelib run hxgodot copy_buildfiles
   ```

3. Generate a new set of bindings (usually updates come with improvements)
   ```bash
   haxelib run hxgodot generate_bindings
   ```

4. Rebuild your project's extension
   ```bash
   scons platform=<windows|linux|macos> target=<debug|release>
   ```

## About Godot versions and binding generation

HxGodot ships with an `extension_api.json` file that was generated by an official Godot 4.2.1 build. In cases where you build the engine yourself or wanna HxGodot try a different version, you want to generate custom HxGodot bindings. You can do that by running:

```shell
<path to your godot executable> --dump-extension-api-with-docs
```

This will generate your `extension_api.json` in the folder you ran the command in. In your project you now need to regenerate the bindings:

```shell
haxelib run hxgodot generate_bindings --extension-api-json=<path to your extension_api.json>
```

Now you can build HxGodot and test your project.

## Common pitfalls
### Assigning properties
You may attempt to update certain member properties in the following way and notice that the position wont get applied to the node.

```haxe
class HxCoolNode extends Node2D {
	override function _ready() {
		this.position.x = 100.0; // this wont apply the value to the position
	}
}
```

This is actually normal. The `position` Vector2 is accessed and copied from Godot and you can do calculations with it. But in order to apply it you need to assign the property again or use the setter function like this:

```haxe
class HxCoolNode extends Node2D {
	override function _ready() {
		var pos = this.position;
		pos.x = 100.0;
		this.position = pos;
		// or
		this.set_position(pos); // that would also work
		// or
		this.position = new Vector2(100.0, this.position.y); // while not optimal, this also works
		// or
		this.position = [100.0, this.position.y]; // while not optimal, this also works since Vector2 is an array under the hood
	}
}
```

### Dangerous GDArrays
Dont work with GDArrays naively! They contain [Variants](https://hxgodot.github.io/docs/godot/variant/Variant.html) and by default they can convert into types prematurely and cause a crash.

```haxe
	// triangles_gd holds an array of Int64
	var triangles_gd:GDArray = surface_data[cast MeshArrayType.ARRAY_INDEX];
	var index:Int = triangles_gd[tidx]; // UNDEFINED BEHAVIOR, DONT DO THIS! The Variant returned from the GDArray sees the `Int` and casts itself to `Int` too early, writing its `Int64` into a the pointer of an `Int`, effectively causing a stack-corruption!!!

	// Instead explicitly force the Variant to cast into the original type first and cast into the wanted type secondly
	var index:Int = ((triangles_gd[tidx]:cpp.Int64):Int); // Good! Unpack Int64 and cast to Int
```

## Debugging
- Windows: Startup your VisualStudio and setup it up to debug launch your compile Godot 4.x executable with the test-project defined on the cmdline. 

You should be able to step through the code on both sides(godot & hxgodot) and see what's going on.


## Good to know
- Godot exposes around 850 classes in the extension API. Haxe's compiler will automatically only compile classes that your code actually imports / uses into the extension.

