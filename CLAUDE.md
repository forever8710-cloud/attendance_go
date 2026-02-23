# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**attendance_go** (WorkFlow) is a workforce management system for logistics centers built with Flutter. Dart workspace monorepo with two apps and three shared packages, backed by Supabase (PostgreSQL + Auth + Edge Functions).

- **Manager Web** (`apps/manager_web/`) — Admin dashboard (Flutter Web) for worker management, attendance, payroll, calendar, settings
- **Worker App** (`apps/worker_app/`) — Mobile app (iOS/Android) for GPS-verified check-in/out with OAuth/OTP auth

## 중요 문서 위치 (항상 참고)

- 제품 요구사항(PRD)          : @docs/workflow_proposal_md/01_PRD_Workflow.md
- 기술 요구사항(TRD)           : @docs/workflow_proposal_md/02_TRD_Workflow.md
- 사용자 흐름 다이어그램       : @docs/workflow_proposal_md/03_UserFlow_Workflow.md
- 프롬프트 설계 가이드         : @docs/workflow_proposal_md/04_PromptDesign_Workflow.md
- 관리자 웹, 근로자 앱 디자인가이드 : @.claude/skills/design-guideline.md

## Build & Run Commands

```bash
# Install all workspace dependencies (run from repo root)
flutter pub get

# Code generation (Freezed models) — run from packages/core
cd packages/core && dart run build_runner build --delete-conflicting-outputs

# Run Manager Web (quote the path on Windows)
cd "C:\my_project\attendance_go\apps\manager_web" && flutter run -d chrome

# Run Worker App
cd apps/worker_app && flutter run -d android   # or -d ios

# Tests
cd apps/manager_web && flutter test
flutter test test/path_to_test.dart  # single test

# Production builds
cd apps/manager_web && flutter build web --no-tree-shake-icons
cd apps/worker_app && flutter build apk --release
```

## Architecture

### Workspace Structure

```
pubspec.yaml                # Root workspace definition
├── apps/
│   ├── manager_web/        # Flutter Web (Riverpod, supabase_flutter, intl, fl_chart, table_calendar, excel)
│   └── worker_app/         # Flutter mobile (adds geolocator, permission_handler, google_fonts)
├── packages/
│   ├── core/               # Shared Freezed models, services, exceptions
│   ├── supabase_client/    # SupabaseService singleton + Riverpod providers
│   └── ui_components/      # Reusable widgets (StatusBadge, SummaryCard)
└── supabase/
    ├── migrations/         # 12 SQL migrations (001–012)
    └── functions/          # Edge Functions (calculate-payroll, create-auth-user)
```

### Feature-based Organization

Each app uses `features/<feature>/` with subdirectories:
- `presentation/` — Screens, widgets, dialogs
- `providers/` — Riverpod providers and notifiers
- `data/` — Repositories (Supabase queries)

**Manager Web features**: auth, dashboard, workers, worker_detail, attendance_records, payroll, settings, accounts
**Worker App features**: auth, home, attendance, payroll, profile

### Data Flow

Screens → Riverpod Providers/Notifiers → Repositories → `SupabaseService.instance`

### Key Shared Packages

- **`packages/core/lib/src/models/`** — Freezed models: Worker, WorkerProfile, Attendance, Payroll, Announcement, Site, Part. Regenerate after changes with `build_runner build`
- **`packages/supabase_client/`** — `SupabaseService` singleton with `client`, `auth`, `functions` getters

## RBAC & Permissions

4-role hierarchy defined in `apps/manager_web/lib/core/utils/permissions.dart`:

| Role | DB value | Web Access | Scope |
|------|----------|------------|-------|
| `AppRole.systemAdmin` | `system_admin` | All menus | All sites |
| `AppRole.owner` | `owner` | All except Accounts | All sites |
| `AppRole.centerManager` | `center_manager` | Dashboard~Settings | Own site only |
| `AppRole.worker` | `worker` | Worker App only | Self only |

Helper functions: `canAccessMenu(role, index)`, `canEditPayroll(role)`, `canEditAttendance(role)`, `canAccessAllSites(role)`, `canManageAccounts(role)`

**Manager Web side nav indexes**: 0=Dashboard, 1=Workers, 2=Attendance, 3=Payroll, 4=Settings, 5=Accounts

## Authentication

- **Manager Web**: Email/password via `signInWithEmail()`. Password recovery via email link → `AuthChangeEvent.passwordRecovery` → `PasswordChangeDialog`
- **Worker App**: Kakao/Google OAuth (`signInWithOAuth`) or SMS OTP. After OAuth, phone number matching against `workers` table. Deep link: `io.supabase.workflowapp://login-callback`

## Database

**Tables** (12 migrations applied):
- `sites` — 4 centers (서이천, 안성, 의왕, 부평) with GPS coordinates
- `parts` — 6 job types with hourly/daily wages
- `workers` — Employee records with role, site_id, part_id
- `worker_profiles` — Extended info (bank, address, SSN, emergency contact)
- `attendances` — Check-in/out with GPS coords; `work_hours` auto-calculated by trigger
- `payrolls` — Monthly salary with `is_finalized` flag; UNIQUE on `(worker_id, year_month)`
- `announcements` — CRUD with `is_active` toggle, optional `site_id`
- `calendar_events` — Dashboard calendar events with category, location, color

**RLS**: Enforced via `get_my_role()` and `get_my_site_id()` helper functions (SECURITY DEFINER). Workers see own data, center_managers see own site, admins see all.

**Edge Functions**:
- `calculate-payroll` — Aggregates attendance data into payroll (service_role)
- `create-auth-user` — Creates Supabase Auth user + workers + worker_profiles atomically (service_role, with rollback)

## Important Conventions

- **Class name `Center`** conflicts with Flutter Widget → use `SiteCenter` instead
- **`DropdownButtonFormField`** uses `initialValue` (not deprecated `value`)
- **`Geolocator`** uses `locationSettings: LocationSettings(accuracy:)` (deprecated positional params removed)
- **Phone numbers**: Store as digits-only, convert with `phone_utils.dart` (E.164 format)
- **Company constants**: `apps/manager_web/lib/core/utils/company_constants.dart` — companies (BT/TK), centers (IC/AS/UW/BP), parts
- **Employee ID format**: `BT-IC001` (company-center-sequence) via `employee_id_generator.dart`
- **`onWorkerTap` signature**: `void Function(String id, String name)` — workerId-based navigation

## Environment

Requires Flutter SDK ≥ 3.41.1 / Dart ≥ 3.10.7. `.env` file in `apps/manager_web/` and `apps/worker_app/`:
- `SUPABASE_URL`, `SUPABASE_ANON_KEY` (required)
- `GOOGLE_MAPS_API_KEY` (optional)
- `JUSO_CONFIRM_KEY` (optional, juso.go.kr address API)

## Lint Configuration

`analysis_options.yaml` excludes generated files (`*.g.dart`, `*.freezed.dart`). No custom lint rules.
