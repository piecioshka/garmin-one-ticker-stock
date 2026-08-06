# Pamięć projektu — garmin-one-ticker-stock

Trwałe fakty o TYM repozytorium. Agent czyta ten plik przez dyrektywę `@MEMORY.md`
w pliku instrukcji repo.

## Zasady wpisów

- Jeden fakt = jeden punkt listy.
- Format: `- [RRRR-MM-DD] [projekt] treść faktu`.
- Fakty dotyczące TEGO repo trzymamy tutaj; preferencje ogólne, fakty o użytkowniku
  i referencje niezwiązane z repo — w globalnym `MEMORY.md`.
- Przed dopisaniem sprawdź, czy fakt już nie istnieje — aktualizuj zamiast duplikować.
- Usuwaj fakty nieaktualne. Pisz zwięźle, po polsku.
- Sekcja `## Fakty` posortowana malejąco po dacie (najnowsze u góry).

## Fakty

- [2026-07-13] [projekt] Aplikacja nazywa się „One Ticker Stock" — widget Connect IQ pokazujący aktualną cenę i wykres intraday (Yahoo chart API, bez klucza). Nazwa wybrana po sprawdzeniu kolizji: „Stocks" zajęte przez oficjalny widget Garmina.
- [2026-07-13] [projekt] Architektura: „fetch on open" + cache w `Application.Storage`, bez background service. Ticker w property `ticker` (`resources/settings/properties.xml`). Czyste funkcje `parseChart`/`scalePoints` mają testy `Toybox.Test` — build z `--unit-test`, potem `monkeydo … fr945 -t`.
- [2026-07-13] [projekt] Domyślny ticker to CELOWO `BZ=F` (Brent) — decyzja usera („zostaw ropę brent jako domyślną"). Nie „naprawiać" na AAPL.
- [2026-07-13] [projekt] PUŁAPKA sideloadu: ustawień z Garmin Connect Mobile nie da się edytować dla `.prg` wgranego po USB — tylko dla aplikacji ze sklepu CIQ. W symulatorze: File → Edit Application → App Settings.
- [2026-07-13] [projekt] Paczka eksportowa do sklepu: `monkeyc -e -r` → `.iq` (archiwum 7z) w `bin/`, klucz w `~/Library/Application Support/Garmin/ConnectIQ/developer_key.der`. Strona w sklepie: https://apps.garmin.com/en-US/apps/f4445669-50fa-4d35-a988-ee1a65721bfb (display name dewelopera: piecioshka).
- [2026-07-13] [projekt] Materiały sklepowe: `docs/store-listing.md` (opis/metadane), `docs/store-cover.png` (500×500), `docs/store-hero.png` (1440×720; źródło `docs/store-hero.html`, render headless Chromium przez lokalny http.server — Playwright MCP blokuje `file://`).
- [2026-07-13] [projekt] PUŁAPKA screenshotów sklepowych: `tmp/shoot*.sh` podmienia sedem default ticker/chartType w `resources/settings/properties.xml` — po sesji zrzutów przywrócić default. Symulator ignoruje `<prg>-settings.json` obok pliku, trzeba czyścić `$TMPDIR/com.garmin.connectiq/GARMIN/APPS/{SETTINGS,DATA}`. Zrzuty: okno sim przez `screencapture -x -l <id>`, crop `tmp/crop_screenshots.py` (384×587), potem pngquant (limit sklepu 150 kB/plik).
