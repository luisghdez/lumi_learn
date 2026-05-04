# Lumi Learn — Design System

A living reference for the visual + interaction language used across the app.
Use this whenever you build a new screen so the experience stays cohesive.

---

## 1. Principles

1. **Glass before color.** Surfaces are translucent + blurred (frosted glass).
   Color is reserved for accents (the `+` create button, the like state, the
   purple/green action accents). Avoid solid colored panels.
2. **Minimal chrome, max content.** No headers/refresh buttons unless they
   add value. Let the content (videos, courses, comments) be the hero.
3. **Motion = identity.** Every state change animates. Switching tabs,
   liking a video, opening a sheet, posting — they all morph in sync.
   Never snap.
4. **Icons over labels.** When an icon is unambiguous, drop the label.
   When labels are needed, keep them tiny and supportive.
5. **Respect the safe zones.** Nothing slides under the navbar. Use the
   `kFlushNavbarHeight` reservation pattern.
6. **One source of truth for shared metrics.** Constants like
   `kFlushNavbarHeight` / `kFloatingNavbarHeight` live in `bottom_nav_bar.dart`
   and are imported, never duplicated.

---

## 2. Color System

We are dark-mode-first. Background is true black; everything on top is
white (or accent) at varying alphas.

### Base
| Token            | Color                  | Usage                                    |
| ---------------- | ---------------------- | ---------------------------------------- |
| `Colors.black`   | `#000000`              | App background, video letterboxes        |
| Glass tint       | `Colors.black @ 0.55`  | Sheets / large glass surfaces            |
| Glass tint light | `Colors.white @ 0.06`  | Floating glass pills (navbar floating)   |
| Glass tint flush | `Colors.black @ 0.18`  | Flush navbar over video                  |
| Glass border     | `Colors.white @ 0.12`  | Hairline border on most glass surfaces   |
| Glass border lit | `Colors.white @ 0.18`  | Selected state on glass icons            |

### Foreground (text)
| Token             | Color                  | Usage                                  |
| ----------------- | ---------------------- | -------------------------------------- |
| Primary text      | `Colors.white`         | Titles, primary copy, active labels    |
| Secondary text    | `Colors.white @ 0.78`  | Body copy / captions                   |
| Tertiary text    | `Colors.white @ 0.55`  | Hints, helper, inactive icons          |
| Disabled text    | `Colors.white @ 0.45`  | Disabled CTAs                           |

### Accents
Used sparingly — only on intentional focal points.

| Token     | Hex        | Usage                                     |
| --------- | ---------- | ----------------------------------------- |
| Like red  | `#FF4D6D`  | Active heart on liked video               |
| Course    | `#39D98A`  | Course-create accent                      |
| Video     | `#8E5CFF`  | Video-create accent / loading spinner    |
| Lumi cool | `#B79CFF`  | Legacy progress / loading spinners       |

The **floating `+` create button** is *always* a white→light-grey gradient
with a soft white outer glow + black drop shadow. It is the single brightest
element on screen by design — never tint it.

---

## 3. Typography

Use the system font (San Francisco / Roboto). Weights:

| Style              | Size  | Weight | Usage                              |
| ------------------ | ----- | ------ | ---------------------------------- |
| Display            | 22    | w800   | Empty-state titles                 |
| Title              | 18    | w700   | Sheet headers                      |
| Subtitle / Body L  | 15    | w600   | Bubble labels, primary actions     |
| Body               | 14    | w500   | Captions, comment body             |
| Body S             | 13    | w500   | Tertiary copy                      |
| Caption            | 12    | w700   | Tab labels, count badges           |
| Micro              | 11    | w600   | Subject pills                      |

`letterSpacing: 0.1–0.2` on uppercase / pill labels for breathing room.
For text rendered over imagery (video captions, action counts) add a soft
shadow:

```dart
shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))]
```

---

## 4. Glass Effects

The signature surface treatment of the app. Always built from the same
recipe.

### Recipe — standard glass surface
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(R),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: B, sigmaY: B),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: glassTint,                          // see below
        borderRadius: BorderRadius.circular(R),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: child,
    ),
  ),
)
```

### Blur strength (`sigma`)
| Surface                | Blur (sigmaX/Y) |
| ---------------------- | --------------- |
| Floating navbar pill   | 24              |
| Action bubbles (menu)  | 28              |
| Bottom sheet           | 30              |
| Liquid glass button    | 18              |
| Comment input pill     | 18              |

### Glass tint
| Surface                            | Tint                       |
| ---------------------------------- | -------------------------- |
| Light surfaces over imagery        | `Colors.white @ 0.06–0.10` |
| Heavy surfaces (sheets, video bar) | `Colors.black @ 0.18–0.55` |
| Selected icon backdrop             | `Colors.white @ 0.10`      |

### Liquid glass button (iOS-style)
For circular/round action buttons — use a vertical specular gradient
*inside* the blurred container:

```dart
gradient: LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    tint.withValues(alpha: 0.22),  // top — brighter (specular highlight)
    tint.withValues(alpha: 0.06),  // bottom — softer
  ],
),
```

Active state: bump the highlight alpha to `0.55`, the lowlight to `0.18`,
the border to `0.65`, and add a colored outer glow (`spreadRadius: 1`).

---

## 5. Spacing & Sizing

Spacing scale (use these, don't invent new values):

`4 · 6 · 8 · 10 · 12 · 14 · 16 · 18 · 20 · 22 · 24 · 28 · 32`

### Standard component sizes

| Component                  | Size    |
| -------------------------- | ------- |
| Liquid glass button        | 50×50   |
| Navbar nav icon (floating) | 48×48   |
| Navbar nav icon (flush)    | 42×42   |
| Navbar `+` button (floating)| 54×54  |
| Navbar `+` button (flush)  | 42×42   |
| Comment send / morph button| 38×38   |
| Comment avatar             | 36×36   |
| Action bubble icon tile    | 36×36   |
| Sheet drag handle          | 40×4    |

### Screen padding
- Horizontal screen padding: **20** (sometimes 16 in tight contexts)
- Bottom safe zone for navbar overlays: **`kFlushNavbarHeight + safeBottom`**

---

## 6. Border Radius

| Surface                       | Radius |
| ----------------------------- | ------ |
| Floating navbar pill          | 40     |
| Bottom sheet (top)            | 30     |
| Action bubbles                | 22     |
| Comment input pill            | 26     |
| Subject pills, chip tags      | 999    |
| Glass cards / large surfaces  | 22–28  |
| Small glass tile (icon bg)    | 12     |

Anything intended to read as a "pill" uses `BorderRadius.circular(999)`.

---

## 7. Animation

### Curves
- **`Curves.easeOutCubic`** — default for slides, height/padding morphs,
  navbar mode switch, sheet entry.
- **`Curves.easeOut`** — default for color/scale on selection.
- **`Curves.easeOutBack`** — pop-in moments: bubble menu open, like-heart
  scale, action emphasis.
- **`Curves.easeInCubic`** — default for reverse animations
  (closing bubbles, dismiss).

### Durations
| Action                                 | ms        |
| -------------------------------------- | --------- |
| Quick state change (selected icon)     | 200–220   |
| Standard surface morph (navbar mode)   | 320 open  |
| Sheet / overlay open                   | 280–320   |
| Sheet / overlay close                  | 220–240   |
| Per-item cascade entry (lists)         | 260 + index×35 (cap 460) |
| Subtle pulse / glow                    | 220       |

### Patterns

**Same-driver morph** — when multiple props change together (e.g. navbar
flush mode), drive them all from one `TweenAnimationBuilder<double>` and
`lerpDouble` each value. Keeps everything in lock-step, never out of phase.

**Stagger by interval** — for groups (e.g. action bubbles), wrap the
single controller in `CurvedAnimation(curve: Interval(start, end, curve: …))`
per child. Reverse with a different `reverseCurve` to flip the order.

**Per-item cascade entry** — for lists, give each `ListView.builder` item a
keyed `TweenAnimationBuilder<double>` with `Duration(260 + index*35).clamp(…, 460)`.
Existing items don't re-animate when a new one is inserted at index 0
because they keep their `ValueKey(item.id)`.

**Morphing CTA** — buttons that change activation state (e.g. comment send)
animate gradient colors, border alpha, glow shadow, and icon color
together via `AnimatedContainer` (220ms easeOut). The button doesn't
appear/disappear — it transforms.

---

## 8. Component Catalog

### Bottom Navbar (`lib/widgets/bottom_nav_bar.dart`)
- Two modes: **floating** (rounded pill, side margins, drop shadow) on
  every tab except Feed; **flush** (edge-to-edge, no border, no shadow,
  black-tinted glass) on Feed.
- All visual props (radius, padding, height, glow alpha) lerp from a
  single `TweenAnimationBuilder<double>(t: flushMode ? 1 : 0)`.
- Icons only — no text labels.
- The **`+`** button is the focal point: white gradient circle, soft
  outer glow, black drop shadow. Slightly larger than nav icons in
  floating mode (54 vs 48), shrinks in flush mode (42 vs 42).
- Tapping `+` rotates it 0° → 135° (becomes ×) and triggers the
  glass-bubble menu (see below).

### Glass-bubble action menu (in `bottom_nav_bar.dart`)
- Inserted into the root `Overlay`, anchored above the `+` via a
  `GlobalKey` on the create button.
- Backdrop is a 45%-black `ColoredBox` faded in over `Interval(0, 0.6)`.
- Two stacked glass pills (radius 22), 210px wide, scale + slide-up
  entry with `easeOutBack` and a 70ms stagger.
- Each pill: accent-tinted icon tile (36×36, radius 12) + label.
- Wrap the overlay's `Stack` in `Material(type: MaterialType.transparency)`
  so `Text` widgets get a default font (no yellow underline).

### Liquid Glass Action Button (in `feed_screen.dart`)
- Used for like / comment on the feed.
- 50×50 circle, blur 18, vertical specular gradient inside.
- `AnimatedContainer` morph for the active state (red glass + scale + glow).
- Icon is **always** white; the *fill* tints, not the glyph.
- Count label below uses a soft text shadow for legibility on imagery.

### Glass Bottom Sheet (e.g. `_CommentsSheet` in `feed_screen.dart`)
- `showModalBottomSheet(backgroundColor: Colors.transparent, isScrollControlled: true)`.
- Inner: `ClipRRect(top radius 30) → BackdropFilter(30) → DecoratedBox(black @ 55% + top hairline white border)`.
- Drag handle: `40×4`, `Colors.white @ 0.24`, radius 999, `top: 10` then `16` below.
- Header is just a title + animated count pill — no refresh icons.
- List items get a per-item slide+fade cascade keyed by `id`.
- Input bar lives at the bottom, wrapped in `AnimatedPadding` so the
  keyboard pushes it up smoothly.

### Glass Text Field (input pill)
- `ClipRRect(radius 26) → BackdropFilter(18) → Container(white @ 8%, border white @ 14%)`.
- Inside: a `TextField` with `border: InputBorder.none`, `enabledBorder: InputBorder.none`, `focusedBorder: InputBorder.none`.
- Cursor color always `Colors.white`.
- `isDense: true`, `contentPadding` `vertical: 10`.
- Hint: `Colors.white @ 0.45`, weight `w500`.

### Morphing send / submit button
- 38–42px circle that lives at the right of an input pill.
- Empty state: glassy / dim (`white gradient @ 0.16 → 0.06`, border `0.18`, no glow).
- Has-text state: solid white→`#E4E4E4` gradient, white border `0.85`, white outer glow (alpha 0.18, blur 14).
- Icon swaps from `white @ 0.45` to `Colors.black`.
- All transitions via `AnimatedContainer(220ms easeOut)`.

### Subject / chip pills
- `padding: 9×4` for small, `12×6` for medium, `16×8` for large.
- `Colors.white @ 0.10–0.14` background, optional 1px white border.
- `borderRadius: 999`.
- Text: `w600/w700`, fontSize `11–13`.

---

## 9. Layout Conventions

### Safe zone for the navbar
Any screen rendered inside `MainScreen`'s `IndexedStack` must reserve the
navbar's footprint at the bottom of its content. For Feed (flush mode):

```dart
final navbarReserved =
    kFlushNavbarHeight + MediaQuery.of(context).padding.bottom;

return Padding(
  padding: EdgeInsets.only(bottom: navbarReserved),
  child: ...,
);
```

For non-Feed screens with floating navbar, content can flow under the
floating pill, *but* sticky CTAs (e.g. a "Save" button) should still leave
`kFloatingNavbarHeight + safe bottom + 12` of clearance.

### Avoid `SafeArea(bottom: true)` when reserving navbar space
If the parent already adds the safe inset (via the navbar reservation
pattern), pass `bottom: false` to inner `SafeArea`s to avoid doubling.

### Background
Default body background: `Colors.black`. Optional gradient overlays for
dramatic surfaces:

```dart
gradient: LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.black.withValues(alpha: 0.45),
    Colors.transparent,
    Colors.black.withValues(alpha: 0.78),
  ],
  stops: [0, 0.42, 1],
)
```

---

## 10. Interaction Patterns

### Tap targets
Minimum **42×42** for any interactive element. Use `GestureDetector(
behavior: HitTestBehavior.opaque)` on bare-text taps to absorb the
correct hit area.

### Disabled vs absent
Prefer **disabled** (dim + non-interactive) over hidden when an action
is contextually unavailable. Helps users discover capability.

### Splash / ripple
Default ripple on `Material` is **off-brand** for our glass surfaces.
Use `GestureDetector` (no splash) instead of `InkWell` whenever the
target is a glass element. If you need a splash, reach for `Theme(data:
copyWith(splashFactory: NoSplash.splashFactory))` to suppress it.

### Error / empty states
Wrap in a glass-circle icon + 2-line copy (title + subtitle) inside
center of the area. See `_EmptyCommentsState` for the canonical pattern.

### Snackbars
Use `Get.snackbar(...)` for transient messages. Keep titles short
(2 words), keep body copy under 80 chars, pick a tint that reflects
severity.

---

## 11. Where things live

| Concern                              | File                                             |
| ------------------------------------ | ------------------------------------------------ |
| Bottom navbar + create menu          | `lib/widgets/bottom_nav_bar.dart`               |
| Navbar height constants              | exported from `bottom_nav_bar.dart`             |
| Video feed (liquid glass actions)    | `lib/screens/feed/feed_screen.dart`             |
| Comments sheet pattern               | `_CommentsSheet` in `feed_screen.dart`          |
| Create video flow (full-page form)   | `lib/screens/videos/create_video_screen.dart`   |
| Glass top bar / icon button pattern  | `_GlassTopBar`, `_GlassIconButton` in create video |
| Glass caption / search field pattern | `_GlassCaptionField`, `_GlassSearchField` ↑     |
| Morphing primary CTA                 | `_PostButton` in create video                   |
| List-row selector (sheet body)       | `_SubjectTile` in create video                  |

When you build a new screen, **read this doc first**, then check the
existing implementations of similar components and copy their structure.
Don't invent new glass tints, blur values, or animation curves unless
this doc gets updated to match.
