// Generated from src/dsa/content/lessons/complexity/bigo-swift-hidden-costs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Where an array's elements live in memory, as a number
func storageAddress(_ array: [Int]) -> Int {
    array.withUnsafeBufferPointer { buffer in
        Int(bitPattern: buffer.baseAddress)
    }
}

// Counts how many writes had to copy the whole array first
func copiesMade(rounds: Int, keepHistory: Bool) -> Int {
    var board = Array(repeating: 0, count: 10_000)
    var history: [[Int]] = []
    var copies = 0
    for round in 0..<rounds {
        if keepHistory {
            history.append(board)          // a snapshot: shares board's storage
        }
        let before = storageAddress(board)
        board[round] = 1                   // one small write
        if storageAddress(board) != before {
            copies += 1                    // the write moved board to new storage
        }
    }
    return copies
}

print("with snapshots:", copiesMade(rounds: 5, keepHistory: true))
print("without snapshots:", copiesMade(rounds: 5, keepHistory: false))
