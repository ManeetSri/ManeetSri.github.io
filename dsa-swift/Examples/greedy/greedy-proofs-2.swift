// Generated from src/dsa/content/lessons/greedy/greedy-proofs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A tiny seeded random number generator, so the tests are the same on every run
struct Seeded {
    var state: UInt64
    mutating func next(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

func overlap(_ a: [Int], _ b: [Int]) -> Bool {
    a[0] < b[1] && b[0] < a[1]                 // half-open: touching is fine
}

// The greedy: go through the intervals in the given order, keep each one that fits with all kept so far
func greedyCount(_ ordered: [[Int]]) -> Int {
    var kept: [[Int]] = []
    for interval in ordered where kept.allSatisfy({ !overlap($0, interval) }) {
        kept.append(interval)
    }
    return kept.count
}

// Try every subset and keep the largest with no overlapping pair
func bruteForce(_ intervals: [[Int]]) -> Int {
    var best = 0
    for mask in 0..<(1 << intervals.count) {
        let chosen = intervals.indices.filter { mask & (1 << $0) != 0 }.map { intervals[$0] }
        let fits = chosen.indices.allSatisfy { i in chosen.indices.allSatisfy { j in i == j || !overlap(chosen[i], chosen[j]) } }
        if fits { best = max(best, chosen.count) }
    }
    return best
}

func test(_ name: String, order: ([[Int]]) -> [[Int]]) {
    var random = Seeded(state: 50)
    for trial in 1...500 {
        let intervals = (0..<random.next(1...7)).map { _ -> [Int] in
            let start = random.next(0...9)
            return [start, start + random.next(1...5)]
        }
        let greedy = greedyCount(order(intervals))
        let best = bruteForce(intervals)
        if greedy != best {
            print("\(name): trial \(trial) fails on \(intervals): \(greedy) instead of \(best)")
            return
        }
    }
    print("\(name): agrees on all 500 inputs")
}

test("earliest end") { $0.sorted { $0[1] < $1[1] } }
test("earliest start") { $0.sorted { $0[0] < $1[0] } }
test("shortest first") { $0.sorted { $0[1] - $0[0] < $1[1] - $1[0] } }
