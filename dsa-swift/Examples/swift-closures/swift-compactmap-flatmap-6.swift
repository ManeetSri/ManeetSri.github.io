// Generated from src/dsa/content/lessons/swift-closures/swift-compactmap-flatmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 1, 4, 1, 5]

let runningTotals = numbers.reduce(into: [Int]()) { totals, number in
    let previous = totals.last ?? 0
    totals.append(previous + number)
}
print(runningTotals)
