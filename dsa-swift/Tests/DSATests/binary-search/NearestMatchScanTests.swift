import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The answer worked out the slow way: every match, then the smallest (distance, index) pair.
private func slowNearest(_ target: Int, _ items: [Int], _ start: Int) -> Int? {
    items.indices.filter { items[$0] == target }.min { (abs($0 - start), $0) < (abs($1 - start), $1) }
}

@Suite struct NearestMatchScanTests {
    @Test("The examples", arguments: [
        ([4, 7, 1, 7, 9, 4, 7], 7, 4, 3 as Int?),
        ([4, 7, 1, 7, 9, 4, 7], 4, 3, 5),
        ([4, 7, 1, 7, 9, 4, 7], 9, 4, 4),
        ([2, 5, 2], 2, 1, 0),
        ([3, 3, 3], 8, 0, nil),
    ])
    func examples(items: [Int], target: Int, start: Int, expected: Int?) {
        #expect(NearestMatchScan.nearestIndex(of: target, in: items, from: start) == expected)
    }

    @Test("Starting at either end")
    func ends() {
        let items = [5, 1, 2, 3, 5]
        #expect(NearestMatchScan.nearestIndex(of: 5, in: items, from: 0) == 0)
        #expect(NearestMatchScan.nearestIndex(of: 3, in: items, from: 0) == 3)
        #expect(NearestMatchScan.nearestIndex(of: 1, in: items, from: 4) == 1)
        #expect(NearestMatchScan.nearestIndex(of: 5, in: items, from: 2) == 0)    // tie: 0 and 4
        #expect(NearestMatchScan.nearestIndex(of: 9, in: items, from: 4) == nil)
    }

    @Test("A single frame")
    func single() {
        #expect(NearestMatchScan.nearestIndex(of: -3, in: [-3], from: 0) == 0)
        #expect(NearestMatchScan.nearestIndex(of: 3, in: [-3], from: 0) == nil)
    }

    @Test("The only match is far away on one side")
    func lopsided() {
        let items = Array(repeating: 0, count: 50) + [Int.min] + Array(repeating: 0, count: 10)
        #expect(NearestMatchScan.nearestIndex(of: Int.min, in: items, from: 59) == 50)
        #expect(NearestMatchScan.nearestIndex(of: Int.min, in: items, from: 0) == 50)
        #expect(NearestMatchScan.nearestIndex(of: Int.max, in: items, from: 30) == nil)
    }

    @Test("Matches the slow answer on many small arrays, from every start")
    func manySmall() {
        var state: UInt64 = 28
        var failures: [String] = []
        for _ in 0..<400 {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            let count = Int(state >> 33) % 12 + 1
            var items: [Int] = []
            for _ in 0..<count {
                state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
                items.append(Int(state >> 33) % 4)
            }
            for start in items.indices {
                for target in 0...4 {
                    let expected = slowNearest(target, items, start)
                    let actual = NearestMatchScan.nearestIndex(of: target, in: items, from: start)
                    if actual != expected && failures.count < 3 {
                        failures.append("target \(target) from \(start) in \(items): got \(String(describing: actual)), expected \(String(describing: expected))")
                    }
                }
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("2,000 searches near the playhead in a million frames")
    func large() {
        let n = 1_000_000
        // Frame i has label i % 1,000, so every label appears every 1,000 frames
        let items = (0..<n).map { $0 % 1_000 }
        var wrong = 0
        for q in 0..<2_000 {
            let start = 3 + (q * 7_919) % (n - 6)                // at least 3 frames from either end
            let target = (start + q % 7 - 3 + 1_000) % 1_000      // a label at most 3 frames away
            let expected = slowNearestWindow(target, items, start)
            if NearestMatchScan.nearestIndex(of: target, in: items, from: start) != expected {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }

    /// The slow answer, but only looking within 3 frames: enough for the large test's targets.
    private func slowNearestWindow(_ target: Int, _ items: [Int], _ start: Int) -> Int? {
        let window = max(0, start - 3)...min(items.count - 1, start + 3)
        return window.filter { items[$0] == target }.min { (abs($0 - start), $0) < (abs($1 - start), $1) }
    }
}
