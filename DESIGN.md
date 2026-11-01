---
name: Liora
description: A day's printed program log on cool paper, with one station blue.
colors:
  paper: "#F4F7FB"
  ink: "#0E1A2B"
  muted: "#3A4C66"
  rule: "#D5DBE3"
  station: "#0C4DA2"
  onStation: "#F4F7FB"
  onStationMuted: "#D5E3F8"
  paperDark: "#0E1A2B"
  inkDark: "#F4F7FB"
  mutedDark: "#C5D2E6"
  ruleDark: "#2C3C55"
  stationDark: "#2F6FE0"
  onStationDark: "#F4F7FB"
  onStationMutedDark: "#FFFFFF"
typography:
  display:
    fontFamily: "BarlowCondensed, Arial Narrow, sans-serif"
    fontSize: "44px"
    fontWeight: 600
    lineHeight: 0.95
    letterSpacing: "-0.02em"
  program:
    fontFamily: "BarlowCondensed, Arial Narrow, sans-serif"
    fontSize: "28px"
    fontWeight: 600
    lineHeight: 0.95
    letterSpacing: "-0.02em"
  title:
    fontFamily: "BarlowCondensed, Arial Narrow, sans-serif"
    fontSize: "22px"
    fontWeight: 600
    lineHeight: 0.95
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "CupertinoSystemDisplay, Roboto, sans-serif"
    fontSize: "34px"
    fontWeight: 700
    lineHeight: 1.05
  headline-android:
    fontFamily: "Roboto, sans-serif"
    fontSize: "28px"
    fontWeight: 700
    lineHeight: 1.05
  body:
    fontFamily: "CupertinoSystemText, Roboto, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "0.5px"
  label:
    fontFamily: "CupertinoSystemText, Roboto, sans-serif"
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.43
    letterSpacing: "0.1px"
  control-ios:
    fontFamily: "CupertinoSystemText, sans-serif"
    fontSize: "17px"
    fontWeight: 600
    letterSpacing: "-0.41px"
  control-android:
    fontFamily: "Roboto, sans-serif"
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.43
    letterSpacing: "0.1px"
rounded:
  none: "0px"
spacing:
  "4": "4px"
  "8": "8px"
  "12": "12px"
  "16": "16px"
  "20": "20px"
  "24": "24px"
  "48": "48px"
components:
  button-on-air:
    backgroundColor: "{colors.onStation}"
    textColor: "{colors.station}"
    typography: "{typography.control-ios}"
    rounded: "{rounded.none}"
    height: "48px"
    padding: "0"
  button-primary:
    backgroundColor: "{colors.station}"
    textColor: "{colors.onStation}"
    typography: "{typography.control-ios}"
    rounded: "{rounded.none}"
    height: "48px"
    padding: "0"
  button-disabled:
    backgroundColor: "{colors.rule}"
    textColor: "{colors.muted}"
    typography: "{typography.control-ios}"
    rounded: "{rounded.none}"
    height: "48px"
    padding: "0"
  button-text:
    textColor: "{colors.station}"
    typography: "{typography.label}"
    rounded: "{rounded.none}"
  listing:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    typography: "{typography.title}"
    rounded: "{rounded.none}"
    padding: "8px 20px"
    height: "48px"
  minute-field:
    textColor: "{colors.onStation}"
    typography: "{typography.program}"
    rounded: "{rounded.none}"
    padding: "8px 12px"
  minute-field-met:
    backgroundColor: "{colors.onStation}"
    textColor: "{colors.station}"
    typography: "{typography.program}"
    rounded: "{rounded.none}"
    padding: "8px 12px"
  choice:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.none}"
    padding: "14px 16px"
    height: "48px"
  choice-selected:
    backgroundColor: "{colors.station}"
    textColor: "{colors.onStation}"
    typography: "{typography.body}"
    rounded: "{rounded.none}"
    padding: "14px 16px"
    height: "48px"
  nav-ios:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.muted}"
    rounded: "{rounded.none}"
  nav-ios-active:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.station}"
    rounded: "{rounded.none}"
---

# Design System: Liora

## Overview

**Creative North Star: "The Printed Program Log"**

Liora reads as one day's program, printed on cool paper. The page is flat and edge to edge. A scheduled day is three bands. The band that is on air is the only field of station blue; the other two stay short and off air. Books that are not in that slot are ruled listings under the bands. The same paper, ink, hairline, and station blue run through the catalog, the habit, the profile, and onboarding. The reader page keeps its own stored colors; only its chrome belongs to this log.

Light and dark follow the platform. Light is cool paper with deep ink. Dark sets the paper to that ink and the ink to the paper, and lifts the station blue so the live band still reads. Type on the live band stays light in both. Program titles are Barlow Condensed. Headers, captions, and controls stay on the platform face: San Francisco on iOS, Roboto on Android. Copy on the screen is the Spanish the app ships.

**Key Characteristics:**

- Cool paper, edge to edge, with one station blue for the live band
- Hairline rules and no cards or shadows
- Square corners on the log's own surfaces
- Barlow Condensed for program titles; the platform face for headers and controls
- A listing is off air, on air, or, for the day's minutes, met
- iOS closes on a Cupertino tab bar; Android closes on a Material 3 navigation bar

## Colors

The palette is cool paper, one blue, and the inks that sit on each. Light tokens are the daytime program. Dark tokens swap paper and ink and use a lighter station blue. There is no second accent.

### Primary

- **Station Blue** (`station`, `#0C4DA2`): the live band, the primary control on paper, the selected choice, the met day, and today's mark on the week and the calendar. In light, this is the only blue.
- **Night Station Blue** (`stationDark`, `#2F6FE0`): the same jobs when the platform is dark. It is lighter so the band still separates from night paper.
- **Station Type** (`onStation`, `#F4F7FB`): type and the control fill on the live band. The dark token is the same hex. It does not flip to night paper.
- **Station Wash** (`onStationMuted`, `#D5E3F8`): secondary type on the light live band, and the outline of the minute field before the goal is met.
- **Bright Station Type** (`onStationMutedDark`, `#FFFFFF`): secondary type on the night live band, and that same minute-field outline in dark.

### Neutral

- **Cool Program Paper** (`paper`, `#F4F7FB`): the page, the off-air listing, the unselected choice, and the iOS bar. Light `onStation` is this same value, used as type on the blue.
- **Program Ink** (`ink`, `#0E1A2B`): primary type on paper, and the snackbar fill. Dark paper is this same value.
- **Slate Caption** (`muted`, `#3A4C66`): dates, authors, off-air captions, inactive iOS tab labels, and disabled control labels.
- **Hairline** (`rule`, `#D5DBE3`): the 1px rule between bands and listings, unselected choice borders, the disabled control fill, and the iOS bar's top border.
- **Night Paper** (`paperDark`, `#0E1A2B`): the page in dark.
- **Night Ink** (`inkDark`, `#F4F7FB`): primary type on night paper. It is the same hex as light paper.
- **Night Caption** (`mutedDark`, `#C5D2E6`): captions and inactive tab labels in dark.
- **Night Hairline** (`ruleDark`, `#2C3C55`): rules, unselected borders, and the disabled control fill in dark.

### Named Rules

**The One Station Rule.** Station blue is the live band, the primary control, the selected mark, and the met day. Paper, ink, muted, and the hairline do the rest of the screen.

**The Station Type Rule.** Type on the live band is `onStation` and `onStationMuted`. In dark mode those stay light (`#F4F7FB` and white).

## Typography

**Display Font:** Barlow Condensed, registered as BarlowCondensed. Program titles use the bundled SemiBold (600). Medium (500) is bundled and unused by titles.

**Body Font:** the platform text theme. On iOS, headlines use CupertinoSystemDisplay and body, labels, and controls use CupertinoSystemText (San Francisco). On Android, the same roles use Roboto.

**Character:** Barlow is the condensed program face, tracked tight, for the book, the period, the promise, and the minute count. Everything that operates the log stays on the platform face at its own size.

### Hierarchy

- **Display** (Barlow Condensed, 600, 44px, line height 0.95, tracking −2% of the size): the live book's title, and the welcome promise on its station band. An empty live title uses the same face at 36px.
- **Program** (Barlow Condensed, 600, 28px, line height 0.95, tracking −2%): the off-air period name and the minute field.
- **Title** (Barlow Condensed, 600, 22px, line height 0.95, tracking −2%): a listing title. Two lines maximum, then ellipsis.
- **Headline** (platform display face, 700, line height 1.05): the schedule header. 34px on iOS, 28px on Android, in ink. The date under it is body text in muted.
- **Body** (platform text, 400, 16px, line height 1.5, tracking 0.5px): authors, empty-state lines, and choice labels. This is Material bodyLarge. Subtitles and secondary lines use bodyMedium (14px, tracking 0.25px, line height 1.43) in muted, or in `onStationMuted` on the live band. Question titles and empty catalog or time headlines use headlineSmall (24px, 400, line height 1.33) and are not program titles.
- **Label** (platform text, 500, 14px, line height 1.43, tracking 0.1px): the time column, the period name beside a live title, a listing's trailing status, and onboarding progress. Time columns set tabular figures. iOS controls are a separate role: CupertinoSystemText at 17px, weight 600, tracking −0.41px. Android filled buttons stay on labelLarge (14px, weight 500, tracking 0.1px) because the theme does not restyle their type.

### Named Rules

**The Two Faces Rule.** Barlow Condensed carries program titles. Page headers, dates, captions, questions, and controls stay on the platform face.

**The Program Tracking Rule.** Every program title uses line height 0.95 and tracking at −2% of its font size.

## Layout

The log is a phone column. The safe area keeps the header below the status bar; the tab bar closes the bottom, so scroll padding does not add a second bottom inset. A scheduled home is a header, a hairline, the live band, a fixed Importar line, then listings. The live band holds the hour, the period, the book, the minute field, and the control. Other books are listings under Importar, each with Eliminar.

The horizontal inset of the log is 20px. Header padding is 20px, 20px, 20px, 12px. Listing padding is 8px vertical and 20px horizontal, with a 48px minimum height. The live band's padding is 20px, 16px, 20px, 16px. Tight stacks inside a band are 4px or 8px. The gap before the control is 16px. Onboarding uses a 24px inset. The week chart is inset 16px; the calendar is inset 8px.

The time column is 64px on a listing and 72px on the live band. Listing trailing text sits 12px off the title. Opening a book goes straight to the reader.

### Named Rules

**The One Band Rule.** A scheduled day is the chosen band, the station field. Importar is one line under it when the library has books. Everything else is a listing on paper.

**The Gutter Rule.** Log inset is 20px. Onboarding inset is 24px.

## Elevation & Depth

The log is flat. Depth is the station field against paper, plus a 1px rule. App bars are elevation 0, with no shadow on scroll and no surface tint. Nothing in this system uses a drop shadow.

The iOS tab bar is paper at 94% opacity with a hairline along its top. That translucency is the bar's own material, not a glass panel. The Android bar is opaque paper; its selection indicator is station at 16% opacity.

### Named Rules

**The Flat Paper Rule.** Surfaces are flat at rest and in motion. Do not add a shadow to separate a band, a listing, a choice, or a control.

## Shapes

Corners on the log are square. Buttons, bands, listings, choices, hour chips, day letters, calendar cells, and week bars all use a 0 radius. Borders, where they exist, are a 1px stroke in the hairline, in station when selected, or in `onStationMuted` on the minute field. Bands and listings are not clipped to a radius. The calendar cell is a 32px square inside a 40px row. Week bars are square columns in a 96px plot.

### Named Rules

**The Square Log Rule.** Authored log surfaces are square (0). The Android navigation indicator stays the Material pill, and dialogs stay platform-rounded, because the theme does not restyle them. That platform rounding does not extend to bands, listings, or buttons.

## Components

Controls are full-width rectangles. A listing is a row on the paper, not a container. Selected things fill with station; they do not grow a shadow or a pill.

### Buttons

- **Shape:** square (0). Height 48px. Width is the column.
- **On air:** `onStation` fill, station label. This is the control at the foot of the live band, including Leer.
- **Primary:** station fill, `onStation` label. This is the control on paper, including Importar and the onboarding advance button.
- **Disabled:** hairline fill, muted label. This pair is set on the schedule action. The onboarding button, when it cannot advance, keeps the platform disabled treatment instead.
- **Text:** station label, no fill. Dialog actions use it.
- **Platform type:** iOS uses a Cupertino button at 17px, weight 600, tracking −0.41px. Android uses a filled button at labelLarge (14px, weight 500). Both are square and 48px tall.
- **Hover / Focus:** the phone UI has no hover. Focus stays on the platform button.

### Chips

Hour chips and day letters are the choice, at a different size. Unselected: paper fill, ink label, 1px hairline. Selected: station fill, `onStation` label, 1px station border. Hour chips pad 14px by 12px. Day letters are 44px tall. The weekday row on onboarding is seven of those letters.

### Cards / Containers

There is no card. A listing is paper (or station, when it is the live row) with a 1px rule under it. Internal padding is 8px by 20px. The leading time column is tabular. The title is the program face; the subtitle is muted body; the trailing status is a label in ink. On air, title and trailing switch to `onStation`, and the subtitle to `onStationMuted`.

The catalog is two blocks. Por añadir lists books still to add, each with a 72×108 cover. A muted label names the book's genre, on the row and as the group heading. Fiction drops out of that label when the book names something more specific. A book appears once, under that genre, in catalog order. Books with no genre follow, without a label. En tu biblioteca stays a short listing, 36×52, and each of those rows keeps the same genre label.

The minute field is an outline, not a card: transparent fill, 1px `onStationMuted` border, program type at 28px in `onStation`, padding 8px by 12px. When the day's minutes are met, the field fills with `onStation` and the numerals switch to station.

Book time on the Tiempo screen is type on paper: the title and the total in platform titleMedium, the total in station, sessions in muted body. No border, radius, or shadow.

### Inputs / Fields

The log has no text field. The minute field above is a status, not an input. Dialogs are the platform alert, with station text buttons. Snackbars use ink as the fill and paper as the label.

### Navigation

iOS uses a Cupertino tab bar: paper at 94% opacity, a 1px hairline on top, active station, inactive muted. Labels are CupertinoSystemText at 10px, weight 500, tracking −0.24px. The items are Descubrimiento, Biblioteca, Tiempo, and Perfil, with the platform's compass, book, timer, and person icons.

Android uses a Material 3 navigation bar on paper. The indicator is station at 16% opacity and keeps the platform pill. Labels are 12px in ink, selected or not. Icons are station when selected and muted otherwise. The labels match the iOS bar.

The schedule header is not a navigation bar. It is ink, in the headline role, with the date in muted body when the screen is the day.

### Live band

The signature is the on-air band, and it is the only band. Station fill. A 72px column holds the hour (tabular, `onStationMuted`) and the period name (`onStation`). Beside it, the book's cover is the record on air: 72×108, square, a 1px `onStationMuted` edge. Without a cover, that same frame stays and carries the title's first letter in Barlow Condensed: ink on paper, or `onStation` on the live band. The book title is program type at 28px in `onStation`, two lines, then ellipsis. The author is body in `onStationMuted`. Under the author, a 4px progress mark and the book's percent. Eliminar sits under that, as a text control. Below, the minute field is labeled Hoy, and the figure reads `0 / 10 min`. When the goal is met the label becomes Meta and the field inverts. Then the on-air control. Empty, the title is the program face at 36px, the line is "Un EPUB de este dispositivo", and the control is Importar. When the library has books, Importar is one fixed line under the band, in the control face, before the shelf. Other books are listings with a 36×52 cover and the same 4px progress mark. A missing file keeps that frame and shows the title's first letter.

Opening a book goes straight to the reader. Reader chrome, separate from the stored page color, uses the light program values: paper at 95% (`#F2F4F7FB`), a 3px station progress color, and an ink track at 20% (`#330E1A2B`). The bar folds in 180ms ease-out. It does not read the dark tokens.

### Habit marks

Week bars are square station columns. The plot is 96px tall. Today’s column has a station wash at 12% opacity, and today’s weekday label is station at weight 700. The goal is a dashed ink line, 1.5px, dash 5px, gap 4px. Calendar days are 32px squares. No reading: transparent, hairline border. Partial: station at 28% opacity, station border. Met: station fill, `onStation` numerals, `onStation` border. Today’s numeral is weight 700.

### Named Rules

**The On Air Control Rule.** A control on the station field inverts: `onStation` fill, station label. A control on paper is station fill, `onStation` label. The schedule action's disabled state is hairline fill and muted label in both places.

## Do's and Don'ts

### Do:

- **Do** take color from the light or dark token set for the current platform brightness: paper, ink, muted, rule, station, onStation, onStationMuted.
- **Do** set program titles in Barlow Condensed at weight 600, line height 0.95, and tracking at −2% of the size. The shipped sizes are 44px, 36px for an empty title, 28px, and 22px.
- **Do** keep schedule headers on the platform face: 34px and weight 700 on iOS, 28px and weight 700 on Android, line height 1.05, in ink.
- **Do** separate bands and listings with a 1px rule, and keep authored corners square (0).
- **Do** keep Importar as one fixed line under the live band when the library has books, in the control face, and keep "Un EPUB de este dispositivo" for the empty library.
- **Do** put Eliminar on each book, on the live band and on each listing.
- **Do** leave the Spanish labels as they ship, including Leer, Importar, and the date line.
- **Do** show a book's cover once on the live band (72×108) and as a 36×52 mark on its listing, square and flat, only when the file has one.
- **Do** group Por añadir by the book's specific genre. The genre is a muted label on the row and on the group. A lone Fiction stays; it drops out when the book names something more specific. En tu biblioteca keeps the same label on each row.

### Don't:

- **Don't** add a second accent, a card, a cover grid, or a drop shadow to the log. A cover is the object in the row, not the way the library is organized.
- **Don't** round bands, listings, choices, minute fields, habit marks, or schedule buttons.
- **Don't** set a platform face on a program title, or Barlow Condensed on a header or a control.
- **Don't** translate the interface into another language or a new tone.
- **Don't** restyle the Android selection pill or the platform dialog into the square log, and don't copy their rounding onto bands and buttons.
- **Don't** paint the book's stored page color as paper or station. Reader chrome is the only part of that screen in this system.
