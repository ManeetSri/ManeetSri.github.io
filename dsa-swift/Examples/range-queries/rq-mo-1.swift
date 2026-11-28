// Generated from src/dsa/content/lessons/range-queries/rq-mo.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Mo's algorithm: the number of distinct values in each range, answered offline
func distinctCounts(_ values: [Int], _ queries: [(left: Int, right: Int)]) -> [Int] {
    var blockSize = 1
    while blockSize * blockSize < values.count { blockSize += 1 }

    // Sort the query numbers by (block of left, right)
    let order = queries.indices.sorted { a, b in
        let blockA = queries[a].left / blockSize, blockB = queries[b].left / blockSize
        return blockA != blockB ? blockA < blockB : queries[a].right < queries[b].right
    }
    print("block size \(blockSize), order:", order.map { "\(queries[$0].left)...\(queries[$0].right)" })

    var count = [Int](repeating: 0, count: (values.max() ?? 0) + 1)   // how often each value is in the window
    var distinct = 0
    func add(_ index: Int) {
        count[values[index]] += 1
        if count[values[index]] == 1 { distinct += 1 }       // a value we didn't have
    }
    func remove(_ index: Int) {
        count[values[index]] -= 1
        if count[values[index]] == 0 { distinct -= 1 }       // its last copy left
    }

    var answers = [Int](repeating: 0, count: queries.count)
    var currentLeft = 0
    var currentRight = -1                                    // the window starts empty
    for q in order {
        let (left, right) = queries[q]
        while currentLeft > left { currentLeft -= 1; add(currentLeft) }      // grow first...
        while currentRight < right { currentRight += 1; add(currentRight) }
        while currentLeft < left { remove(currentLeft); currentLeft += 1 }   // ...then shrink
        while currentRight > right { remove(currentRight); currentRight -= 1 }
        answers[q] = distinct                                // stored in the query's original place
    }
    return answers
}

let birds = [3, 1, 3, 2, 1, 3, 4, 2]
let surveys = [(left: 0, right: 4), (left: 5, right: 7), (left: 1, right: 3), (left: 2, right: 6), (left: 0, right: 7)]
print("answers:", distinctCounts(birds, surveys))
