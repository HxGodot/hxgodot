package godot.macros;

#if macro

import godot.macros.TypeMacros;

using StringTools;

@:structInit
private class BBStackLevel {
    public var id:String;
    public var params:Array<String>;
    public var raw:String;
    public var content:String = "";
    public var closed:Bool = false;
    public var unknown:Bool = false;
    var ldDump:BBStackLevel->String = null;

    public static function create(_id:String, _params:Array<String>, _raw:String):BBStackLevel {
        var res:BBStackLevel = {id: _id, params: _params, raw: _raw};

        switch (_id) {
            //
            case 'b': res.ldDump = (_sl) -> '**${_sl.content}**';
            //
            case 'i': res.ldDump = (_sl) -> '*${_sl.content}*';
            //
            case 'ul': res.ldDump = (_sl) -> '- ${_sl.content}';
            //
            case 'ol': res.ldDump = (_sl) -> '- ${_sl.content}';
            //
            case 'codeblocks': res.ldDump = (_sl) -> '<p>${_sl.content}</p>';
            //
            case 'codeblock', 
                 'csharp', 
                 'gdscript': res.ldDump = (_sl) -> 
                    '```${_id}\n${_id=="gdscript" ? "#" : "//"}${_id}\n${_sl.content}```'.replace("\n\n", "\n");
            //
            case 'code': res.ldDump = (_sl) -> '`${_sl.content}`';
            //
            case 'url': res.ldDump = (_sl) -> {
                    var url = _sl.params.length > 0 ? _sl.params[0] : _sl.content;
                    url = url.replace("$DOCS_URL", "https://docs.godotengine.org/en/stable");
                    return '[${_sl.content}]($url)';
                };
            //
            case 'member', 
                 'constant', 
                 'param': {
                res.closed = true;
                res.ldDump = (_sl) -> {
                    var tokens = _sl.params[0].split(".");
                    tokens[0] = TypeMacros.getTypeName(tokens[0]);
                    return '`${TypeMacros.getTypeName(tokens.join("."))}`';
                };
            }
            //
            case 'method': {
                res.closed = true; 
                res.ldDump = (_sl) -> {
                    var tokens = _sl.params[0].split(".");
                    tokens[0] = TypeMacros.getTypeName(tokens[0]);
                    if (tokens.length > 1)
                        return '`${tokens.join(".")}`';
                    else
                        return '<code><a href="#${_sl.params[0]}">${_sl.params[0]}</a></code>';
                };
            }
            //
            case 'color': res.ldDump = (_sl) -> '${_sl.content}';
            //
            default: {
                res.unknown = true; 
                res.ldDump = (_sl) -> '${_sl.content}';
            }
        }
        return res;
    }

    public function isCodeTag():Bool
        return id == 'code';

    public function isCodeBlock():Bool {
        return switch(id) {
            case 'gdscript', 'csharp', 'codeblock': true;
            default: false;
        };
    }

    public function dump(_parent:BBStackLevel):String {
        var isInsideCodeBlock = _parent != null ? _parent.isCodeBlock() : false;
        var isInsideCodeTag = _parent != null ? _parent.isCodeTag() : false;

        // make sure we dont accidently break the comment blocks:
        content = content.replace("*/", "* /");

        if (unknown) {
            var tn = TypeMacros.getTypeName(id);
            if (id != tn) {
                return '`${tn}`';
            } else {
                var res = '`${raw}`';
                if (Std.isOfType(Std.parseInt(id.charAt(0)), Int)) {
                    res = '[$raw]';
                    if (content.length > 0)
                        res += '${content}[/${id}]';
                    res = '$res';
                }
                else if (isInsideCodeTag) {
                    res = '${raw}';
                    if (id.charAt(0) == id.charAt(0).toLowerCase()) {
                        if (content.length > 0)
                            res += '${content}';
                        res = '$res'; // [code][unnamed_project][/code]
                    } else
                        res = '`$res`'; // [code][Vector2][/code]
                } else if (isInsideCodeBlock) {
                    res = '[$raw]';
                    if (content.length > 0)
                        res += '${content}[/${id}]';
                    res = '$res';
                }
                return res;
            }
        } else {
            return ldDump != null && !isInsideCodeBlock && !isInsideCodeTag ? ldDump(this) : '${content}';
        }
    }
}

class DocTools {
    public static function convertBBCodeToMarkdown(_str:String):String {
        if (_str == null)
            return null;
        
        var stack:Array<BBStackLevel> = [{id:'_root', params:[], raw: ''}];
        var input = _str.replace("\n", "\n\n");
        var output = new StringBuf();
        var pos = null;
        var re_tags = ~/\[([^\]]+)\]/gm;

        while (re_tags.match(input)) {
            pos = re_tags.matchedPos();         
            stack[0].content += input.substr(0, pos.pos);
            var code = re_tags.matched(1);
            var tokens = code.indexOf('=') != -1 ? code.split("=") : code.split(" ");
            var id = tokens.shift();
            var isTerminator = id.startsWith("/");
            if (isTerminator && id.endsWith(stack[0].id)) {
                stack[0].closed = true;
                var tmp = stack.shift();
                stack[0].content += tmp.dump(stack[0]);
            } else {
                var tag = BBStackLevel.create(id, tokens, '$code');
                if (tag != null) {
                    if (!stack[0].isCodeTag() && !stack[0].isCodeBlock() && !tag.closed && !tag.unknown)
                        stack.unshift(tag);
                    else
                        stack[0].content += tag.dump(stack[0]);
                }
            }
            input = input.substr(pos.pos + pos.len);
        }
        
        stack[0].content += input.substr(0);
        output.add(stack[0].dump(null));

        return output.toString(); 
    }

    public static function test() {
        trace(convertBBCodeToMarkdown(test_string));
    }

    static var test_string = "
Returns the absolute value of a [Variant] parameter [param x] (i.e. non-negative value). Supported types: [int], [float], [Vector2], [Vector2i], [Vector3], [Vector3i], [Vector4], [Vector4i].
[codeblock]
var a = abs(-1)
# a is 1

var b = abs(-1.2)
# b is 1.2

var c = abs(Vector2(-3.5, -4))
# c is (3.5, 4)

var d = abs(Vector2i(-5, -6))
# d is (5, 6)

var e = abs(Vector3(-7, 8.5, -3.8))
# e is (7, 8.5, 3.8)

var f = abs(Vector3i(-7, -8, -9))
# f is (7, 8, 9)
[/codeblock]
[b]Note:[/b] For better type safety, use [method absf], [method absi], [method Vector2.abs], [method Vector2i.abs], [method Vector3.abs], [method Vector3i.abs], [method Vector4.abs], or [method Vector4i.abs].

Draws multiple disconnected lines with a uniform [param width] and segment-by-segment coloring. Each segment is defined by two consecutive points from [param points] array and a corresponding color from [param colors] array, i.e. i-th segment consists of [code]points[2 * i][/code], [code]points[2 * i + 1][/code] endpoints and has [code]colors[i][/code] color. When drawing large amounts of lines, this is faster than using individual [method draw_line] calls. To draw interconnected lines, use [method draw_polyline_colors] instead.
If [param width] is negative, then two-point primitives will be drawn instead of a four-point ones. This means that when the CanvasItem is scaled, the lines will remain thin. If this behavior is not desired, then pass a positive [param width] like [code]1.0[/code].
    ";
}

#end 