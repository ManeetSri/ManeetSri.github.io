import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The statement's row hash, written out independently.
private func column(_ tag: String, _ row: Int, _ width: Int) -> Int {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for byte in tag.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 0x0000_0100_0000_01B3
    }
    var z = hash &+ UInt64(row)
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return Int((z ^ (z >> 31)) % UInt64(width))
}

/// A plain count-min model: a grid of counters, updated the obvious way.
private struct Model {
    let width: Int
    let depth: Int
    var grid: [[Int]]

    init(width: Int, depth: Int) {
        self.width = width
        self.depth = depth
        grid = Array(repeating: Array(repeating: 0, count: width), count: depth)
    }

    mutating func add(_ tag: String, _ count: Int = 1) {
        for row in 0..<depth {
            grid[row][column(tag, row, width)] += count
        }
    }

    func estimate(_ tag: String) -> Int {
        (0..<depth).map { grid[$0][column(tag, $0, width)] }.min()!
    }
}

/// A deterministic stream: some popular tags and a long tail.
private func makeStream(length: Int, popular: [(String, Int)], tail: Int, seed: UInt64) -> [String] {
    var stream: [String] = []
    for (tag, count) in popular {
        stream += Array(repeating: tag, count: count)
    }
    var state = seed
    func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state >> 33
    }
    while stream.count < length {
        stream.append("tag\(next() % UInt64(tail))")
    }
    for i in stream.indices.reversed() {
        stream.swapAt(i, Int(next() % UInt64(i + 1)))
    }
    return stream
}

@Suite struct TrendingTagsSketchTests {
    @Test("column(of:row:width:) is the given helper")
    func helper() {
        for tag in ["swift", "ios", "", "🙂"] {
            for row in 0..<4 {
                #expect(TrendingTagsSketch.column(of: tag, row: row, width: 97) == column(tag, row, 97))
            }
        }
    }

    @Test("A new sketch is all zeros")
    func empty() {
        let sketch = TrendingTagsSketch.Sketch(width: 8, depth: 3)
        #expect(sketch.total == 0)
        #expect(sketch.estimate("anything") == 0)
        #expect((0..<3).allSatisfy { row in (0..<8).allSatisfy { sketch.counter(row: row, column: $0) == 0 } })
    }

    @Test("Each add increments one counter per row")
    func countersMatch() {
        var sketch = TrendingTagsSketch.Sketch(width: 11, depth: 4)
        var model = Model(width: 11, depth: 4)
        for (i, tag) in ["swift", "ios", "swift", "xcode", "wwdc", "swift", "ios"].enumerated() {
            sketch.add(tag, count: i + 1)
            model.add(tag, i + 1)
        }
        #expect(sketch.total == 28)
        for row in 0..<4 {
            for c in 0..<11 where sketch.counter(row: row, column: c) != model.grid[row][c] {
                Issue.record("counter(row: \(row), column: \(c)) is \(sketch.counter(row: row, column: c)), expected \(model.grid[row][c])")
            }
        }
    }

    @Test("Estimates are the row minimum: never below the true count")
    func neverUnder() {
        let stream = makeStream(length: 20_000, popular: [("swift", 900), ("ios", 400)], tail: 3_000, seed: 7)
        var sketch = TrendingTagsSketch.Sketch(width: 300, depth: 4)
        var model = Model(width: 300, depth: 4)
        var exact: [String: Int] = [:]
        for tag in stream {
            sketch.add(tag)
            model.add(tag)
            exact[tag, default: 0] += 1
        }
        for (tag, count) in exact {
            let estimate = sketch.estimate(tag)
            if estimate < count || estimate != model.estimate(tag) {
                Issue.record("estimate(\(tag)) is \(estimate); true count \(count), expected \(model.estimate(tag))")
                return
            }
        }
        #expect(sketch.estimate("never-seen") == model.estimate("never-seen"))
        #expect(sketch.total == 20_000)
    }

    @Test("Heavy hitters: reported once, the moment the estimate reaches the threshold")
    func heavyHittersSmall() {
        // Width 1 makes every tag share one counter, so the estimate is the stream position
        #expect(TrendingTagsSketch.heavyHitters(in: ["a", "b", "c", "a", "d"], width: 1, depth: 2, threshold: 3) == ["c", "a", "d"])
        // A wide sketch counts these few tags exactly
        #expect(TrendingTagsSketch.heavyHitters(in: ["x", "y", "x", "z", "y", "x"], width: 1_000, depth: 4, threshold: 2) == ["x", "y"])
        #expect(TrendingTagsSketch.heavyHitters(in: [], width: 10, depth: 2, threshold: 1) == [])
        #expect(TrendingTagsSketch.heavyHitters(in: ["solo"], width: 10, depth: 2, threshold: 1) == ["solo"])
    }

    @Test("Heavy hitters match the model and include every truly frequent tag", arguments: [(64, 3), (272, 5), (1_000, 2)])
    func heavyHittersModel(width: Int, depth: Int) {
        let stream = makeStream(length: 10_000, popular: [("swift", 1_200), ("ios", 900), ("wwdc", 600), ("xcode", 300), ("swiftui", 150)],
                                tail: 5_000, seed: UInt64(width))
        let threshold = 200
        var model = Model(width: width, depth: depth)
        var expected: [String] = []
        var exact: [String: Int] = [:]
        for tag in stream {
            model.add(tag)
            exact[tag, default: 0] += 1
            if model.estimate(tag) >= threshold && !expected.contains(tag) {
                expected.append(tag)
            }
        }
        let result = TrendingTagsSketch.heavyHitters(in: stream, width: width, depth: depth, threshold: threshold)
        #expect(result == expected)
        for (tag, count) in exact where count >= threshold {
            #expect(result.contains(tag), "\(tag) appears \(count) times, so it must be reported")
        }
    }

    @Test("Merging two sketches gives the sketch of both streams")
    func merge() {
        let first = makeStream(length: 3_000, popular: [("a", 300)], tail: 500, seed: 1)
        let second = makeStream(length: 2_000, popular: [("b", 250)], tail: 500, seed: 2)
        var left = TrendingTagsSketch.Sketch(width: 50, depth: 3)
        var right = TrendingTagsSketch.Sketch(width: 50, depth: 3)
        var both = TrendingTagsSketch.Sketch(width: 50, depth: 3)
        first.forEach { left.add($0) }
        second.forEach { right.add($0) }
        (first + second).forEach { both.add($0) }
        left.merge(right)
        #expect(left.total == 5_000)
        for row in 0..<3 {
            for c in 0..<50 where left.counter(row: row, column: c) != both.counter(row: row, column: c) {
                Issue.record("merged counter(row: \(row), column: \(c)) is wrong")
            }
        }
        #expect(left.estimate("a") == both.estimate("a"))
    }

    @Test("200,000 tags with a small sketch")
    func large() {
        let stream = makeStream(length: 200_000, popular: [("swift", 9_000), ("ios", 6_000), ("visionos", 2_500), ("watchos", 1_200)],
                                tail: 50_000, seed: 99)
        let result = TrendingTagsSketch.heavyHitters(in: stream, width: 2_000, depth: 5, threshold: 1_000)
        #expect(result.sorted() == ["ios", "swift", "visionos", "watchos"])
        var sketch = TrendingTagsSketch.Sketch(width: 2_000, depth: 5)
        stream.forEach { sketch.add($0) }
        #expect(sketch.estimate("swift") >= 9_000)
        #expect(sketch.estimate("swift") <= 9_000 + 200_000 / 100, "within 1% of the stream, comfortably")
        #expect(sketch.total == 200_000)
    }
}
