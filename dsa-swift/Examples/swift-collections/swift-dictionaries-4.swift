// Generated from src/dsa/content/lessons/swift-collections/swift-dictionaries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var stock = ["apple": 5, "pear": 2]

let oldPears = stock.updateValue(10, forKey: "pear")
print(oldPears ?? -1)

let oldPlums = stock.updateValue(1, forKey: "plum")
print(oldPlums ?? -1)

let removed = stock.removeValue(forKey: "apple")
print(removed ?? -1, stock.count)
