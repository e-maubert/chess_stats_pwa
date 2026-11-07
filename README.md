# Chess Stats PWA

A Flutter progressive web app (PWA) that shows a [chess.com](https://www.chess.com) player's statistics for the **current month**.

Enter a chess.com username and the app shows:

- results **by color** (white / black);
- results **by opening**;
- results **by opponent country**;
- a **breakdown of losses by cause** (checkmate, resignation, timeout…).

Statistics can be filtered by time control. The user interface is currently available in French only.

Data comes from the [chess.com public API](https://www.chess.com/news/view/published-data-api) (`https://api.chess.com/pub/player/<username>/games/<YYYY>/<MM>`). No API key is required.

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK ≥ 3.0)
- A recent browser (Chrome, Edge, Firefox…)

## Getting started

```bash
flutter pub get
flutter run -d web-server --web-port 8080 --web-hostname localhost
```

Then open http://localhost:8080. The username `hikaru` is handy for testing, as he plays a lot of games.

After changing the code, stop and restart the server: reloading the page is not enough.

## Useful commands

```bash
flutter analyze   # static analysis
flutter test      # unit tests
flutter build web # production build in build/web
```

## Architecture

Entry point: `lib/main.dart` → `screens/home_screen.dart` (search) → `screens/stats_screen.dart` → `widgets/stats_display.dart` (main statistics page).

| Folder | Purpose |
|---|---|
| `lib/models/` | Data (`ChessStats`, `CountryGame`…) |
| `lib/services/` | chess.com API calls, caching, calculations and aggregations |
| `lib/viewmodels/` | Screen state (time-control filters, sorting) as `ChangeNotifier` |
| `lib/screens/`, `lib/views/`, `lib/widgets/` | UI only |
| `lib/l10n/` | Translations (`translations.dart` and `.arb` files) |
| `test/` | Unit tests |
| `web/` | PWA files (`index.html`, `manifest.json`, service worker) |

Main libraries:

- [`provider`](https://pub.dev/packages/provider) for state management;
- [`fl_chart`](https://pub.dev/packages/fl_chart) for charts;
- [`http`](https://pub.dev/packages/http) for API calls;
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) for caching (1-hour lifetime).

## Workflow

Client feedback is tracked on a Trello board. It is handled by Claude Code agents: one turns client emails into cards, one develops them, and one reviews the code. Their instructions are in `.claude/agents/`, and the project conventions are described in [`CLAUDE.md`](CLAUDE.md) (in French).
