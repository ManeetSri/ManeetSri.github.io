// Generated from src/dsa/content/lessons/complexity/bigo-amortised-methods.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A decimal odometer, stored least significant digit first
func increment(_ digits: inout [Int]) -> Int {
    var changed = 0
    var position = 0
    while position < digits.count && digits[position] == 9 {
        digits[position] = 0          // a 9 rolls over to 0
        changed += 1
        position += 1
    }
    if position == digits.count {
        digits.append(1)              // a new leading digit
    } else {
        digits[position] += 1
    }
    return changed + 1
}

for n in [10, 100, 1_000, 10_000] {
    var digits = [0]
    var total = 0
    var worst = 0
    for _ in 0..<n {
        let cost = increment(&digits)
        total += cost
        worst = max(worst, cost)
    }
    print("\(n) increments: \(total) digit changes, worst single increment \(worst)")
}
