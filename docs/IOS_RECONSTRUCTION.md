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

## Follow-up reconstruction pass

Built on `33b19cf`, preserving the later native-framework, warning-screen and menu fixes.

- Fixed the underlying bundled week-list reader on iOS and the fallback's literal-backslash newline split. The shipped index contains seven weeks and twenty songs.
- Story selection and resume now use the selected week's ID even when hidden weeks are filtered from the menu.
- iOS asset lookup handles original Windows filename case differences, including `SAD_DEMON` versus `Sad_Demon.json`. Atlas helpers now pass the requested library as the library argument, rather than as an asset type.
- Gameplay touch lanes cover the lower 64% of the game view with visible original arrow artwork and colored feedback. Menu hitboxes extend to the bottom and side edges. Button backgrounds use scaled one-pixel graphics instead of allocating full-size bitmaps.
- Combo placement supports touch dragging; rating placement also accepts the directional pad. Key rebinding can be canceled with Back, and its timeout restores the correct binding row instead of indexing past it. Pause music respects the None setting.
- Failed song/library loads display a return-to-menu action. Late asynchronous callbacks cannot leave a destroyed loading state or switch into gameplay after a load failure.
- Codemagic keeps the M4 runner, explicitly pins hxcpp 4.3.2, hxp 1.3.0 and format 3.8.0, and no longer runs dependency-changing `lime setup` after pinning. Its generated-project check verifies final-app framework linking and packaged videos.

Validation: all 809 original asset blobs remain identical to the PC reference; all seven week definitions, twenty playable Hard charts, their character artwork/atlases and stages, and ten videos pass the content check. Haxe touch tests and iOS C++ generation pass; generated hxcpp build instructions contain the native video source without framework linker flags. All Codemagic shell scripts pass `bash -n`. The existing flixel-ui enum warning remains.

The archived, unlisted Phantasm chart references `Happy_Mouse` artwork absent from the original repository. It is not part of the twenty menu-listed songs and has not been enabled or replaced with invented artwork. Full Xcode linking, installation, performance, and complete-song playthroughs still require Codemagic and an iPhone.
