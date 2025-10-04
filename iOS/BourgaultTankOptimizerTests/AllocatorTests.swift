//
//  AllocatorTests.swift
//  BourgaultTankOptimizerTests
//
//  Unit tests for the allocator algorithm
//

import XCTest
@testable import BourgaultTankOptimizer

final class AllocatorTests: XCTestCase {
    
    // Test allocation within capacity
    func testAllocateWithinCapacity() throws {
        // Arrange: Create a model with sufficient capacity
        let model = TankModel(name: "Test", capacities: [100, 100, 50])
        let product = Product(name: "TestProduct", densityLbPerBu: 50)
        let selection = ProductSelection(product: product, rate: 100)
        
        // Act: Allocate with imperial units
        let result = Allocator.allocate(
            model: model,
            selections: [selection],
            fieldSize: 1.0,
            unitSystem: .imperial
        )
        
        // Assert: No errors and correct allocation
        XCTAssertFalse(result.hasErrors, "Should not have errors")
        
        let totalFilled = result.tankAllocations.reduce(0.0) { $0 + $1.fillBushels }
        
        // 100 lb/ac * 1 ac / 50 lb/bu = 2 bu
        XCTAssertEqual(totalFilled, 2.0, accuracy: 0.0001, "Total filled should be 2 bushels")
        
        // Should not have unallocated tanks
        let unallocated = result.tankAllocations.filter { $0.isUnallocated }
        XCTAssertTrue(unallocated.isEmpty, "Should not have unallocated products")
    }
    
    // Test allocation when capacity is insufficient
    func testAllocateWithInsufficientCapacity() throws {
        // Arrange: Create a model with very limited capacity
        let model = TankModel(name: "Test", capacities: [1])
        let product = Product(name: "TestProduct", densityLbPerBu: 1)
        let selection = ProductSelection(product: product, rate: 1000)
        
        // Act: Allocate
        let result = Allocator.allocate(
            model: model,
            selections: [selection],
            fieldSize: 1.0,
            unitSystem: .imperial
        )
        
        // Assert: Should have unallocated product
        let unallocated = result.tankAllocations.filter { $0.isUnallocated }
        XCTAssertFalse(unallocated.isEmpty, "Should have unallocated product")
        
        // Total bushels needed should be 1000
        let totalNeeded = result.productsBushels.reduce(0.0) { $0 + $1.bushels }
        XCTAssertEqual(totalNeeded, 1000.0, accuracy: 0.0001, "Total needed should be 1000 bushels")
    }
    
    // Test bushels calculation in imperial units
    func testComputeBushelsImperial() throws {
        let bushels = Allocator.computeBushelsNeeded(
            rate: 100.0,      // lb/ac
            area: 160.0,      // acres
            unitSystem: .imperial,
            densityLbPerBu: 60.0  // lb/bu
        )
        
        // 100 * 160 / 60 = 266.67
        XCTAssertEqual(bushels, 266.6667, accuracy: 0.001, "Imperial bushels calculation")
    }
    
    // Test bushels calculation in metric units
    func testComputeBushelsMetric() throws {
        let densityLbPerBu = 60.0
        let densityKgPerBu = densityLbPerBu * 0.453592
        
        let bushels = Allocator.computeBushelsNeeded(
            rate: 100.0,      // kg/ha
            area: 64.75,      // hectares (approximately 160 acres)
            unitSystem: .metric,
            densityLbPerBu: densityLbPerBu
        )
        
        // 100 * 64.75 / densityKgPerBu
        let expected = (100.0 * 64.75) / densityKgPerBu
        XCTAssertEqual(bushels, expected, accuracy: 0.001, "Metric bushels calculation")
    }
    
    // Test tank list building and sorting
    func testBuildTankList() throws {
        let capacities = [635.0, 230.0, 140.0, 295.0, 44.0]
        let tanks = Allocator.buildTankList(capacities: capacities)
        
        // Should have 5 tanks
        XCTAssertEqual(tanks.count, 5, "Should have 5 tanks")
        
        // Should be sorted by capacity (largest first)
        XCTAssertEqual(tanks[0].capacity, 635.0, "Largest tank should be first")
        XCTAssertEqual(tanks[1].capacity, 295.0, "Second largest tank")
        XCTAssertEqual(tanks[2].capacity, 230.0, "Third largest tank")
        XCTAssertEqual(tanks[3].capacity, 140.0, "Fourth largest tank")
        XCTAssertEqual(tanks[4].capacity, 44.0, "Smallest tank should be last")
        
        // Check labels
        XCTAssertEqual(tanks[0].label, "Tank 1", "Should have correct label")
    }
    
    // Test multiple products allocation
    func testMultipleProductsAllocation() throws {
        let model = TankModel(name: "Test", capacities: [100, 100, 50])
        
        let wheat = Product(name: "Wheat", densityLbPerBu: 60)
        let canola = Product(name: "Canola", densityLbPerBu: 50)
        
        let selections = [
            ProductSelection(product: wheat, rate: 60),
            ProductSelection(product: canola, rate: 50)
        ]
        
        let result = Allocator.allocate(
            model: model,
            selections: selections,
            fieldSize: 1.0,
            unitSystem: .imperial
        )
        
        // Should allocate both products
        XCTAssertEqual(result.productsBushels.count, 2, "Should have 2 products")
        XCTAssertFalse(result.hasErrors, "Should not have errors")
        
        // Check that products are sorted by bushels (largest first)
        XCTAssertTrue(result.productsBushels[0].bushels >= result.productsBushels[1].bushels,
                      "Products should be sorted by bushels needed")
    }
    
    // Test empty inputs
    func testEmptyInputs() throws {
        let model = TankModel(name: "Test", capacities: [100])
        
        // Test with no products
        let result1 = Allocator.allocate(
            model: model,
            selections: [],
            fieldSize: 100.0,
            unitSystem: .imperial
        )
        XCTAssertTrue(result1.hasErrors, "Should have errors with no products")
        
        // Test with zero field size
        let product = Product(name: "Test", densityLbPerBu: 50)
        let result2 = Allocator.allocate(
            model: model,
            selections: [ProductSelection(product: product, rate: 100)],
            fieldSize: 0,
            unitSystem: .imperial
        )
        XCTAssertTrue(result2.hasErrors, "Should have errors with zero field size")
    }
}
