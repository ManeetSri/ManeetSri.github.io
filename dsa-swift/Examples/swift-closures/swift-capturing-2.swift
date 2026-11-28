// Generated from src/dsa/content/lessons/swift-closures/swift-capturing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var total = 0
let add = { (amount: Int) in
    total += amount
}

add(5)
add(10)
print(total)

total = 100
add(1)
print(total)
