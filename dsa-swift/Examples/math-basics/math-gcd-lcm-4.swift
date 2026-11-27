// Generated from src/dsa/content/lessons/math-basics/math-gcd-lcm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ first: Int, _ second: Int) -> Int {
    var a = abs(first)
    var b = abs(second)
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}

var total = 1
var n = 1
while true {
    let next = n + 1
    let step = (total / gcd(total, next)).multipliedReportingOverflow(by: next)
    if step.overflow {
        print("lcm(1...\(next)) overflows")
        break
    }
    total = step.partialValue
    n = next
}
print("lcm(1...\(n)) = \(total)")
