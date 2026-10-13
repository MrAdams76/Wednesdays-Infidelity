import util.AssetCaseIndex;

class AssetPathsTest
{
    static function main():Void
    {
        var assets = new AssetCaseIndex([
            "assets/shared/images/characters/Sad_Demon.json",
            "assets/shared/images/characters/SAD_DEMON.png",
            "assets/images/titleEnter.xml"
        ]);
        var cases = [
            ["shared:assets/shared/images/characters/SAD_DEMON.json", "shared:assets/shared/images/characters/Sad_Demon.json"],
            ["shared:assets/shared/images/characters/SAD_DEMON.png", "shared:assets/shared/images/characters/SAD_DEMON.png"],
            ["assets/images/TITLEENTER.xml", "assets/images/titleEnter.xml"],
            ["shared:assets/shared/images/missing.png", "shared:assets/shared/images/missing.png"]
        ];
        for (entry in cases)
            if (assets.resolve(entry[0]) != entry[1]) throw 'Asset lookup failed: ${entry[0]}';
        Sys.println("Asset paths: original atlas case, library prefixes, default assets and missing paths passed");
    }
}
