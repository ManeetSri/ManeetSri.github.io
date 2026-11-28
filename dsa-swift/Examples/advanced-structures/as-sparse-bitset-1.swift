// Generated from src/dsa/content/lessons/advanced-structures/as-sparse-bitset.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

// Compressed sparse row: the nonzero values row by row, their columns, and where each row starts
struct CSRMatrix {
    let rows: Int
    let columns: Int
    private(set) var values: [Int] = []
    private(set) var columnIndices: [Int] = []
    private(set) var rowStart: [Int]             // row r's entries are at rowStart[r]..<rowStart[r + 1]

    init(rows: Int, columns: Int, entries: [Int: Int]) {   // entries: row * columns + column → value
        self.rows = rows
        self.columns = columns
        rowStart = Array(repeating: 0, count: rows + 1)
        for key in entries.keys.sorted() {       // sorted keys are in row order, then column order
            values.append(entries[key]!)
            columnIndices.append(key % columns)
            rowStart[key / columns + 1] += 1     // count entries per row…
        }
        for r in 0..<rows {
            rowStart[r + 1] += rowStart[r]       // …then turn the counts into starting positions
        }
    }

    func value(_ row: Int, _ column: Int) -> Int {
        for k in rowStart[row]..<rowStart[row + 1] where columnIndices[k] == column {
            return values[k]
        }
        return 0
    }

    // Matrix × vector, touching only the stored entries
    func multiply(_ vector: [Int]) -> [Int] {
        (0..<rows).map { r in
            (rowStart[r]..<rowStart[r + 1]).reduce(0) { $0 + values[$1] * vector[columnIndices[$1]] }
        }
    }
}

// 1,000 users × 1,000 songs; each user has rated a few songs (1 to 5 stars)
let n = 1_000
var generator = SeededGenerator(state: 3)
var ratings: [Int: Int] = [:]                    // dictionary of keys: row * n + column → value
for user in 0..<n {
    for _ in 0..<3 {
        let song = Int(generator.next() % UInt64(n))
        ratings[user * n + song] = Int(generator.next() % 5) + 1
    }
}
let csr = CSRMatrix(rows: n, columns: n, entries: ratings)
print("cells:", n * n, " stored:", csr.values.count, " CSR arrays:",
      csr.values.count + csr.columnIndices.count + csr.rowStart.count, "Ints")

let row0 = csr.rowStart[0]..<csr.rowStart[1]
print("user 0 rated songs", row0.map { csr.columnIndices[$0] }, "with stars", row0.map { csr.values[$0] })
print("user 0, song 366:", csr.value(0, 366), " song 365:", csr.value(0, 365))

// The same matrix stored densely: every cell, mostly zeros
var dense = Array(repeating: Array(repeating: 0, count: n), count: n)
for (key, stars) in ratings {
    dense[key / n][key % n] = stars
}

// Weight each song and score every user: dense touches every cell, CSR only the ratings
let weights = (0..<n).map { $0 % 7 }
let sparseScores = csr.multiply(weights)
let denseScores = dense.map { row in zip(row, weights).reduce(0) { $0 + $1.0 * $1.1 } }
print("same scores:", sparseScores == denseScores, " dense multiplications:", n * n,
      " sparse:", csr.values.count)
