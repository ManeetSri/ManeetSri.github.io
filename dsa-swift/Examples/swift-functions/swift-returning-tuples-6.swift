// Generated from src/dsa/content/lessons/swift-functions/swift-returning-tuples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

typealias Bounds = (low: Int, high: Int)

func widen(_ range: Bounds, by amount: Int) -> Bounds {
    (range.low - amount, range.high + amount)
}

let wider = widen((low: 3, high: 7), by: 2)
print(wider.low, wider.high)
