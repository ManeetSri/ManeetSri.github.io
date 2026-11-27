// Generated from src/dsa/content/lessons/prefix-sums/prefix-difference-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func applySlowly(count: Int, updates: [(first: Int, last: Int, amount: Int)]) -> [Int] {
    var values = Array(repeating: 0, count: count)
    for update in updates {
        for index in update.first...update.last {
            values[index] += update.amount
        }
    }
    return values
}

print(applySlowly(count: 6, updates: [(1, 3, 5), (2, 5, 2), (0, 1, 10)]))
