// Generated from src/dsa/content/lessons/swift-types/swift-mutating.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Inventory {
    var counts: [String: Int]

    init() {
        counts = [:]
    }

    mutating func add(_ item: String, quantity: Int = 1) {
        counts[item, default: 0] += quantity
    }

    mutating func remove(_ item: String) -> Bool {
        guard let current = counts[item], current > 0 else {
            return false
        }
        counts[item] = current - 1
        return true
    }

    var totalItems: Int {
        counts.values.reduce(0, +)
    }
}

var bag = Inventory()
bag.add("apple", quantity: 3)
bag.add("pear")
print(bag.remove("apple"))
print(bag.remove("plum"))
print(bag.totalItems)
print(bag.counts["apple"] ?? 0)
