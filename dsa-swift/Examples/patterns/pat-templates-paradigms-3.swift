// Generated from src/dsa/content/lessons/patterns/pat-templates-paradigms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// One DP three ways: the most you can take from houses in a row, never two neighbours
// State: best(i) = the most from houses i, i + 1, ...  Transition: skip house i, or take it and skip i + 1.

// 1. Top-down: write the recursion, then cache it
func robMemo(_ houses: [Int]) -> Int {
    var memo = Array(repeating: -1, count: houses.count)   // -1: not computed yet
    func best(_ i: Int) -> Int {
        if i >= houses.count { return 0 }                    // base: no houses left
        if memo[i] != -1 { return memo[i] }
        let result = max(best(i + 1), houses[i] + best(i + 2))
        memo[i] = result
        return result
    }
    return best(0)
}

// 2. Bottom-up: the same recurrence, filled in an order where i + 1 and i + 2 are ready first
func robTable(_ houses: [Int]) -> Int {
    let n = houses.count
    var table = Array(repeating: 0, count: n + 2)            // table[n] and table[n + 1] are the base cases
    for i in stride(from: n - 1, through: 0, by: -1) {
        table[i] = max(table[i + 1], houses[i] + table[i + 2])
    }
    return table[0]
}

// 3. Saving space: each cell needs only the two after it
func robRolling(_ houses: [Int]) -> Int {
    var next = 0                                             // table[i + 1]
    var afterNext = 0                                        // table[i + 2]
    for value in houses.reversed() {
        let current = max(next, value + afterNext)
        afterNext = next
        next = current
    }
    return next
}

let street = [6, 1, 2, 7, 3, 1, 5]
print(robMemo(street), robTable(street), robRolling(street))
print(robMemo([]), robTable([4]), robRolling([2, 9, 3]))
