// Generated from src/dsa/content/lessons/swift-collections/swift-dictionaries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let stock = ["apple": 5, "pear": 2, "fig": 0]

if let apples = stock["apple"] {
    print("apples: \(apples)")
}

if let kiwis = stock["kiwi"] {
    print("kiwis: \(kiwis)")
} else {
    print("no kiwis listed")
}

print(stock["kiwi"] ?? 0)
