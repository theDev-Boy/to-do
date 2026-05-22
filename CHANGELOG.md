# Changelog

All notable changes to the Finishly (formerly To-Do) app are documented in this file.

## [1.0.0] - 2026-05-21

### 🎯 Project & Branding
- **App renamed** from "To-Do" to **"Finishly"** throughout the entire app
- **Launcher icons** generated from `assets/logo_icon.png` using `flutter_launcher_icons`
- Android app label updated to "Finishly" in `AndroidManifest.xml`
- Updated `pubspec.yaml` with launcher icon configuration (adaptive icon on dark background `#0A0A12`)

### 🔔 Notification System
- **NotificationProvider** — full-featured state management for all notification settings
  - Overdue task repeater with configurable interval (1–60 minutes)
  - Due-soon alerts with configurable lead time (5–60 minutes)
  - Daily digest with configurable time
  - Streak milestone celebrations (7, 30, 100, 365 days)
  - Focus session completion alerts
  - Quiet hours with start/end time and critical override option
  - Toggle controls for haptic, sound, and badge notifications
  - Persistence via `SharedPreferences`
  - Unread notification badge count
- **NotificationService** — native Android notification integration using `flutter_local_notifications` v21
  - Category-specific notification channels (overdue, due-soon, reminders, daily digest, streaks)
  - Notification actions (open app, dismiss)
  - In-app banner display via overlay
  - Badge support
- **OverdueChecker** — periodic timer (30s interval) that scans tasks and fires overdue notifications with deduplication to prevent spam
- **NotificationCenterScreen** — full notification inbox with:
  - Read/unread state per notification
  - Mark all as read action
  - Clear all action
  - Individual dismiss
- **NotificationSettingsScreen** — comprehensive settings UI for all notification toggles
- **NotificationItem model** with `NotificationType` enum (overdue, dueSoon, reminder, dailyDigest, streakMilestone, focusComplete, taskShared)
- Notification bell icon in home screen AppBar with unread count badge

### ✨ Enhanced Bulk Actions & Multi-Select
- **BulkActionBar** — animated slide-up action bar in multi-select mode with:
  - Complete selected tasks (with confetti celebration)
  - Delete selected tasks (with undo toast)
  - Duplicate selected tasks
  - Move to category
  - Change priority
  - Set due date
  - Add tag to all selected
  - Export selected tasks
- **UndoToast** — animated overlay toast with countdown bar for reversible actions
- **ContextMenu** — long-press context menu on task tiles with options:
  - Duplicate task
  - Move to category
  - Change priority
  - Add reminder
  - Archive task
  - Delete task
- Enhanced multi-select UI in HomeScreen and TasksScreen
- Select all / deselect all support
- Haptic feedback on selection changes

### 🎨 Premium Polish
- **ConfettiOverlay** — 4 celebration levels:
  - `showMinorConfetti` — small particle burst (task complete)
  - `showMediumConfetti` — moderate celebration
  - `showMajorConfetti` — full celebration (streak milestones)
  - `showEpicConfetti` — maximum celebration
- **HapticService** — unified haptic feedback (light, medium, heavy, selection click)
- **SoundService** — system sound effects for bulk actions
- Animated task tile entry with `ScaleTransition` (ease-out-back curve)
- Streak badge with fire icon in AppBar
- Swipe-to-complete (left swipe) and swipe-to-delete (right swipe) on task tiles
- Notification unread badge counter
- Improved EmptyState component

### 🔒 Security Improvements

#### Input Sanitization (`lib/services/sanitizer.dart`)
- **Title sanitization**: strips control characters, trims whitespace, enforces 200-char max
- **Description sanitization**: strips control characters, enforces 2000-char max
- **Tag sanitization**: lowercased, restricted to `[a-zA-Z0-9\s\-.#+]` only, enforces 30-char max per tag, max 20 tags
- **Subtask title sanitization**: strips control characters, enforces 150-char max
- **Search query sanitization**: strips control characters, enforces 100-char max
- **Priority validation**: clamped to range [0, 4]
- **Category index validation**: clamped to valid range

#### SQL Injection Protection
- All database queries use **parameterized statements** (`whereArgs`) via `sqflite`'s built-in API
- No raw SQL string concatenation with user input anywhere
- **ID validation**: all task IDs validated against regex `^[a-zA-Z0-9\-_]+$` before database operations
- `PRAGMA foreign_keys = ON` enabled for referential integrity

#### Tags Storage Security
- Tags were previously stored as **comma-separated strings** → vulnerable to injection if a tag contained a comma
- **Switched to `|||` delimiter** — the pipe character is excluded from sanitized tag characters, making delimiter injection impossible
- Secure `encodeTags`/`decodeTags` methods with graceful handling of malformed data

#### Safe Deserialization (`lib/models/task.dart`)
- **Type guards** on all `fromJson()` field extractions to prevent runtime crashes from malformed data
- **Timestamp range validation**: rejected timestamps outside year range ~1900–2100
- **Priority clamping**: deserialized priority values clamped to [0, 4]
- **Subtasks safe parsing**: type-checked list iteration with null-safe field extraction
- **Tags safe parsing**: null-safe with fallback to empty list

#### Data Validation at Provider Layer (`lib/providers/task_provider.dart`)
- `addTask()` sanitizes all inputs at the provider boundary before creating Task objects
- All user inputs are sanitized again at the UI layer in `TaskCreateSheet._save()`
- **Defense in depth**: inputs validated at both UI and provider layers

#### Time Format Validation (`lib/providers/notification_provider.dart`)
- Quiet hours start/end times validated against `HH:MM` regex pattern before saving
- Daily digest time validated against `HH:MM` regex pattern
- Prevents malformed time strings from being persisted

### 🗄️ Architecture & Infrastructure
- `lib/services/sanitizer.dart` — centralized input sanitization utility
- `lib/services/haptic_service.dart` — haptic feedback wrapper
- `lib/services/sound_service.dart` — sound effects wrapper
- `lib/services/overdue_checker.dart` — periodic overdue task checker
- `lib/services/notification_service.dart` — native notification integration
- `lib/providers/notification_provider.dart` — notification state management
- `lib/models/notification_item.dart` — notification data model
- `lib/widgets/confetti_overlay.dart` — particle celebration system
- `lib/widgets/undo_toast.dart` — reversible action toast
- `lib/widgets/context_menu.dart` — long-press context menu
- `lib/widgets/bulk_action_bar.dart` — multi-select action bar
- `lib/screens/notification_center_screen.dart` — notification inbox
- `lib/screens/notification_settings_screen.dart` — notification preferences

### 📦 Package Dependencies Added
- `flutter_local_notifications: ^21.0.0` — native notification support
- `flutter_launcher_icons: ^0.14.4` — app icon generation
- `audioplayers: ^6.6.0` — audio playback (prepared for sound effects)
- `shared_preferences: ^2.5.5` — settings persistence

### 🔧 Fixes
- Fixed all `flutter_local_notifications` v21 API calls (all parameters converted to named parameters)
- Fixed import paths across all files
- Fixed deprecated `activeColor` → `activeThumbColor` in Switch widget
- Fixed bracket structure in `bulk_action_bar.dart`
- Added `mounted` guards for async context safety
- Removed `.characters.take()` calls that required external dependency — replaced with `_truncate()` using `substring()`
