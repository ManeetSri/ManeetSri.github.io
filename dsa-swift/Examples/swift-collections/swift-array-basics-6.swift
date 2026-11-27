// Generated from src/dsa/content/lessons/swift-collections/swift-array-basics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let fruits = ["apple", "pear", "fig"]

for fruit in fruits {
    print(fruit)
}

for i in fruits.indices {
    print(i, fruits[i])
}

for (i, fruit) in fruits.enumerated() {
    print("\(i): \(fruit)")
}
