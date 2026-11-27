import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct LoopRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ProfitLoopFinderTests {
    /// Floyd–Warshall: a negative loop exists exactly when some trader can get back to themselves for less than 0
    private func hasLoop(_ n: Int, _ trades: [[Int]]) -> Bool {
        let infinity = Int.max / 4
        var dist = Array(repeating: Array(repeating: infinity, count: n), count: n)
        for i in 0..<n { dist[i][i] = 0 }
        for trade in trades { dist[trade[0]][trade[1]] = min(dist[trade[0]][trade[1]], trade[2]) }
        for k in 0..<n {
            for i in 0..<n where dist[i][k] < infinity {
                for j in 0..<n where dist[k][j] < infinity {
                    dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
                }
            }
        }
        return (0..<n).contains { dist[$0][$0] < 0 }
    }

    /// True when `loop` is a list of distinct traders joined by trades, end to start, totalling below zero
    private func isProfitLoop(_ loop: [Int], _ n: Int, _ trades: [[Int]]) -> Bool {
        guard !loop.isEmpty, Set(loop).count == loop.count, loop.allSatisfy({ (0..<n).contains($0) }) else { return false }
        var cheapest: [Int: Int] = [:]                   // key from * n + to
        for trade in trades {
            cheapest[trade[0] * n + trade[1]] = min(cheapest[trade[0] * n + trade[1]] ?? Int.max, trade[2])
        }
        var total = 0
        for (index, trader) in loop.enumerated() {
            guard let cost = cheapest[trader * n + loop[(index + 1) % loop.count]] else { return false }
            total += cost
        }
        return total < 0
    }

    @Test("No profit to be made", arguments: [
        (3, [[0, 1, 4], [1, 2, -1], [2, 0, -2]]),
        (1, []),
        (4, [[0, 1, -5], [1, 2, -5], [2, 3, -5]]),
        (2, [[0, 1, 3], [1, 0, -3]]),
        (2, [[0, 0, 0], [1, 1, 4]]),
    ] as [(Int, [[Int]])])
    func noLoop(n: Int, trades: [[Int]]) {
        #expect(ProfitLoopFinder.findLoop(traderCount: n, trades: trades) == [])
    }

    @Test("Finds a loop", arguments: [
        (3, [[0, 1, 4], [1, 2, -1], [2, 0, -4]]),
        (2, [[0, 1, 3], [1, 0, -4]]),
        (1, [[0, 0, -1]]),
        (5, [[0, 1, 2], [1, 2, 2], [3, 4, -3], [4, 3, 1]]),
        (4, [[0, 1, 1], [1, 2, 1], [2, 3, 1], [3, 1, -3], [0, 2, 5]]),
        (3, [[0, 1, 5], [0, 1, -2], [1, 0, 1]]),
    ] as [(Int, [[Int]])])
    func findsLoop(n: Int, trades: [[Int]]) {
        let loop = ProfitLoopFinder.findLoop(traderCount: n, trades: trades)
        #expect(isProfitLoop(loop, n, trades), "returned \(loop)")
    }

    @Test("Agrees with Floyd–Warshall on 400 small random markets")
    func randomSmall() {
        var random = LoopRandom(seed: 31)
        for _ in 0..<400 {
            let n = Int.random(in: 1...7, using: &random)
            let trades = (0..<Int.random(in: 0...14, using: &random)).map { _ in
                [Int.random(in: 0..<n, using: &random), Int.random(in: 0..<n, using: &random), Int.random(in: -6...15, using: &random)]
            }
            let loop = ProfitLoopFinder.findLoop(traderCount: n, trades: trades)
            if hasLoop(n, trades) {
                #expect(isProfitLoop(loop, n, trades), "returned \(loop) for \(trades)")
            } else {
                #expect(loop == [], "returned \(loop) for \(trades)")
            }
        }
    }

    /// Trades whose cost is potential[to] - potential[from] + extra: around any loop the potentials cancel,
    /// so a loop's total is the sum of its extras. Plenty of individual trades are negative.
    private func market(_ n: Int, trades count: Int, using random: inout LoopRandom) -> (potential: [Int], trades: [[Int]]) {
        let potential = (0..<n).map { _ in Int.random(in: 0...1_000_000, using: &random) }
        let trades = (0..<count).map { _ -> [Int] in
            let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
            return [a, b, potential[b] - potential[a] + Int.random(in: 0...20, using: &random)]
        }
        return (potential, trades)
    }

    @Test("1,500 traders and 8,000 trades without a profit loop")
    func largeNoLoop() {
        var random = LoopRandom(seed: 2_000)
        let (_, trades) = market(1_500, trades: 8_000, using: &random)
        #expect(ProfitLoopFinder.findLoop(traderCount: 1_500, trades: trades) == [])
    }

    @Test("1,500 traders and 8,000 trades hiding one profit loop of 40 traders")
    func largeHiddenLoop() {
        var random = LoopRandom(seed: 2_001)
        let (potential, randomTrades) = market(1_500, trades: 8_000, using: &random)
        var trades = randomTrades
        // The hidden loop's extras are all 0 except one trade that is 1 cheaper: a total of -1
        let members = Array((0..<1_500).shuffled(using: &random).prefix(40))
        for (index, from) in members.enumerated() {
            let to = members[(index + 1) % members.count]
            trades.append([from, to, potential[to] - potential[from] - (index == 0 ? 1 : 0)])
        }
        trades.shuffle(using: &random)
        let loop = ProfitLoopFinder.findLoop(traderCount: 1_500, trades: trades)
        #expect(isProfitLoop(loop, 1_500, trades))
    }
}
