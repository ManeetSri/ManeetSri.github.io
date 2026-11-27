// Generated from src/dsa/content/lessons/hashing/hash-load-factor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func rehashMoves(inserting n: Int) -> Int {
    var buckets = 8
    var count = 0
    var moves = 0
    for _ in 0..<n {
        count += 1
        if count > buckets * 3 / 4 {
            moves += count               // every entry moves to the new array
            buckets *= 2
        }
    }
    return moves
}

for n in [1_000, 10_000, 100_000, 1_000_000] {
    print("\(n) inserts: \(rehashMoves(inserting: n)) entries moved")
}
