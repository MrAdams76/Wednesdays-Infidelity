package input;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.io.Path;

class NativeVideoBuild
{
    public static function build():Array<Field>
    {
        var root = Path.normalize(sys.FileSystem.fullPath(Path.directory(Context.resolvePath("input/NativeVideo.hx")) + "/../../native/ios"));
        var pos = Context.currentPos();
        var type = Context.getLocalClass().get();
        type.meta.add(":include", [macro $v{root + "/WIVideo.h"}], pos);
        var xml = '<files id="haxe"><file name="${root}/WIVideo.mm" /></files>'
            + '<target id="haxe"><lib name="-framework AVFoundation" /><lib name="-framework UIKit" /><lib name="-framework AVKit" /></target>';
        type.meta.add(":buildXml", [macro $v{xml}], pos);
        return Context.getBuildFields();
    }
}
#end
