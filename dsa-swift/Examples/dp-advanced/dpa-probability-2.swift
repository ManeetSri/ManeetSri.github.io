// Generated from src/dsa/content/lessons/dp-advanced/dpa-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// Expected number of rolls of a fair die to get from square 0 to square goal or beyond
func expectedRolls(goal: Int) -> [Double] {
    var expected = [Double](repeating: 0, count: goal + 6)   // squares at or past the goal need 0 more rolls
    for square in stride(from: goal - 1, through: 0, by: -1) {   // backwards: later squares are known
        var sum = 0.0
        for face in 1...6 {
            sum += expected[square + face]
        }
        expected[square] = 1 + sum / 6                       // one roll, then wherever it lands
    }
    return expected
}

let board = expectedRolls(goal: 20)
print("from 0:", String(format: "%.4f", board[0]))
print("from 19:", String(format: "%.4f", board[19]))
print("from 15:", String(format: "%.4f", board[15]))

// Rolling a 6 now wastes the turn: expected[s] = 1 + (1/6)·expected[s] + (1/6)·(the other five)
func expectedRollsWastedSix(goal: Int) -> Double {
    var expected = [Double](repeating: 0, count: goal + 6)
    for square in stride(from: goal - 1, through: 0, by: -1) {
        var sum = 0.0
        for face in 1...5 {
            sum += expected[square + face]
        }
        expected[square] = (1 + sum / 6) / (1 - 1.0 / 6)     // solved for expected[s]
    }
    return expected[0]
}
print("wasted sixes:", String(format: "%.4f", expectedRollsWastedSix(goal: 20)))
