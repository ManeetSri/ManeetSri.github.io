import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SeatingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TeamSeatingSwapsTests {
    /// True when the 1s form a single block around the circle
    private func isTogether(_ seats: [Int]) -> Bool {
        let n = seats.count
        var blocks = 0
        for i in 0..<n where seats[i] == 1 && seats[(i + 1) % n] == 0 {
            blocks += 1
        }
        return blocks <= 1
    }

    /// Breadth-first search over every arrangement reachable by swaps: the true fewest swaps, for tiny tables
    private func bySearch(_ seats: [Int]) -> Int {
        var distance: [[Int]: Int] = [seats: 0]
        var queue = [seats]
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            if isTogether(current) { return distance[current]! }
            for i in current.indices where current[i] == 1 {
                for j in current.indices where current[j] == 0 {
                    var next = current
                    next.swapAt(i, j)
                    if distance[next] == nil {
                        distance[next] = distance[current]! + 1
                        queue.append(next)
                    }
                }
            }
        }
        return -1
    }

    /// Count the team in every block of k seats directly: O(n · k)
    private func byEveryBlock(_ seats: [Int]) -> Int {
        let n = seats.count
        let team = seats.reduce(0, +)
        if team == 0 { return 0 }
        var best = 0
        for start in 0..<n {
            var inBlock = 0
            for offset in 0..<team {
                inBlock += seats[(start + offset) % n]
            }
            best = max(best, inBlock)
        }
        return team - best
    }

    /// Prefix sums over the seats written out twice: O(n), and a different route to the same answer
    private func byPrefixSums(_ seats: [Int]) -> Int {
        let n = seats.count
        let team = seats.reduce(0, +)
        if team == 0 { return 0 }
        let doubled = seats + seats
        var prefix = [0]
        for seat in doubled {
            prefix.append(prefix.last! + seat)
        }
        var best = 0
        for start in 0..<n {
            best = max(best, prefix[start + team] - prefix[start])
        }
        return team - best
    }

    @Test("Examples and small cases", arguments: [
        ([1, 0, 1, 0, 1], 1),
        ([1, 1, 0, 0, 1], 0),
        ([1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0], 2),
        ([0, 0, 0], 0),
        ([1], 0),
        ([0], 0),
        ([1, 1, 1, 1], 0),
        ([0, 1, 0, 1, 1, 0, 0], 1),
        ([1, 0, 1, 0, 1, 0, 1, 0], 2),
        ([0, 1, 1, 0, 1, 0, 0, 1], 1),
    ] as [([Int], Int)])
    func examples(seats: [Int], expected: Int) {
        #expect(TeamSeatingSwaps.fewestSwaps(seats: seats) == expected)
    }

    @Test("Matches a search over every arrangement, for every table of up to 9 seats")
    func exhaustiveSmall() {
        for n in 1...9 {
            for mask in 0..<(1 << n) {
                let seats = (0..<n).map { (mask >> $0) & 1 }
                #expect(TeamSeatingSwaps.fewestSwaps(seats: seats) == bySearch(seats), "seats \(seats)")
            }
        }
    }

    @Test("Matches counting every block, on 300 random tables of up to 300 seats")
    func randomMedium() {
        var random = SeatingRandom(seed: 59)
        for _ in 0..<300 {
            let n = Int.random(in: 1...300, using: &random)
            let density = Int.random(in: 0...100, using: &random)
            let seats = (0..<n).map { _ in Int.random(in: 0..<100, using: &random) < density ? 1 : 0 }
            #expect(TeamSeatingSwaps.fewestSwaps(seats: seats) == byEveryBlock(seats))
        }
    }

    @Test("200,000 seats")
    func large() {
        var random = SeatingRandom(seed: 2_059)
        let n = 200_000
        for density in [3, 50, 97] {
            let seats = (0..<n).map { _ in Int.random(in: 0..<100, using: &random) < density ? 1 : 0 }
            #expect(TeamSeatingSwaps.fewestSwaps(seats: seats) == byPrefixSums(seats))
        }

        // Alternating seats: every block of n / 2 seats holds exactly n / 4 of the team
        let alternating = (0..<n).map { ($0 + 1) % 2 }
        #expect(TeamSeatingSwaps.fewestSwaps(seats: alternating) == n / 4)

        // A block that wraps round the table, with one member stranded opposite it
        var wrapped = Array(repeating: 0, count: n)
        for i in 0..<1_000 {
            wrapped[(n - 500 + i) % n] = 1
        }
        wrapped[n / 2] = 1
        #expect(TeamSeatingSwaps.fewestSwaps(seats: wrapped) == 1)

        #expect(TeamSeatingSwaps.fewestSwaps(seats: Array(repeating: 1, count: n)) == 0)
    }
}
