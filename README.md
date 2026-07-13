# garmin-stocks ⌚📈

📊 Connect IQ widget for the Garmin Forerunner 945 that shows the current
price and an intraday chart of any stock ticker you configure in the app
settings.

## Screenshots 📸

| Apple                                              | XTB                                              | Brent oil                                          | NASDAQ-100                                             | Bitcoin                                              |
| -------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------- |
| `AAPL`                                             | `XTB.WA`                                         | `BZ=F`                                             | `^NDX`                                                 | `BTC-USD`                                            |
| <img src="docs/screenshots/apple.png" width="150"> | <img src="docs/screenshots/xtb.png" width="150"> | <img src="docs/screenshots/brent.png" width="150"> | <img src="docs/screenshots/nasdaq100.png" width="150"> | <img src="docs/screenshots/bitcoin.png" width="150"> |

## Features 🚀

- 💰 Current price with change vs. previous close (green/red)
- 📈 Intraday line chart (1 day, 15-minute interval); when Yahoo has no
  candles for the current UTC day yet (typical for crypto), the widget
  falls back to a 2-day window
- 🕒 Instrument name and session status (opens/closes/closed) in the
  watch-local time
- 🌍 Any instrument known to Yahoo Finance: stocks (`AAPL`), crypto
  (`BTC-USD`), indices (`^NDX`), futures (`BZ=F`), GPW tickers (`XTB.WA`)
- 💾 Last successful quote cached on the watch — the widget always shows
  data instantly and refreshes in the background
- 🚨 Error states for no phone connection and unknown tickers

## Data source 🌐

Unofficial Yahoo Finance chart API (no API key required):

```
GET https://query1.finance.yahoo.com/v8/finance/chart/{TICKER}?range=1d&interval=15m
```

Requests go through the Garmin Connect Mobile app on your phone, so the
watch must be paired and the phone online.

## Requirements 🧰

- Connect IQ SDK (tested with 9.2.0) installed via the official SDK Manager
- Device files for `fr945` downloaded in the SDK Manager (Devices tab)
- A developer key (`developer_key.der`)

> [!IMPORTANT]
> Use the simulator app bundled inside the SDK directory (the one pointed to
> by `~/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg`). A
> `ConnectIQ.app` moved out of the SDK `bin/` directory (e.g. by the Homebrew
> cask) hangs on startup, because it cannot find SDK resources next to
> itself.

## Build 🔨

```sh
monkeyc -f monkey.jungle -d fr945 \
  -o bin/garmin-stocks.prg \
  -y "$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der" -w
```

## Tests 🧪

Unit tests cover the Yahoo response parser and the chart scaling logic.
Start the simulator first, then:

```sh
SDK="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
open -a "$SDK/bin/ConnectIQ.app"

monkeyc -f monkey.jungle -d fr945 -o bin/garmin-stocks-test.prg \
  -y "$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der" --unit-test
"$SDK/bin/monkeydo" bin/garmin-stocks-test.prg fr945 -t
```

## Run in the simulator ▶️

```sh
"$SDK/bin/monkeydo" bin/garmin-stocks.prg fr945
```

Change the ticker in the simulator via _File → Edit Application →
App Settings_.

## Install on the watch ⌚

Connect the watch over USB and copy the app:

```sh
cp bin/garmin-stocks.prg /Volumes/GARMIN/GARMIN/APPS/
```

The widget appears in the widget carousel (UP/DOWN buttons from the watch
face).

> [!WARNING]
> Editing app settings from Garmin Connect Mobile works only for apps
> installed from the Connect IQ Store. For a sideloaded `.prg` the ticker
> stays at the value baked into `resources/settings/properties.xml`
> (default: `BZ=F`, Brent crude futures) — change it there and rebuild, or publish the app in the
> store (a beta listing is enough) to configure it from the phone.

## License 📄

[The MIT License](https://piecioshka.mit-license.org) @ 2026
