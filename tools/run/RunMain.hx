import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class RunMain
{
   static var projectDir:String;
   static var libDir:String;
   static var bindingDir:String;
   static var templateDir:String;

   static var setupProject = false;
   static var forceGeneration = false;
   static var confirmYes = false;


   public static function log(s:String) Sys.print(s);

   public static function run(dir:String, command:String, args:Array<String>)
   {
      var oldDir:String = "";
      if (dir!="") {
         oldDir = Sys.getCwd();
         Sys.setCwd(dir);
      }
      Sys.command(command,args);
      if (oldDir!="")
         Sys.setCwd(oldDir);
   }

   public static function main()
   {  
      var args = Sys.args();

      projectDir = Path.normalize(args.pop());
      libDir = Path.normalize(Sys.getCwd());
      bindingDir = Path.join([projectDir, 'bindings']);

      if (args.length > 0) {
         for (i in 0...args.length)
            if (args[i].indexOf("init")==0) {
               setupProject = true;
               forceGeneration = true;
            }
            else if (args[i].indexOf("generate_bindings")==0)
               forceGeneration = true;
            else if (args[i].indexOf("-y")==0)
               confirmYes = true;
      }

      var successSetup = false;
      var successGeneration = false;
      if (setupProject)
         successSetup = doAction('Do you want to populate your project folder ($projectDir) with a sample project?\n', doSetupProject);

      if (forceGeneration)
         successGeneration = doAction('Do you want to generate the Godot 4 bindings in your project folder ($projectDir)?\nThis can be done manually:\n\n 1. Generate Godot4 Haxe bindings:\n     cd $libDir\n     haxe build-bindings.hxml -D output="$bindingDir"\n', doGenerateBindings);
      
      if (successSetup) {
         if (successGeneration)
            log('Your project has been setup successfully. You can compile it now via:\n\n     haxe build.hxml\n     (use -debug for a debug-build)\n\nAfterwards you can open it in Godot 4 - Have fun! :)');
         else
            log('Your project folder has been setup but you lack the Godot 4 bindings.\nRun the following command to generate them:\n\n     haxelib run hxgodot generate_bindings\n');
      }
   }

   public static function doSetupProject()
   { 
      log("Populating project folder...\n");
      templateDir = Path.join([libDir, "tools", "template"]);
      _recursiveLoop(templateDir);
      log("Done.\n");
      return true;
   }

   public static function doGenerateBindings()
   {
      log("Generate Godot4 Haxe bindings...\n");
      run("", "haxe", ["build-bindings.hxml", '-D', 'output="$bindingDir"']);
      sys.io.File.saveContent(Path.join([bindingDir, '.gdignore']), '');
      log("Done.\n");

      return true;
   }


   public static function doAction(_prompt:String, _executeAction:()->Bool) {
      if (confirmYes) {
         _executeAction();
      } else {
         log(_prompt);
         var gotUserResponse = false;
         neko.vm.Thread.create(function() {
            Sys.sleep(30);
            if (!gotUserResponse)
            {
               Sys.println("\nTimeout waiting for response.");
               Sys.println("Stopping.");
               Sys.exit(-1);
            }
         } );

         while(true)
         {
            Sys.print("\nWould you like me to do this for you now? [y/n]\n");
            var code = Sys.getChar(true);
            gotUserResponse = true;
            if (code<=32)
               break;
            var answer = String.fromCharCode(code);
            if (answer=="y" || answer=="Y")
            {
               log("\n");
               //setup();
               if (!_executeAction())
                  break;
               return true;
            }
            if (answer=="n" || answer=="N"){
               log("\n");
               break;
            }
         }
         Sys.println("Stopping.");
         return false;
      }
      return true;
   }

   static function _recursiveLoop(directory:String) {
      if (sys.FileSystem.exists(directory)) {
         //trace("directory found: " + directory);
         for (file in sys.FileSystem.readDirectory(directory)) {
            var path = haxe.io.Path.join([directory, file]);
            if (!sys.FileSystem.isDirectory(path)) {
               //trace("file found: " + path);
               _copyFile(path);
            } else {
               var directory = haxe.io.Path.addTrailingSlash(path);
               //trace("directory found: " + directory);
               _recursiveLoop(directory);
            }
         }
      } else {
         Sys.println('"$directory" does not exists');
      }
   }

   static function _copyFile(_path:String) {
      var rel = _path.substr(templateDir.length);
      var abs = Path.join([projectDir, rel]);
      Sys.println(abs);
      var dir = Path.directory(abs);
      if (!FileSystem.exists(dir))
         FileSystem.createDirectory(dir);
      File.copy(_path, abs);
   }
}
