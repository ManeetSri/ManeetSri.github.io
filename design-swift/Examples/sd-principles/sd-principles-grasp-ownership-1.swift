// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-grasp-ownership.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Product {
    let id: String
    let name: String
    let pricePence: Int
}

struct LineItem {
    let product: Product
    fileprivate(set) var quantity: Int

    // Expert: a line has the price and the quantity
    var subtotalPence: Int { product.pricePence * quantity }
}

struct Cart {
    static let maxQuantity = 10
    private(set) var lines: [LineItem] = []

    // Expert: the cart has the lines
    var totalPence: Int { lines.reduce(0) { $0 + $1.subtotalPence } }
    var itemCount: Int { lines.reduce(0) { $0 + $1.quantity } }

    // Creator: the cart contains line items, so it makes them, and merges repeats
    mutating func add(_ product: Product, quantity: Int = 1) {
        if let index = lines.firstIndex(where: { $0.product.id == product.id }) {
            lines[index].quantity = min(Self.maxQuantity, lines[index].quantity + quantity)
        } else {
            lines.append(LineItem(product: product, quantity: min(Self.maxQuantity, quantity)))
        }
    }
}

func pounds(_ pence: Int) -> String {
    String(format: "£%d.%02d", pence / 100, pence % 100)
}

let oatMilk = Product(id: "p1", name: "Oat milk", pricePence: 150)
let coffee = Product(id: "p2", name: "Coffee beans", pricePence: 640)

var cart = Cart()
cart.add(oatMilk)
cart.add(coffee)
cart.add(oatMilk, quantity: 12)

for line in cart.lines {
    print("\(line.product.name) × \(line.quantity) = \(pounds(line.subtotalPence))")
}
print("\(cart.itemCount) items, total \(pounds(cart.totalPence))")
