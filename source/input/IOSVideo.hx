package input;

#if ios
import flixel.FlxG;
import openfl.display.Sprite;
import openfl.events.Event;

/** Native AVFoundation playback of the original bundled PC cinematics. */
class IOSVideo extends Sprite
{
    public var readyCallback:Void->Void;
    public var finishCallback:Void->Void;
    public var onError:Void->Void;
    public var skipable:Bool = false;
    public var focus:Bool = true;
    public var isPlaying:Bool = false;
    var ready:Bool = false;
    var pauseMusic:Bool = false;

    public function new(?focus:Bool = true)
    {
        super();
        this.focus = focus;
    }

    public function playVideo(path:String, ?repeat:Bool = false, ?pauseMusic:Bool = false):Void
    {
        this.pauseMusic = pauseMusic;
        if (pauseMusic && FlxG.sound.music != null) FlxG.sound.music.pause();
        isPlaying = true;
        ready = false;
        FlxG.stage.addEventListener(Event.ENTER_FRAME, update);
        FlxG.signals.focusLost.add(pause);
        FlxG.signals.focusGained.add(resume);
        NativeVideo.play(path, skipable, repeat);
    }

    function update(event:Event):Void
    {
        if (!isPlaying) return;
        NativeVideo.volume(FlxG.sound.muted ? 0 : FlxG.sound.volume);
        var status = NativeVideo.status();
        if (status == 1 && !ready)
        {
            ready = true;
            if (readyCallback != null) readyCallback();
        }
        if (status == -1)
        {
            trace("iOS video playback failed");
            if (onError != null) onError();
            finishVideo();
        }
        else if (status == 2) finishVideo();
    }

    public function finishVideo():Void
    {
        if (!isPlaying) return;
        var callback = finishCallback;
        dispose();
        if (pauseMusic && FlxG.sound.music != null) FlxG.sound.music.resume();
        if (callback != null) callback();
    }

    public function pause():Void { if (focus && isPlaying) NativeVideo.pause(); }
    public function resume():Void { if (focus && isPlaying) NativeVideo.resume(); }
    public function dispose():Void
    {
        isPlaying = false;
        FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);
        FlxG.signals.focusLost.remove(pause);
        FlxG.signals.focusGained.remove(resume);
        NativeVideo.dispose();
    }
}
#end
