package input;

/** Aggregates fingers by action so lifting one finger never releases another. */
class TouchActions
{
    public var held:Map<String, Bool> = [];
    public var pressed:Map<String, Bool> = [];
    public var released:Map<String, Bool> = [];

    public function new() {}

    public function advance(actions:Array<String>):Void
    {
        var next:Map<String, Bool> = [];
        for (action in actions) next.set(action, true);
        pressed = [];
        released = [];
        for (action in next.keys())
            if (!held.exists(action)) pressed.set(action, true);
        for (action in held.keys())
            if (!next.exists(action)) released.set(action, true);
        held = next;
    }

    public function check(action:String):Bool
    {
        if (StringTools.endsWith(action, "-press"))
            return pressed.exists(action.substr(0, action.length - 6));
        if (StringTools.endsWith(action, "-release"))
            return released.exists(action.substr(0, action.length - 8));
        if (action == "accept" || action == "back" || action == "pause" || action == "reset" || action == "preview")
            return pressed.exists(action);
        return held.exists(action);
    }

    public function clear():Void
    {
        held = [];
        pressed = [];
        released = [];
    }
}
