# hxgodot-cpp

Integrate Haxe and its hxcpp target runtime via the Godot 4.x GDExtension into Godot 4.x.

## What?
> There always was interest from the Haxe community and I think it would be great it can work with Godot, but somehow it never materialized into anything. - Godot's Project Lead Juan: https://twitter.com/reduzio/status/1548236136551632900

Let's make this work. 

This is an early (pre-alpha) Haxe-hxcpp project that builds a dynamic library that can be loaded by Godot 4.x. 

## Goal
The goal is to evolve this project into a full library that allows writing extensions and new nodes in Haxe and eventually allow for cppia-scripting.

## Getting started

1. Check out and build the Godot master(debug+tools) to have a working Godot 4.x Editor.
2. Then clone this repository and init the godot-headers submodule: `git submodule update --init --recursive`
3. Build the library: `make debug`. This will build a dll into `test/demo/bin`
4. Open your Godot4 editor and load the project that's located in `test/demo`. 
5. The project will load a demo project and in the scene inspector you will find a node called `HxExample2` that instantiates the included Haxe-class `src/HxExample2.hx` and runs an attach script called `test.gd` 

![image](https://user-images.githubusercontent.com/5015415/186016512-4b8a47c6-cb23-4707-a93a-e15fdb1e7e47.png)

## Debugging

- Windows: Startup your VisualStudio and setup it up to launch your compile Godot 4.x executable with the test-project defined on the cmdline. 
`<path to godot binary> -e --path <included test project folder>`
You should be able to step through the code on both sides(godot & hxgodot) and see what's going on.

## What's missing
See the https://github.com/dazKind/hxgodot-cpp/issues

## Contribute

You know cpp, Haxe and would love to have a lasting impact when it comes to opensource gamedevelopment? 

Then join the effort here!

To get in touch, visit the #haxe discord(https://discord.gg/VR6S5uft), via twitter(https://twitter.com/dazKind) or via michael.bickel[at]gmail.com.
