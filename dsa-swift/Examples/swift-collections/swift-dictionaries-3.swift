// Generated from src/dsa/content/lessons/swift-collections/swift-dictionaries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var stock = ["apple": 5, "pear": 2, "fig": 0]

stock["kiwi"] = 7
stock["apple"] = 6
stock["fig"] = nil

print(stock.count)
print(stock["apple"] ?? 0, stock["kiwi"] ?? 0)
print(stock["fig"] ?? -1)
