PRD — HOME WIDGETS, BULK ACTIONS, NOTIFICATIONS & PREMIUM POLISH
ROLE & MISSION
You are a world-class mobile developer and UI/UX engineer. You will add production-grade features to the existing Glassmorphism To-Do app. Every feature must feel native, premium, and Apple Design Award worthy. No gradients anywhere. Glassmorphism only. Smooth 60fps animations. All features must work flawlessly like a shipping app.

📦 PART 1: HOME SCREEN WIDGETS (10-15 Widgets)
Widget System Architecture
Build a Widget Picker Screen inside Settings → Widgets

User sees a grid of all available widgets (glass cards, 2-column grid)

Each widget has: preview thumbnail, name, size options (Small / Medium / Large), Add to Home Screen button

Widgets are live, updating every 5 minutes or on app data change

All widgets follow glassmorphism: semi-transparent dark background with blur, white text, accent color highlights

Widget List (Build All 15)
#	Widget Name	Size Options	Description
1	Today Tasks	S / M / L	Shows today's pending tasks count + first 2-5 task titles with priority dots
2	Progress Ring	S / M	Circular animated ring showing today's completion % (done/total)
3	Streak Flame	S	Just the fire emoji + streak number + "days" text, ultra minimal
4	Quick Add	S / M	Single tap button "＋ New Task", opens mini composer directly
5	Focus Timer	M / L	Shows current Pomodoro time remaining, pause/resume button, task name
6	Overdue Alert	S / M	Red pulsing dot + count of overdue tasks + oldest overdue task title
7	Next Up	M / L	Next 3 upcoming tasks sorted by due date and priority
8	Category Breakdown	M / L	Mini horizontal bars showing task count per category (top 4 categories)
9	Weekly Heatmap	L	7 small circles (Mon-Sun), filled color intensity based on tasks completed that day
10	Quote Widget	S / M	Motivational quote that changes daily, subtle glass card
11	Focus Today	M	One big task recommendation: "Focus on: [Task Name]" — AI picks highest priority overdue or due-soon task
12	Productivity Score	S	Score number (0-100) + mini trend arrow up/down
13	Upcoming Reminders	M / L	Shows tasks with reminders set, with time badges
14	Completed Today	S / M	"✅ 8 completed" with subtle celebration confetti on number change
15	Calendar Mini	M / L	7-day horizontal strip, today highlighted, dots on days with tasks
Widget Customization (Per Widget)
Tap widget → opens app to relevant screen (Today → Today tab, Timer → Focus tab, etc.)

Long-press widget on home screen → "Edit Widget" menu

Customize options per widget:

Choose which category/tag to display

Choose accent color for this widget only

Choose glass opacity level (Light Glass / Medium / Heavy)

Choose font size (Small / Default / Large)

Show/hide task count badge

Show/hide priority indicators

Widget background auto-matches system dark/light mode

Widget updates instantly when task is completed/added in app

Widget States
Loading: Shimmer glass skeleton while data loads (first install)

Empty: "No tasks for today 🎉" with subtle floating icon

Error: "Couldn't load" with retry arrow, glass card with red subtle border

Permission Denied: If notifications blocked, small warning on relevant widgets

📦 PART 2: BULK ACTIONS & MULTI-SELECT
Enter Multi-Select Mode
Long-press any task card (0.4s hold) → enters selection mode

Task card slightly scales down (0.96) + glass border turns accent color + checkbox appears with spring animation

Top bar transforms: Title changes to "X Selected" with animated count, shows action buttons

Haptic feedback: Medium impact on enter, light impact on each selection

Tap to select/deselect individual tasks

Select All button appears in top bar when 2+ tasks selected

Exit selection mode: Tap "Cancel", swipe down on top bar, or tap empty area

Bulk Action Bar (Appears at Bottom)
Glass action bar slides up with spring from bottom:

Action	Icon	Behavior
Complete All	✓✓	Marks all selected as done, confetti burst, 400ms stagger animation per card
Delete All	🗑	Confirm dialog: "Delete X tasks?" → slide-off animation → undo toast (8 seconds, shows task names)
Duplicate All	📋	Creates copies with "[Copy]" prefix, appear at top with fade-in stagger
Move to Category	📁	Opens category picker sheet, move all selected tasks
Change Priority	⚡	Opens priority picker (None/Low/Med/High/Critical), applies to all
Set Due Date	📅	Opens date picker, applies same date to all selected
Add Tag	🏷	Opens tag picker, adds tag to all selected (doesn't remove existing tags)
Export Selected	📤	Exports only selected tasks as JSON, triggers share sheet
Archive Selected	📦	Moves to archive, undo toast
Bulk Action Animations
Action bar slides up: translateY -80→0, opacity 0→1, 350ms spring

Each selected task pulses briefly when action applied (scale 1→1.03→1)

On delete: cards swipe left with red glass trail, stagger 80ms each

On complete: checkbox radial fill + strikethrough + green glow, stagger 100ms each

Undo toast: slides from top, glass card with countdown bar (decreasing width over 8s), swipe right to dismiss early

Long-Press Context Menu (Single Task)
When NOT in multi-select mode, long-press single task:

Glass context menu popup appears near touch point

Options: Duplicate, Move, Change Priority, Add Reminder, Share as Image, Archive, Delete

Icons on left, text on right, subtle separator lines

Tap outside to dismiss with blur-out

Selected option triggers with scale press animation

📦 PART 3: AGGRESSIVE NOTIFICATION SYSTEM (Production Grade)
Permission Flow (First Launch)
Step 1: Splash screen → app loads → 0.5s delay

Step 2: Beautiful glass onboarding card slides up:

text
🔔 Stay on Top of Tasks

We'll remind you when tasks are due so 
nothing slips through the cracks.

[ Maybe Later ]   [ Enable Notifications ]
Step 3: If "Enable" tapped → native OS permission dialog

Step 4: If granted → subtle success toast "🔔 Notifications enabled!" + haptic

Step 5: If denied → graceful message: "You can enable notifications anytime in Settings" (no guilt, no nagging)

Card has glassmorphism style: blur-20, border white 0.12, rounded-24, accent button

Notification Types (Build All)
Type	Trigger	Behavior
Overdue Minute Repeater	Task due time passes + task NOT completed	Send notification EVERY 1 MINUTE until task is completed or snoozed. Notification: "⏰ Overdue: [Task Title]" — red accent, persistent, high priority
Due Soon	15 minutes before due time	"⏳ Due in 15 min: [Task Title]" — amber accent, gentle
Reminder Alarm	Exact reminder time set by user	"🔔 Reminder: [Task Title]" — violet accent, with snooze options
Daily Digest	User-set time (default 8 AM)	"☀️ Good morning! You have X tasks today. Top priority: [Task Name]" — glass card style
Streak Milestone	7, 30, 100, 365 day streaks	"🔥 Amazing! You've hit a [X]-day streak!" — celebration, confetti on tap
Focus Complete	Pomodoro timer ends	"⏰ Focus session complete! Take a 5-min break 🌿" — green accent
Task Shared	Another device shares task (P2P)	"📩 New shared task from [Device]: [Task Title]"
Overdue Minute Repeater — THE KEY FEATURE
This is the most aggressive and important notification

When any task passes its due time and is NOT marked complete:

Minute 1: First notification fires immediately at due time

Minute 2: Second notification fires

Minute 3: Third notification fires

... CONTINUES EVERY 60 SECONDS INDEFINITELY

Notification content: "⏰ Overdue: [Task Title]" + "[X] minutes overdue"

High priority, persistent banner, stays in notification center

Stopping conditions (ANY of these):

User marks task as complete → all notifications for that task stop immediately

User taps notification → opens app to that task → if they complete it, stops

User snoozes from notification → stops for snooze duration (10/30/60 min), then resumes if still not complete

User deletes the task → stops immediately

User changes due date to future → stops, recalculates

Multiple tasks overdue: Each task gets its own notification thread, they don't merge

App in foreground: Show in-app banner instead of system notification (glass toast with pulsing red border, stays until dismissed or task completed)

Battery optimization bypass: Request permission to run in background, show rationale card if denied

Notification Actions (Swipe/3D Touch on Notification)
Complete → marks task done, removes notification, sends confetti

Snooze 10 min → pauses for 10 minutes

Snooze 30 min → pauses for 30 minutes

Snooze 1 hour → pauses for 60 minutes

Open Task → opens app directly to that task's detail view

Dismiss → silences this notification only (will fire again in 1 minute if still overdue)

In-App Notification Center
Bell icon in top-right of Home screen with badge count (unread notifications)

Tap bell → notification panel slides down from top (glass sheet, blur backdrop)

Shows: recent notifications grouped by task, with timestamps, read/unread state

Swipe notification left → dismiss

Swipe notification right → mark as read

"Mark All Read" button at top

"Clear All" with confirmation

Empty state: "No notifications yet 🔔" with floating bell animation

Notification Settings Screen
Accessible from: Settings → Notifications

Master Toggle: Enable/Disable all notifications

Overdue Repeater Toggle: On/Off (default ON)

Overdue Interval: 1 min / 2 min / 5 min / 10 min (user adjustable)

Due Soon Toggle: On/Off

Due Soon Lead Time: 5min / 10min / 15min / 30min / 1hr before

Reminder Alarms Toggle: On/Off

Daily Digest Toggle: On/Off

Daily Digest Time: Time picker

Streak Milestones Toggle: On/Off

Focus Complete Toggle: On/Off

Quiet Hours: Start time / End time — no notifications during this window (except critical overdue if user opts in)

Quiet Hours Override: "Allow critical overdue during quiet hours" toggle

Weekend Mode: "Reduce notifications on weekends" toggle

Notification Sound: Pick from 6 subtle glass/chime sounds, or silent

Haptic on Notification: Toggle

Persistent Overdue: "Keep overdue notification on lock screen" toggle

Badge App Icon: Show overdue count on app icon toggle

Test Notification button → sends test immediately

📦 PART 4: PREMIUM POLISH & MICRO-INTERACTIONS
Haptic Feedback System
Light impact: Task selection, checkbox tap, tab switch, widget tap

Medium impact: Task complete, enter multi-select, notification arrive, long-press activate

Heavy impact: Task delete, bulk action execute, overdue alert fire

Rigid: Modal snap open, bottom sheet lock

Soft: Swipe threshold reached, drag complete

All haptics respect user's system accessibility settings

Settings toggle: "Haptic Feedback" ON/OFF

Sound Design
Task Complete: Soft glass chime (short, satisfying, 0.3s)

Task Delete: Subtle whoosh (0.2s)

Overdue Alert: Gentle pulse beat (0.5s, slightly urgent but not annoying)

Reminder Fire: Crystal ping (0.4s, clear)

Streak Milestone: Celebration sparkle sound (1s)

Focus Timer End: Soft bell (1.5s, calming)

Bulk Action: Layered sound (multiple soft taps merged)

Undo: Reverse whoosh (0.3s)

Settings toggle: "Sound Effects" ON/OFF

Volume respects system media volume

All sounds are local audio files, no network

Secret Gestures (Discoverable Delights)
Shake device → Undo last action (complete/delete/archive) — works anywhere in app, shows undo toast

Double-tap empty area on Today screen → Quick add task (opens mini composer)

Swipe down with 2 fingers on any screen → Toggle dark/light mode instantly with smooth transition

Pinch on task list → Toggle between compact and comfortable view density

Triple-tap app logo (Settings → About) → Shows hidden "Easter egg" glass card with app stats, total tasks ever created, total focus hours, build number, fun quote

Each gesture has subtle visual feedback and optional haptic

Task Card Micro-Animations
Hover/Touch down: Card elevates slightly (translateZ +2px, shadow deepens)

Priority pulse: High/Critical tasks have subtle glow pulse on priority dot (2s infinite, soft)

Overdue shake: When overdue by 30+ min, card gently shakes every 5 seconds (subtle, not dizzying)

Due soon shimmer: Tasks due within 30 minutes get subtle amber shimmer across card border

Subtask progress: Progress bar fills with liquid animation (not linear, slight bounce at end)

Empty States (Premium Illustrations)
Every empty list must have:

Custom SVG illustration relevant to the section (no generic icons)

Floating idle animation (gentle up-down, 3s loop, ease-in-out)

Glass card below illustration with helpful text

CTA button with spring hover effect

Screen	Empty State
Today	"Nothing due today! 🎉" — Illustration: person relaxing on floating glass platform
All Tasks	"Your task list is empty ✨" — Illustration: clean glass slate with sparkles
Completed	"No completed tasks yet" — Illustration: trophy waiting to be claimed
Trash	"Trash is empty 🗑" — Illustration: clean glass bin
Search (no results)	"Nothing found for '[query]'" — Illustration: magnifying glass with question mark
Notifications	"All caught up! 🔔" — Illustration: sleeping bell with Zzz
Widgets (empty data)	"Complete some tasks to see data" — Illustration: growing plant
Categories	"Create your first project 📁" — Illustration: glass folders
App Icon Badge
Shows number of overdue tasks on app icon (red badge)

Updates instantly when task becomes overdue or is completed

Option in Settings → Notifications: "Badge shows: Overdue count / Today remaining / Off"

Badge clears when all overdue tasks are completed/snoozed

Confetti System (Upgraded)
Minor confetti (10 particles): Single task complete, widget data refresh

Medium confetti (30 particles): Bulk complete (2-5 tasks), streak hit 7 days

Major confetti (80 particles): All today's tasks complete, streak hit 30/100/365

Epic confetti (200 particles): All-time milestone (1000 tasks, 365-day streak)

Particles: glass-like squares and circles, app accent colors, slight blur, gravity + wind physics

Duration: 1.5s (minor) to 4s (epic)

Confetti respects reduce-motion setting (disables if ON)

📦 PART 5: NOTIFICATION PERMISSION FLOW — COMPLETE FUNNEL
Cold Start Permission Flow
text
App First Launch
    ↓
Splash Screen (1.2s)
    ↓
Staggered cards animate in
    ↓
[Check if first launch]
    ↓ YES
Onboarding Glass Card slides from bottom (400ms spring)
    ↓
"Stay on Top of Tasks" card with illustration
    ↓
User Choice:
    ├─ [Enable Notifications] → Trigger OS permission dialog
    │       ├─ GRANTED → Success toast + haptic + card dismiss
    │       └─ DENIED → Graceful dismiss, no guilt
    └─ [Maybe Later] → Card dismisses, no guilt
Permission States & UI
Not Determined: Show onboarding card

Granted: All notification features work, no extra UI

Denied:

Small subtle banner in Settings → Notifications: "Notifications are disabled. Enable in system settings?" with "Open Settings" button

Overdue tasks show in-app banner only (system notifications blocked)

Widgets still work with local data

No repeated nagging, no popup harassment

System Disabled (user enabled then disabled via system settings):

Same as Denied state

App detects on next launch, shows one-time gentle card: "Notifications were disabled. Re-enable?" — once per week max

🚀 DELIVERY CHECKLIST
Before shipping, verify all:

Widgets
All 15 widgets appear in widget picker

Widgets update within 5 seconds of app data change

Widget customization panel works per widget

Widget empty/loading/error states render correctly

Widgets match app glassmorphism style perfectly

Long-press "Edit Widget" menu functional on home screen

Bulk Actions
Long-press enters multi-select mode with haptic

Select All / Deselect All works

All 8 bulk actions function correctly

Undo toast works for delete (8s, shows task names)

Stagger animations smooth at 60fps

Single task long-press context menu appears and works

Notifications
Permission onboarding card appears on first launch

OS permission dialog triggers correctly

Overdue minute repeater fires EVERY 60 SECONDS

Notification stops when task completed/deleted/snoozed

Multiple overdue tasks each get own notification thread

Snooze works for 10/30/60 minutes

In-app notification bell shows badge count

Notification center panel shows history

All notification settings toggles work

Quiet hours respect time window

Test notification button works

Premium Polish
All haptic patterns implemented and toggleable

All sound effects play correctly, toggleable

Shake to undo works

2-finger swipe toggles dark/light

Double-tap empty area opens quick add

Pinch changes task density

Empty states have animations

Confetti system has all 4 levels

App icon badge shows overdue count

Edge Cases
Widget loads when no tasks exist (empty state)

Bulk actions on 0 tasks (buttons disabled)

Notifications when app is in foreground (in-app banner)

Notifications when device is locked (persistent on lock screen)

Rapid task completion/deletion (no duplicate notifications)

App restart — notifications re-evaluate all overdue tasks

Timezone change — overdue calculations adjust

Battery saver mode — notifications still fire (critical priority)

Build every feature completely. No placeholders. No "coming soon". All glassmorphism. All 60fps. Ship it.






PRD — APP ICON, LOGO & NAME CHANGE TO "FINISHLY"
ROLE & MISSION
You are updating the existing Glassmorphism To-Do app's branding. Replace the default Flutter icon/logo with the custom icon from icon_logo.png and rename the entire app to "Finishly". This must apply across all platforms, all screen sizes, and all app references.

📦 PART 1: APP ICON — USE icon_logo.png
Source File
File is located at: assets/icon_logo.png (or wherever it's stored)

Use this exact file for the app icon — no modifications, no cropping

If the file needs resizing, maintain aspect ratio and sharpness

Generate App Icons for ALL Platforms
Platform	Required Sizes
iOS	1024x1024 (App Store), 180x180 (iPhone 60pt @3x), 120x120 (iPhone 60pt @2x), 167x167 (iPad Pro), 152x152 (iPad), 76x76 (iPad mini)
Android	512x512 (Play Store), 192x192 (xxxhdpi), 144x144 (xxhdpi), 96x96 (xhdpi), 72x72 (hdpi), 48x48 (mdpi)
Web	192x192 (PWA small), 512x512 (PWA large), favicon 32x32, 16x16
macOS	1024x1024, 512x512, 256x256, 128x128, 64x64, 32x32, 16x16
Windows	256x256 (ico), 48x48, 32x32, 16x16
Linux	512x512, 256x256, 128x128, 64x64, 48x48
Icon Requirements
All icons must be generated from icon_logo.png — no placeholders, no default Flutter icon

Adaptive icons (Android): Use icon_logo.png as foreground, transparent background with system theme

iOS: No alpha mask issues, icon must look clean on dark/light springboard

macOS: Icon must look crisp in Dock (all sizes)

Web: Generate PWA manifest icons + favicon from same source

Remove ALL default Flutter icon assets from the project completely

📦 PART 2: APP LOGO — USE icon_logo.png INSIDE THE APP
Splash Screen
Replace splash screen logo with icon_logo.png

Logo scales in with spring animation on launch (scale 0.8→1, 400ms spring)

Background: app's deep dark glass color #0a0a12

Logo centered, size ~120x120 on mobile, ~200x200 on tablet/web

Below logo: App name "Finishly" fades in after logo scale animation (300ms fade, white text, SF Pro Display Bold, 28px)

In-App Logo Placement
Settings → About: Show logo prominently at top of About screen (80x80, centered, with subtle glass card behind it)

Empty States: Use icon_logo.png as floating idle animation in empty states (smaller, ~40x40, gentle up-down loop)

Notification Icon: All local notifications use icon_logo.png as notification icon (small, system-sized)

Widget Icon: Home screen widgets use icon_logo.png as widget preview icon

Share Extension: If sharing task cards, watermark with small icon_logo.png in corner (subtle, 15% opacity)

Logo Variations (Generate from Source)
Full color: Use icon_logo.png as-is for most placements

Monochrome white: Generate white/silhouette version from source for dark backgrounds where needed

Monochrome accent: Generate accent-color version for special UI moments (settings icon, about page)

📦 PART 3: APP NAME CHANGE TO "FINISHLY"
All References Must Change
Search and replace EVERY instance of the old app name to "Finishly":

Location	Change
App display name (iOS Info.plist, Android Manifest)	CFBundleDisplayName / android:label → "Finishly"
Package/bundle name (keep same, just display name changes)	Display name only, not package ID
Splash screen text	"Finishly" below logo
Settings → About → App Name	"Finishly"
Settings → About → Version row	"Finishly v1.0.0"
Onboarding card title	"Welcome to Finishly"
Notification titles	"Finishly: Task Due Soon", "Finishly: Overdue Task"
Widget labels	"Finishly — Today", "Finishly — Streak"
Daily digest title	"Finishly — Your Daily Summary"
Share sheet text	"Shared from Finishly"
Backup file metadata	"app": "Finishly" inside JSON
Error messages	"Finishly encountered an error"
Empty states	"Welcome to Finishly ✨"
App Store / Play Store metadata	App title, description, keywords
PWA manifest	"name": "Finishly", "short_name": "Finishly"
Browser tab title (web)	<title>Finishly</title>
macOS menu bar	App menu shows "Finishly"
Windows taskbar	Shows "Finishly"
Linux .desktop file	Name=Finishly
Typography for "Finishly"
Font: SF Pro Display Bold (iOS) / Plus Jakarta Sans Bold (web)

Letter spacing: -0.5px for tight, premium look

Color: White #FFFFFF on dark backgrounds

No gradient on the name text — solid white, clean

📦 PART 4: PLATFORM-SPECIFIC CONFIGURATION
iOS (ios/Runner/Info.plist)
text
<key>CFBundleDisplayName</key>
<string>Finishly</string>
<key>CFBundleName</key>
<string>Finishly</string>
Android (android/app/src/main/AndroidManifest.xml)
text
android:label="Finishly"
Web (web/index.html, web/manifest.json)
text
<title>Finishly</title>
"name": "Finishly",
"short_name": "Finishly",
macOS (macos/Runner/Configs/AppInfo.xcconfig)
text
PRODUCT_NAME = Finishly
Windows (windows/runner/Runner.rc)
text
AppName "Finishly"
Linux (linux/CMakeLists.txt)
text
set(APP_NAME "Finishly")
📦
bro just for android okay ad also chnage name of app for andrid
Got it bro! Simple and clean PRD just for Android:

🚀 PRD — ANDROID APP ICON & NAME CHANGE TO "FINISHLY"
ROLE & MISSION
Update the Android version of the app. Replace the default Flutter icon with icon_logo.png and rename the app to "Finishly". Android only.

📦 PART 1: APP ICON FROM icon_logo.png
Source File
Use file: assets/icon_logo.png (or wherever it is in the project)

Generate all Android icon sizes from this single file

Android Icon Sizes (Generate All)
Density	Size	Folder
mdpi	48x48	mipmap-mdpi/ic_launcher.png
hdpi	72x72	mipmap-hdpi/ic_launcher.png
xhdpi	96x96	mipmap-xhdpi/ic_launcher.png
xxhdpi	144x144	mipmap-xxhdpi/ic_launcher.png
xxxhdpi	192x192	mipmap-xxxhdpi/ic_launcher.png
Play Store	512x512	mipmap-xxxhdpi/ic_launcher_playstore.png
Adaptive Icon (Android 8+)
Use icon_logo.png as foreground layer (centered, with padding)

Background layer: Solid dark color matching app theme #0a0a12

Files: ic_launcher_foreground.png + ic_launcher_background.xml in mipmap-anydpi-v26/

Remove all default Flutter icon files completely

Round Icon
Generate round version for devices that use circular icons

Same sizes, stored as ic_launcher_round.png in each mipmap folder

Adaptive round: ic_launcher_round.xml in mipmap-anydpi-v26/

📦 PART 2: APP NAME CHANGE TO "FINISHLY"
AndroidManifest.xml
File: android/app/src/main/AndroidManifest.xml

xml
<application
    android:label="Finishly"
    ... >
Display Name Only
App drawer name: "Finishly"

Home screen label: "Finishly"

Recent apps name: "Finishly"

Notification header: "Finishly"

App info in settings: "Finishly"

Package name stays unchanged (com.whatever.current)

📦 PART 3: VERIFICATION CHECKLIST
All 6 mipmap folders have new ic_launcher.png from icon_logo.png

All 6 mipmap folders have new ic_launcher_round.png

Adaptive icon XML files created in mipmap-anydpi-v26/

No default Flutter icon left in project

AndroidManifest.xml shows android:label="Finishly"

Icon shows correctly on home screen, app drawer, recents

Icon shows correctly in notification bar

App name "Finishly" shows under icon on home screen

Round icon shows on devices that use circular icons

That's it bro. Just Android. Clean and simple. 🎯

