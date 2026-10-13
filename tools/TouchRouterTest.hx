import input.TouchRouter;

class TouchRouterTest
{
    static function expect(value:Bool, message:String):Void
    {
        if (!value) throw message;
    }

    static function main():Void
    {
        var router = new TouchRouter();
        router.zones = TouchRouter.gameplay("Hitbox", 1280, 720);
        router.zones.push({x:20, y:15, width:140, height:65, action:"pause"});
        router.zones.push({x:1070, y:15, width:190, height:90, action:"dodge"});
        router.advance([{id:1,x:0,y:0},{id:2,x:320,y:150},{id:3,x:640,y:719},{id:4,x:1279,y:719}]);
        for (name in ["left", "down", "up", "right"])
            expect(router.actions.check('note_$name-press'), 'Full-height chord lost $name');
        router.advance([{id:1,x:320,y:150}]);
        expect(!router.actions.check('note_left') && router.actions.check('note_down'), "Boundary overlaps two lanes");
        router.advance([{id:1,x:50,y:30},{id:2,x:1100,y:30}]);
        expect(router.actions.check("pause") && router.actions.check("dodge-press"), "Utility buttons failed");
        expect(!router.actions.check("note_left") && !router.actions.check("note_right"), "Utility buttons also hit notes");
        router.reset([1]);
        router.advance([{id:1,x:400,y:300},{id:5,x:700,y:300}]);
        expect(!router.actions.check("note_down") && router.actions.check("note_up-press"), "Carried finger leaked across state");
        router.advance([]);
        router.advance([{id:1,x:400,y:300}]);
        expect(router.actions.check("note_down-press"), "Reused finger ID stayed blocked");
        router.advance([{id:1,x:400,y:300},{id:2,x:400,y:300}]);
        router.advance([{id:2,x:400,y:300}]);
        expect(router.actions.check("note_down") && !router.actions.check("note_down-release"), "Second finger lost sustain");
        router.advance([{id:2,x:700,y:300}]);
        expect(router.actions.check("note_down-release") && router.actions.check("note_up-press"), "Slide transfer failed");
        for (layout in ["Left pad", "Right pad"])
        {
            router.reset([]);
            router.zones = TouchRouter.gameplay(layout, 1280, 720);
            for (i in 0...4)
            {
                var zone = router.zones[i];
                expect(zone.x >= 0 && zone.y >= 0 && zone.x + zone.width <= 1280 && zone.y + zone.height <= 720,
                    '$layout button outside viewport');
                router.advance([{id:1,x:zone.x + zone.width / 2,y:zone.y + zone.height / 2}]);
                expect(router.actions.check(zone.action), '$layout button does not match hitbox');
            }
        }
        router.advance([]);
        expect(!router.actions.check("note_right"), "Released pad stuck down");
        Sys.println("Touch routing: full-height chords, boundaries, utility priority, state reset, reused IDs, holds, slides and both pads passed");
    }
}
