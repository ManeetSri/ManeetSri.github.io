// Generated from src/dsa/content/lessons/linear-sorts/sort-radix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let signBit: UInt = 1 << 63
for value in [Int.min, -1, 0, 1, Int.max] {
    let key = UInt(bitPattern: value) ^ signBit
    print(value, "->", key)
}
