// Generated from src/dsa/content/lessons/bits/bits-gray-code-bitsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ x: Int, width: Int) -> String {
    let digits = String(x, radix: 2)
    return String(repeating: "0", count: width - digits.count) + digits
}

let n = 3
var previous = 0
for i in 0..<(1 << n) {
    let gray = i ^ (i >> 1)
    let changed = (gray ^ previous).nonzeroBitCount
    print(i, binary(i, width: n), binary(gray, width: n), changed)
    previous = gray
}
