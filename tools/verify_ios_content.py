"""Check required original content and iOS reconstruction wiring before an IPA build."""
from pathlib import Path
import json
import re
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
errors = []
asset_paths = {str(path.relative_to(ROOT)).lower() for path in (ROOT / "assets").rglob("*") if path.is_file()}

def require(path):
    if not (ROOT / path).is_file():
        errors.append(f"Missing bundled content: {path}")

project = ET.parse(ROOT / "Project.xml").getroot()
assert any("ios" in node.get("if", "") for node in project.findall("define")
           if node.get("name") == "VIDEOS_ALLOWED"), "iOS cutscenes are disabled"
assert not (ROOT / "source/lime/_internal/backend/native/NativeApplication.hx").exists(), \
    "iOS is shadowing the pinned Lime native backend"
frameworks = {node.get("name") for node in project.findall("dependency") if node.get("if") == "ios"}
assert {"AVFoundation.framework", "CoreMedia.framework"} <= frameworks, "Native video frameworks are missing"
assert "-framework" not in (ROOT / "source/input/NativeVideoBuild.hx").read_text(), \
    "Framework linker flags must not reach the hxcpp static archiver"

for path in ["native/ios/WIVideo.mm", "native/ios/WIVideo.h", "source/input/MobileInput.hx",
             "assets/preload/images/titleEnter.png", "assets/preload/images/titleEnter.xml",
             "assets/preload/music/freakyMenu.ogg", "assets/shared/images/grain.png"]:
    require(path)

cutscenes = (ROOT / "source/states/game/CutsceneState.hx").read_text()
videos = re.findall(r'video = "([^"]+)";', cutscenes)
for name in videos:
    require(f"assets/videos/{name}.mp4")

weeks = ROOT / "assets/preload/weeks"
week_names = [name.strip() for name in (weeks / "weekList.txt").read_text().splitlines() if name.strip()]
assert len(week_names) == len(set(week_names)), "Duplicate week IDs"
assert set(week_names) == {path.stem for path in weeks.glob("*.json")}, "Week index is incomplete"
songs = set()
for path in weeks.glob("*.json"):
    for entry in json.loads(path.read_text())["songs"]:
        songs.add(entry[0].lower().replace(" ", "-"))
for song in sorted(songs):
    require(f"assets/songs/{song}/Inst.ogg")
    # The original menu defaults to Hard; a different chart alone is insufficient.
    require(f"assets/preload/data/{song}/{song}-hard.json")
    charts = list((ROOT / "assets/preload/data" / song).glob("*.json"))
    charts = [path for path in charts if path.stem != "events"]
    if not charts:
        errors.append(f"Missing charts: {song}")
    for chart in charts:
        data = json.loads(chart.read_text().rstrip().rstrip("\x00"))["song"]
        if data.get("needsVoices"):
            require(f"assets/songs/{song}/Voices.ogg")
        for key in ["player1", "player2", "gfVersion"]:
            if data.get(key):
                character_path = f'assets/preload/characters/{data[key]}.json'
                require(character_path)
                if (ROOT / character_path).exists():
                    character = json.loads((ROOT / character_path).read_text())
                    image = character.get("image")
                    bases = [ROOT / "assets/preload/images", ROOT / "assets/shared/images"]
                    atlas_ext = {"SPARROW": "xml", "PACKER": "txt", "JSON": "json", "GENERICXML": "xml"}.get(character.get("dataType", "SPARROW"), "xml")
                    for ext in ["png", atlas_ext]:
                        if image and not any(str((base / f"{image}.{ext}").relative_to(ROOT)).lower() in asset_paths for base in bases):
                            errors.append(f"Missing character artwork: {image}.{ext}")
        if data.get("stage"):
            require(f'assets/preload/stages/{data["stage"]}.json')

for path in ["source/states/menus/WarningState.hx", "source/states/menus/TitleState.hx"]:
    source = (ROOT / path).read_text()
    assert "TOUCH RECEIVED - APP STILL RUNNING" not in source, "Startup is still diagnostic-only"
    assert "ClientPrefs.shaders = false" not in source, "Original shaders are forcibly disabled"
assert "finishVideo();" not in (ROOT / "codemagic.yaml").read_text(), "Build still replaces video with a skip stub"
if "--generated-project" in sys.argv:
    generated = ROOT / "export/release/ios"
    projects = list(generated.glob("*.xcodeproj/project.pbxproj"))
    assert len(projects) == 1, "Expected one generated iOS Xcode project"
    xcode = projects[0].read_text()
    for framework in ["AVFoundation", "CoreMedia"]:
        assert f"{framework}.framework in Frameworks" in xcode, f"Xcode does not link {framework}"
    for name in videos:
        assert list(generated.glob(f"*/assets/assets/videos/{name}.mp4")), f"Xcode resources omit {name}"
if errors:
    raise SystemExit("\n".join(sorted(set(errors))))
print(f"Content check passed: {len(week_names)} weeks, {len(songs)} songs with Hard charts, character artwork, stages, {len(videos)} cinematics and native frameworks")
