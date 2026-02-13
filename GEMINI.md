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
- [x] Creating matches (Venue, Date/Time).
- [x] Attendance declaration (In/Out/Reserve).
- [x] Tactical Pitch (Drag & Drop)
- [x] **New:** Team Composition View Embedded in Match Details.
- [ ] Weather Integration (Planned)
- [ ] Formation Templates (Planned)

### Phase 4: Gameplay & Algorithms (✅ Completed)
- **Auto-Balancing**: Algorithm automatically balances teams based on player skills when status is set to "IN".
- **Team View**: Integrated directly into `MatchDetailsScreen`.
- **Drag & Drop**: Admins can manually adjust teams.

### Phase 5: Stats & Payments (📅 Planned)
- Post-match voting (Man of the Match).
- Payment tracking.

### Phase 6: UX/UI Overhaul (✅ Partially Completed)
- [x] **Goal**: "Effect WOW" & Premium Feel.
- [x] **Branding**: Integrate Logo (`assets/logo/footstar-logo.svg`) and Colors (`#00A86B`, `#FFD700`).
- [x] **Theme**: Custom `ThemeData` with modern fonts (Poppins/Montserrat) and styling.
- [x] **Screens Overhauled**:
    - **Splash Screen**: Animated logo with "Neon Turf" glow.
    - **Login/Register**: Dark mode, "Glassmorphism" fields, neon accents.
    - **Onboarding**:
        - **Skill Hexagon**: Interactive radar chart for attribute distribution.
        - **Position Selector**: 2D Mini-Pitch with multi-selection (up to 3 positions).

## 5. Database Schema (Supabase)

### `profiles`
- `id` (UUID, PK, FK to `auth.users`)
- `first_name`, `last_name`, `age`, `positions...`
- `speed`, `technique`... (Skills 1-5)

### `groups`
- `id` (UUID, PK)
- `name`, `invite_code`, `owner_id`
- `is_public`, `city`, `latitude`, `longitude`

### `group_members`
- `id` (UUID, PK)
- `group_id`, `profile_id`
- `role` ('ADMIN', 'PLAYER')
- `status` ('PENDING', 'ACCEPTED', 'REJECTED')

## 6. Development Guidelines
- **State Management**: Using `setState` for MVP, potentially `Riverpod`/`Bloc` later.
- **Architecture**: Feature-based folder structure (`features/auth`, `features/groups`).
- **AI Context**: Use this file to understand the high-level goals before diving into code.


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

