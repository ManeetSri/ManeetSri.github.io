import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PanelRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PanelBulkOrdersTests {
    /// Brute force: try every way to split the panels into batches (each panel joins an existing batch
    /// or starts a new one)
    private func bruteForce(_ panels: [[Int]]) -> Int {
        var best = Int.max
        var batches: [(width: Int, height: Int)] = []
        func place(_ index: Int, _ cost: Int) {
            if index == panels.count {
                best = min(best, batches.reduce(0) { $0 + $1.width * $1.height })
                return
            }
            let (w, h) = (panels[index][0], panels[index][1])
            for b in batches.indices {
                let saved = batches[b]
                batches[b] = (max(saved.width, w), max(saved.height, h))
                place(index + 1, cost)
                batches[b] = saved
            }
            batches.append((w, h))
            place(index + 1, cost)
            batches.removeLast()
        }
        place(0, 0)
        return panels.isEmpty ? 0 : best
    }

    /// The staircase of panels nothing covers, widths rising and heights falling
    private func staircase(_ panels: [[Int]]) -> (width: [Int], height: [Int]) {
        var width: [Int] = [], height: [Int] = []
        for panel in panels.sorted(by: { ($0[0], $0[1]) > ($1[0], $1[1]) }) where panel[1] > (height.last ?? 0) {
            width.append(panel[0])
            height.append(panel[1])
        }
        return (width.reversed(), height.reversed())
    }

    /// The batch DP on the staircase with every split tried: O(n²)
    private func quadratic(_ panels: [[Int]]) -> Int {
        let (width, height) = staircase(panels)
        let n = width.count
        var best = [Int](repeating: Int.max, count: n + 1)
        best[0] = 0
        for i in 1...max(n, 1) where i <= n {
            for j in 0..<i {
                best[i] = min(best[i], best[j] + width[i - 1] * height[j])
            }
        }
        return best[n]
    }

    /// The same DP with a Li Chao tree over the query widths: a different way to find the lowest line
    private func liChao(_ panels: [[Int]]) -> Int {
        let (width, height) = staircase(panels)
        let n = width.count
        if n == 0 { return 0 }
        var lineSlope = [Int](repeating: 0, count: 4 * n), lineIntercept = [Int](repeating: Int.max, count: 4 * n)
        var hasLine = [Bool](repeating: false, count: 4 * n)
        func at(_ m: Int, _ c: Int, _ i: Int) -> Int { m * width[i] + c }
        func insert(_ m: Int, _ c: Int) {
            var (node, lo, hi, m, c) = (1, 0, n - 1, m, c)
            while true {
                if !hasLine[node] {
                    (lineSlope[node], lineIntercept[node], hasLine[node]) = (m, c, true)
                    return
                }
                let mid = (lo + hi) / 2
                if at(m, c, mid) < at(lineSlope[node], lineIntercept[node], mid) {
                    swap(&m, &lineSlope[node])
                    swap(&c, &lineIntercept[node])
                }
                if lo == hi { return }
                if at(m, c, lo) < at(lineSlope[node], lineIntercept[node], lo) {
                    (node, hi) = (2 * node, mid)
                } else if at(m, c, hi) < at(lineSlope[node], lineIntercept[node], hi) {
                    (node, lo) = (2 * node + 1, mid + 1)
                } else {
                    return
                }
            }
        }
        func query(_ i: Int) -> Int {
            var (node, lo, hi, best) = (1, 0, n - 1, Int.max)
            while hasLine[node] {
                best = min(best, at(lineSlope[node], lineIntercept[node], i))
                if lo == hi { break }
                let mid = (lo + hi) / 2
                if i <= mid { (node, hi) = (2 * node, mid) } else { (node, lo) = (2 * node + 1, mid + 1) }
            }
            return best
        }
        var best = 0
        insert(height[0], 0)
        for i in 0..<n {
            best = query(i)
            if i + 1 < n { insert(height[i + 1], best) }
        }
        return best
    }

    @Test("Examples and small cases", arguments: [
        ([[100, 1], [15, 15], [20, 5], [1, 100]], 500),
        ([[3, 4]], 12),
        ([[2, 2], [1, 1], [2, 1], [1, 2]], 4),
        ([[5, 1], [1, 5]], 10),
        ([[4, 4], [4, 4], [4, 4]], 16),
        ([[14, 1], [6, 4], [1, 10], [10, 2], [3, 7]], 80),
        ([], 0),
    ] as [([[Int]], Int)])
    func examples(panels: [[Int]], expected: Int) {
        #expect(PanelBulkOrders.cheapestOrders(panels) == expected)
    }

    @Test("Matches every way to batch on 300 small random orders")
    func randomSmall() {
        var random = PanelRandom(seed: 58)
        for _ in 0..<300 {
            let panels = (0..<Int.random(in: 1...7, using: &random)).map { _ in
                [Int.random(in: 1...12, using: &random), Int.random(in: 1...12, using: &random)]
            }
            #expect(PanelBulkOrders.cheapestOrders(panels) == bruteForce(panels))
        }
    }

    @Test("Matches the O(n²) DP on 2,000 random panels")
    func randomMedium() {
        var random = PanelRandom(seed: 2_000)
        for _ in 0..<3 {
            let panels = (0..<2_000).map { _ in
                [Int.random(in: 1...1_000_000, using: &random), Int.random(in: 1...1_000_000, using: &random)]
            }
            #expect(PanelBulkOrders.cheapestOrders(panels) == quadratic(panels))
        }
    }

    @Test("50,000 panels that all lie on the staircase")
    func largeStaircase() {
        // Widths rise and heights fall, so no panel covers another and the DP sees all 50,000
        var random = PanelRandom(seed: 50_000)
        let n = 50_000
        var widths = Set<Int>(), heights = Set<Int>()
        while widths.count < n { widths.insert(Int.random(in: 1...1_000_000, using: &random)) }
        while heights.count < n { heights.insert(Int.random(in: 1...1_000_000, using: &random)) }
        let w = widths.sorted(), h = heights.sorted(by: >)
        let panels = (0..<n).map { [w[$0], h[$0]] }.shuffled(using: &random)
        #expect(PanelBulkOrders.cheapestOrders(panels) == liChao(panels))

        // Plus 20,000 covered panels mixed in, which change nothing
        let covered = (0..<20_000).map { i in [max(1, w[i * 2] - 1), max(1, h[i * 2] - 1)] }
        #expect(PanelBulkOrders.cheapestOrders((panels + covered).shuffled(using: &random)) == liChao(panels))
    }
}
