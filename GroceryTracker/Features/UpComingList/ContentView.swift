//
//  ContentView.swift
//  GroceryTracker
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroceryItem.name, order: .forward) private var items: [GroceryItem]
    
    @State private var isAddingItem = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(items) { item in
                        ItemRowView(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
                
            }
            .navigationTitle("Grocery List")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleAddingItem){
                        Text("Add")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $isAddingItem) {
                AddItemView()
            }
        }
    }
    
    private func toggleAddingItem(){
        isAddingItem.toggle()
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation(.spring) {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct ItemRowView: View {
    @Bindable var item: GroceryItem
    
    var body: some View {
        HStack {
            Button(action: { 
                withAnimation {
                    item.isChecked.toggle()
                }
            }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isChecked ? .green : .primary)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isChecked, color: .primary)
                Text("Quantity: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .strikethrough(item.isChecked, color: .secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var newItemName = ""
    @State private var newItemQuantity = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $newItemName)
                    Stepper("Quantity: \(newItemQuantity)", value: $newItemQuantity, in: 1...100)
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                        dismiss()
                    }
                    .disabled(newItemName.isEmpty)
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation(.spring) {
            let newItem = GroceryItem(name: newItemName, quantity: newItemQuantity)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: GroceryItem.self, configurations: config)
        
        // Add sample data
        let sampleItems = [
            GroceryItem(name: "Apples", quantity: 5, isChecked: true),
            GroceryItem(name: "Milk", quantity: 1),
            GroceryItem(name: "Bread", quantity: 2),
            GroceryItem(name: "Eggs", quantity: 12, isChecked: false)
        ]
        
        for item in sampleItems {
            container.mainContext.insert(item)
        }
        
        return ContentView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
