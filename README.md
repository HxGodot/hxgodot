![logo.png](https://hxgodot.github.io/logo2.png)
# HxGodot - A Haxe GDExtension for Godot 4

HxGodot combines Haxe's hxcpp target with Godot 4's GDExtension mechanism to supercharge the way you build games with Godot. Nodes are written in Haxe, bundled as a GDExtension and behave like any other Node in your scenes(attach scripts, signals, etc).

> **Warning** There might be crashes, pieces of the API not working or straight up missing. That being said, we appreciate you testing HxGodot in smaller projects. Feel free to get in touch in should you face issues or bugs.


## Getting started
### Prerequisites & Toolchain: 
- A Commandline shell of your choice. We assume a *nix-based shell for all commands presented here.
- [SCons](https://scons.org/)
- [Haxe 4.2+](https://haxe.org/download/)
  
  Install Haxe and setup Haxe's package manager via `haxelib setup` 
- hxcpp 4.2+
  
  Install hxcpp by running `haxelib install hxcpp`
- Godot 4 beta10+ (best build from master)

### First time setup

When you are first starting out HxGodot is able to generate a simple example project for you. Let's go into a shell and do that:

1. Install hxgodot via `haxelib`: 
   
   ```haxelib git hxgodot https://github.com/HxGodot/hxgodot.git```
2. Create yourself a folder somewhere for the sample project we are about to generate and enter it: 

   `mkdir <sample_project> && cd <sample_project>`
3. Now run the included cli-tool and and follow the instructions: 

   `haxelib run hxgodot init`

   ![image](https://user-images.githubusercontent.com/5015415/212423704-a1a145c6-56e3-43fe-afce-36860a453e1f.png)

   Let's take a closer look at the folder's content, that we just generated for you:
   
   ![image](https://user-images.githubusercontent.com/5015415/212425501-696bff72-4f84-4792-bc49-901849bef3c8.png)
   
   - `bin`: Will contain the compiled gdextension binaries
   - `bindings`: Will contain the generated Haxe bindings for Godot4's classes. Also holds a `log.txt` which contains reports about things that were ignored or could not be handled. Usefull if you miss a function in Godot's API, here you will usually find the reason why.
   - `build.hxml`: this contains the build-instructions for Haxe when building the extension. Here you can add extra compiler defines for debugging or specify which Haxe code modules you want to include in your extension or which third party Haxe libraries to include. See the included comments.
   - `example.gdextension`: This is the extension-file Godot4 will use to load the correct binaries for your CPU architecture.
   - `project.godot`: Main Godot Project File. This file is the entry-point for Godot and includes a section to include loading our `example.gdextension` file
   - `SConstruct`: This is the SCONS build file. This what runs the build pipeline and assembles the binary of your choice.
   - `src`: This folder contains the sample's Haxe code. It holds basic examples of a few Godot nodes written in Haxe and runs a few tests & interactions.
   
 4. Build the extension:
    `scons platform=<windows|linux|macos> target=<debug|release>`
    
 5. Open the sample-project in Godot4
    ![image](https://user-images.githubusercontent.com/5015415/212428088-965ae83c-e1dc-4a98-b82d-4c42e4866f87.png)
    Here you will find the scenetree with the custom Haxe nodes that are contained in the extension.
 
 6. You can now study the included Haxe code and play around with it. Just repeat Step 4 and restart Godot. 
    Feel free to modify this project or use it as a base for a more complex project.
    
    Speaking of a more complex project, you can also checkout our full sample game here: https://github.com/HxGodot/squash-the-creeps-3d-hxgodot
 
## Updating the HxGodot in an existing project

In cases where hxgodot was updated you dont need to recreate your existing project. In such cases you can follow the following steps:

1.  Update hxgodot via git

    `haxelib git hxgodot https://github.com/HxGodot/hxgodot.git`:
2. Generate a new set of bindings (usually updates come with improvements)
    
    `haxelib run hxgodot generate_bindings`
3. Rebuild your project's extension

    `scons platform=<windows|linux|macos> target=<debug|release>`



## Debugging
- Windows: Startup your VisualStudio and setup it up to launch your compile Godot 4.x executable with the test-project defined on the cmdline. 
`<path to godot binary> -e --path <included test project folder>`
You should be able to step through the code on both sides(godot & hxgodot) and see what's going on.

