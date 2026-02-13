# Design Principles & Style Guide

## 1. Core Atmosphere
- **Vibe**: "Enter the Arena". Energetic, premium, dark sports aesthetic.
- **Key Emotions**: Adrenaline, Focus, Professionalism (even for amateurs).

## 2. Color Palette
- **Pitch Black (#0B0C10)**: Main background. Deep, OLED-friendly black.
- **Carbon Grey (#1F2833)**: Surface color (cards, inputs).
- **Neon Turf (#66FCF1)**: Primary Action/CTA (Buttons, Active States).
- **Tactical Green (#45A29E)**: Secondary elements (icons, stats).
- **Golden Whistle (#FFC107)**: Accents and highlights.
- **Red Card (#CF6679)**: Destructive actions (Resign, Delete).

## 3. UI Components & Behavior

### Splash Screen
- **Background**: Pitch Black.
- **Effect**: Subtle pitch lines in background with a "charging/pulsing" animation effect.
- **Logo**: Starts as Carbon Grey outline, then ignites to Neon Turf (like stadium lights turning on).
- **Duration**: ~1.5s.

### Login Screen ("The Locker Room")
- **Background**: Pitch Black with subtle bottom pattern (net/lines) in Carbon Grey.
- **Inputs**:
    - Default: Carbon Grey fill, no border.
    - Focus: Neon Turf glowing border/ring.
- **Primary Button**:
    - Fill: Neon Turf.
    - Text: Pitch Black, Poppins Bold (High Contrast).
- **Secondary Links**: Tactical Green (muted).

### Profile Creation ("Build Your Player")
- **Player Card (Header)**:
    - **Concept**: A "FUT Card" (FIFA Ultimate Team style) that updates live.
    - **Style**: Carbon Grey card with Golden Whistle accents. Shows Name, Overall Rating (calculated from skills), and Position.
- **Attributes (Skills)**:
    - **Interaction**: Dual-view.
        - **Input**: Neon Sliders (lines that glow brighter as value increases).
        - **Visual**: Hexagon/Radar Chart that morphs in real-time as sliders move.
    - **Feedback**: "Total Points" counter pulses Red (over limit) or Gold (perfect distribution).
- **Position Selection**:
    - **Interface**: 2D Mini-Pitch (2/3 width) + Info Panel (1/3 width).
    - **Action**: Tap zone on pitch to select **up to 3** positions (Primary, Secondary, Tertiary).
    - **Feedback**: Zones light up, numbered 1-3. Info panel shows details for the last tapped position.

### Dashboard (Home Screen)
- **Navigation**: "Dom" (Home) Tab.
- **Hero Section (Top 40%)**:
    - **Content**: The "Next Match" Card. Most important info (Countdown, Check-in Button).
    - **Visual**: Dominant, perhaps with a dynamic background (e.g., stadium photo with dark overlay).
- **Quick Actions (Middle)**:
    - **Groups Carousel**: Horizontal scroll of Team Badges (Circular).
    - **Add Group**: Neon Turf "+" button at the end.
- **Match List (Bottom)**:
    - **Content**: Vertical list of other/future matches.
    - **Style**: More compact Carbon Grey cards.

### Match Details ("The Pitch")
- **Tactical Board (Default View)**:
    - **Visual**: Dark Green styling (Night Pitch).
    - **Interaction**:
        - **Admin**: Can drag & drop ANY player token to set formation.
        - **Player**: Can drag ONLY their own token to suggest position or move to bench.
- **Bench / Reserves**:
    - **Logic**: First come, first served queue for reserves. Auto-promotion if a main player resigns.
- **Action Buttons**:
    - **Join/Play**: Neon Turf, Full Width/Large.
    - **Resign/Leave**: Red Card (#CF6679), Same Size as Join. High contrast warning.

### Groups & Discovery ("Scouting Network")
- **Group View**:
    - **Header**: Team Crest + Stats (Goals, Matches).
    - **Members**: "Locker Room" Grid view (Player Cards) instead of a list. Admin = Captain Armband.
- **Discovery (Map of Poland)**:
    - **Visual**: Dark Mode Map.
    - **Markers**: "Bubbles" / Clusters indicating the count of teams in a city (e.g., "7" over Warsaw).
    - **Interaction**:
        - Tap Bubble/City -> Side Panel slides in.
        - **Side Panel**: List of teams in that city with "Join" buttons.
