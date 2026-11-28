// Generated from src/dsa/content/lessons/bits/bits-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func onesByKernighan(_ x: UInt64) -> Int {
    var n = x
    var count = 0
    while n != 0 {
        n &= n - 1
        count += 1
    }
    return count
}

print(onesByKernighan(0b1011_0100))
print(onesByKernighan((1 << 40) | 1))
print(onesByKernighan(UInt64.max))
