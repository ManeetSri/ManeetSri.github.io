// Generated from src/dsa/content/lessons/range-queries/rq-mo.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How far the two ends travel in total: queries in the order given, against Mo's order
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

func travel(_ queries: [(left: Int, right: Int)], order: [Int]) -> Int {
    var currentLeft = 0
    var currentRight = -1
    var moves = 0
    for q in order {
        moves += abs(queries[q].left - currentLeft) + abs(queries[q].right - currentRight)
        currentLeft = queries[q].left
        currentRight = queries[q].right
    }
    return moves
}

var dice = Dice(seed: 62)
let n = 20_000
let queries = (0..<20_000).map { _ -> (left: Int, right: Int) in
    let a = dice.roll(0...(n - 1)), b = dice.roll(0...(n - 1))
    return (min(a, b), max(a, b))
}
let blockSize = 142                                   // about √20,000
let given = Array(queries.indices)
let mo = queries.indices.sorted { a, b in
    let blockA = queries[a].left / blockSize, blockB = queries[b].left / blockSize
    return blockA != blockB ? blockA < blockB : queries[a].right < queries[b].right
}
print("in the order given:", travel(queries, order: given))
print("in Mo's order:     ", travel(queries, order: mo))
print("n × q:             ", n * queries.count)
print("(n + q) × √n:      ", (n + queries.count) * blockSize)
