package util;

/** Lime lists local IDs; OpenFL lookups may prefix those IDs with a library. */
class AssetCaseIndex
{
    var paths:Map<String, String> = [];

    public function new(assetIds:Array<String>)
    {
        for (id in assetIds) paths.set(id.toLowerCase(), id);
    }

    public function resolve(path:String):String
    {
        var colon = path.indexOf(":");
        var prefix = colon < 0 ? "" : path.substr(0, colon + 1);
        var localPath = path.substr(colon + 1);
        var exact = paths.get(localPath.toLowerCase());
        return exact == null ? path : prefix + exact;
    }
}
