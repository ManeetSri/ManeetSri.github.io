// Generated from src/dsa/content/lessons/swift-functions/swift-argument-labels.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func square(_ number: Int) -> Int {
    number * number
}

func larger(_ a: Int, _ b: Int) -> Int {
    a > b ? a : b
}

print(square(4))
print(larger(7, 12))
