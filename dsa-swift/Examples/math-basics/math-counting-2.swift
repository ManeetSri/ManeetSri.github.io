// Generated from src/dsa/content/lessons/math-basics/math-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var factorial = 1
var n = 1
while true {
    let next = factorial.multipliedReportingOverflow(by: n + 1)
    if next.overflow {
        print("\(n + 1)! overflows")
        break
    }
    factorial = next.partialValue
    n += 1
}
print("\(n)! = \(factorial)")
