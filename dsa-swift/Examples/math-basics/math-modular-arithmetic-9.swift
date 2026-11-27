// Generated from src/dsa/content/lessons/math-basics/math-modular-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 1_000_000_007
var hash = 0
for byte in "abc".utf8 {
    hash = (hash * 31 + Int(byte)) % mod
}
print(hash)
print(97 * 31 * 31 + 98 * 31 + 99)
