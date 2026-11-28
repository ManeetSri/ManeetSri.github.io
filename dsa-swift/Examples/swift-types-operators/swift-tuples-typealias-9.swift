// Generated from src/dsa/content/lessons/swift-types-operators/swift-tuples-typealias.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func smallerAndLarger(_ x: Int, _ y: Int) -> (smaller: Int, larger: Int) {
    return x < y ? (x, y) : (y, x)
}

let pair = smallerAndLarger(9, 4)
print(pair.smaller, pair.larger)
