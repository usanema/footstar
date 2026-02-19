# FootStar - Project Overview

## 1. Project Description
**FootStar** is an application designed to help amateur football teams organize matches, manage player attendance, handle payments, and track statistics. It aims to solve the common chaos of organizing "Sunday league" games.

## 2. Technology Stack
- **Frontend**: Flutter (Mobile & Web)
- **Backend**: Java 21 + Spring Boot 3.2 (Business Logic, API)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth (Client-side login, Backend JWT verification)
- **Maps**: OpenStreetMap (planned via `flutter_map`)

## 3. Project Structure
The repository is divided into two main components:
- `footstar-frontend/`: Flutter application code.
- `footstar-backend/`: Spring Boot application code.

## 4. Key Features & Status

### Phase 1: Authentication & Onboarding (✅ Completed)
- **Auth**: Email/Password login & registration via Supabase.
- **Profile Creation**:
    - **Personal Info**: Name, Age, Position (Primary/Secondary).
    - **Skill Assessment**: Users distribute **30 points** across 8 attributes (Speed, Technique, etc.).
    - **Data**: Stored in `profiles` table in Supabase.
- **UX Improvements**:
    - Submit Login on Enter key.
    - Logout functionality.

### Phase 2: Group Management (✅ Completed)
- **Create Group**: Users can create teams with a unique invite code.
- **Discovery**: Public groups are searchable by name or city.
- **Joining**:
    - Users request to join via Invite Code.
    - **Roles**: Owner (ADMIN) and Members (PLAYER).
    - **Status**: Membership requires Admin approval (`PENDING` -> `ACCEPTED`).
- **Database**: `groups` and `group_members` tables created.

### Phase 3: Match Organization (✅ Completed)
- [x] Creating matches (Venue, Date/Time, Max Players, Description, Recurring flag).
- [x] Attendance declaration (IN / OUT / RESERVE).
- [x] Tactical Pitch (Drag & Drop) — `TacticalBoardWidget` with full-screen expand.
- [x] Team Composition View embedded in `MatchDetailsScreen`.
- [x] **Bench Widget** — shows unplaced IN-players; admin can drag them to pitch.
- [ ] Weather Integration (Planned — FS-6)
- [ ] Formation Templates (Planned — FS-2)

### Phase 4: Gameplay & Algorithms (✅ Completed)
- **Auto-Balancing**: `TeamBalancerService` balances teams by player skill when status changes to IN.
- **Pitch Positioning**: `PitchPositioningService` assigns normalized (x, y) coordinates.
- **Team View**: Integrated directly into `MatchDetailsScreen`.
- **Drag & Drop**: Admins can manually move players between teams and on the pitch.
- **Clear Position**: Players can be dragged from pitch back to bench (clears pitchX/Y).

### Phase 5: Stats & Payments (📅 Planned)
- Post-match voting / Man of the Match (FS-5).
- Payment tracking (FS-4).

### Phase 6: UX/UI Overhaul (✅ Partially Completed)
- [x] **Branding**: Logo (`assets/logo/footstar-logo.svg`), Colors (`#00A86B` primary, `#FFD700` secondary).
- [x] **Theme**: `AppColors` + `AppTextStyles` in `core/app_theme.dart` (Poppins/Montserrat).
- [x] **Splash Screen**: Animated logo with "Neon Turf" glow.
- [x] **Login/Register**: Dark mode, Glassmorphism fields, neon accents, floodlight animation.
- [x] **Onboarding**: Radar chart skill selector + 2D Mini-Pitch position selector (up to 3 positions).
- [x] **Bottom Navigation** (`MainScreen`): 3 tabs — Home, Explore, Profile — with nested `Navigator` per tab.
- [x] **Explore Screen**: Search for matches, groups, and players with debounced query + 3 tabs.

### Phase 7: Carpooling (✅ Completed — embedded in Match Details)
- Players can declare they have a car and set available seats.
- Visible in `PlayerListCard` — car icon shown next to player name.
- Controls (toggle + seat counter) visible only for the current user.

## 5. Frontend File Structure (key files)

```
lib/
├── core/
│   └── app_theme.dart              # AppColors, AppTextStyles, ThemeData
├── features/
│   ├── auth/                       # Login, Register screens
│   ├── splash/                     # SplashScreen (animated logo)
│   ├── onboarding/                 # OnboardingScreen, SkillHexagon, PositionSelector
│   │   └── data/models/profile_model.dart
│   ├── home/
│   │   └── presentation/
│   │       ├── main_screen.dart        # Root: BottomNavigationBar + IndexedStack (3 tabs)
│   │       ├── home_screen.dart        # Home tab content
│   │       ├── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── tab_navigator.dart
│   │           ├── next_match_card.dart
│   │           ├── groups_carousel.dart
│   │           └── compact_match_list.dart
│   ├── explore/
│   │   ├── data/search_repository.dart
│   │   └── presentation/
│   │       ├── explore_screen.dart     # Search: Matches / Groups / Players tabs
│   │       └── widgets/
│   │           ├── match_search_card.dart
│   │           ├── group_search_card.dart
│   │           └── player_search_card.dart
│   ├── groups/
│   │   ├── data/
│   │   │   ├── group_repository.dart
│   │   │   ├── models/group_model.dart
│   │   │   └── models/group_member_model.dart
│   │   └── presentation/
│   │       ├── create_group_screen.dart
│   │       ├── find_group_screen.dart
│   │       └── group_details_screen.dart
│   └── matches/
│       ├── data/
│       │   ├── match_repository.dart
│       │   └── models/
│       │       ├── match_model.dart        # id, groupId, date, location, maxPlayers, isRecurring
│       │       └── match_player_model.dart # id, matchId, profileId, status, team, pitchX/Y, hasCar, carSeats
│       ├── domain/services/
│       │   ├── team_balancer_service.dart
│       │   └── pitch_positioning_service.dart
│       └── presentation/
│           ├── create_match_screen.dart
│           ├── match_details_screen.dart   # Main hub: hero, status, roster, tactical board, bench
│           ├── team_generation_screen.dart
│           └── widgets/
│               ├── match_hero_section.dart
│               ├── status_selector.dart        # IN / OUT / RESERVE buttons
│               ├── player_list_card.dart       # Tabbed roster: ALL / TEAM A / TEAM B + carpooling
│               ├── tactical_board_widget.dart  # Drag & drop pitch, full-screen mode
│               └── bench_widget.dart           # Unplaced players, admin drag-to-bench
```

## 6. Database Schema (Supabase)

### `profiles`
- `id` (UUID, PK, FK to `auth.users`)
- `first_name`, `last_name`, `age`
- `position_primary`, `position_secondary` (up to 3 positions stored)
- `speed`, `technique`, `strength`, `stamina`, `passing`, `shooting`, `defending`, `goalkeeping` (int, total = 30)
- `avatar_url` (optional)

### `groups`
- `id` (UUID, PK)
- `name`, `invite_code`, `owner_id`
- `is_public`, `city`, `latitude`, `longitude`

### `group_members`
- `id` (UUID, PK)
- `group_id`, `profile_id`
- `role` ('ADMIN', 'PLAYER')
- `status` ('PENDING', 'ACCEPTED', 'REJECTED')

### `matches`
- `id` (UUID, PK)
- `group_id`, `date`, `location`, `max_players`
- `description`, `is_recurring`, `recurrence_pattern`
- `created_at`

### `match_attendance` (match_players)
- `id` (UUID, PK)
- `match_id`, `profile_id`
- `status` ('IN', 'OUT', 'RESERVE', 'UNKNOWN')
- `team` ('A', 'B', null)
- `pitch_x`, `pitch_y` (double, normalized 0.0–1.0, nullable)
- `has_car` (bool), `car_seats` (int)

## 7. Backlog (footstar-frontend/backlog/tasks/)

| ID | Title | Status | Milestone |
|----|-------|--------|-----------|
| FS-1 | Bottom Navigation Implementation | ✅ Done | Phase 6 |
| FS-2 | Formation Templates | ⬜ To Do | Phase 3 |
| FS-3 | Map Implementation (Discovery) | ⬜ To Do | Phase 6 |
| FS-4 | Payment Tracking | ⬜ To Do | Phase 5 |
| FS-5 | Post-match Voting & Man of the Match | ⬜ To Do | Phase 5 |
| FS-6 | Weather Integration | ⬜ To Do | Phase 3 |

**Next recommended task**: FS-6 (Weather Integration) or FS-2 (Formation Templates) — both Phase 3.

## 8. Development Guidelines
- **State Management**: Using `setState` for MVP, potentially `Riverpod`/`Bloc` later.
- **Architecture**: Feature-based folder structure (`features/auth`, `features/groups`, etc.).
- **Design System**: All colors/fonts via `AppColors` and `AppTextStyles` from `core/app_theme.dart`.
- **Admin vs Player**: `isAdmin` flag passed to screens; admin-only features (drag & drop, team moves) gated behind it.
- **Supabase direct**: Frontend calls Supabase directly (no Spring Boot backend used yet in frontend).
- **AI Context**: Read this file first to understand project state before diving into code.


<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_workflow_overview()` tool to load the tool-oriented overview (it lists the matching guide tools).

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->
