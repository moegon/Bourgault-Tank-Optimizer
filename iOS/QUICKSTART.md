# Quick Start Guide - iOS Developer

## Prerequisites

Before you begin, ensure you have:
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (download from Mac App Store)
- Basic understanding of Swift and iOS development
- An Apple ID (free tier works for simulator testing)

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/moegon/Bourgault-Tank-Optimizer.git
cd Bourgault-Tank-Optimizer
```

### Step 2: Open the iOS Project

```bash
cd iOS
open BourgaultTankOptimizer.xcodeproj
```

Xcode will launch and open the project.

### Step 3: Build and Run

1. In Xcode, select a simulator from the device menu (e.g., "iPhone 15")
2. Press **Cmd + R** or click the ▶️ Play button
3. Wait for the build to complete
4. The app will launch in the iOS Simulator

**First build may take 1-2 minutes. Subsequent builds are faster.**

## Project Tour

### Key Files to Know

| File | Purpose |
|------|---------|
| `Models.swift` | Data structures (Product, TankModel, etc.) |
| `Allocator.swift` | Core allocation algorithm |
| `ContentView.swift` | Main screen UI |
| `ProductSelectionView.swift` | Product picker |
| `ResultsView.swift` | Results display |
| `AllocatorTests.swift` | Unit tests |

### Project Navigator (Left Sidebar)

```
📁 BourgaultTankOptimizer
  📄 BourgaultTankOptimizerApp.swift    ← App entry point
  📄 ContentView.swift                   ← Main UI
  📄 Models.swift                        ← Data models
  📄 Allocator.swift                     ← Algorithm
  📄 ProductSelectionView.swift          ← Product picker
  📄 ResultsView.swift                   ← Results view
  📁 Assets.xcassets                     ← Images/colors
  📁 Preview Content                     ← SwiftUI previews

📁 BourgaultTankOptimizerTests
  📄 AllocatorTests.swift                ← Unit tests
```

## Running Tests

### In Xcode

1. Press **Cmd + U** to run all tests
2. Or click the test navigator (diamond icon, 5th icon from top left)
3. Click individual tests to run them

### From Command Line

```bash
xcodebuild test \
  -project BourgaultTankOptimizer.xcodeproj \
  -scheme BourgaultTankOptimizer \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Expected output:**
```
Test Suite 'All tests' passed at ...
Executed 8 tests, with 0 failures (0 unexpected)
```

## Using the App

### Basic Workflow

1. **Launch** → App opens to main screen
2. **Select cart model** → Tap the picker, choose a model (e.g., "91300")
3. **Enter field size** → Tap the field, enter a number (e.g., "160")
4. **Add products** → Tap "Add Product", select from catalog
5. **Set rates** → For each product, enter application rate
6. **Calculate** → Tap "Calculate Allocation"
7. **View results** → Tap "View Results" to see tank assignments

### Example Calculation

**Inputs:**
- Model: 91300
- Units: Imperial
- Field Size: 160 acres
- Products:
  - Wheat @ 100 lb/ac
  - Canola @ 5 lb/ac

**Expected Results:**
- Wheat: 266.7 bushels (fills Tank 1 at 42%)
- Canola: 16.0 bushels (fills Tank 4 at 5.4%)
- Utilization: 20.6%

## Development Tips

### SwiftUI Previews

Many files have a `#Preview` block at the bottom. You can:
1. Click "Resume" in the canvas (right side)
2. See live preview without running app
3. Interact with preview in real-time

### Live Preview

1. Open `ContentView.swift`
2. Click "Resume" in the canvas (or Cmd + Option + P)
3. Make changes to code
4. Preview updates automatically

### Debugging

**Print Debugging:**
```swift
print("Field size: \(fieldSize)")
```

**Breakpoints:**
1. Click left gutter next to line number
2. Blue arrow appears
3. Run app, execution pauses at breakpoint

**LLDB Console:**
- View variables: `po fieldSize`
- Continue: `continue` or `c`

## Common Issues

### Issue: "No such module 'BourgaultTankOptimizer'"

**Solution:** Clean and rebuild
1. Product → Clean Build Folder (Cmd + Shift + K)
2. Product → Build (Cmd + B)

### Issue: Simulator won't launch

**Solution:**
1. Xcode → Preferences → Locations
2. Verify Command Line Tools is set
3. Restart Xcode

### Issue: Code signing error

**Solution:**
1. Select project in navigator
2. Select target "BourgaultTankOptimizer"
3. Signing & Capabilities tab
4. Change "Team" to your Apple ID or "None" for simulator

### Issue: Tests fail

**Solution:**
1. Check if tests compile
2. Read error messages carefully
3. Ensure test target is selected

## Making Changes

### Adding a New Product

**In `Models.swift`:**
```swift
static let catalog: [Product] = [
    // ... existing products ...
    Product(name: "YourProduct", densityLbPerBu: 55),
]
```

### Changing Tank Capacities

**In `Models.swift`:**
```swift
static let allModels: [TankModel] = [
    TankModel(name: "91300", capacities: [635, 230, 140, 295, 44]),
    // Modify capacities array ↑
]
```

### Modifying UI

**In `ContentView.swift`, find the view you want to change:**
```swift
Text("Tank Optimizer")
    .font(.largeTitle)       // Change font
    .foregroundColor(.blue)  // Change color
```

## Code Style

Follow these conventions:

### Naming
- Types: `PascalCase` (e.g., `TankModel`)
- Variables: `camelCase` (e.g., `fieldSize`)
- Functions: `camelCase` (e.g., `calculatePlan()`)

### Formatting
- Indent: 4 spaces (Xcode default)
- Line length: ~100 characters max
- Blank line between functions

### Comments
```swift
// Single-line comment

/// Documentation comment for functions
/// - Parameter rate: Application rate
/// - Returns: Bushels needed
func computeBushels(rate: Double) -> Double {
    // Implementation
}
```

## SwiftUI Basics

### State Management
```swift
@State private var fieldSize: String = "160"
// When fieldSize changes, view re-renders
```

### Views
```swift
VStack {          // Vertical stack
    Text("Hello")
    Button("Tap") { }
}

HStack {          // Horizontal stack
    Text("Left")
    Spacer()
    Text("Right")
}

List {            // Scrollable list
    Text("Item 1")
    Text("Item 2")
}
```

### Navigation
```swift
NavigationLink(destination: ResultsView()) {
    Text("View Results")
}
// Tapping pushes ResultsView onto stack
```

## Testing Guide

### Writing a New Test

**In `AllocatorTests.swift`:**
```swift
func testMyNewFeature() throws {
    // Arrange: Set up test data
    let model = TankModel(name: "Test", capacities: [100])
    
    // Act: Perform action
    let result = Allocator.allocate(...)
    
    // Assert: Verify result
    XCTAssertEqual(result.utilizationPercent, 50.0, accuracy: 0.1)
}
```

### Running Single Test
- Click diamond icon next to test function
- Or Cmd + Click test name

## Deployment

### For Personal Use (Simulator)
- Already works! Just run in Xcode.

### For Testing on Device
1. Connect iPhone/iPad via USB
2. Select device in Xcode
3. Trust computer on device
4. Free Apple ID: Works for 7 days, then re-deploy
5. Paid Apple Developer ($99/year): Works for 1 year

### For Distribution (App Store)
1. Join Apple Developer Program ($99/year)
2. Create app record in App Store Connect
3. Archive app (Product → Archive)
4. Upload to App Store Connect
5. Submit for review

## Resources

### Apple Documentation
- [Swift Language Guide](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### This Project
- [Main README](README.md) - Feature overview
- [IMPLEMENTATION.md](IMPLEMENTATION.md) - Technical details
- [DESIGN.md](DESIGN.md) - UI/UX design

### Getting Help
- Check existing issues on GitHub
- Apple Developer Forums
- Stack Overflow (tag: swift, swiftui)

## Next Steps

1. ✅ Run the app
2. ✅ Run the tests
3. ✅ Explore the code
4. Try making a small change (e.g., default field size)
5. Add a new product to the catalog
6. Modify the UI colors or layout
7. Add a new feature (e.g., save last calculation)

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd + R | Run app |
| Cmd + B | Build |
| Cmd + U | Run tests |
| Cmd + Shift + K | Clean build folder |
| Cmd + / | Comment/uncomment |
| Cmd + [ | Decrease indent |
| Cmd + ] | Increase indent |
| Cmd + Click | Jump to definition |
| Cmd + Option + P | Resume canvas preview |
| Cmd + K | Clear console |

## Build Times

**Initial build:** 60-120 seconds
**Incremental build:** 5-10 seconds
**Clean build:** 30-60 seconds

*Times vary by Mac performance*

---

**Happy coding!** 🚀

If you have questions or find bugs, please open an issue on GitHub.
