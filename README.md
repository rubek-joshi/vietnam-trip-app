# Vietnam Handbook

Offline Flutter trip companion for **Danang – Hoi An – Hanoi – Halong Bay** (22–28 Sep 2026).

## Features

1. **Home** — USD / NPR / VND converter with saved history (sort by label or amount)
2. **Checklist** — Swipeable Day 1–7 todos (opens on the active trip day)
3. **Budget** — Dual wallets (VND default + USD), USD→VND exchanges, expenses with live NPR, remaining balance + stats
4. **Phrases** — Offline English ↔ Vietnamese travel dictionary
5. **Others** — Package costs, hotels, inclusions, itinerary, vouchers, tipping calculator (×9), FX rates, settings

## Run

```bash
flutter pub get
flutter run
```

All data is stored locally with Hive. No network required.
