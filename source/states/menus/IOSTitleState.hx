package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Lightweight iOS title-screen fallback. Keeps original artwork while avoiding
 * desktop intro scripts, shader initialization, and synchronous music seeks.
 */
class IOSTitleState extends FlxState
{
    private var status:FlxText;
    private var ready:Bool = false;

    override public function create():Void
    {
        super.create();
        FlxG.camera.bgColor = FlxColor.BLACK;
        status = new FlxText(0, FlxG.height - 95, FlxG.width, "LOADING MICKEY TITLE...", 32);
        status.setFormat(null, 32, FlxColor.WHITE, CENTER);

        // Load one image at a time and report missing assets instead of passing
        // invalid image paths to FlxSprite.loadGraphic.
        var bgPath = Paths.image("Spiral Shader Still");
        if (bgPath != null)
        {
            var bg = new FlxSprite().loadGraphic(bgPath);
            bg.setGraphicSize(FlxG.width, FlxG.height);
            bg.updateHitbox();
            add(bg);
        }
        else
            trace("iOS missing title spiral: " + bgPath);

        var mickeyPath = Paths.image("mickeysangre", "preload");
        if (mickeyPath != null)
        {
            var mickey = new FlxSprite().loadGraphic(mickeyPath);
            mickey.screenCenter();
            add(mickey);
        }
        else
            trace("iOS missing Mickey artwork: " + mickeyPath);

        add(status);
        status.text = "TAP TO OPEN MENU";
        status.y = FlxG.height - 95;
        ready = true;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (!ready) return;
        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                ready = false;
                FlxG.switchState(new MainMenuState());
                return;
            }
        }
    }
}
