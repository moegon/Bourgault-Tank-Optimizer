//
//  Allocator.swift
//  BourgaultTankOptimizer
//
//  Core allocation algorithm for distributing products across tanks
//

import Foundation

/// Handles tank allocation calculations
class Allocator {
    
    // Conversion constants
    private static let lbsToKg = 0.453592
    private static let acresToHa = 0.404685642
    
    /// Compute bushels needed for a product
    /// - Parameters:
    ///   - rate: Application rate (lb/ac or kg/ha depending on unit system)
    ///   - area: Field area (acres or hectares depending on unit system)
    ///   - unitSystem: Current unit system
    ///   - densityLbPerBu: Product density in pounds per bushel
    /// - Returns: Bushels required
    static func computeBushelsNeeded(rate: Double, area: Double, unitSystem: UnitSystem, densityLbPerBu: Double) -> Double {
        let densityKgPerBu = densityLbPerBu * lbsToKg
        
        switch unitSystem {
        case .imperial:
            // bushels = (lb/ac * ac) / (lb/bu)
            return (rate * area) / densityLbPerBu
        case .metric:
            // bushels = (kg/ha * ha) / (kg/bu)
            return (rate * area) / densityKgPerBu
        }
    }
    
    /// Build sorted tank list from capacities
    /// - Parameter capacities: Array of tank capacities in bushels
    /// - Returns: Array of tanks sorted by capacity (largest first)
    static func buildTankList(capacities: [Double]) -> [Tank] {
        let labels = ["Tank 1", "Tank 2", "Tank 3", "Tank 4", "Saddle"]
        let tanks = capacities.enumerated().map { index, capacity in
            Tank(
                label: index < labels.count ? labels[index] : "Tank \(index + 1)",
                capacity: capacity,
                index: index
            )
        }
        return tanks.sorted { $0.capacity > $1.capacity }
    }
    
    /// Allocate products to tanks using a greedy algorithm
    /// - Parameters:
    ///   - model: Tank model with capacities
    ///   - selections: Product selections with rates
    ///   - fieldSize: Field size in current unit system
    ///   - unitSystem: Current unit system
    /// - Returns: Allocation result with tank assignments
    static func allocate(model: TankModel, selections: [ProductSelection], fieldSize: Double, unitSystem: UnitSystem) -> AllocationResult {
        
        // Validate inputs
        guard fieldSize > 0, !selections.isEmpty else {
            return AllocationResult(
                model: model,
                fieldSize: fieldSize,
                unitSystem: unitSystem,
                productsBushels: [],
                tankAllocations: [],
                utilizationPercent: 0,
                errors: ["Enter a valid field size and at least one product."]
            )
        }
        
        // Calculate bushels needed for each product
        var productsBushels: [(name: String, rate: Double, bushels: Double)] = []
        for selection in selections {
            let bushels = computeBushelsNeeded(
                rate: selection.rate,
                area: fieldSize,
                unitSystem: unitSystem,
                densityLbPerBu: selection.product.densityLbPerBu
            )
            productsBushels.append((
                name: selection.product.name,
                rate: selection.rate,
                bushels: bushels
            ))
        }
        
        // Sort products by bushels needed (largest first) for greedy allocation
        productsBushels.sort { $0.bushels > $1.bushels }
        
        // Build sorted tank list
        let tanks = buildTankList(capacities: model.capacities)
        
        // Greedy allocation algorithm
        var allocations: [TankAllocation] = []
        var tankIndex = 0
        
        for productInfo in productsBushels {
            var remaining = productInfo.bushels
            
            // Fill tanks with this product until it's all allocated or tanks run out
            while remaining > 0 && tankIndex < tanks.count {
                let tank = tanks[tankIndex]
                let fill = min(tank.capacity, remaining)
                
                allocations.append(TankAllocation(
                    tankLabel: tank.label,
                    capacity: tank.capacity,
                    productName: productInfo.name,
                    fillBushels: fill,
                    fillPercent: (fill / tank.capacity) * 100
                ))
                
                remaining -= fill
                tankIndex += 1
            }
            
            // If product couldn't be fully allocated, mark as unallocated
            if remaining > 0 {
                allocations.append(TankAllocation(
                    tankLabel: "UNALLOCATED",
                    capacity: 0,
                    productName: productInfo.name,
                    fillBushels: remaining,
                    fillPercent: 0
                ))
            }
        }
        
        // Calculate utilization
        let totalCapacity = model.totalCapacity
        let totalBushelsNeeded = productsBushels.reduce(0) { $0 + $1.bushels }
        let utilizationPercent = min(100, (totalBushelsNeeded / totalCapacity) * 100)
        
        return AllocationResult(
            model: model,
            fieldSize: fieldSize,
            unitSystem: unitSystem,
            productsBushels: productsBushels,
            tankAllocations: allocations,
            utilizationPercent: utilizationPercent,
            errors: []
        )
    }
}
