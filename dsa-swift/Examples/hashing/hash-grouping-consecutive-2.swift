// Generated from src/dsa/content/lessons/hashing/hash-grouping-consecutive.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Month: Hashable {
    let year: Int
    let month: Int
}

struct Order {
    let id: Int
    let year: Int
    let month: Int
    let total: Int
}

let orders = [
    Order(id: 1, year: 2026, month: 3, total: 40),
    Order(id: 2, year: 2026, month: 4, total: 15),
    Order(id: 3, year: 2026, month: 3, total: 25),
    Order(id: 4, year: 2025, month: 12, total: 60),
]

let byMonth = Dictionary(grouping: orders, by: { Month(year: $0.year, month: $0.month) })
for key in byMonth.keys.sorted(by: { ($0.year, $0.month) < ($1.year, $1.month) }) {
    let totals = byMonth[key]!.map { $0.total }
    print("\(key.year)-\(key.month): \(totals.reduce(0, +))")
}
