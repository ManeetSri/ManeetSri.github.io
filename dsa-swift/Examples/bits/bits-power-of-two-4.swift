// Generated from src/dsa/content/lessons/bits/bits-power-of-two.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for x in [13, 16, 21] {
    print(x % 8, x & 7, x / 8, x >> 3, (x + 7) & ~7)
}
