// Generated from src/dsa/content/lessons/capstones/cap-sudoku.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The course's seeded generator: the same seed gives the same puzzle on every run
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
    mutating func shuffle<T>(_ items: inout [T]) {           // Fisher–Yates
        for i in stride(from: items.count - 1, to: 0, by: -1) {
            items.swapAt(i, roll(0...i))
        }
    }
}

// The 27 units: 9 rows, 9 columns, 9 boxes, each a list of 9 cell indexes (0...80)
let units: [[Int]] = (0..<9).map { r in (0..<9).map { r * 9 + $0 } }
    + (0..<9).map { c in (0..<9).map { $0 * 9 + c } }
    + (0..<9).map { b in (0..<9).map { (b / 3 * 3 + $0 / 3) * 9 + b % 3 * 3 + $0 % 3 } }

struct Board {
    var cells: [Int]                                   // 0 means empty
    var used = Array(repeating: 0, count: 27)          // per unit, bit d set when digit d is placed

    init(_ cells: [Int]) {
        self.cells = Array(repeating: 0, count: 81)
        for (i, digit) in cells.enumerated() where digit != 0 {
            place(digit, at: i)
        }
    }

    static func unitsOf(_ i: Int) -> (Int, Int, Int) {
        (i / 9, 9 + i % 9, 18 + i / 27 * 3 + i % 9 / 3)
    }

    /// Bits 1...9 set for the digits that could still go in cell i
    func candidates(_ i: Int) -> Int {
        let (r, c, b) = Board.unitsOf(i)
        return ~(used[r] | used[c] | used[b]) & 0b11_1111_1110
    }

    mutating func place(_ digit: Int, at i: Int) {
        cells[i] = digit
        let (r, c, b) = Board.unitsOf(i)
        for unit in [r, c, b] { used[unit] |= 1 << digit }
    }

    /// Fills forced cells until nothing changes. Returns false on a contradiction.
    mutating func propagate() -> Bool {
        var changed = true
        while changed {
            changed = false
            for i in 0..<81 where cells[i] == 0 {               // naked single: one digit fits the cell
                let mask = candidates(i)
                if mask == 0 { return false }
                if mask.nonzeroBitCount == 1 {
                    place(mask.trailingZeroBitCount, at: i)
                    changed = true
                }
            }
            for (u, unit) in units.enumerated() {               // hidden single: one cell fits the digit
                for digit in 1...9 where used[u] & (1 << digit) == 0 {
                    let spots = unit.filter { cells[$0] == 0 && candidates($0) & (1 << digit) != 0 }
                    if spots.isEmpty { return false }
                    if spots.count == 1 {
                        place(digit, at: spots[0])
                        changed = true
                    }
                }
            }
        }
        return true
    }
}

var guesses = 0

/// Counts solutions, stopping at `limit`. Copies the board per call, so undoing is free.
func search(_ start: Board, limit: Int, first: inout [Int]?, order: (inout [Int]) -> Void) -> Int {
    var board = start
    guard board.propagate() else { return 0 }
    var best = -1, fewest = 10
    for i in 0..<81 where board.cells[i] == 0 {                 // the most constrained cell
        let count = board.candidates(i).nonzeroBitCount
        if count < fewest { (best, fewest) = (i, count) }
    }
    if best == -1 {
        if first == nil { first = board.cells }
        return 1
    }
    var digits = (1...9).filter { board.candidates(best) & (1 << $0) != 0 }
    order(&digits)
    var found = 0
    for digit in digits where found < limit {
        guesses += 1
        var next = board
        next.place(digit, at: best)
        found += search(next, limit: limit - found, first: &first, order: order)
    }
    return found
}

func solutions(_ cells: [Int], limit: Int) -> Int {
    var ignored: [Int]? = nil
    return search(Board(cells), limit: limit, first: &ignored, order: { _ in })
}

/// A random full grid (the solver with shuffled digits), then remove cells while the answer stays unique
func generate(seed: UInt64) -> (puzzle: [Int], solution: [Int]) {
    var dice = Dice(seed: seed)
    var full: [Int]? = nil
    _ = search(Board(Array(repeating: 0, count: 81)), limit: 1, first: &full, order: { dice.shuffle(&$0) })
    var puzzle = full!
    var order = Array(0..<81)
    dice.shuffle(&order)
    for i in order {
        let kept = puzzle[i]
        puzzle[i] = 0
        if solutions(puzzle, limit: 2) != 1 {
            puzzle[i] = kept                                     // removing it allowed a second answer
        }
    }
    return (puzzle, full!)
}

func show(_ cells: [Int]) {
    for r in 0..<9 {
        print(cells[(r * 9)..<(r * 9 + 9)].map { $0 == 0 ? "." : String($0) }.joined(separator: " "))
    }
}

let (puzzle, solution) = generate(seed: 74)
show(puzzle)
print("clues:", puzzle.filter { $0 != 0 }.count, "solutions:", solutions(puzzle, limit: 2))

var solved: [Int]? = nil
guesses = 0
_ = search(Board(puzzle), limit: 1, first: &solved, order: { _ in })
print("solved matches the generated grid:", solved! == solution, "guesses:", guesses)

var oneTooMany = puzzle
let lastClue = oneTooMany.lastIndex { $0 != 0 }!
oneTooMany[lastClue] = 0
print("without its last clue:", solutions(oneTooMany, limit: 2), "solutions (stopped counting at 2)")
