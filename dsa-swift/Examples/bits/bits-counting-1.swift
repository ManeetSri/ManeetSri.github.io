// Generated from src/dsa/content/lessons/bits/bits-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 12
print(n.nonzeroBitCount, n.trailingZeroBitCount, n.leadingZeroBitCount)
print(UInt8(12).leadingZeroBitCount)
print(0.trailingZeroBitCount, 0.leadingZeroBitCount)
print(Int.bitWidth - n.leadingZeroBitCount)
