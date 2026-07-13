# Connect IQ Store listing 🏪

Materiały do wklejenia w formularzu Developer Dashboard
(https://apps.garmin.com/developer/dashboard) przy publikacji aplikacji.

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
- Intraday line chart (1 day, 15-minute candles); automatic 2-day fallback
  when the current day has no data yet (typical for crypto mornings)
- Instrument name and session status (opens/closes/closed) shown in your
  watch-local time
- Works with any instrument known to Yahoo Finance: stocks (AAPL), crypto
  (BTC-USD), indices (^NDX), futures (BZ=F), Warsaw Stock Exchange tickers
  (XTB.WA) and more
- Last successful quote is cached on the watch, so the widget always shows
  data instantly and refreshes in the background
- Clear error states for no phone connection and unknown tickers

SETUP

Set your ticker in the app settings (Garmin Connect Mobile → device →
Connect IQ apps → One Ticker Stock → Settings). Use Yahoo Finance ticker
symbols.

DATA SOURCE

Quotes come from the public Yahoo Finance chart API (no account or API key
needed). Requests go through the Garmin Connect Mobile app on your phone,
so the watch must be paired and the phone online. This app is not
affiliated with Yahoo. Data may be delayed — do not use it as the sole
basis for trading decisions.
```

## What's new (wersja 1.0.0)

```
Initial release.
```

## Metadane formularza

| Pole                  | Wartość                                                      |
| --------------------- | ------------------------------------------------------------ |
| Type                  | Widget                                                       |
| Category              | Finance (jeśli brak — Lifestyle)                             |
| Supported devices     | Forerunner 945 (wynika z manifestu w `.iq`)                  |
| Permissions           | Communications — pobieranie notowań przez telefon            |
| Source code URL       | https://github.com/piecioshka/garmin-one-ticker-stock        |
| Privacy: dane osobowe | Aplikacja nie zbiera ani nie wysyła żadnych danych osobowych |

## Grafiki

- Screenshoty (min. 1): `docs/screenshots/apple.png`, `bitcoin.png`,
  `brent.png`, `nasdaq100.png`, `xtb.png`
- Ikona aplikacji jest w paczce `.iq` (launcher icon z zasobów)
