package godot;

enum abstract GDPropertyHint(Int) from Int to Int {
    var NONE = 0; ///< no hint provided.
    var RANGE; ///< hint_text = "min,max[,step][,or_greater][,or_less][,hide_slider][,radians][,degrees][,exp][,suffix:<keyword>] range.
    var ENUM; ///< hint_text= "val1,val2,val3,etc"
    var ENUM_SUGGESTION; ///< hint_text= "val1,val2,val3,etc"
    var EXP_EASING; /// exponential easing function (Math::ease) use "attenuation" hint string to revert (flip h), "positive_only" to exclude in-out and out-in. (ie: "attenuation,positive_only")
    var LINK;
    var FLAGS; ///< hint_text= "flag1,flag2,etc" (as bit flags)
    var LAYERS_2D_RENDER;
    var LAYERS_2D_PHYSICS;
    var LAYERS_2D_NAVIGATION;
    var LAYERS_3D_RENDER;
    var LAYERS_3D_PHYSICS;
    var LAYERS_3D_NAVIGATION;
    var FILE; ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,"
    var DIR; ///< a directory path must be passed
    var GLOBAL_FILE; ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,"
    var GLOBAL_DIR; ///< a directory path must be passed
    var RESOURCE_TYPE; ///< a resource object type
    var MULTILINE_TEXT; ///< used for string properties that can contain multiple lines
    var EXPRESSION; ///< used for string properties that can contain multiple lines
    var PLACEHOLDER_TEXT; ///< used to set a placeholder text for string properties
    var COLOR_NO_ALPHA; ///< used for ignoring alpha component when editing a color
    var IMAGE_COMPRESS_LOSSY;
    var IMAGE_COMPRESS_LOSSLESS;
    var OBJECT_ID;
    var TYPE_STRING; ///< a type string, the hint is the base type to choose
    var NODE_PATH_TO_EDITED_NODE; ///< so something else can provide this (used in scripts)
    var METHOD_OF_VARIANT_TYPE; ///< a method of a type
    var METHOD_OF_BASE_TYPE; ///< a method of a base type
    var METHOD_OF_INSTANCE; ///< a method of an instance
    var METHOD_OF_SCRIPT; ///< a method of a script & base
    var PROPERTY_OF_VARIANT_TYPE; ///< a property of a type
    var PROPERTY_OF_BASE_TYPE; ///< a property of a base type
    var PROPERTY_OF_INSTANCE; ///< a property of an instance
    var PROPERTY_OF_SCRIPT; ///< a property of a script & base
    var OBJECT_TOO_BIG; ///< object is too big to send
    var NODE_PATH_VALID_TYPES;
    var SAVE_FILE; ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,". This opens a save dialog
    var GLOBAL_SAVE_FILE; ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,". This opens a save dialog
    var INT_IS_OBJECTID;
    var ARRAY_TYPE;
    var INT_IS_POINTER;
    var LOCALE_ID;
    var LOCALIZABLE_STRING;
    var NODE_TYPE; ///< a node object type
    var HIDE_QUATERNION_EDIT; /// Only Node3D::transform should hide the quaternion editor.
    var PASSWORD;
    var MAX;
}