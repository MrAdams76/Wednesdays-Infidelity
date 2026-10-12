# Wednesday's Infidelity V2: iOS reconstruction

Source reconstruction pass, October 12, 2026. Target: iPhone 15.
Base: `ios/clean-baseline` at `95812a358ee88e3de216056f26ef172a97817525`.
PC reference: `lunarcleint/Wednesdays-Infidelity` at `7040c99293fbf1fef55f56c7593bf0954553e2ca`.

## Implemented

- Continue follows the original warning, unfinished notice and title flow. The diagnostic stop and still-image title replacement are removed.
- Original title atlas animations, spiral, chromatic effects, bloom and transition animation are active according to the user's settings. iOS retains the original 1280 x 720 game space.
- The old vendored Lime native backend is isolated to desktop builds. iOS uses the pinned Lime 8.2.2 backend, avoiding mismatched native event structures. Existing SDL synthetic-mouse suppression is retained. The device tap crash must still be retested.
- Menu controls feed the existing Controls actions in Story Mode, both Freeplay menus, options, pause, game over and confirmation dialogs. Four independent touch lanes feed the original note judgement and sustain logic. Dodge, pause, preview and menu-code entry are available by touch.
- Song loading uses registered asset IDs rather than Sound objects. Charts, extra event files and all original song scripts use bundled asset access on iOS. Shared assets are registered before startup artwork is requested.
- All ten original cinematics are packaged. AVFoundation plays the original MP4 files with their original progression-dependent skip permissions, aspect ratio, completion callbacks, focus handling and volume. Codemagic no longer replaces video playback with a skip stub.
- Chromatic uniforms have their declared vector sizes. GLSL ES float arithmetic and VHS RGB component sampling are corrected. Bloom retains its original sampling formula with constant loop bounds for GLES.
- Freeplay preview loads audio asynchronously and rejects stale requests after selection or state changes.

## Verified locally

- All 809 original asset blobs match the PC reference. No songs, charts, audio, character assets, backgrounds, films or animation atlases were modified or removed.
- Content checks cover 20 week songs, required charts/voices/characters, all ten cutscenes, the title atlas and original grain.
- Haxe touch tests pass for four-finger chords, sustains, duplicate fingers, sliding, press/release edges and focus reset.
- iOS Haxe type checking and C++ code generation pass with the pinned library versions. One existing flixel-ui enum warning remains.
- Lime iOS update generates the Xcode project and copies all ten MP4s under the generated resource folder.
- The five fragment shader bodies compile as GLSL ES using Mesa with a minimal compatible sampling header. This verifies shader syntax, not visual fidelity or Apple GPU performance.

## Required before declaring the whole port complete

This Linux environment cannot compile or run an iPhone application. No newly built IPA or complete-song device test is claimed.

Run Codemagic's `ios-unsigned` workflow on this branch. It checks content, touch behavior and Objective-C++ syntax before compiling the unsigned ARM64 app. Then install the IPA and verify startup taps; every menu; repeated restart/game-over transitions; simultaneous notes and holds; dodging; every original cinematic; and both story endings. Compare each song's full visuals and audio timing against the original PC build, including its grain, shaders, character phases and camera sequences.

The source changes restore the original implementations and their iOS execution paths. A clean build and full device/PC comparison are still necessary to establish that every runtime issue is resolved. `master` remains the Windows baseline.
