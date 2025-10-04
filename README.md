# Bourgault Tank Optimizer

Desktop and iOS apps to optimize tank allocations for Bourgault 9000 I-Series air carts.

## Features
- Select model (91300, 9950, 9650, L9950, L9650)
- Imperial (lb/ac, acres) and metric (kg/ha, hectares)
- Common grains/fertilizers with typical densities (mass per bushel)
- Greedy allocation across tanks to maximize utilization and synchronize empties
- Save, load, export, and delete optimization plans

## Install & run
1. Install Node.js (LTS).
2. From the project folder:


## Build installers
- Windows:

Creates `dist/Bourgault Tank Optimizer Setup.exe`.

- macOS:

Creates `dist/Bourgault Tank Optimizer Setup.exe`.

- macOS:

Creates `dist/Bourgault-Tank-Optimizer.dmg` (notarization/signing recommended for distribution).

- Linux:
Creates AppImage/Deb packages in `dist/`.

## iOS Version

An iOS version of the app is available in the `iOS/` directory. See [iOS/README.md](iOS/README.md) for details on building and running the iOS app.

### iOS Quick Start
```bash
cd iOS
open BourgaultTankOptimizer.xcodeproj
```

Then build and run in Xcode (Cmd+R). Requires Xcode 15+ and iOS 16+.

## Notes
- Densities vary by variety, moisture, and blend. Adjust rates accordingly.
- Saddle tank is included as a fifth tank where applicable.

Build and run
Install dependencies:

Node.js LTS installed.

In the project folder:

npm install

Run in development:

npm start

Package installers (Win/macOS/Linux):

npm run dist

Find installers in the dist/ folder.
