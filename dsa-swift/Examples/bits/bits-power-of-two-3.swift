// Generated from src/dsa/content/lessons/bits/bits-power-of-two.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func highestBit(_ n: Int) -> Int {
    Int.bitWidth - 1 - n.leadingZeroBitCount
}

func nextPowerOfTwo(_ n: Int) -> Int {
    1 << (Int.bitWidth - (n - 1).leadingZeroBitCount)
}

for n in [1, 5, 8, 9, 1000] {
    print(n, highestBit(n), nextPowerOfTwo(n))
}
