// Generated from src/dsa/content/lessons/swift-collections/swift-dictionaries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let stock = ["pear": 2, "apple": 5, "kiwi": 7]

print(stock.count)
print(stock.isEmpty)
print(stock.keys.sorted())
print(stock.values.sorted())
print(stock.values.reduce(0, +))
