import sys.FileSystem;
import haxe.io.Path;

class RunMain
{
   static var projectDir:String;
   static var libDir:String;
   static var bindingDir:String;

   static var forceGeneration = false;
   static var confirmYes = false;

   public static function main()
   {  
      var args = Sys.args();

      projectDir = args.pop();
      libDir = Path.normalize(Sys.getCwd());
      bindingDir = Path.join([projectDir, 'bindings']);

      if (args.length > 0) {
         for (i in 0...args.length)
            if (args[i].indexOf("--generate_bindings")==0)
               forceGeneration = true;
            else if (args[i].indexOf("-y")==0)
               confirmYes = true;
      }

      if (!executeHxGodot())
         showMessage();
   }

   public static function showMessage()
   {  
      /*
      var varName = "HXCPP_NONINTERACTIVE";
      var nonInteractive:Bool =Sys.getEnv(varName)!=null;
      if (!nonInteractive)
         for(arg in Sys.args())
            if (arg.indexOf("-D"+varName)==0 )
               nonInteractive = true;


      if (nonInteractive)
      {
         Sys.println('HXCPP in $dir is missing hxcpp.n');
         Sys.exit(-1);
      }
      */
      if (confirmYes) {
         setup();
         Sys.println("Stopping.");
         Sys.exit(-1);
      }

      if (forceGeneration) {
         log('You want to generate the Godot bindings in your project folder ($projectDir)?');
         log('This can be done manually:');
      } else {
         log('Your project-folder ($projectDir) appears to be lacking the Godot bindings.');
         log('Before this can be used, you need to:');
      }
      log(' 1. Generate Godot4 Haxe bindings:');
      log('     cd $libDir');
      log('     haxe build-bindings.hxml -D output="$bindingDir"');

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
            log("");
            setup();
            if (!executeHxGodot())
               break;
            return;
         }
         if (answer=="n" || answer=="N")
            break;
      }

      Sys.println("Stopping.");
      Sys.exit(-1);
   }

   public static function setup()
   {
      log("Generate Godot4 Haxe bindings...");
      run("", "haxe", ["build-bindings.hxml", '-D', 'output="$bindingDir"']);
      log("Initial setup complete.");
   }

   public static function run(dir:String, command:String, args:Array<String>)
   {
      var oldDir:String = "";
      if (dir!="")
      {
         oldDir = Sys.getCwd();
         Sys.setCwd(dir);
      }
      Sys.command(command,args);
      if (oldDir!="")
         Sys.setCwd(oldDir);
   }

   public static function executeHxGodot()
   {
      if (!sys.FileSystem.exists(bindingDir) || forceGeneration)
         return false;

      /*
      if (Sys.args().indexOf("-DHXCPP_NEKO_BUILDTOOL=1")<0)
      {
         var os = Sys.systemName();
         var isWindows = (new EReg("window","i")).match(os);
         var isMac = (new EReg("mac","i")).match(os);
         var isLinux = (new EReg("linux","i")).match(os);
         var binDir = isWindows ? "Windows" : isMac ? "Mac64" : isLinux ? "Linux64" : null;
         
         if (binDir!=null)
         {
            var compiled = 'bin/$binDir/BuildTool';
            if (isWindows)
               compiled += ".exe";
            if (FileSystem.exists(compiled))
            {
               var dotN = FileSystem.stat("hxcpp.n").mtime.getTime();
               var dotExe= FileSystem.stat(compiled).mtime.getTime();
               if (dotExe<dotN)
               {
                  var path = Sys.getCwd() + compiled;
                  Sys.println('Warning - $path file is out-of-date.  Please delete or rebuild.');
               }
               else
               {
                  Sys.exit( Sys.command( compiled, Sys.args() ) );
               }
            }
         }
      }*/

      //neko.vm.Loader.local().loadModule("./hxcpp.n");
      return true;
   }   

   public static function log(s:String) Sys.println(s);
}
