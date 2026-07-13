# garmin-one-ticker-stock ⌚📈

[![Connect IQ Store](https://img.shields.io/badge/Connect_IQ_Store-One_Ticker_Stock-007CC3?logo=garmin)](https://apps.garmin.com/en-US/apps/f4445669-50fa-4d35-a988-ee1a65721bfb)

📊 Connect IQ widget for Garmin watches — Forerunner 945, tactix 7
(incl. AMOLED / epix Pro Gen 2), Venu 2/3/4 and vívoactive 3/4/5/6 — that
shows the current price and an intraday chart of any stock ticker you
configure in the app settings. The layout scales to every screen size.

Available as **One Ticker Stock** in the official
[Connect IQ Store](https://apps.garmin.com/en-US/apps/f4445669-50fa-4d35-a988-ee1a65721bfb).

## Screenshots 📸

Each screenshot comes from a different watch model:

| Apple                                              | XTB                                              | Brent oil                                          | NASDAQ-100                                             | Bitcoin                                              |
| -------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------- |
| `AAPL`                                             | `XTB.WA`                                         | `BZ=F` (candlestick)                               | `NQ=F` (candlestick)                                   | `BTC-USD`                                            |
| Forerunner 945                                     | vívoactive 5                                     | tactix 7                                           | Venu 3                                                 | epix Pro (Gen 2)                                     |
| <img src="docs/screenshots/apple.png" width="150"> | <img src="docs/screenshots/xtb.png" width="150"> | <img src="docs/screenshots/brent.png" width="150"> | <img src="docs/screenshots/nasdaq100.png" width="150"> | <img src="docs/screenshots/bitcoin.png" width="150"> |

## Features 🚀

- 💰 Current price with change vs. previous close (green/red)
- 📈 Price chart of 15-minute candles with a configurable window: last 24
  hours (default), last 48 hours, or the last trading session; when the
  window is empty (stock exchanges on weekends, before the session), the
  widget falls back to the last two trading days
- 🕯️ Configurable chart type: line (default) or candlestick
- ✂️ Dashed vertical line marking the break between trading sessions when
  the chart spans more than one (weekends, overnight gaps)
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
- Device files for the target devices (e.g. `fr945`, `fenix7x`, `venu3`)
  downloaded in the SDK Manager (Devices tab)
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
  -o bin/garmin-one-ticker-stock.prg \
  -y "$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der" -w
```

## Tests 🧪

Unit tests cover the Yahoo response parser and the chart scaling logic.
Start the simulator first, then:

```sh
SDK="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
open -a "$SDK/bin/ConnectIQ.app"

monkeyc -f monkey.jungle -d fr945 -o bin/garmin-one-ticker-stock-test.prg \
  -y "$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der" --unit-test
"$SDK/bin/monkeydo" bin/garmin-one-ticker-stock-test.prg fr945 -t
```

## Run in the simulator ▶️

```sh
"$SDK/bin/monkeydo" bin/garmin-one-ticker-stock.prg fr945
```

Change the ticker in the simulator via _File → Edit Application →
App Settings_.

## Install from the Connect IQ Store 🏪

Install [One Ticker Stock](https://apps.garmin.com/en-US/apps/f4445669-50fa-4d35-a988-ee1a65721bfb)
from the Connect IQ Store (via Garmin Connect Mobile or the Connect IQ app).
This is the recommended way — app settings (ticker, chart window, chart
type) are then editable from the phone.

## Install manually (sideload) ⌚

Connect the watch over USB and copy the app:

```sh
cp bin/garmin-one-ticker-stock.prg /Volumes/GARMIN/GARMIN/APPS/
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
