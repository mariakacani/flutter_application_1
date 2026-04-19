# WhatsApp Clone Modernization - TODO Steps

## Plan Progress: 0/N - Approved ✓

**Overview:** Restructure to full WhatsApp-like app with functional drawer nav, bottom bar (Chats/Calls/Status), vibrant gradients/neon colors, animations, glassmorphism cards, story carousel, search, FAB new chat.

**Step 1: Refactor lib/main.dart**
- Wrap in HomeScaffold w/ Material3 theme (vibrant colors).
- Status: ☐ Pending

**Step 2: Create lib/screens/home_screen.dart**
- Scaffold w/ ChatDrawer, BottomNavBar, indexed body tabs.
- Status: ☐ Pending

**Step 3: Create lib/screens/chats_screen.dart**
- Animated searchable chat list, glass cards, story carousel.
- Status: ☐ Pending

**Step 4: Edit lib/screens/calls_screen.dart & status_screen.dart**
- Add drawer support, custom_app_bar, animations.
- Status: ☐ Pending

**Step 5: Edit lib/widgets/drawer_menu.dart & custom_app_bar.dart**
- Functional callbacks for nav/profile.
- Status: ☐ Pending

**Step 6: Add animations/widgets (flutter_animate if approved)**
- Hero, StaggeredList, gradients.
- Status: ☐ Pending

**Step 7: Test & polish**
- flutter run -d chrome, hot reload.
- Status: ☐ Pending

**Post-steps:** flutter pub get (no new deps initially).

**Expected:** Modern WhatsApp UI w/ vibrant colors, smooth nav, web-ready.
