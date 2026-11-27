// Generated from src/dsa/content/lessons/complexity/bigo-little-o.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func tenthPower(_ n: Int) -> Int {
    var result = 1
    for _ in 0..<10 {
        result *= n
    }
    return result
}

var n = 2
var twoToN = 4
while twoToN <= tenthPower(n) {
    n += 1
    twoToN *= 2
}
print("2ⁿ first beats n¹⁰ at n = \(n)")
print("n¹⁰ = \(tenthPower(n)), 2ⁿ = \(twoToN)")
