// Generated from src/dsa/content/lessons/divide-conquer/dc-fast-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let m = 1_000_000_007
var calls = 0

// Decrease by one: x^n = x · x^(n - 1)
func powerByOne(_ x: Int, _ n: Int) -> Int {
    calls += 1
    return n == 0 ? 1 : x * powerByOne(x, n - 1) % m
}

// Two calls on n / 2: correct, but it recomputes the same half
func powerTwice(_ x: Int, _ n: Int) -> Int {
    calls += 1
    if n == 0 { return 1 }
    let square = powerTwice(x, n / 2) * powerTwice(x, n / 2) % m
    return n % 2 == 0 ? square : square * x % m
}

// One call on n / 2, used twice
func power(_ x: Int, _ n: Int) -> Int {
    calls += 1
    if n == 0 { return 1 }
    let half = power(x, n / 2)
    let square = half * half % m
    return n % 2 == 0 ? square : square * x % m
}

for n in [10, 1_000, 10_000] {
    var counts: [Int] = []
    var answers: [Int] = []
    for method in [powerByOne, powerTwice, power] {
        calls = 0
        answers.append(method(3, n))
        counts.append(calls)
    }
    let agree = Set(answers).count == 1 ? "agree" : "disagree"
    print("n = \(n): by one \(counts[0]) calls, two halves \(counts[1]), one half \(counts[2]); answers \(agree)")
}
