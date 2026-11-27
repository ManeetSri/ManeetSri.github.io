// Generated from src/dsa/content/lessons/bits/bits-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ x: UInt8) -> String {
    let digits = String(x, radix: 2)
    return String(repeating: "0", count: 8 - digits.count) + digits
}

var n: UInt8 = 0b1011_0100
while n != 0 {
    print(binary(n))
    n &= n - 1
}
