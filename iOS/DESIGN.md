# iOS App Visual Design

## Screen Mockups Description

This document describes the visual design and user interface of the iOS Bourgault Tank Optimizer app. Since we cannot include actual screenshots, this provides detailed descriptions of each screen's appearance.

## Main Screen (ContentView)

### Layout
```
┌─────────────────────────────────────┐
│ ← Tank Optimizer                    │
├─────────────────────────────────────┤
│                                     │
│ ╔═══════════════════════════════╗ │
│ ║ Configuration                  ║ │
│ ╠═══════════════════════════════╣ │
│ ║ Unit System      [ Imperial ▼]║ │
│ ║ Cart Model       [ 91300 ▼   ]║ │
│ ║                  (1344 bu tot) ║ │
│ ║ Field Size       [160      ]ac║ │
│ ╚═══════════════════════════════╝ │
│                                     │
│ ╔═══════════════════════════════╗ │
│ ║ Products                       ║ │
│ ╠═══════════════════════════════╣ │
│ ║ Wheat (60 lb/bu)               ║ │
│ ║     [100.00] lb/ac      [🗑️]   ║ │
│ ║─────────────────────────────  ║ │
│ ║ Canola (50 lb/bu)              ║ │
│ ║     [5.00] lb/ac        [🗑️]   ║ │
│ ║─────────────────────────────  ║ │
│ ║ [+] Add Product                ║ │
│ ╚═══════════════════════════════╝ │
│                                     │
│ ┌─────────────────────────────────┐│
│ │  ⚙️ Calculate Allocation        ││
│ │      (Blue Button)              ││
│ └─────────────────────────────────┘│
│                                     │
│ ┌─────────────────────────────────┐│
│ │  📊 View Results                ││
│ │      (Green Button)             ││
│ └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Visual Details

**Navigation Bar:**
- Large title: "Tank Optimizer"
- iOS standard navigation bar styling
- White/system background

**Configuration Section:**
- Grouped form style with rounded corners
- Gray section header "Configuration"
- Three rows:
  1. **Unit System Picker**: Right-aligned dropdown showing "Imperial" or "Metric"
  2. **Cart Model Picker**: Shows model name and total capacity in parentheses
  3. **Field Size Input**: Number input field with unit label (ac or ha) in secondary gray

**Products Section:**
- Gray section header "Products"
- Each product shown as a card with:
  - **Product name** in bold (e.g., "Wheat")
  - **Density** in lighter text (e.g., "60 lb/bu")
  - **Rate input field** with decimal keyboard
  - **Unit label** in secondary gray (lb/ac or kg/ha)
  - **Red trash icon** button on the right
- Divider lines between products
- Blue "Add Product" button at bottom with plus icon

**Action Buttons:**
- Full width with rounded corners
- **Calculate Button**: 
  - Blue background (#007AFF iOS blue)
  - White text and gear icon
  - Disabled (grayed) if no products or invalid field size
- **View Results Button**:
  - Green background
  - White text and chart icon
  - Only appears after calculation

### Color Scheme
- Background: System grouped background (light gray)
- Text: Primary (black) and secondary (gray)
- Accent: iOS blue (#007AFF)
- Success: Green (#34C759)
- Destructive: Red (#FF3B30)

---

## Product Selection Screen (ProductSelectionView)

### Layout
```
┌─────────────────────────────────────┐
│ Cancel       Select Product         │
├─────────────────────────────────────┤
│ 🔍 Search products                  │
├─────────────────────────────────────┤
│                                     │
│ GRAINS & PULSES                     │
│ ┌─────────────────────────────────┐│
│ │ Wheat                      [+]  ││
│ │ 60 lb/bu                        ││
│ ├─────────────────────────────────┤│
│ │ Durum                      [+]  ││
│ │ 60 lb/bu                        ││
│ ├─────────────────────────────────┤│
│ │ Barley                     [+]  ││
│ │ 48 lb/bu                        ││
│ ├─────────────────────────────────┤│
│ │ Oats                       [+]  ││
│ │ 32 lb/bu                        ││
│ └─────────────────────────────────┘│
│                                     │
│ FERTILIZERS                         │
│ ┌─────────────────────────────────┐│
│ │ Urea (46-0-0)              [+]  ││
│ │ 48 lb/bu                        ││
│ ├─────────────────────────────────┤│
│ │ MAP (11-52-0)              [+]  ││
│ │ 60 lb/bu                        ││
│ └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Visual Details

**Navigation:**
- Inline title "Select Product" (centered, smaller)
- Left: "Cancel" button in blue
- Modal presentation (slides up from bottom)

**Search Bar:**
- iOS standard search field
- Placeholder: "Search products"
- Light gray background
- Magnifying glass icon

**Product List:**
- Organized by category sections
- Section headers in ALL CAPS, gray, small font
- Each product row:
  - **Product name** in headline font
  - **Density** below in caption font, gray
  - **Blue circle with plus icon** on right
- Tap anywhere on row to select
- Auto-dismisses after selection

---

## Results Screen (ResultsView)

### Layout
```
┌─────────────────────────────────────┐
│ ← Results                           │
├─────────────────────────────────────┤
│                                     │
│ ╔═══════════════════════════════╗ │
│ ║ Summary                        ║ │
│ ╠═══════════════════════════════╣ │
│ ║ Cart Model           91300     ║ │
│ ║ Field Size           160.00 ac ║ │
│ ║ Cart Utilization     20.6% ✓  ║ │
│ ║ Total Capacity       1344 bu   ║ │
│ ╚═══════════════════════════════╝ │
│                                     │
│ ╔═══════════════════════════════╗ │
│ ║ Products Required              ║ │
│ ╠═══════════════════════════════╣ │
│ ║ Wheat                 266.7 bu ║ │
│ ║ Rate: 100.00 lb/ac             ║ │
│ ║───────────────────────────────║ │
│ ║ Canola                 16.0 bu ║ │
│ ║ Rate: 5.00 lb/ac               ║ │
│ ╚═══════════════════════════════╝ │
│                                     │
│ ╔═══════════════════════════════╗ │
│ ║ Tank Allocation                ║ │
│ ╠═══════════════════════════════╣ │
│ ║ Tank 1         635 bu capacity ║ │
│ ║ Wheat                  266.7 bu║ │
│ ║                          42.0% ║ │
│ ║ ████████░░░░░░░░░░░░          ║ │
│ ║───────────────────────────────║ │
│ ║ Tank 4         295 bu capacity ║ │
│ ║ Canola                  16.0 bu║ │
│ ║                           5.4% ║ │
│ ║ █░░░░░░░░░░░░░░░░░░░░         ║ │
│ ╚═══════════════════════════════╝ │
│                                     │
└─────────────────────────────────────┘
```

### Visual Details

**Navigation:**
- Back button "< Results" to return to main screen
- Inline title style

**Summary Section:**
- Key-value pairs right-aligned
- **Cart Utilization** color-coded:
  - Green text if < 75%
  - Orange text if 75-90%
  - Red text if > 90%
- Checkmark (✓) or warning (⚠️) icon next to utilization

**Products Required Section:**
- Each product in its own row
- Product name in headline font
- Bushels amount in bold blue on right
- Application rate below in caption font, gray

**Tank Allocation Section:**
- Each tank as a separate card
- Tank header shows:
  - **Tank name** (Tank 1, Tank 2, etc.) in bold
  - **Capacity** on right in caption gray
- Product allocation shows:
  - **Product name** in secondary gray
  - **Bushels filled** in bold blue on right
  - **Fill percentage** below in gray
- **Visual fill bar**:
  - Horizontal progress bar showing fill level
  - Color-coded:
    - Green if > 90% full (good utilization)
    - Blue if 50-90% full
    - Orange if < 50% full (low utilization)
  - Gray background with colored fill

**Unallocated Products** (if any):
- Red background tint
- "UNALLOCATED" label in red
- Product name and amount
- No fill bar

**Error Display** (if errors):
- Red background section at top
- Warning triangle icon
- Error message in red text

---

## Interaction Patterns

### Tap Behaviors
- **Product row in catalog**: Select and add product, dismiss sheet
- **Trash icon**: Remove product from list
- **Calculate button**: Run allocation, enable View Results button
- **View Results button**: Navigate to results screen
- **Back button**: Return to previous screen
- **Add Product button**: Open product picker modal

### Keyboard Behaviors
- **Number inputs**: Show decimal numeric keyboard
- **Dismiss**: Tap outside or "Done" on keyboard
- **Tab navigation**: Not applicable (touch-based)

### Gestures
- **Swipe**: Navigate back (iOS standard)
- **Pull to refresh**: Not implemented
- **Scroll**: Standard list scrolling

### Animations
- **Sheet presentation**: Slide up from bottom
- **Navigation**: Slide from right (push), slide to left (pop)
- **Button tap**: Slight scale down on press
- **Fill bars**: Smooth width animation
- **Color changes**: Smooth fade transitions

---

## Responsive Design

### iPhone (Portrait)
- Single column layout
- Full-width buttons
- Scrollable content
- Safe area insets respected

### iPhone (Landscape)
- Same layout, more compressed
- Keyboard may cover lower content
- Scroll to ensure visibility

### iPad
- Could use larger widths
- Could implement split view (future enhancement)
- More whitespace
- Larger fonts possible

---

## Accessibility Features

### VoiceOver Support
- All buttons labeled
- Value descriptions for inputs
- State announcements (selected, disabled)
- Proper navigation order

### Dynamic Type
- Text scales with user preference
- Layout adjusts for larger text
- No text truncation

### Color Contrast
- All text meets WCAG AA standards
- Color is not the only indicator (icons + text)
- High contrast mode compatible

### Touch Targets
- Minimum 44×44 points for all interactive elements
- Adequate spacing between buttons
- No overlapping touch areas

---

## Visual Polish

### Typography
- **Large Title**: 34pt, Bold (Navigation titles)
- **Headline**: 17pt, Semibold (Product names, tank labels)
- **Body**: 17pt, Regular (Main text)
- **Caption**: 12pt, Regular (Secondary info, units)

### Spacing
- Section padding: 16pt
- Row spacing: 8-12pt
- Button height: 50pt
- Corner radius: 10pt (buttons), 8pt (cards)

### Shadows & Depth
- Subtle shadows on cards
- No heavy drop shadows (iOS 7+ flat design)
- Proper layering with colors

### Icons
- SF Symbols used throughout
- Consistent sizing (20-24pt)
- Proper alignment with text

---

## Example User Flow

1. **Launch app** → See main screen with default values
2. **Tap "Add Product"** → Product picker slides up
3. **Search or scroll** → Find "Wheat"
4. **Tap Wheat** → Returns to main, Wheat added with 0.00 rate
5. **Edit rate** → Tap rate field, enter 100
6. **Repeat** → Add more products
7. **Tap "Calculate Allocation"** → Runs calculation
8. **"View Results" appears** → Tap to see results
9. **View results** → Scroll through tanks
10. **Tap back** → Return to main, modify and recalculate

---

This visual design maintains iOS native patterns while providing clear, efficient access to all tank optimization features.
