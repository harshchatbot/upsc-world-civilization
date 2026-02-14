# UPSC World: Civilization

Repository layout:
- `mobile/` -> Flutter Android application
- `backend/` -> Backend code (currently empty)

## Development Notes
Use this file to track what was added/changed and which commands were run.

## Update Log
- 2026-02-13: Implemented MVP Scene Engine architecture with bilingual JSON-driven scene/quiz flow, parallax UI, riverpod notifiers, go_router scene->quiz navigation, and just_audio mixer scaffolding.
- 2026-02-13: Built bilingual Scene Player MVP (English/Hindi) with local JSON scene + quiz loading, language preference persistence, Riverpod scene progression controller, 2-track `just_audio` mixer, and 2.5D parallax scene rendering.
- 2026-02-13: Fixed map asset filename mismatch so background loads (`world_ancient_parchment.png`).
- 2026-02-13: Added map camera controls with initial focus, `focusOnNode` animation API, and post-quiz camera jump to next era using `/map?focusNodeId=...`.
- 2026-02-13: Added `RealisticWorldMap` widget with zoom/pan, animated nodes, and fog-of-war overlay, and wired it into the map screen.
- 2026-02-13: Upgraded Android Google Services Gradle plugin from `4.3.15` to `4.4.4`.
- 2026-02-13: Initialized Flutter MVP app and moved all Flutter files into `mobile/`.
- 2026-02-13: Created monorepo root structure with `mobile/` and `backend/`.
- 2026-02-13: Added root `README.md` and root `.gitignore`.

## Command Log
- `cd mobile && flutter pub get`
- `cd mobile && flutter analyze`
- `cd mobile && flutter test`
- `cd mobile && flutter pub get`
- `dart format mobile/lib mobile/test`
- `cd mobile && flutter analyze`
- `cd mobile && flutter test`
- `cd mobile && flutter pub get`
- `dart format mobile/lib mobile/test`
- `cd mobile && flutter analyze`
- `cd mobile && flutter test`
- `cd mobile && flutter analyze`
- `apply_patch` (updated map background asset path to `.png`)
- `dart format mobile/lib/features/map/widgets/realistic_world_map.dart mobile/lib/features/map/presentation/civilization_map_screen.dart mobile/lib/features/quiz/presentation/quiz_screen.dart mobile/lib/app/app_router.dart`
- `cd mobile && flutter analyze`
- `dart format mobile/lib/features/map/widgets/realistic_world_map.dart mobile/lib/features/map/presentation/civilization_map_screen.dart`
- `cd mobile && flutter analyze`
- `sed -n '1,220p' mobile/android/settings.gradle.kts`
- `apply_patch` (updated Google Services plugin version to `4.4.4`)
- `flutter create --project-name upsc_world_civilization --platforms=android .`
- `flutter pub add go_router flutter_riverpod firebase_core cloud_firestore shared_preferences cupertino_icons`
- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `mkdir -p mobile backend`
- `find . -mindepth 1 -maxdepth 1 ! -name '.' ! -name 'mobile' ! -name 'backend' -exec mv {} mobile/ \\;`

## How To Keep This Updated
Whenever you add features or run important setup/build/deploy commands, append entries in:
- `Update Log` for what changed
- `Command Log` for commands used
