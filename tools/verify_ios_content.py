"""Check required original content and iOS reconstruction wiring before an IPA build."""
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
errors = []

def require(path):
    if not (ROOT / path).is_file():
        errors.append(f"Missing bundled content: {path}")

project = ET.parse(ROOT / "Project.xml").getroot()
assert any("ios" in node.get("if", "") for node in project.findall("define")
           if node.get("name") == "VIDEOS_ALLOWED"), "iOS cutscenes are disabled"
assert not (ROOT / "source/lime/_internal/backend/native/NativeApplication.hx").exists(), \
    "iOS is shadowing the pinned Lime native backend"

for path in ["native/ios/WIVideo.mm", "native/ios/WIVideo.h", "source/input/MobileInput.hx",
             "assets/preload/images/titleEnter.png", "assets/preload/images/titleEnter.xml",
             "assets/preload/music/freakyMenu.ogg", "assets/shared/images/grain.png"]:
    require(path)

cutscenes = (ROOT / "source/states/game/CutsceneState.hx").read_text()
videos = re.findall(r'video = "([^"]+)";', cutscenes)
for name in videos:
    require(f"assets/videos/{name}.mp4")

weeks = ROOT / "assets/preload/weeks"
songs = set()
for path in weeks.glob("*.json"):
    for entry in json.loads(path.read_text())["songs"]:
        songs.add(entry[0].lower().replace(" ", "-"))
for song in sorted(songs):
    require(f"assets/songs/{song}/Inst.ogg")
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
                require(f'assets/preload/characters/{data[key]}.json')

for path in ["source/states/menus/WarningState.hx", "source/states/menus/TitleState.hx"]:
    source = (ROOT / path).read_text()
    assert "TOUCH RECEIVED - APP STILL RUNNING" not in source, "Startup is still diagnostic-only"
    assert "ClientPrefs.shaders = false" not in source, "Original shaders are forcibly disabled"
assert "finishVideo();" not in (ROOT / "codemagic.yaml").read_text(), "Build still replaces video with a skip stub"
if errors:
    raise SystemExit("\n".join(sorted(set(errors))))
print(f"Content check passed: {len(songs)} week songs, {len(videos)} original cinematics, title atlas and grain")
