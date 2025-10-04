//
//  Models.swift
//  BourgaultTankOptimizer
//
//  Swift data models for tank optimization
//

import Foundation

/// Unit system for measurements
enum UnitSystem: String, CaseIterable {
    case imperial = "Imperial"
    case metric = "Metric"
    
    var areaUnit: String {
        switch self {
        case .imperial: return "ac"
        case .metric: return "ha"
        }
    }
    
    var rateUnit: String {
        switch self {
        case .imperial: return "lb/ac"
        case .metric: return "kg/ha"
        }
    }
}

/// Tank model with capacity configuration
struct TankModel {
    let name: String
    let capacities: [Double] // Capacities in bushels for each tank
    
    var totalCapacity: Double {
        capacities.reduce(0, +)
    }
    
    /// All available Bourgault tank models
    static let allModels: [TankModel] = [
        TankModel(name: "91300", capacities: [635, 230, 140, 295, 44]),
        TankModel(name: "9950", capacities: [465, 165, 100, 220, 44]),
        TankModel(name: "9650", capacities: [195, 130, 130, 195, 44]),
        TankModel(name: "L9950", capacities: [220, 100, 165, 465, 44]),
        TankModel(name: "L9650", capacities: [195, 130, 130, 195, 44])
    ]
}

/// Product with density information
struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let densityLbPerBu: Double // Density in pounds per bushel
    
    /// Catalog of common products with typical densities
    static let catalog: [Product] = [
        // Grains & pulses
        Product(name: "Wheat", densityLbPerBu: 60),
        Product(name: "Durum", densityLbPerBu: 60),
        Product(name: "Barley", densityLbPerBu: 48),
        Product(name: "Oats", densityLbPerBu: 32),
        Product(name: "Canola", densityLbPerBu: 50),
        Product(name: "Flax", densityLbPerBu: 56),
        Product(name: "Peas", densityLbPerBu: 60),
        Product(name: "Lentils", densityLbPerBu: 60),
        Product(name: "Soybeans", densityLbPerBu: 60),
        Product(name: "Corn", densityLbPerBu: 56),
        // Fertilizers (approximate, varies by blend and moisture)
        Product(name: "Urea (46-0-0)", densityLbPerBu: 48),
        Product(name: "MAP (11-52-0)", densityLbPerBu: 60),
        Product(name: "DAP (18-46-0)", densityLbPerBu: 62),
        Product(name: "Ammonium Sulphate (21-0-0-24S)", densityLbPerBu: 60),
        Product(name: "Potash (0-0-60)", densityLbPerBu: 70),
        Product(name: "MESZ (12-40-0-10S-1Zn)", densityLbPerBu: 61)
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.name == rhs.name
    }
}

/// Product selection with application rate
struct ProductSelection: Identifiable {
    let id = UUID()
    let product: Product
    var rate: Double // Rate in current unit system (lb/ac or kg/ha)
}

/// Individual tank in the allocation
struct Tank {
    let label: String
    let capacity: Double
    let index: Int
}

/// Allocation result for a single tank
struct TankAllocation: Identifiable {
    let id = UUID()
    let tankLabel: String
    let capacity: Double
    let productName: String
    let fillBushels: Double
    let fillPercent: Double
    
    var isUnallocated: Bool {
        tankLabel == "UNALLOCATED"
    }
}

/// Complete allocation result
struct AllocationResult {
    let model: TankModel
    let fieldSize: Double
    let unitSystem: UnitSystem
    let productsBushels: [(name: String, rate: Double, bushels: Double)]
    let tankAllocations: [TankAllocation]
    let utilizationPercent: Double
    let errors: [String]
    
    var hasErrors: Bool {
        !errors.isEmpty
    }
}
