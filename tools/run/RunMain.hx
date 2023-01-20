import sys.thread.Thread;
import haxe.Constraints.Function;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

using StringTools;

class RunMain {
   static var projectDir:String;
   static var libDir:String;
   static var bindingDir:String;
   static var templateDir:String;

   static var setupProject = false;
   static var forceGeneration = false;
   static var confirmYes = false;

   // these only use widely supported colors and formatting codes. should work on all platforms.
   public static var RESET:String = '\x1b[0m';
   public static var BOLD:String = '\x1b[1m';
   public static var LIGHT:String = '\x1b[2m';

   public static var REGULAR_TEXT:String = '\x1b[0;1m';
   public static var COMMAND_TEXT:String = '\x1b[0m';
   public static var ALT_COMMAND_TEXT:String = '\x1b[0;2m';
   public static var SUCCESS_TEXT:String = '\x1b[0;32m';
   public static var STATUS_TEXT:String = '\x1b[0;36m';
   public static var ERROR_TEXT:String = '\x1b[0;31m';

   public static var LogoHxColor:String = '\x1b[0;33m';
   public static var LogoGodotColor:String = '\x1b[0;36m';

   public static function log(s:String) {
      Sys.println('$s$RESET');
   }

   public static function run(dir:String, command:String, args:Array<String>) {
      var oldDir:String = "";

      if (dir != "") {
         oldDir = Sys.getCwd();
         Sys.setCwd(dir);
      }

      Sys.command(command, args);
      if (oldDir != "")
         Sys.setCwd(oldDir);
   }

   /**
      Gets if color and formatting should be enabled or not. formatting is
      disabled if the environment variable HXGODOT_DISABLE_COLOR is "true",
      "yes", or "1", or if the "-disable-color" flag is present
   **/
   public static var colorEnabled(get, never):Bool;

   static function get_colorEnabled():Bool {
      if (flags.contains('disable-color'))
         return false;
      if (Sys.getEnv('HXGODOT_DISABLE_COLOR') == null)
         return true;
      var envVar = Sys.getEnv('HXGODOT_DISABLE_COLOR').toLowerCase();
      if (envVar == 'true' || envVar == 'yes' || envVar == '1')
         return false;
      return true;
   }

   public static function main() {
      var args = Sys.args();

      projectDir = Path.normalize(args.pop());
      libDir = Path.normalize(Sys.getCwd());
      bindingDir = Path.join([projectDir, 'bindings']);

      parseArgs(args);

      if (!colorEnabled) {
         // disables all colors and formatting in output
         RESET = "";
         LIGHT = "";
         BOLD = "";
         REGULAR_TEXT = "";
         COMMAND_TEXT = "";
         ALT_COMMAND_TEXT = "";
         SUCCESS_TEXT = "";
         STATUS_TEXT = "";
         ERROR_TEXT = "";
         LogoHxColor = "";
         LogoGodotColor = "";
      }

      var libInfo = haxe.Json.parse(File.getContent(Path.join([libDir, 'haxelib.json'])));

      if (arguments.length == 0) {
         log(formatHeader('HxGodot (${libInfo.version})'));
         log('\n${REGULAR_TEXT}Use ${COMMAND_TEXT}haxelib run hxgodot help${REGULAR_TEXT} for usage');
         return;
      }

      log('${REGULAR_TEXT}HxGodot (${libInfo.version})');

      switch (args[0]) {
         case 'init' | 'setup':
            // setup project
            if (FileSystem.readDirectory(projectDir).length != 0) {
               log('${ERROR_TEXT}Warning: ${BOLD}The current directory is not empty!');
            }
            var confirmed = prompt('${REGULAR_TEXT}Do you want to populate the current directory ${RESET}($projectDir)${REGULAR_TEXT} with a sample project?',
               doSetupProject, () -> {
                  log('${ERROR_TEXT}${BOLD}No action taken.');
               });
            if (!confirmed)
               return;
            var madeBindings = prompt('${REGULAR_TEXT}Do you want to generate Godot 4 bindings to use with the sample project?', doGenerateBindings, () -> {
               log('${ERROR_TEXT}${BOLD}Did not generate bindings.');
               log('${REGULAR_TEXT}Your project has been setup successfully, ${ERROR_TEXT}but you lack the Godot 4 bindings${RESET}${BOLD}.');
               log('${REGULAR_TEXT}You can generate them manually with `${COMMAND_TEXT}haxelib run hxgodot generate_bindings${RESET}${BOLD}`');
            });
            if (madeBindings) {
               log('${REGULAR_TEXT}Your project has been setup successfully. You can compile it now via:

 ${COMMAND_TEXT}scons platform=<windows|linux|macos> target=<debug|release>

${REGULAR_TEXT}Afterwards, you can open it in Godot 4 - Have fun! :)');
            }
         case 'generate_bindings':
            // generate bindings
            prompt('${REGULAR_TEXT}Do you want to generate Godot 4 bindings in the current directory? ${RESET}($projectDir)', doGenerateBindings, () -> {
               log('${ERROR_TEXT}${BOLD}No action taken.');
            });
         case 'help' | 'usage':
            log('\n${REGULAR_TEXT}Usage:
 ${COMMAND_TEXT}haxelib run hxgodot init
  ${REGULAR_TEXT}1. Setup a sample project in the current working directory.
  2. Generate Godot 4 bindings in the current working directory.

 ${COMMAND_TEXT}haxelib run hxgodot generate_bindings ${ALT_COMMAND_TEXT}[--extension-api-json=<path>]
  ${REGULAR_TEXT}1. Generate Godot 4 bindings in the current working directory.
  
${REGULAR_TEXT}Flags:
 ${COMMAND_TEXT}-y${REGULAR_TEXT}: Automatically confirm any yes/no prompts.
 ${COMMAND_TEXT}-disable-color${REGULAR_TEXT}: Disables color and formatting in output. Can also be disabled by setting ${COMMAND_TEXT}HXGODOT_DISABLE_COLOR=true${REGULAR_TEXT}.');

         #if debug
         case 'header':
            // lets you do `hxgodot header <text>` to test the formatter function
            args.shift(); // to remove the 'header' arg
            log(formatHeader(args.join(' ')));
         #end
      }
   }

   public static function doSetupProject() {
      log('${STATUS_TEXT}Populating project folder...');
      templateDir = Path.join([libDir, "tools", "template"]);
      _recursiveLoop(templateDir);
      log('${SUCCESS_TEXT}Done.\n');
   }

   public static function doGenerateBindings() {
      log('${STATUS_TEXT}Generating Godot 4 Haxe bindings...');
      var args = ['build-bindings.hxml', '-D', 'output="$bindingDir"'];
      if (options.exists('extension-api-json')) {
         args.push('-D');
         args.push('EXT_API_JSON="${options.get('extension-api-json')}"');
      }
      run("", "haxe", args);
      File.saveContent(Path.join([bindingDir, '.gdignore']), '');
      log('${SUCCESS_TEXT}Done.');
   }

   public static inline final PROMPT_TIMEOUT_DURATION:Float = 30;

   public static function prompt(text:String, onYes:Function, onNo:Function):Bool {
      while (true) {

         if (flags.contains('y')) {
            //Sys.println('y');
            onYes();
            return true;
         }
         
         Sys.print(text.trim() + ' $RESET[y/N] ');

         var thread = Thread.create(() -> {
            Sys.sleep(PROMPT_TIMEOUT_DURATION);
            if (Thread.readMessage(false) == null) {
               log('\r\n${ERROR_TEXT}Timeout waiting for user input.\r');
               onNo();
               Sys.exit(-1);
            }
         });

         var code = Sys.getChar(true);
         Sys.print('\n');
         thread.sendMessage(true);

         switch code {
            case 'y'.code | 'Y'.code:
               // yes
               onYes();
               return true;
            case 'n'.code | 'N'.code | 13: // 13 = enter, default
               // no
               onNo();
               return false;
            case 3: // Ctrl+C
               log('${ERROR_TEXT}Exiting.');
               Sys.exit(-1);
               return false;
            default:
               log('${ERROR_TEXT}Please press either ${BOLD}y${ERROR_TEXT} for yes or ${BOLD}n${ERROR_TEXT} for no.');
         }
      }

      return false;
   }

   static function _recursiveLoop(directory:String) {
      if (FileSystem.exists(directory)) {
         for (file in FileSystem.readDirectory(directory)) {
            var path = Path.join([directory, file]);
            if (!FileSystem.isDirectory(path)) {
               _copyFile(path);
            } else {
               var directory = Path.addTrailingSlash(path);
               _recursiveLoop(directory);
            }
         }
      } else {
         log('"$directory" does not exists');
      }
   }

   static function _copyFile(_path:String) {
      var rel = _path.substr(templateDir.length);
      var abs = Path.join([projectDir, rel]);
      log(abs);
      var dir = Path.directory(abs);
      if (!FileSystem.exists(dir))
         FileSystem.createDirectory(dir);
      File.copy(_path, abs);
   }

   /** adds the given string to the header to print */
   static function formatHeader(insert:String):String {
      var header = '${LogoHxColor} __ __     ${LogoGodotColor}_____       _     _
${LogoHxColor}|  |  |_ _${LogoGodotColor}|   __|___ _| |___| |_
${LogoHxColor}|     |_|_${LogoGodotColor}|  |  | . | . | . |  _|
${LogoHxColor}|__|__|_|_${LogoGodotColor}|_____|___|___|___| |\n';
      // adds the insert to the following line if its too long
      if (insert.length > 27)
         return '$header                            |__|\n${StringTools.trim(insert)}';
      // makes sure there are 28 characters before the ascii art continues
      return '$header$RESET${BOLD}${StringTools.rpad(insert, " ", 28)}${LogoGodotColor}|__|$RESET';
   }

   public static var arguments:Array<String> = [];
   public static var flags:Array<String> = [];
   public static var options:Map<String, Null<String>> = [];

   public static function parseArgs(args:Array<String>) {
      var pastArgs = false;

      for (arg in args) {
         if (arg.startsWith('--')) {
            pastArgs = true;
            var eqPos = arg.indexOf('=');
            var key;
            var value = '';
            if (eqPos < 0) {
               key = arg.substr(2);
            } else {
               key = arg.substr(2, eqPos - 2);
               value = arg.substr(eqPos + 1);
            }
            if (options.exists(key))
               options.set(key, options.get(key) + ' $value');
            else
               options.set(key, value);
         } else if (arg.startsWith('-')) {
            pastArgs = true;
            if (!flags.contains(arg.substr(1))) {
               flags.push(arg.substr(1));
            }
         } else {
            arguments.push(arg);
         }
      }
   }
}
