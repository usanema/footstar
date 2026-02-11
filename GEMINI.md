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

### Phase 2: Group Management (🚧 In Progress)
- **Create Group**: Users can create teams with a unique invite code.
- **Discovery**: Public groups are searchable by name or city (Database & Repository ready).
- **Joining**:
    - Users request to join via Invite Code.
    - **Roles**: Owner (ADMIN) and Members (PLAYER).
    - **Status**: Membership requires Admin approval (`PENDING` -> `ACCEPTED`).
- **Database**: `groups` and `group_members` tables created.

### Phase 3: Match Organization (✅ Implemented / 🚧 In Progress)
- [x] Creating matches (Venue, Date/Time).
- [x] Attendance declaration (In/Out/Reserve).
- [x] Tactical Pitch (Drag & Drop)
- [ ] Weather Integration
- [ ] Formation Templates

### Phase 4: Gameplay & Algorithms (📅 Planned)
- Team balancing algorithm based on player skills.
- Team generation view.

### Phase 5: Stats & Payments (📅 Planned)
- Post-match voting (Man of the Match).
- Payment tracking.

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
