// Generated from src/dsa/content/lessons/concurrent-structures/cc-data-races.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumOfSquares(_ numbers: ClosedRange<Int>) -> Int {
    numbers.reduce(0) { $0 + $1 * $1 }
}

let total = await withTaskGroup(of: Int.self) { group in
    for start in stride(from: 1, through: 1_000, by: 250) {
        group.addTask {
            sumOfSquares(start...(start + 249))
        }
    }
    var sum = 0
    for await part in group {
        sum += part
    }
    return sum
}
print(total)
print(sumOfSquares(1...1_000))
