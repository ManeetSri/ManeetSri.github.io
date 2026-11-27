// Generated from src/dsa/content/lessons/swift-collections/swift-dictionaries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let stock = ["pear": 2, "apple": 5, "kiwi": 7]

for name in stock.keys.sorted() {
    print(name, stock[name] ?? 0)
}

for (name, count) in stock.sorted(by: { $0.key < $1.key }) {
    print("\(name): \(count)")
}
