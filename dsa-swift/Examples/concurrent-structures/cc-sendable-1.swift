// Generated from src/dsa/content/lessons/concurrent-structures/cc-sendable.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Order {                      // Sendable automatically: every stored property is Sendable
    let id: Int
    var items: [String]
}

final class ShopInfo: Sendable {    // allowed: final, and every property is a let of a Sendable type
    let name: String
    let currency: String

    init(name: String, currency: String) {
        self.name = name
        self.currency = currency
    }
}

actor Kitchen {
    private var received: [Order] = []

    func receive(_ order: Order) {
        received.append(order)
    }

    var itemCount: Int {
        received.reduce(0) { $0 + $1.items.count }
    }
}

let shop = ShopInfo(name: "Corner Café", currency: "GBP")
let kitchen = Kitchen()

var order = Order(id: 1, items: ["tea", "toast"])
await kitchen.receive(order)        // the kitchen stores its own copy
order.items.append("jam")           // changes only this copy

await withTaskGroup(of: Void.self) { group in
    for id in 2...4 {
        group.addTask {
            await kitchen.receive(Order(id: id, items: ["coffee in \(shop.currency)"]))
        }
    }
}
print(shop.name, order.items.count, await kitchen.itemCount)
