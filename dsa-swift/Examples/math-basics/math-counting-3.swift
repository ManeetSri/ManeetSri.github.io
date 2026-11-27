// Generated from src/dsa/content/lessons/math-basics/math-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func choose(_ n: Int, _ k: Int) -> Int {
    if k < 0 || k > n {
        return 0
    }
    let k = min(k, n - k)
    var result = 1
    for i in 0..<k {
        result = result * (n - i) / (i + 1)
    }
    return result
}

print(choose(5, 2), choose(52, 5), choose(10, 0), choose(4, 7))
print(choose(60, 30))
