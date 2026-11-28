// Generated from src/dsa/content/lessons/dp-foundations/dp-memoisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// f(0) = 1, and f(n) = f(n / 2) + f(n / 3), rounding down
var memo: [Int: Int] = [0: 1]

func f(_ n: Int) -> Int {
    if let known = memo[n] {
        return known
    }
    let result = f(n / 2) + f(n / 3)
    memo[n] = result
    return result
}

print(f(1_000_000_000_000))
print("different subproblems:", memo.count)
