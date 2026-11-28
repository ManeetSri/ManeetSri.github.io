// Generated from src/dsa/content/lessons/heaps/heap-heapify.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The most swaps each method can need, level by level, in a full heap of 1,023 values
let levels = 10                                      // 1 + 2 + 4 + … + 512 = 1,023 values
var siftDownTotal = 0
var siftUpTotal = 0
for depth in 0..<levels {
    let nodes = 1 << depth                           // 2 to the power depth
    let toBottom = levels - 1 - depth                // most swaps sifting down from this level
    let toTop = depth                                // most swaps sifting up from this level
    siftDownTotal += nodes * toBottom
    siftUpTotal += nodes * toTop
    print("depth \(depth): \(nodes) × \(toBottom) swaps down, \(nodes) × \(toTop) swaps up")
}
print("bottom-up heapify: at most \(siftDownTotal) swaps")
print("1,023 inserts:     at most \(siftUpTotal) swaps")
