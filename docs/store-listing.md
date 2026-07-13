# Connect IQ Store listing 🏪

Copy-paste materials for the Developer Dashboard form
(https://apps.garmin.com/developer/dashboard) used when publishing the app.

## App name

```
One Ticker Stock
```

## Summary / Description

```
One ticker. One glance. One Ticker Stock shows the current price and an
intraday chart of a single financial instrument — right in your widget
carousel.

FEATURES

- Current price with change vs. previous close (green/red)
- Price chart of 15-minute candles with a configurable window: last 24
  hours (default), last 48 hours, or the last trading session; automatic
  fallback to the last two trading days when the window is empty
- Configurable chart type: line (default) or candlestick
- Dashed vertical line marking the break between trading sessions when the
  chart spans more than one
- Instrument name and session status (opens/closes/closed) shown in your
  watch-local time
- Works with any instrument known to Yahoo Finance: stocks (AAPL), crypto
  (BTC-USD), indices (^NDX), futures (BZ=F), Warsaw Stock Exchange tickers
  (XTB.WA) and more
- Last successful quote is cached on the watch, so the widget always shows
  data instantly and refreshes in the background
- Clear error states for no phone connection and unknown tickers

SETUP

Set your ticker, chart window and chart type in the app settings (Garmin
Connect Mobile → device → Connect IQ apps → One Ticker Stock → Settings).
Use Yahoo Finance ticker symbols.

DATA SOURCE

Quotes come from the public Yahoo Finance chart API (no account or API key
needed). Requests go through the Garmin Connect Mobile app on your phone,
so the watch must be paired and the phone online. This app is not
affiliated with Yahoo. Data may be delayed — do not use it as the sole
basis for trading decisions.
```

## What's new

Per-release notes for the "What's new" field live in
[`CHANGELOG.md`](../CHANGELOG.md) — paste the section of the released
version.

## Form metadata

| Field                  | Value                                                                                                                                             |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Type                   | Widget                                                                                                                                            |
| Category               | Finance (fall back to Lifestyle if absent)                                                                                                        |
| Supported devices      | Forerunner 945, tactix 7 (incl. AMOLED / epix Pro Gen 2), Venu 2/2S/2 Plus/3/3S/4, vívoactive 3/4/4S/5/6 (derived from the manifest in the `.iq`) |
| Permissions            | Communications — fetching quotes through the phone                                                                                                |
| Source code URL        | https://github.com/piecioshka/garmin-one-ticker-stock                                                                                             |
| Privacy: personal data | The app does not collect or send any personal data                                                                                                |

## Artwork

- Hero Image (1440×720, optional): `docs/store-hero.png` — tactix 7 with a
  line chart (`docs/store-hero-tactix.png`) next to Venu 3 with candles
  (`docs/screenshots/nasdaq100.png`); source: `docs/store-hero.html`,
  rendered with headless Chromium at 1440×720
- Cover Image (500×500, required): `docs/store-cover.png` — Venu 3 face
  with NQ=F candles
- Screenshots (at least 1, each < 150 kB), each taken on a different watch
  model: `docs/screenshots/apple.png` (Forerunner 945), `bitcoin.png`
  (epix Pro Gen 2), `brent.png` (tactix 7, candlestick mode),
  `nasdaq100.png` (Venu 3, candlestick mode), `xtb.png` (vívoactive 5)
- The app icon ships inside the `.iq` package (launcher icon from resources)
