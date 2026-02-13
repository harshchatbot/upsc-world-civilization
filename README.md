# UPSC World: Civilization

Repository layout:
- `mobile/` -> Flutter Android application
- `backend/` -> Backend code (currently empty)

## Development Notes
Use this file to track what was added/changed and which commands were run.

## Update Log
- 2026-02-13: Initialized Flutter MVP app and moved all Flutter files into `mobile/`.
- 2026-02-13: Created monorepo root structure with `mobile/` and `backend/`.
- 2026-02-13: Added root `README.md` and root `.gitignore`.

## Command Log
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
