//
//  ContentView.swift
//  BourgaultTankOptimizer
//
//  Main view coordinating the UI
//

import SwiftUI

struct ContentView: View {
    @State private var selectedModel: TankModel = TankModel.allModels[0]
    @State private var fieldSize: String = "160"
    @State private var unitSystem: UnitSystem = .imperial
    @State private var productSelections: [ProductSelection] = []
    @State private var allocationResult: AllocationResult?
    @State private var showProductPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main configuration form
                Form {
                    Section(header: Text("Configuration")) {
                        // Unit system picker
                        Picker("Unit System", selection: $unitSystem) {
                            ForEach(UnitSystem.allCases, id: \.self) { system in
                                Text(system.rawValue).tag(system)
                            }
                        }
                        .onChange(of: unitSystem) { oldValue, newValue in
                            convertRates(from: oldValue, to: newValue)
                        }
                        
                        // Model picker
                        Picker("Cart Model", selection: $selectedModel) {
                            ForEach(TankModel.allModels, id: \.name) { model in
                                Text("\(model.name) (\(Int(model.totalCapacity)) bu total)")
                                    .tag(model)
                            }
                        }
                        
                        // Field size input
                        HStack {
                            Text("Field Size")
                            TextField("Field Size", text: $fieldSize)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text(unitSystem.areaUnit)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section(header: Text("Products")) {
                        if productSelections.isEmpty {
                            Text("No products added yet.")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(productSelections) { selection in
                                ProductRowView(
                                    selection: selection,
                                    unitSystem: unitSystem,
                                    onRateChange: { newRate in
                                        updateRate(for: selection.id, newRate: newRate)
                                    },
                                    onRemove: {
                                        removeProduct(selection.id)
                                    }
                                )
                            }
                        }
                        
                        Button(action: { showProductPicker = true }) {
                            Label("Add Product", systemImage: "plus.circle.fill")
                        }
                    }
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: calculate) {
                        Label("Calculate Allocation", systemImage: "gearshape.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(productSelections.isEmpty || fieldSize.isEmpty)
                    
                    if let result = allocationResult {
                        NavigationLink(destination: ResultsView(result: result)) {
                            Label("View Results", systemImage: "chart.bar.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Tank Optimizer")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showProductPicker) {
                ProductSelectionView { product in
                    addProduct(product)
                    showProductPicker = false
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Add a product to the selections
    private func addProduct(_ product: Product) {
        let selection = ProductSelection(product: product, rate: 0)
        productSelections.append(selection)
    }
    
    /// Remove a product from selections
    private func removeProduct(_ id: UUID) {
        productSelections.removeAll { $0.id == id }
    }
    
    /// Update the rate for a product
    private func updateRate(for id: UUID, newRate: Double) {
        if let index = productSelections.firstIndex(where: { $0.id == id }) {
            productSelections[index].rate = newRate
        }
    }
    
    /// Convert rates when unit system changes
    private func convertRates(from oldSystem: UnitSystem, to newSystem: UnitSystem) {
        guard oldSystem != newSystem else { return }
        
        // Conversion factor: 1 lb/ac = 1.120849 kg/ha
        let factor = 1.120849
        
        for i in productSelections.indices {
            if newSystem == .metric {
                productSelections[i].rate *= factor
            } else {
                productSelections[i].rate /= factor
            }
        }
        
        // Convert field size
        if let currentSize = Double(fieldSize) {
            let acToHa = 0.404685642
            let converted = newSystem == .metric ? currentSize * acToHa : currentSize / acToHa
            fieldSize = String(format: "%.2f", converted)
        }
    }
    
    /// Calculate the allocation
    private func calculate() {
        guard let area = Double(fieldSize), area > 0 else {
            allocationResult = AllocationResult(
                model: selectedModel,
                fieldSize: 0,
                unitSystem: unitSystem,
                productsBushels: [],
                tankAllocations: [],
                utilizationPercent: 0,
                errors: ["Please enter a valid field size."]
            )
            return
        }
        
        allocationResult = Allocator.allocate(
            model: selectedModel,
            selections: productSelections,
            fieldSize: area,
            unitSystem: unitSystem
        )
    }
}

/// Row view for a product selection
struct ProductRowView: View {
    let selection: ProductSelection
    let unitSystem: UnitSystem
    let onRateChange: (Double) -> Void
    let onRemove: () -> Void
    
    @State private var rateText: String
    
    init(selection: ProductSelection, unitSystem: UnitSystem, onRateChange: @escaping (Double) -> Void, onRemove: @escaping () -> Void) {
        self.selection = selection
        self.unitSystem = unitSystem
        self.onRateChange = onRateChange
        self.onRemove = onRemove
        _rateText = State(initialValue: String(format: "%.2f", selection.rate))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(selection.product.name)
                        .font(.headline)
                    Text("\(Int(selection.product.densityLbPerBu)) lb/bu")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                TextField("Rate", text: $rateText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .onChange(of: rateText) { _, newValue in
                        if let rate = Double(newValue) {
                            onRateChange(rate)
                        }
                    }
                
                Text(unitSystem.rateUnit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)
                
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
