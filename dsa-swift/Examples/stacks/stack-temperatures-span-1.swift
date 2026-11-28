// Generated from src/dsa/content/lessons/stacks/stack-temperatures-span.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func daysUntilCheaper(_ prices: [Int]) -> [Int] {
    var waits = Array(repeating: 0, count: prices.count)
    var waiting: [Int] = []                    // days whose price hasn't dropped yet
    for (day, price) in prices.enumerated() {
        while let earlier = waiting.last, prices[earlier] > price {
            waits[earlier] = day - earlier      // the distance, not the value
            waiting.removeLast()
        }
        waiting.append(day)
    }
    return waits
}

print(daysUntilCheaper([9, 8, 10, 12, 7, 11]))
