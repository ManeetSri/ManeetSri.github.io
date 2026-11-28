import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GridWordHuntTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    static func board(_ rows: [String]) -> [[Character]] {
        rows.map { Array($0) }
    }

    /// The slow, obviously correct check: search for one word on its own.
    static func canTrace(_ word: String, on board: [[Character]]) -> Bool {
        let letters = Array(word)
        let rows = board.count
        let columns = board[0].count
        var used = Array(repeating: Array(repeating: false, count: columns), count: rows)
        func walk(_ row: Int, _ column: Int, _ index: Int) -> Bool {
            guard row >= 0, row < rows, column >= 0, column < columns,
                  !used[row][column], board[row][column] == letters[index] else { return false }
            if index == letters.count - 1 { return true }
            used[row][column] = true
            defer { used[row][column] = false }
            return walk(row - 1, column, index + 1) || walk(row, column + 1, index + 1)
                || walk(row + 1, column, index + 1) || walk(row, column - 1, index + 1)
        }
        for row in 0..<rows {
            for column in 0..<columns where walk(row, column, 0) {
                return true
            }
        }
        return false
    }

    static let sample = board(["star", "pent", "oats", "ndew"])

    @Test("The example from the statement")
    func example() {
        let words = ["star", "tent", "pest", "neat", "seat", "spoon", "stew", "sand", "pond", "oat", "tea"]
        #expect(GridWordHunt.findWords(in: Self.sample, words: words) == ["neat", "oat", "pond", "star", "stew", "tea", "tent"])
    }

    @Test("A cell can't be used twice in one word")
    func noReuse() {
        let board = Self.board(["ab"])
        #expect(GridWordHunt.findWords(in: board, words: ["aba", "ab", "ba", "bab"]) == ["ab", "ba"])
    }

    @Test("Diagonal neighbours don't count")
    func noDiagonals() {
        let board = Self.board(["ax", "xb"])
        #expect(GridWordHunt.findWords(in: board, words: ["ab", "axb", "ba"]) == ["axb"])
    }

    @Test("A one-cell board")
    func oneCell() {
        let board = Self.board(["q"])
        #expect(GridWordHunt.findWords(in: board, words: ["q", "qq", "a"]) == ["q"])
    }

    @Test("Repeated words are reported once")
    func repeats() {
        let board = Self.board(["cat", "zzz"])
        #expect(GridWordHunt.findWords(in: board, words: ["cat", "cat", "at", "cat"]) == ["at", "cat"])
    }

    @Test("Words that are prefixes of other words are both found")
    func prefixWords() {
        let board = Self.board(["tea", "zzm"])
        #expect(GridWordHunt.findWords(in: board, words: ["te", "tea", "team", "teams"]) == ["te", "tea", "team"])
    }

    @Test("Nothing to find")
    func nothing() {
        #expect(GridWordHunt.findWords(in: Self.sample, words: ["xyz", "starz"]) == [])
        #expect(GridWordHunt.findWords(in: Self.sample, words: []) == [])
    }

    @Test("Small random boards agree with searching for each word separately")
    func smallRandom() {
        var steps = Steps(seed: 99)
        let letters = Array("abc")
        var mismatches = 0
        for _ in 0..<200 {
            let rows = 1 + steps.next(below: 4)
            let columns = 1 + steps.next(below: 4)
            let board = (0..<rows).map { _ in (0..<columns).map { _ in letters[steps.next(below: 3)] } }
            let words = (0..<20).map { _ in String((0...steps.next(below: 5)).map { _ in letters[steps.next(below: 3)] }) }
            let expected = Set(words.filter { Self.canTrace($0, on: board) }).sorted()
            if GridWordHunt.findWords(in: board, words: words) != expected { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("A 12 × 12 board and 20,000 words")
    func large() {
        var steps = Steps(seed: 1_212)
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        let size = 12
        let board = (0..<size).map { _ in (0..<size).map { _ in letters[steps.next(below: 26)] } }
        var words: [String] = []
        // Half the words are traced along random paths, so they're really there
        let moves = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        while words.count < 10_000 {
            var row = steps.next(below: size)
            var column = steps.next(below: size)
            var used: Set<Int> = [row * size + column]
            var word = String(board[row][column])
            let length = 3 + steps.next(below: 8)
            while word.count < length {
                let (dr, dc) = moves[steps.next(below: 4)]
                let r = row + dr
                let c = column + dc
                guard r >= 0, r < size, c >= 0, c < size, !used.contains(r * size + c) else {
                    if steps.next(below: 4) == 0 { break } else { continue }
                }
                row = r
                column = c
                used.insert(r * size + c)
                word.append(board[r][c])
            }
            words.append(word)
        }
        // The other half are random, and most aren't there
        while words.count < 20_000 {
            words.append(String((0..<(3 + steps.next(below: 8))).map { _ in letters[steps.next(below: 26)] }))
        }
        let expected = Set(words.filter { Self.canTrace($0, on: board) }).sorted()
        #expect(expected.count > 5_000)
        #expect(GridWordHunt.findWords(in: board, words: words) == expected)
    }

    @Test("A board of a's, where removing found words keeps the search small")
    func pruningMatters() {
        var rows = Array(repeating: String(repeating: "a", count: 12), count: 12)
        rows[5] = "aaaaabcaaaaa"
        let board = Self.board(rows)
        var words = (1...14).map { String(repeating: "a", count: $0) }
        let letters = "abcdefghijklmnopqrstuvwxyz"
        for x in letters {
            for y in letters {
                words.append("aaaaa" + String(x) + String(y))
            }
        }
        let expected = (1...14).map { String(repeating: "a", count: $0) }
            + ["aaaaaab", "aaaaaac", "aaaaaba", "aaaaabc", "aaaaaca", "aaaaacb"]
        #expect(GridWordHunt.findWords(in: board, words: words) == expected.sorted())
    }
}
