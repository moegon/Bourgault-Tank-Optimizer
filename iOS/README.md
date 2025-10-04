# Bourgault Tank Optimizer - iOS

An iOS application for optimizing tank allocations for Bourgault 9000 I-Series air carts.

## Features

- **Cart Models**: Support for 91300, 9950, 9650, L9950, and L9650 models
- **Unit Systems**: Imperial (lb/ac, acres) and Metric (kg/ha, hectares)
- **Product Catalog**: Common grains and fertilizers with typical densities
- **Smart Allocation**: Greedy allocation algorithm to maximize tank utilization
- **Visual Results**: Clear display of tank allocations with fill indicators
- **Unit Conversion**: Automatic rate and area conversion when switching units

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Project Structure

```
iOS/BourgaultTankOptimizer/
├── BourgaultTankOptimizerApp.swift  # Main app entry point
├── Models.swift                      # Data models (Product, TankModel, etc.)
├── Allocator.swift                   # Core allocation algorithm
├── ContentView.swift                 # Main UI view
├── ProductSelectionView.swift        # Product picker UI
├── ResultsView.swift                 # Results display UI
└── Assets.xcassets/                  # App assets and icons
```

## Building and Running

### Using Xcode

1. Open the project in Xcode:
   ```bash
   open iOS/BourgaultTankOptimizer.xcodeproj
   ```

2. Select a simulator or connected iOS device as the build target

3. Press Cmd+R to build and run the app

### Running Tests

1. In Xcode, press Cmd+U to run all tests
2. Or use the Test Navigator (Cmd+6) to run specific tests

Alternatively, from the command line:
```bash
xcodebuild test -project iOS/BourgaultTankOptimizer.xcodeproj \
  -scheme BourgaultTankOptimizer \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Usage

1. **Select Cart Model**: Choose your Bourgault model from the dropdown
2. **Choose Unit System**: Select Imperial or Metric units
3. **Enter Field Size**: Input the size of your field
4. **Add Products**: Tap "Add Product" to select products from the catalog
5. **Set Application Rates**: Enter the rate for each product
6. **Calculate**: Tap "Calculate Allocation" to compute the tank assignments
7. **View Results**: Review the allocation results with visual fill indicators

## Implementation Details

### Core Algorithm

The allocation algorithm (`Allocator.swift`) implements a greedy approach:
1. Calculate bushels needed for each product based on rate, area, and density
2. Sort products by bushels required (largest first)
3. Sort tanks by capacity (largest first)
4. Allocate products sequentially to available tanks
5. Mark any overflow as "UNALLOCATED"

This mirrors the JavaScript implementation from the Electron version.

### Unit Conversions

- **Rate conversion**: 1 lb/ac = 1.120849 kg/ha
- **Area conversion**: 1 acre = 0.404685642 hectares
- **Density**: lb/bu to kg/bu using 1 lb = 0.453592 kg

### Data Models

- **TankModel**: Represents cart models with tank capacities
- **Product**: Product catalog with densities (lb/bu)
- **ProductSelection**: User's product choices with rates
- **AllocationResult**: Complete result with tank assignments and utilization

## Testing

The test suite (`AllocatorTests.swift`) includes:
- Allocation within capacity
- Insufficient capacity handling
- Imperial and metric unit calculations
- Tank sorting and labeling
- Multiple product allocation
- Edge case validation

## Notes

- Densities are typical values and may vary by variety, moisture, and blend
- Adjust application rates as needed for your specific products
- The Saddle tank is included as a fifth tank where applicable
- All calculations maintain precision for accurate field operations

## Architecture

The app follows SwiftUI best practices:
- **MVVM pattern**: Models, Views, and business logic are separated
- **Declarative UI**: SwiftUI for modern, reactive interfaces
- **Testability**: Core logic is independent and unit-tested
- **Accessibility**: Follows Apple's Human Interface Guidelines

## Future Enhancements

Potential improvements:
- Save and load optimization plans
- Export results as PDF or CSV
- Historical plan comparison
- Advanced optimization algorithms (beyond greedy)
- Support for custom products and densities
- iPad-optimized layout
- Dark mode support

## License

MIT License - See main repository LICENSE file

## Credits

iOS implementation based on the Electron desktop version.
Original concept and algorithm by moses.
