// Generated from src/dsa/content/lessons/bits/bits-power-of-two.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isPowerOfTwo(_ n: Int) -> Bool {
    n > 0 && n & (n - 1) == 0
}

for n in [1, 2, 6, 64, 96, 0, -8, Int.min] {
    print(n, isPowerOfTwo(n))
}
