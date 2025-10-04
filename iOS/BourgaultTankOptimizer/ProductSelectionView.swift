//
//  ProductSelectionView.swift
//  BourgaultTankOptimizer
//
//  Product picker view for selecting from the catalog
//

import SwiftUI

struct ProductSelectionView: View {
    let onSelect: (Product) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return Product.catalog
        }
        return Product.catalog.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Grains & Pulses")) {
                    ForEach(filteredProducts.filter { isGrainOrPulse($0) }) { product in
                        ProductCatalogRow(product: product) {
                            onSelect(product)
                        }
                    }
                }
                
                Section(header: Text("Fertilizers")) {
                    ForEach(filteredProducts.filter { isFertilizer($0) }) { product in
                        ProductCatalogRow(product: product) {
                            onSelect(product)
                        }
                    }
                }
            }
            .navigationTitle("Select Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search products")
        }
    }
    
    private func isGrainOrPulse(_ product: Product) -> Bool {
        let grainNames = ["Wheat", "Durum", "Barley", "Oats", "Canola", "Flax", "Peas", "Lentils", "Soybeans", "Corn"]
        return grainNames.contains(product.name)
    }
    
    private func isFertilizer(_ product: Product) -> Bool {
        !isGrainOrPulse(product)
    }
}

struct ProductCatalogRow: View {
    let product: Product
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                    Text("\(Int(product.densityLbPerBu)) lb/bu")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    ProductSelectionView { product in
        print("Selected: \(product.name)")
    }
}
