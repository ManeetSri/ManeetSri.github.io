// Generated from src/dsa/content/lessons/stacks/stack-temperatures-span.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func spans(_ prices: [Int]) -> [Int] {
    var result: [Int] = []
    var higher: [Int] = []                       // indexes with a strictly higher price, decreasing
    for (day, price) in prices.enumerated() {
        while let top = higher.last, prices[top] <= price {
            higher.removeLast()
        }
        result.append(day - (higher.last ?? -1))
        higher.append(day)
    }
    return result
}

print(spans([100, 80, 60, 70, 60, 75, 85]))
