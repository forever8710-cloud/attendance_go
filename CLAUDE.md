# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**attendance_go** (출퇴근GO) is a workforce management system for logistics centers built with Flutter. It's a Dart workspace monorepo containing two apps and three shared packages, backed by Supabase (PostgreSQL + Auth).

- **Manager Web** (`apps/manager_web/`) — Admin dashboard (Flutter Web) for worker management, attendance records, payroll, and settings
- **Worker App** (`apps/worker_app/`) — Mobile app (iOS/Android) for GPS-verified check-in/out via OTP auth

## Build & Run Commands

```bash
# Install all workspace dependencies (run from repo root)
flutter pub get

# Code generation (Freezed models + JSON serialization) — run from packages/core
cd packages/core && dart run build_runner build --delete-conflicting-outputs

# Run Manager Web
cd apps/manager_web && flutter run -d chrome

# Run Worker App
cd apps/worker_app && flutter run -d android   # or -d ios

# Run tests for a specific app/package
cd apps/manager_web && flutter test
cd apps/worker_app && flutter test

# Run a single test file
flutter test test/path_to_test.dart

# Production builds
cd apps/manager_web && flutter build web
cd apps/worker_app && flutter build apk --release
```

## Architecture

### Workspace Structure

```
pubspec.yaml              # Root workspace definition
├── apps/
│   ├── manager_web/      # Flutter Web app (flutter_riverpod, supabase_flutter, intl)
│   └── worker_app/       # Flutter mobile app (adds geolocator, permission_handler)
├── packages/
│   ├── core/             # Shared data models (Freezed), services, exceptions
│   ├── supabase_client/  # Supabase initialization & provider setup
│   └── ui_components/    # Reusable widgets (StatusBadge, SummaryCard)
└── supabase/
    ├── migrations/       # SQL schema: tables, indexes, triggers, RLS policies
    └── functions/        # Edge Functions (e.g., calculate-payroll)
```

### Key Patterns

- **State Management**: Flutter Riverpod — providers live alongside their features (e.g., `features/auth/providers/`)
- **Data Models**: Freezed + JsonSerializable in `packages/core/lib/src/models/`. After modifying models, regenerate with `build_runner build`
- **Feature-based Organization**: Each app organizes code under `features/<feature>/` with `presentation/`, `providers/`, `repositories/` subdirectories
- **Layering**: Screens → Providers (Riverpod) → Repositories → Supabase services
- **Authentication**: Email/password for managers, phone OTP for workers (role field: `worker` | `manager`)

### Database

Five core tables: `sites`, `parts` (wage groups), `workers`, `attendances`, `payrolls`. Schema defined in `supabase/migrations/001-004`. Key details:
- `work_hours` auto-calculated via PostgreSQL trigger on checkout
- Row-Level Security enforces site-scoped access by role
- `payrolls` has a UNIQUE constraint on `(worker_id, year_month)`

## Environment

Requires Flutter SDK ≥ 3.10.7 / Dart ≥ 3.10.7. Copy `.env.example` to `.env` and provide:
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` (required)
- `GOOGLE_MAPS_API_KEY` (optional, for map features)

## Lint Configuration

`analysis_options.yaml` excludes generated files (`*.g.dart`, `*.freezed.dart`). No custom lint rules currently configured.

## Development Notes

- Auth repositories currently use in-memory demo data; Supabase integration is in progress
- The manager web UI uses Material Design 3 with Indigo seed color and light/dark mode support
- Worker app GPS verification uses a configurable radius (default 100m) around site coordinates
- Documentation (PRD, TRD, User Flow) is in `docs/`
