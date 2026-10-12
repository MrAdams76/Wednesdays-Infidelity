package input;

#if ios
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.game.PlayState;

/** Runs as a plugin after Flixel updates touches, before states read controls. */
class MobileInput extends FlxBasic
{
    public static var actions = new TouchActions();
    var owner:FlxState;
    var padCamera:FlxCamera;
    var pad:FlxGroup;
    var hitboxes:Array<FlxSprite> = [];
    var names:Array<String> = [];
    var blocked:Map<Int, Bool> = [];

    public function new()
    {
        super();
        FlxG.signals.focusLost.add(clear);
    }

    public static function check(action:String):Bool return actions.check(action);

    function clear():Void
    {
        actions.clear();
        for (touch in FlxG.touches.list) blocked.set(touch.touchPointID, true);
    }

    override public function update(elapsed:Float):Void
    {
        var current:FlxState = FlxG.state;
        while (current.subState != null) current = current.subState;
        if (current != owner || (padCamera != null && FlxG.cameras.list.indexOf(padCamera) < 0))
        {
            rebuild(current);
            // A press that opened a menu must not select its first entry too.
            clear();
        }
        var active:Array<String> = [];
        for (touch in FlxG.touches.list)
        {
            if (!touch.pressed)
            {
                blocked.remove(touch.touchPointID);
                continue;
            }
            if (blocked.exists(touch.touchPointID)) continue;
            for (i in 0...hitboxes.length)
                if (touch.overlaps(hitboxes[i], padCamera)) active.push(names[i]);
        }
        actions.advance(active);
        for (i in 0...hitboxes.length)
            hitboxes[i].alpha = StringTools.startsWith(names[i], "note_")
                ? (actions.held.exists(names[i]) ? 0.08 : 0.0)
                : (actions.held.exists(names[i]) ? 0.35 : 0.14);
    }

    function rebuild(current:FlxState):Void
    {
        if (pad != null) pad.destroy();
        pad = null;
        // Substates may retain the last padCamera. Reuse it until Flixel resets
        // cameras for a new state, rather than destroying it under a pause menu.
        if (padCamera != null && FlxG.cameras.list.indexOf(padCamera) < 0) padCamera = null;
        hitboxes = [];
        names = [];
        owner = current;
        var type = Type.getClassName(Type.getClass(current));
        if (type == "states.menus.WarningState" || type == "states.menus.TitleState"
            || type == "states.menus.UnfinishedState" || type == "states.game.CutsceneState"
            || type == "states.LoadingState" || type == "util.CustomFadeTransition" || type == "Init" || type == "data.SpecsDetector") return;

        if (padCamera == null)
        {
            padCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
            padCamera.bgColor = FlxColor.TRANSPARENT;
            FlxG.cameras.add(padCamera, false);
        }
        pad = new FlxGroup();
        if (Std.isOfType(current, PlayState))
        {
            var labels = ["LEFT", "DOWN", "UP", "RIGHT"];
            var laneNames = ["note_left", "note_down", "note_up", "note_right"];
            for (i in 0...4)
                button(i * FlxG.width / 4, FlxG.height * 0.55, FlxG.width / 4, FlxG.height * 0.45, laneNames[i], labels[i]);
            button(20, 15, 140, 65, "pause", "PAUSE");
            button(FlxG.width - 210, 15, 190, 90, "dodge", "DODGE");
        }
        else
        {
            var labels = ["LEFT", "UP", "DOWN", "RIGHT", "SELECT", "BACK"];
            var menuNames = ["ui_left", "ui_up", "ui_down", "ui_right", "accept", "back"];
            var w = (FlxG.width - 40) / labels.length;
            for (i in 0...labels.length)
                button(20 + i * w, FlxG.height - 90, w - 6, 72, menuNames[i], labels[i]);
            if (type == "states.menus.FreeplayState") button(20, 15, 160, 65, "preview", "PREVIEW");
            if (type == "states.menus.MainMenuState")
            {
                button(20, 15, 140, 65, "code", "CODE");
                if (data.Progression.beatMainWeek) button(FlxG.width - 210, 15, 190, 65, "reset", "RESET SAVE");
            }
            if (type == "states.options.BaseOptionsMenu" || type.indexOf("SettingsSubState") >= 0
                || type == "states.options.NoteOffsetState") button(20, 15, 140, 65, "reset", "RESET");
        }
    }

    function button(x:Float, y:Float, w:Float, h:Float, action:String, label:String):Void
    {
        var box = new FlxSprite(x, y).makeGraphic(Std.int(w), Std.int(h), FlxColor.WHITE);
        box.scrollFactor.set();
        box.cameras = [padCamera];
        box.alpha = 0.14;
        pad.add(box);
        hitboxes.push(box);
        names.push(action);
        var text = new FlxText(x, y + h - 38, w, label, 22);
        text.setFormat(null, 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.scrollFactor.set();
        text.cameras = [padCamera];
        pad.add(text);
    }

    override public function draw():Void
    {
        if (pad != null) pad.draw();
    }

    override public function destroy():Void
    {
        FlxG.signals.focusLost.remove(clear);
        if (pad != null) pad.destroy();
        if (padCamera != null && FlxG.cameras.list.indexOf(padCamera) >= 0) FlxG.cameras.remove(padCamera);
        actions.clear();
        super.destroy();
    }
}
#end
