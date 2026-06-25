# Glass Weather — Example App Design

**Date:** 2026-06-25
**Status:** Approved design, ready for implementation
**Type:** New example app (showcase) for `liquid_glass_native`

## Goal

A real-feel iOS weather app that showcases the native liquid glass widgets layered
over a condition-driven gradient backdrop. A native `LiquidGlassTabBar` (bottom)
splits the app into three tabs — **Weather**, **Search**, **Settings**. City search
via Open-Meteo (no API key, no GPS permission). Lives inside the existing example
app and is launched from a button in the gallery.

### Tabs (bottom `LiquidGlassTabBar`)

| Tab | SF Symbol | Content |
| --- | --- | --- |
| Weather | `cloud.sun` | Current conditions card + hourly strip + 7-day list (scroll). Backdrop reflects current condition. Empty state prompts "Search a city". |
| Search | `magnifyingglass` | `LiquidGlassSearchBar` + recent/last result. Picking a city loads weather and auto-switches to the Weather tab. |
| Settings | `gearshape` | Units toggle (°C / °F) via `LiquidGlassSegmentedControl`, plus an About glass card (data source credit, lib name). |

The tab bar replaces the in-content segmented Hourly/7-Day toggle: the Weather tab
shows hourly strip and 7-day list stacked in one scroll.

## Constraints

- iOS 26+ for real glass; widgets fall back gracefully below that (handled by the lib).
- No API key, no device permissions. Anyone cloning the repo can run it.
- Must not break the existing widget gallery.

## Stack

| Concern | Choice |
| --- | --- |
| HTTP | `dio` |
| Functional error handling | `dartz` (`Either<Failure, T>`) |
| Dependency injection | `get_it` |
| State management | `flutter_bloc` (Cubit) |
| Tests | `flutter_test`, `bloc_test`, `mocktail` |

Add these to `example/pubspec.yaml` only. The plugin package itself gains no new deps.

## Data Source — Open-Meteo

Two endpoints, no auth:

1. **Geocoding** — `https://geocoding-api.open-meteo.com/v1/search?name={query}&count=1&language=en&format=json`
   → returns `results[0]`: `{ name, latitude, longitude, country, admin1, timezone }`.
   Empty/absent `results` → `NotFoundFailure`.

2. **Forecast** — `https://api.open-meteo.com/v1/forecast` with query params:
   - `latitude`, `longitude`, `timezone=auto`
   - `current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day`
   - `hourly=temperature_2m,weather_code` (next 24h sliced client-side from `time` array)
   - `daily=weather_code,temperature_2m_max,temperature_2m_min` (7 days)

Units: always fetch metric (Celsius, km/h) — Open-Meteo defaults. °C/°F is a
display-only conversion in `formatters` driven by `SettingsCubit`; no re-fetch.

## Architecture — feature-first, layered

```
example/lib/weather/
  weather_app.dart                     # entry widget: theme + BlocProvider + WeatherPage
  injection.dart                       # get_it registration (call once on launch)
  domain/
    failures.dart                      # sealed Failure: NetworkFailure, NotFoundFailure, UnknownFailure
    entities/
      location.dart                    # Location(name, country, admin1, lat, lon, timezone)
      current_weather.dart             # CurrentWeather(tempC, feelsLikeC, humidity, windKph, code, isDay)
      hourly_forecast.dart             # HourlyForecast(time, tempC, code) + list usage
      daily_forecast.dart              # DailyForecast(date, code, maxC, minC)
      weather_bundle.dart              # WeatherBundle(location, current, List<Hourly>, List<Daily>)
    repositories/
      weather_repository.dart          # abstract; returns Either<Failure, T>
  data/
    datasources/
      weather_remote_data_source.dart  # dio calls, returns parsed models or throws DioException
    models/
      geo_location_model.dart          # fromJson -> Location
      forecast_model.dart              # fromJson -> current/hourly/daily lists
    repositories/
      weather_repository_impl.dart     # try/catch dio -> Either; maps errors to Failure
  presentation/
    cubit/
      weather_cubit.dart               # search(query): geocode -> forecast -> emit
      weather_state.dart               # sealed states
      settings_cubit.dart              # TempUnit (celsius|fahrenheit); emits TempUnit
      tab_cubit.dart                   # current tab index 0..2; switchTo(i)
    pages/
      weather_home.dart                # Stack(backdrop + IndexedStack(tabs) + LiquidGlassTabBar)
      tabs/
        weather_tab.dart               # current card + hourly strip + daily list (scroll)
        search_tab.dart                # search bar + last result; on pick -> load + switch tab
        settings_tab.dart              # unit segmented + about card
    widgets/
      condition_backdrop.dart          # full-screen AnimatedContainer gradient
      current_conditions_card.dart     # LiquidGlassCard, big temp block
      hourly_strip.dart                # horizontal ListView of LiquidGlassContainer chips
      daily_list.dart                  # column of LiquidGlassCard rows
      weather_status_view.dart         # loading (LiquidGlassActivityIndicator) / error / empty
  shared/
    weather_codes.dart                 # WMO code -> WeatherVisual(label, IconData, Gradient, isDayAware)
    formatters.dart                    # temp rounding + C/F conversion, hour/day label formatting
```

### Why these boundaries

- `weather_codes.dart` and `formatters.dart` are pure, dependency-free → trivially unit-testable and used by multiple widgets.
- Datasource throws; repository is the *only* place that converts exceptions → `Either<Failure, T>`. Cubit never sees a raw exception.
- Each widget takes plain entities as constructor args (no cubit lookups inside leaf widgets) → testable in isolation, parallelizable.

## Data Flow

```
(Search tab) SearchBar.onSubmitted(query)
  -> WeatherCubit.search(query)
       emit(WeatherLoading)
       repo.search(query)  ->  Either<Failure, Location>
         left  -> emit(WeatherError(msg))
         right -> repo.getForecast(location) -> Either<Failure, WeatherBundle>
                    left  -> emit(WeatherError(msg))
                    right -> emit(WeatherLoaded(bundle))
                             + TabCubit.switchTo(0)   // jump to Weather tab
```

### Cubits

- **`WeatherCubit`** — owns the search→forecast flow and `WeatherState`. Holds `_lastQuery` for Retry.
- **`SettingsCubit`** — state is `TempUnit { celsius, fahrenheit }`; `setUnit(unit)`. Default celsius. Widgets read it (via `context.watch`) to pick formatter; no re-fetch.
- **`TabCubit`** — state is `int` index 0..2; `switchTo(i)`. `WeatherCubit` listens-and-switches to tab 0 on a successful load (via a `BlocListener` in `weather_home.dart`, not a direct cubit→cubit call, to keep cubits decoupled).

### States (sealed `WeatherState`)

- `WeatherInitial` — empty; Weather tab shows "Search a city" prompt.
- `WeatherLoading` — activity indicator, keep last backdrop if any.
- `WeatherLoaded(WeatherBundle bundle)` — full forecast. (Hourly + daily both shown stacked; the old `ForecastView` toggle is removed since the tab bar restructures navigation.)
- `WeatherError(String message)` — glass error card + Retry (re-runs `_lastQuery`).

States are immutable with value equality (manual `==`/`hashCode` or `equatable`).

## UI / Visual Design

Direction: **glass over a condition-driven gradient**. The gradient is the only color
source; glass widgets stay neutral and let the backdrop read through. Oversized
temperature numeral as the focal point (exaggerated-minimalism cue). Font: **Inter**
(spatial/glass mood) for Flutter text; native glass widgets keep system font.

### Condition gradients (`weather_codes.dart`)

WMO `weather_code` + `is_day` → `WeatherVisual`:

| Condition | Codes | Day gradient (top→bottom) | Night gradient |
| --- | --- | --- | --- |
| Clear | 0,1 | `#2E8BFF → #6FB8FF` | `#0A0E27 → #1B2A6B` |
| Cloudy | 2,3 | `#5B7A99 → #93A9C0` | `#1A2332 → #3A4A5E` |
| Fog | 45,48 | `#8896A6 → #B9C4CE` | `#222A33 → #3E4750` |
| Drizzle/Rain | 51–67,80–82 | `#3A5A78 → #5E7E97` | `#0E1A2B → #243B53` |
| Snow | 71–77,85,86 | `#7FA8C9 → #C8DCEC` | `#1C2638 → #38506E` |
| Thunder | 95–99 | `#2C3142 → #4A4E6B` | `#0A0A14 → #232338` |

Each entry also carries: `label` (e.g. "Partly cloudy"), `IconData` (Material weather icons — no emoji), `accent` color for chips.

### Shell layout (`weather_home.dart`)

`Stack`:
1. `ConditionBackdrop` — fills screen; `AnimatedContainer(300ms, easeOut)` cross-fades gradient on current-condition change. Shared across all tabs. Respects reduced-motion (set instantly). Settings/Search tabs use the same backdrop (last known condition, or a neutral clear-day gradient if none yet).
2. `SafeArea` → `IndexedStack(index: tabIndex)` holding the three tab bodies (IndexedStack keeps each tab's scroll/state alive).
3. `LiquidGlassTabBar` pinned to bottom: items = Weather/Search/Settings with SF Symbols above; `currentIndex` from `TabCubit`, `onTap` → `switchTo`.
4. `BlocListener<WeatherCubit>` → on `WeatherLoaded`, `TabCubit.switchTo(0)`.

### Weather tab (`weather_tab.dart`)

`BlocBuilder<WeatherCubit>`; scrollable `Column`, bottom padding clears the tab bar:
- `CurrentConditionsCard` — city name (small caps), big temp (`~96sp`, weight 200, unit from SettingsCubit), condition label, `H {max}° L {min}°`, feels-like + humidity + wind row.
- `HourlyStrip` (next 24h).
- `DailyList` (7-day).
- States other than loaded → `WeatherStatusView` centered (initial prompt / loading / error+retry).

### Search tab (`search_tab.dart`)

`LiquidGlassSearchBar` near top; below it a hint or the last searched city as a tappable glass card. `onSubmitted` → `WeatherCubit.search`. While loading, inline `LiquidGlassActivityIndicator`. On success the shell switches to Weather tab automatically.

### Settings tab (`settings_tab.dart`)

- Units: `LiquidGlassSegmentedControl(['°C','°F'])` bound to `SettingsCubit`.
- About: `LiquidGlassCard` — "Data: Open-Meteo", "Built with liquid_glass_native".

### Spacing & type scale

- Spacing rhythm: 4 / 8 / 16 / 24 / 32. Screen padding 16. Card inner padding 20.
- Type scale (Inter): display 96 / title 28 / body 17 / caption 13. Line-height 1.3 body.
- Touch targets ≥ 44pt (search bar, segmented, retry button).

### Motion

- One hero motion per view: temp number fades + slides up 8px on load (`easeOut`, 300ms).
- Backdrop gradient cross-fade on condition change.
- All animations gated on `MediaQuery.disableAnimations` / reduced-motion → instant.
- Dispose any `AnimationController` in `dispose()`.

## Error Handling

| Situation | Failure | UI |
| --- | --- | --- |
| No network / dio timeout / 5xx | `NetworkFailure` | "Can't reach weather service" + Retry |
| Geocoding empty results / 404 | `NotFoundFailure` | "City not found. Try another name." |
| Parse error / anything else | `UnknownFailure` | "Something went wrong" + Retry |

Cubit folds `Either`; UI maps `WeatherError.message` (already human-readable, set by repo).

## Testing

| Unit under test | Type | Tool |
| --- | --- | --- |
| `weather_codes` mapping (code+isDay → visual) | pure unit | flutter_test |
| `formatters` (temp round, C→F conversion, labels) | pure unit | flutter_test |
| model `fromJson` (geo + forecast, incl. empty results) | unit | flutter_test |
| `WeatherRepositoryImpl` error mapping (dio throws → Left) | unit | mocktail |
| `WeatherCubit` happy path + each failure path | bloc | bloc_test + mocktail |
| `SettingsCubit` setUnit, `TabCubit` switchTo | bloc | bloc_test |
| key widgets render given entities (golden optional) | widget | flutter_test |

## Gallery Integration

Add one entry to `example/lib/gallery.dart` that pushes `WeatherApp`. Call
`configureWeatherDependencies()` (get_it) lazily on first launch (guard against
double-registration). Existing gallery demos untouched.

## Out of Scope (v1, YAGNI)

- GPS location, saved cities / multi-city list, deep links, persistent cache /
  settings persistence (units reset on relaunch), widget/extension, localization
  beyond English.

---

# Swarm Execution Plan

Tasks grouped into waves. Within a wave, tasks are independent and can run in
parallel by separate agents. Each task lists files it owns (no two parallel tasks
write the same file) and its dependencies.

## Wave 0 — Scaffolding (1 agent, blocking)

**T0. Project wiring**
- Add deps to `example/pubspec.yaml`: `dio`, `dartz`, `get_it`, `flutter_bloc`; dev: `bloc_test`, `mocktail`. Run `flutter pub get`.
- Create empty package dirs under `example/lib/weather/` per architecture tree.
- Add Inter font (Google Fonts via `google_fonts` dep OR bundled) — decision: use `google_fonts` dep for zero asset wiring.
- Output: compiles, `flutter analyze` clean.
- **Blocks all other waves.**

## Wave 1 — Pure core (parallel, after T0)

Independent, no cross-deps. Spawn together.

- **T1. Domain layer** — owns `domain/failures.dart`, `domain/entities/*`, `domain/repositories/weather_repository.dart`. Plain immutable classes + abstract repo. + unit test stubs N/A (entities trivial).
- **T2. `shared/weather_codes.dart`** — `WeatherVisual` + full WMO mapping table + gradients/icons. + `test/weather/weather_codes_test.dart`.
- **T3. `shared/formatters.dart`** — temp/label/hour/day formatting. + `test/weather/formatters_test.dart`.

> T1 defines entity field names; T2/T3 don't import entities (operate on primitives + return visuals/strings), so they're safe in parallel. If an agent finds it needs an entity type, it imports from T1's declared file path (names fixed in this spec).

## Wave 2 — Data + State (parallel, after Wave 1)

- **T4. Data layer** — owns `data/models/*`, `data/datasources/weather_remote_data_source.dart`, `data/repositories/weather_repository_impl.dart`. Depends on T1 (entities/repo iface). + `test/weather/forecast_model_test.dart`, `test/weather/weather_repository_impl_test.dart` (mocktail Dio).
- **T5. Cubits + state** — owns `presentation/cubit/weather_cubit.dart`, `weather_state.dart`, `settings_cubit.dart`, `tab_cubit.dart`. Depends on T1 (repo iface) only — mock repo in tests, does NOT need T4 done. + `test/weather/weather_cubit_test.dart`, `test/weather/settings_tab_cubit_test.dart` (bloc_test + mock repo).

> T4 and T5 both depend only on T1's interface, not on each other → parallel.

## Wave 3 — UI widgets (parallel, after Wave 1)

Leaf widgets take entities + `TempUnit` as args → buildable against T1 + T2/T3 only (no cubit lookups inside leaf widgets).

- **T6. `condition_backdrop.dart`** — full-screen animated gradient from `WeatherVisual`.
- **T7. `current_conditions_card.dart`** — takes `CurrentWeather` + `Location` + `TempUnit`.
- **T8. `hourly_strip.dart` + `daily_list.dart` + `weather_status_view.dart`** — take lists/state + `TempUnit`.

> T6–T8 partition the `widgets/` folder; no shared files. Each imports entities (T1), visuals (T2), formatters (T3), and lib glass widgets.

## Wave 4 — Tab bodies + shell (after Waves 2 & 3)

- **T9a. Tab bodies** — owns `presentation/pages/tabs/weather_tab.dart`, `search_tab.dart`, `settings_tab.dart`. Wires `BlocBuilder`/`context.watch` for WeatherCubit + SettingsCubit, composes T6–T8 widgets + lib `LiquidGlassSearchBar` / `LiquidGlassSegmentedControl` / `LiquidGlassCard`. Depends on T5, T6–T8.
- **T9b. Shell + wiring** — owns `presentation/pages/weather_home.dart`, `weather_app.dart`, `injection.dart`, and the gallery entry in `example/lib/gallery.dart`. Builds the `Stack` + `IndexedStack` + `LiquidGlassTabBar`, multi-BlocProvider, `BlocListener` tab-switch on load, get_it registration. Depends on T9a, T4, T5.

> T9a then T9b (sequential: shell imports the tab bodies). One agent can do both, or two in sequence.

## Wave 5 — Verify (1 agent, after T9b)

- **T10. Verification** — `flutter analyze`, `flutter test`, run app on iOS sim, confirm: tab bar switches Weather/Search/Settings; Search loads a city and auto-jumps to Weather tab; unit toggle in Settings flips °C/°F live; error path shows retry; backdrop matches condition; gallery still works. Report evidence.

## Dependency graph

```
T0 ──> T1 ──┬──> T4 ───────────┐
            ├──> T5 ───────────┤
T0 ──> T2 ──┼──> T6 ──┐        │
T0 ──> T3 ──┼──> T7 ──┼─> T9a ─┴─> T9b ──> T10
            └──> T8 ──┘
```

## Swarm contract (per agent)

- Write only files your task owns. Do not edit another task's files.
- Use exact file paths, class names, and field names from this spec — they are the integration contract.
- Add tests listed for your task. Run `flutter analyze` on your files before reporting done.
- Report: files created, tests added, analyze/test result.
