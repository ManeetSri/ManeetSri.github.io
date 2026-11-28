// Generated from src/dsa/design/content/lessons/sd-state/sd-state-derived.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Line {
    let name: String
    let pence: Int
    var quantity: Int
}

/// Stores a total as well as the lines it comes from
struct DriftingBasket {
    private(set) var lines: [Line] = []
    private(set) var totalPence = 0

    mutating func add(_ line: Line) {
        lines.append(line)
        totalPence += line.pence * line.quantity
    }

    mutating func setQuantity(_ quantity: Int, at index: Int) {
        lines[index].quantity = quantity   // the total was forgotten here
    }
}

/// Stores only the facts, and computes the rest when asked
struct Basket {
    private(set) var lines: [Line] = []

    var totalPence: Int { lines.reduce(0) { $0 + $1.pence * $1.quantity } }
    var itemCount: Int { lines.reduce(0) { $0 + $1.quantity } }
    var canCheckOut: Bool { itemCount > 0 }

    mutating func add(_ line: Line) { lines.append(line) }
    mutating func setQuantity(_ quantity: Int, at index: Int) { lines[index].quantity = quantity }
}

var drifting = DriftingBasket()
var basket = Basket()
for line in [Line(name: "Coffee", pence: 450, quantity: 1), Line(name: "Bagel", pence: 300, quantity: 2)] {
    drifting.add(line)
    basket.add(line)
}
drifting.setQuantity(3, at: 0)
basket.setQuantity(3, at: 0)

print("Stored total:", drifting.totalPence)
print("Computed total:", basket.totalPence, "for", basket.itemCount, "items")
