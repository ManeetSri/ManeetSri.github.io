// Generated from src/dsa/content/lessons/fenwick/bit-lowbit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each number, its last four bits, and its lowest set bit
for i in 1...12 {
    let binary = String(i, radix: 2)
    let padded = String(repeating: "0", count: 4 - binary.count) + binary
    print(i, padded, i & -i)
}
