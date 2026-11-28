// Generated from src/dsa/content/lessons/prefix-sums/prefix-difference-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func applyUpdates(count: Int, updates: [(first: Int, last: Int, amount: Int)]) -> [Int] {
    var diff = Array(repeating: 0, count: count + 1)   // one spare slot for last + 1
    for update in updates {
        diff[update.first] += update.amount
        diff[update.last + 1] -= update.amount
    }
    print("diff:", diff)

    var values: [Int] = []
    var running = 0
    for index in 0..<count {
        running += diff[index]
        values.append(running)
    }
    return values
}

print(applyUpdates(count: 6, updates: [(1, 3, 5), (2, 5, 2), (0, 1, 10)]))
