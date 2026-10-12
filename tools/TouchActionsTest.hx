import input.TouchActions;

class TouchActionsTest
{
    static function expect(value:Bool, message:String):Void
    {
        if (!value) throw message;
    }

    static function main():Void
    {
        var input = new TouchActions();
        input.advance(["note_left", "note_down", "note_up", "note_right"]);
        for (lane in ["left", "down", "up", "right"])
            expect(input.check("note_" + lane + "-press"), "Four-finger chord dropped " + lane);
        input.advance(["note_left", "note_left", "note_down"]);
        expect(input.check("note_left"), "Hold lost");
        expect(!input.check("note_left-press"), "Hold retriggered");
        expect(input.check("note_up-release"), "Release edge lost");
        input.advance(["note_left"]);
        expect(!input.check("note_left-release"), "Lifting a second finger released the first");
        input.advance(["note_right", "accept", "dodge"]);
        expect(input.check("note_left-release") && input.check("note_right-press"), "Slide did not transfer lanes");
        expect(input.check("accept") && input.check("dodge-press"), "Menu or dodge action lost");
        input.advance(["note_right", "accept", "dodge"]);
        expect(!input.check("accept") && !input.check("dodge-press"), "Held menu/dodge action retriggered");
        input.clear();
        expect(!input.check("note_right") && !input.check("accept"), "Focus/state reset retained input");
        input.advance([]);
        expect(!input.check("note_right-release"), "Old release leaked across states");
        Sys.println("Touch actions: chords, sustains, duplicate fingers, sliding, edges and focus reset passed");
    }
}
