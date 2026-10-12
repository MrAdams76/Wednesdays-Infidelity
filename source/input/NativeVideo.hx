package input;

#if ios
@:build(input.NativeVideoBuild.build())
extern class NativeVideo
{
    @:native("wi_video_play") public static function play(path:cpp.ConstCharStar, skippable:Bool, repeat:Bool):Void;
    @:native("wi_video_status") public static function status():Int;
    @:native("wi_video_pause") public static function pause():Void;
    @:native("wi_video_resume") public static function resume():Void;
    @:native("wi_video_volume") public static function volume(value:Float):Void;
    @:native("wi_video_dispose") public static function dispose():Void;
    @:native("wi_menu_code_open") public static function openCode():Void;
    @:native("wi_menu_code_poll") public static function pollCode():cpp.ConstCharStar;
}
#end
