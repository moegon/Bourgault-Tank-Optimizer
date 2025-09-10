# Bourgault Tank Optimizer — Project Report

Date: 2025-09-10

This report summarizes the current state of the Bourgault Tank Optimizer desktop app, the design and algorithms used, verification performed, CI/packaging, and recommended next steps.

## Summary

The Bourgault Tank Optimizer is an Electron-based desktop utility to help plan product (grains, fertilizers) allocations into the Bourgault 9000 I-Series air cart tanks. It supports imperial and metric units, has a product catalog with typical densities (lb per bushel), a greedy allocation algorithm, save/load/export of plans, and basic packaging configuration.

## Files & structure

- `package.json` — app metadata, start/build/test scripts, devDependencies.
- `main.js` — Electron main process, IPC handlers for history (save/list/delete/export), and simple storage in Documents directory (`tank_optimizations.json`).
- `renderer.js` — UI wiring, uses `lib/allocator` for allocation, manages form and history UI.
- `data.js` — model tank capacities and product densities.
- `lib/allocator.js` — allocation logic (unit-agnostic entry points and greedy allocation). Unit-tested.
- `test/allocator.test.js` — Mocha/Chai unit tests (happy path and over-capacity case).
- `assets/icon.svg` — base SVG icon wired into build config.
- `.github/workflows/ci.yml` — GitHub Actions workflow to install deps, run tests and run electron-builder (no publish).
- `REPORT.md` — this document.

## Design & Algorithm

- Unit support: The app supports two unit systems:
  - Imperial: lb/acre, acres
  - Metric: kg/ha, hectares

- Bushel calculation:
  - For each product, the app stores a typical `lbPerBu` value.
  - computeBushelsNeeded(rate, area) converts the mass-based rate into bushels needed using the stored density; allocator receives bushels per product.

- Allocation algorithm (in `lib/allocator.js`):
  - Build a list of tanks with capacities from the chosen model.
  - Sort tanks by capacity descending.
  - Sort products by bushels needed descending.
  - Greedily fill the largest available tank(s) with the largest remaining product until exhausted or tanks used.
  - Any remaining bushels become `UNALLOCATED` entries.

This strategy is intentionally simple (greedy) and matches the initial specification: maximize utilization and simplify refill synchronization by placing larger volumes in larger tanks.

## Tests & Verification

- Unit tests:
  - `test/allocator.test.js` contains two tests:
    - Allocation within capacity (verifies total bushels computed and assigned).
    - Over-capacity behavior (verifies that UNALLOCATED entries appear when tanks are insufficient).

- Local test run results (on developer machine):

  npm test

  => 2 passing (9ms)

These tests are a small safety net. More tests are recommended for:
  - Unit conversion accuracy (lb/ac <-> kg/ha and ac <-> ha).
  - Multi-product and split allocation cases.
  - Edge cases (zero/negative input, extremely large numbers, floating rounding tolerances).

## CI & Packaging

- GitHub Actions workflow (`.github/workflows/ci.yml`) runs on push/pull-request to `main`/`master`. It:
  - Installs Node (Node 20), runs `npm install`.
  - Runs tests (`npm test`).
  - Executes `npm run dist -- --publish never` to exercise electron-builder (produces artifacts in `dist/`).

- Packaging config in `package.json` uses `electron-builder` with simple cross-platform targets (AppImage/deb for Linux, nsis/zip for Windows, dmg/zip for macOS). An `assets/icon.svg` file is included; adding PNG/ICO/ICNS files for each platform will improve launcher icons.

## Security & Storage

- Saved optimizations are serialized to `tank_optimizations.json` in the user's Documents folder. This is a simple local storage mechanism. If plans contain sensitive data, consider encrypting the file or allowing export/import with user-chosen locations.

## What I changed recently

- Extracted allocation logic to `lib/allocator.js` and updated `renderer.js` accordingly.
- Added unit tests and a CI workflow file.
- Added `assets/icon.svg` and wired an icon path into `package.json` build config.

## Next recommended work (prioritized)

1. Expand unit tests (increase coverage):
   - Add tests for unit conversions, multi-product splits, and precision checks.
2. Add platform icons:
   - Generate PNG/ICO/ICNS at recommended sizes and add them to `assets/`.
3. UI polish:
   - Improve layout responsiveness, add visual cues for tank fill levels (bars), and add printable/exportable report view.
4. Packaging improvements & CI:
   - Add signed macOS builds (notarization), and CI secrets for code signing where needed.
5. Optional algorithm improvements:
   - Replace greedy allocation with a small optimization routine (knapsack-like, or ILP) to minimize UNALLOCATED and balance refill timing.

## How to run (developer)

1. Install dependencies

```bash
cd /path/to/bourgault-tank-optimizer
npm install
```

2. Run tests

```bash
npm test
```

3. Run in development

```bash
npm start
```

4. Build installers (local)

```bash
npm run dist
```

## Requirements coverage mapping

- Create project files (package.json, main.js, index.html, renderer.js, data.js, README.md) — Done
- Add automated tests — Done (basic coverage) ✅
- Add icons and polish UI layout — Partially done (SVG icon added). PNG/ICO/ICNS and visual UI polish are recommended next steps. ⚠️
- Add packaging CI configuration — Done (GitHub Actions workflow added) ✅

## Repository & publishing

The project was initialized as a local git repository and committed. If you want the repo published to GitHub as a public repository, provide a preferred repository name or confirm I should create `moses/bourgault-tank-optimizer` and push (requires `gh` or your provided remote). I can then push the code and report back with the public URL.

## Final notes

This report is intentionally concise and actionable. If you'd like, I can:
- Add more unit tests now (I recommend adding conversion tests next).
- Produce platform-specific icons and wire them into electron-builder.
- Create and push a public GitHub repo named `bourgault-tank-optimizer` under your account and return the URL.

Pick one next action and I'll proceed.
