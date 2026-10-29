# Synapse Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build "Synapse", an ambient, widget-first routine, medication, hydration, health, and memory companion app in Flutter using the Adaptive Bento architecture.

**Architecture:** A local-first Flutter application featuring a dynamic time-aware Bento UI, an NLP intent parser for conversational audio/text input, a local persistence and encryption engine, and native home/lock screen widget synchronization (`home_widget`).

**Tech Stack:** 
- Flutter & Dart
- State Management: `flutter_riverpod`
- Local Database & Storage: `shared_preferences` / SQLite (`sqflite` or JSON document store)
- Audio & Speech: `speech_to_text` + simulated voice visualizer
- Home & Lock Screen Widgets: `home_widget`
- Notifications & Alarms: `flutter_local_notifications`
- Sensors: `sensors_plus` / `pedometer` for sedentary activity sensing
- Styling: Custom Obsidian dark theme with glassmorphism, haptics (`HapticFeedback`), and spring physics

**Spec:** `design_synapse_adaptive_bento.md`

---

## Global Constraints & Principles
- **No Boilerplate Material Look**: Custom minimalist obsidian theme (`#0A0A0C`), subtle luminescent glows (emerald `#10B981`, cyan/water `#06B6D4`, amber `#F59E0B`, violet `#8B5CF6`), and monospaced serials (`SYN.AM`, `DOSAGE.2X`, `H2O.250ML`).
- **Physical Haptic Feedback**: Every primary action (toggle ring, voice record start/stop, water drop log, reminder dismiss) triggers tactile haptic feedback.
- **TDD & High Testability**: Core data models, NLP intent parsing, inventory decrementing, hydration logging, and adherence score calculations are thoroughly tested with unit tests before wiring to the UI.

---

## File Structure & Module Decomposition

```
D:\Dev\synapse/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   └── utils/
│   │       ├── haptics_util.dart
│   │       └── date_time_util.dart
│   ├── models/
│   │   ├── routine_item.dart
│   │   ├── movement_state.dart
│   │   ├── hydration_state.dart
│   │   ├── memory_item.dart
│   │   └── smart_reminder.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── nlp_parser_service.dart
│   │   ├── adherence_report_service.dart
│   │   ├── movement_sensor_service.dart
│   │   └── widget_sync_service.dart
│   ├── providers/
│   │   ├── routine_provider.dart
│   │   ├── hydration_provider.dart
│   │   ├── memory_provider.dart
│   │   ├── movement_provider.dart
│   │   └── reminder_provider.dart
│   ├── ui/
│   │   ├── widgets/
│   │   │   ├── bento_card.dart
│   │   │   ├── pillbox_tile.dart
│   │   │   ├── movement_tile.dart
│   │   │   ├── hydration_tile.dart
│   │   │   ├── memory_vault_tile.dart
│   │   │   ├── adherence_ring.dart
│   │   │   └── ambient_mic_capsule.dart
│   │   └── screens/
│   │       ├── home_bento_screen.dart
│   │       ├── query_sheet.dart
│   │       └── report_export_sheet.dart
└── test/
    ├── models/
    │   ├── routine_item_test.dart
    │   ├── hydration_state_test.dart
    │   └── memory_item_test.dart
    └── services/
        ├── nlp_parser_service_test.dart
        ├── adherence_report_service_test.dart
        └── storage_service_test.dart
```

---

## Task Breakdown

### Task 1: Project Scaffolding & Theme Engine
- [ ] Initialize `pubspec.yaml` with essential dependencies (`flutter_riverpod`, `shared_preferences`, `intl`, `uuid`).
- [ ] Implement `AppColors` and `AppTheme` with the Obsidian editorial palette, custom text themes, and smooth card radius tokens.
- [ ] Create `HapticsUtil` and `DateTimeUtil` for uniform physical feedback and DaySector calculations.

### Task 2: Core Domain Models & Unit Tests (TDD)
- [ ] Write unit tests for `RoutineItem` (inventory decrement logic, refill threshold alert calculation, streak progression).
- [ ] Write unit tests for `HydrationState` (intake increments, target percentages, timestamp logs).
- [ ] Implement `RoutineItem`, `MovementState`, `HydrationState`, `MemoryItem`, and `SmartReminder` data models with clean JSON serialization.
- [ ] Run test suite and confirm all model tests pass cleanly.

### Task 3: Local Persistence & Storage Service
- [ ] Write unit tests for `StorageService` verifying save/load/delete of routines, hydration logs, memories, and reminders.
- [ ] Implement `StorageService` using local key-value JSON document persistence.
- [ ] Run test suite and verify storage resilience and offline retrieval.

### Task 4: NLP Intent & Entity Parser Engine
- [ ] Write unit tests for `NLPParserService` covering:
  - Routine extraction: *"Take 2 Metformin at 8am with food"* $\rightarrow$ `RoutineItem`
  - Hydration logging: *"Drank a glass of water"* or *"Had 500ml"* $\rightarrow$ Hydration Intent
  - Spaced dosing: *"Take Pill B 30 mins after breakfast"* $\rightarrow$ `SmartReminder` with countdown
  - Passive memory: *"Car parked on Level 2 Spot B14"* $\rightarrow$ `MemoryItem`
  - Adherence query: *"Did I take my blood pressure pills?"* $\rightarrow$ Query Intent
- [ ] Implement `NLPParserService` with regex and pattern matching heuristics for on-device zero-latency parsing.
- [ ] Verify test suite passes with 100% accuracy on sample voice utterances.

### Task 5: Movement & Hydration Inactivity Engines
- [ ] Implement `MovementSensorService` to calculate sedentary intervals and micro-break recommendations.
- [ ] Create `MovementNotifier` and `HydrationNotifier` in Riverpod to track daily steps, active standing hours, and water consumption.
- [ ] Add double-pulse haptic alert trigger when inactivity exceeds 50 minutes, paired with a water hydration prompt.

### Task 6: Adherence Report & Clinical PDF Exporter
- [ ] Write unit tests for `AdherenceReportService` verifying 30-day compliance percentage calculations, movement consistency, and hydration averages.
- [ ] Implement `AdherenceReportService` to aggregate daily logs and generate clean markdown/tabular clinical summaries.
- [ ] Verify adherence math and export formatting.

### Task 7: Adaptive Bento UI Components
- [ ] Implement `BentoCard` with frosted glassmorphism border and subtle background depth.
- [ ] Implement `PillboxTile` with time-sector toggle rings, food tags, and supply indicators.
- [ ] Implement `HydrationTile` with liquid wave progress visualizer and quick `+250ml` droplet button.
- [ ] Implement `MovementTile` with circular progress arc and quick micro-break actions.
- [ ] Implement `MemoryVaultTile` with visual photo thumbnail anchors and tag chips.
- [ ] Implement `AmbientMicCapsule` floating dock with pulsating audio decibel animations and tap-to-talk state.

### Task 8: Main Dashboard & Time-Morphing Engine
- [ ] Implement `HomeBentoScreen` connecting Riverpod providers to the Adaptive Bento grid.
- [ ] Implement dynamic hero slot shifting based on `DateTime.now()`:
  - Morning (06:00–12:00): Pillbox Hero + Morning Water Kickoff
  - Midday (12:00–18:00): Movement & Micro-Break Hero + Hydration Wave
  - Evening (18:00–23:59): Night Regimen + Daily Hydration Review
- [ ] Add `QuerySheet` ("Ask Synapse") conversational slide-up sheet.
- [ ] Add `ReportExportSheet` with 30-day compliance visual graph and export action.

### Task 9: Home Screen Widget Integration Hook
- [ ] Implement `WidgetSyncService` bridging Flutter state to native AppWidget / WidgetKit payloads via JSON synchronization.
- [ ] Verify automated background sync whenever a medication, water intake, or movement item is toggled.
