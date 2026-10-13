package input;

typedef TouchZone = {x:Float, y:Float, width:Float, height:Float, action:String};
typedef TouchContact = {id:Int, x:Float, y:Float};

/** Android-style overlap buttons: each finger contributes to one action. */
class TouchRouter
{
    public var actions = new TouchActions();
    public var zones:Array<TouchZone> = [];
    var blocked:Map<Int, Bool> = [];

    public function new() {}

    public function reset(downIds:Array<Int>):Void
    {
        actions.clear();
        blocked = [];
        for (id in downIds) blocked.set(id, true);
    }

    public function advance(contacts:Array<TouchContact>):Void
    {
        var down:Map<Int, Bool> = [];
        for (contact in contacts) down.set(contact.id, true);
        for (id in blocked.keys()) if (!down.exists(id)) blocked.remove(id);
        var active:Array<String> = [];
        for (contact in contacts)
        {
            if (blocked.exists(contact.id)) continue;
            // Last drawn controls win: Pause/Dodge must never also hit a note.
            var i = zones.length;
            while (i > 0)
            {
                var zone = zones[--i];
                if (contact.x >= zone.x && contact.x < zone.x + zone.width
                    && contact.y >= zone.y && contact.y < zone.y + zone.height)
                {
                    active.push(zone.action);
                    break;
                }
            }
        }
        actions.advance(active);
    }

    public static function gameplay(layout:String, width:Float, height:Float):Array<TouchZone>
    {
        var names = ["note_left", "note_down", "note_up", "note_right"];
        if (layout != "Left pad" && layout != "Right pad")
            return [for (i in 0...4) {x: i * width / 4, y: 0.0, width: width / 4, height: height, action: names[i]}];
        var size = Math.min(width / 9, height / 5);
        var gap = 8.0;
        var left = layout == "Left pad" ? 20.0 : width - 20 - size * 3 - gap * 2;
        var bottom = height - size - 24;
        return [
            {x:left, y:bottom, width:size, height:size, action:names[0]},
            {x:left + size + gap, y:bottom, width:size, height:size, action:names[1]},
            {x:left + size + gap, y:bottom - size - gap, width:size, height:size, action:names[2]},
            {x:left + (size + gap) * 2, y:bottom, width:size, height:size, action:names[3]}
        ];
    }
}
