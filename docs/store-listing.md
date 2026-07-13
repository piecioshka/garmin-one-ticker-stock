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

## What's new (version 1.0.0)

```
Initial release.
```

## What's new (version 1.1.0)

```
- New setting: chart window — last 24 hours (default), last 48 hours, or
  the last trading session.
- New setting: chart type — line (default) or candlestick.
- Session breaks (weekends, overnight gaps) are marked on the chart with a
  dashed vertical line when the chart spans more than one trading session.
- The ticker setting now explains the data source and the expected Yahoo
  Finance symbol format.
- Error messages for bad data include the configured ticker.
- Tightened the vertical layout: price and session change sit closer to the
  top, giving the chart more breathing room.
```

## Form metadata

| Field                  | Value                                                   |
| ---------------------- | ------------------------------------------------------- |
| Type                   | Widget                                                  |
| Category               | Finance (fall back to Lifestyle if absent)              |
| Supported devices      | Forerunner 945 (derived from the manifest in the `.iq`) |
| Permissions            | Communications — fetching quotes through the phone      |
| Source code URL        | https://github.com/piecioshka/garmin-one-ticker-stock   |
| Privacy: personal data | The app does not collect or send any personal data      |

## Artwork

- Hero Image (1440×720, optional): `docs/store-hero.png` (source:
  `docs/store-hero.html`, rendered with headless Chromium at 1440×720)
- Cover Image (500×500, required): `docs/store-cover.png`
- Screenshots (at least 1, each < 150 kB): `docs/screenshots/apple.png`
  (with the dashed session-break line), `bitcoin.png`, `brent.png`
  (candlestick mode), `nasdaq100.png` (candlestick mode), `xtb.png`
- The app icon ships inside the `.iq` package (launcher icon from resources)
