// Generated from src/dsa/content/lessons/range-queries/rq-sqrt-decomposition.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Steps for a long query, 1...(n - 2), for different block sizes: partial blocks one element at a
// time, whole blocks one step each
func steps(n: Int, blockSize: Int, left: Int, right: Int) -> Int {
    var count = 0
    var i = left
    while i <= right {
        if i % blockSize == 0 && i + blockSize - 1 <= right {
            i += blockSize
        } else {
            i += 1
        }
        count += 1
    }
    return count
}

let n = 10_000
for blockSize in [10, 50, 100, 200, 1_000, 5_000] {
    let blocks = (n + blockSize - 1) / blockSize
    print("block size \(blockSize): \(blocks) blocks, \(steps(n: n, blockSize: blockSize, left: 1, right: n - 2)) steps")
}
