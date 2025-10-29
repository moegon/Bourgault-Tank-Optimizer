//
//  ResultsView.swift
//  BourgaultTankOptimizer
//
//  Display allocation results
//

import SwiftUI

struct ResultsView: View {
    let result: AllocationResult
    
    var body: some View {
        List {
            // Error section if any
            if result.hasErrors {
                Section {
                    ForEach(result.errors, id: \.self) { error in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                        }
                    }
                }
            } else {
                // Summary section
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Cart Model")
                        Spacer()
                        Text(result.model.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Field Size")
                        Spacer()
                        Text(String(format: "%.2f %@", result.fieldSize, result.unitSystem.areaUnit))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Cart Utilization")
                        Spacer()
                        Text(String(format: "%.1f%%", result.utilizationPercent))
                            .foregroundColor(utilizationColor)
                            .bold()
                    }
                    
                    HStack {
                        Text("Total Capacity")
                        Spacer()
                        Text("\(Int(result.model.totalCapacity)) bu")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Products section
                Section(header: Text("Products Required")) {
                    ForEach(result.productsBushels, id: \.name) { product in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(product.name)
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.1f bu", product.bushels))
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            Text(String(format: "Rate: %.2f %@", product.rate, result.unitSystem.rateUnit))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                // Tank allocation section
                Section(header: Text("Tank Allocation")) {
                    ForEach(result.tankAllocations) { allocation in
                        TankAllocationRow(allocation: allocation)
                    }
                }
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var utilizationColor: Color {
        if result.utilizationPercent > 90 {
            return .red
        } else if result.utilizationPercent > 75 {
            return .orange
        } else {
            return .green
        }
    }
}

struct TankAllocationRow: View {
    let allocation: TankAllocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(allocation.tankLabel)
                    .font(.headline)
                    .foregroundColor(allocation.isUnallocated ? .red : .primary)
                
                Spacer()
                
                if !allocation.isUnallocated {
                    Text(String(format: "%.0f bu capacity", allocation.capacity))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(allocation.productName)
                    .foregroundColor(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f bu", allocation.fillBushels))
                        .font(.headline)
                        .foregroundColor(.blue)
                    if !allocation.isUnallocated {
                        Text(String(format: "%.0f%% full", allocation.fillPercent))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Visual fill indicator for allocated tanks
            if !allocation.isUnallocated {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(fillColor)
                            .frame(width: geometry.size.width * CGFloat(allocation.fillPercent / 100), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, allocation.isUnallocated ? 8 : 0)
        .background(allocation.isUnallocated ? Color.red.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
    
    private var fillColor: Color {
        if allocation.fillPercent > 90 {
            return .green
        } else if allocation.fillPercent > 50 {
            return .blue
        } else {
            return .orange
        }
    }
}

#Preview {
    NavigationView {
        ResultsView(result: AllocationResult(
            model: TankModel.allModels[0],
            fieldSize: 160,
            unitSystem: .imperial,
            productsBushels: [
                ("Wheat", 100, 266.7),
                ("Canola", 5, 16.0)
            ],
            tankAllocations: [
                TankAllocation(tankLabel: "Tank 1", capacity: 635, productName: "Wheat", fillBushels: 266.7, fillPercent: 42.0),
                TankAllocation(tankLabel: "Tank 4", capacity: 295, productName: "Canola", fillBushels: 16.0, fillPercent: 5.4)
            ],
            utilizationPercent: 20.6,
            errors: []
        ))
    }
}
