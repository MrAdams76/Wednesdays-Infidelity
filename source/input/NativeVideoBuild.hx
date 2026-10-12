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
        // hxcpp creates a static archive on iOS. Apple frameworks must be
        // linked by the Xcode app target, not passed to libtool here.
        var xml = '<files id="haxe"><file name="${root}/WIVideo.mm" /></files>';
        type.meta.add(":buildXml", [macro $v{xml}], pos);
        return Context.getBuildFields();
    }
}
#end
