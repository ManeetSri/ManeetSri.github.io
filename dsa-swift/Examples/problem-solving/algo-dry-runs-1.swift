// Generated from src/dsa/content/lessons/problem-solving/algo-dry-runs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func digitSum(_ number: Int) -> Int {
    var n = number
    var total = 0
    while n > 0 {
        total += n % 10
        n /= 10
    }
    return total
}

print(digitSum(472))
print(digitSum(5))
print(digitSum(0))
