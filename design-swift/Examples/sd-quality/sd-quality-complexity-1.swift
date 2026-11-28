// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-complexity.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct LineItem {
    let name: String
    let pence: Int
    var quantity: Int
}

// Stores the total, so every mutation must remember to update it
struct StoredTotalCart {
    var items: [LineItem] = []
    var total = 0

    mutating func add(_ item: LineItem) {
        items.append(item)
        total += item.pence * item.quantity
    }

    mutating func setQuantity(_ quantity: Int, at index: Int) {
        items[index].quantity = quantity   // the total is now wrong, and nothing says so
    }
}

// Derives the total, so it can't disagree with the items
struct DerivedTotalCart {
    var items: [LineItem] = []
    var total: Int { items.reduce(0) { $0 + $1.pence * $1.quantity } }

    mutating func add(_ item: LineItem) { items.append(item) }
    mutating func setQuantity(_ quantity: Int, at index: Int) { items[index].quantity = quantity }
}

var stored = StoredTotalCart()
var derived = DerivedTotalCart()
for item in [LineItem(name: "Coffee", pence: 350, quantity: 1), LineItem(name: "Croissant", pence: 280, quantity: 1)] {
    stored.add(item)
    derived.add(item)
}
stored.setQuantity(3, at: 0)
derived.setQuantity(3, at: 0)

print("Stored total: £" + String(format: "%.2f", Double(stored.total) / 100))
print("Derived total: £" + String(format: "%.2f", Double(derived.total) / 100))
