//
//  Item.swift
//  GroceryTracker
//

import Foundation
import SwiftData

@Model
final class GroceryItem {
    var name: String
    var quantity: Int
    var isChecked: Bool
    
    init(name: String, quantity: Int, isChecked: Bool = false) {
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
    }
}
