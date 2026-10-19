# Contributing to One Ticker Stock

How to build, test and run the widget, and where its data comes from. For what the app does, see the [README](README.md).

## Requirements

- Connect IQ SDK (tested with 9.2.0) installed via the official SDK Manager
- Device files for the target devices (e.g. `fr945`, `fenix7x`, `venu3`) downloaded in the SDK Manager (Devices tab)
- A developer key (`developer_key.der`)

> [!IMPORTANT]
> Use the simulator app bundled inside the SDK directory (the one pointed to by `~/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg`). A `ConnectIQ.app` moved out of the SDK `bin/` directory (e.g. by the Homebrew cask) hangs on startup, because it cannot find SDK resources next to itself.

## Build

```sh
monkeyc -f monkey.jungle -d fr945 \
  -o bin/garmin-one-ticker-stock.prg \
  -y "$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der" -w
```

The store package is an `.iq` file built with `monkeyc -e -r` into `bin/`.

## Tests

Unit tests (`Toybox.Test`) cover the Yahoo response parser and the chart scaling logic (`source/*Test.mc`). Start the simulator first, then:

```sh
SDK="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
open -a "$SDK/bin/ConnectIQ.app"

monkeyc -f monkey.jungle -d fr945 -o bin/garmin-one-ticker-stock-test.prg \
  -y "$HOME/Library/Application Support/Garmin/ConnectIQ/developer_key.der" --unit-test
"$SDK/bin/monkeydo" bin/garmin-one-ticker-stock-test.prg fr945 -t
```

## Run in the simulator

```sh
"$SDK/bin/monkeydo" bin/garmin-one-ticker-stock.prg fr945
```

Change the ticker in the simulator via _File → Edit Application → App Settings_.

## Install manually (sideload)

Connect the watch over USB and copy the app:

```sh
cp bin/garmin-one-ticker-stock.prg /Volumes/GARMIN/GARMIN/APPS/
```

The widget appears in the widget carousel (UP/DOWN buttons from the watch face).

> [!WARNING]
> Editing app settings from Garmin Connect Mobile works only for apps installed from the Connect IQ Store. For a sideloaded `.prg` the ticker stays at the value baked into `resources/settings/properties.xml` (default: `BZ=F`, Brent crude futures) - change it there and rebuild, or publish the app in the store (a beta listing is enough) to configure it from the phone.

## Data source

Unofficial Yahoo Finance chart API (no API key required):

```
GET https://query1.finance.yahoo.com/v8/finance/chart/{TICKER}?period1={now-24h}&period2={now}&interval=15m
```

The trailing 24 h (default) and 48 h chart windows query a `period1`/`period2` timestamp range; the "last session" window uses `range=1d` instead. Requests go through the Garmin Connect Mobile app on your phone, so the watch must be paired and the phone online.

## Project structure

| Path                                    | What it holds                                                      |
| --------------------------------------- | ------------------------------------------------------------------ |
| `manifest.xml`, `monkey.jungle`         | app manifest (supported devices, permissions) and build config     |
| `source/StocksApp.mc`                   | app entry point                                                    |
| `source/StocksView.mc`                  | widget view                                                        |
| `source/YahooClient.mc`                 | Yahoo chart request and response parsing                           |
| `source/ChartRenderer.mc`               | line and candlestick chart drawing                                 |
| `source/SessionInfo.mc`                 | session status (opens/closes/closed)                               |
| `source/*Test.mc`                       | unit tests                                                         |
| `resources/settings/`                   | app settings (ticker, chart window, chart type) and defaults       |
| `docs/store-listing.md`                 | Connect IQ Store listing texts                                     |
| `docs/store-*.png`, `docs/screenshots/` | store cover, hero (source: `docs/store-hero.html`) and screenshots |

The widget fetches the quote when opened and caches the last successful response in `Application.Storage`; there is no background service.

## Releases

Each release gets an entry in [CHANGELOG.md](CHANGELOG.md); the same notes go into the "What's new" field of the Connect IQ Store Developer Dashboard.

## Conventions

- Commits follow Conventional Commits in English (`feat:`, `fix:`, `docs:`, `style:`, `chore:`).
- The default ticker is intentionally `BZ=F` (Brent).
- Temporary files go to `tmp/` (ignored by git).
