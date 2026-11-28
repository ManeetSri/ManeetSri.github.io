import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run replays the same traces
private struct TraceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CachePolicyReplayTests {
    typealias Policy = CachePolicyReplay.Policy

    /// Keeps the cached ids in an array and searches it on every request: slow, but clearly right.
    private func reference(_ trace: [Int], _ capacity: Int, _ policy: Policy) -> Int {
        var cached: [Int] = []                   // FIFO: arrival order; LRU: least recent first
        var uses: [Int: Int] = [:]
        var lastUse: [Int: Int] = [:]
        var hits = 0
        for (time, id) in trace.enumerated() {
            if let index = cached.firstIndex(of: id) {
                hits += 1
                if policy == .lru {
                    cached.remove(at: index)
                    cached.append(id)
                }
            } else {
                if cached.count == capacity {
                    var victim = 0
                    if policy == .lfu {
                        victim = cached.indices.min {
                            (uses[cached[$0]]!, lastUse[cached[$0]]!) < (uses[cached[$1]]!, lastUse[cached[$1]]!)
                        }!
                    }
                    uses[cached[victim]] = nil
                    cached.remove(at: victim)
                }
                cached.append(id)
            }
            uses[id, default: 0] += 1
            lastUse[id] = time
        }
        return hits
    }

    /// A skewed trace: a few popular ids, many rare ones, and popularity that drifts over time.
    private func skewedTrace(count: Int, ids: Int, seed: UInt64) -> [Int] {
        var random = TraceRandom(seed: seed)
        return (0..<count).map { step in
            let drift = step / max(1, count / 8) * (ids / 16)
            if Int.random(in: 0..<10, using: &random) < 7 {
                return (drift + Int.random(in: 0..<max(1, ids / 20), using: &random)) % ids   // popular now
            }
            return Int.random(in: 0..<ids, using: &random)                                       // anything
        }
    }

    @Test("Examples", arguments: [
        ([1, 2, 3, 1, 2, 4, 1, 2, 5, 1, 2, 6, 1, 3, 1, 2], 3, [5, 8, 9]),
        ([1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4], 3, [0, 0, 0]),
        ([1, 1, 1, 1, 2, 2, 2, 2, 3, 4, 3, 4, 3, 4, 3, 4], 3, [12, 12, 6]),
        ([1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5], 3, [3, 2, 2]),
        ([1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5], 4, [2, 4, 4]),
        ([], 2, [0, 0, 0]),
        ([7, 7, 7], 1, [2, 2, 2]),
        ([1, 2, 1, 2, 1, 2], 1, [0, 0, 0]),
        ([1_000_000_000, 0, 1_000_000_000, 0], 2, [2, 2, 2]),
    ] as [([Int], Int, [Int])])
    func examples(trace: [Int], capacity: Int, expected: [Int]) {
        for (policy, hits) in zip(Policy.allCases, expected) {
            #expect(CachePolicyReplay.hits(trace: trace, capacity: capacity, policy: policy) == hits, "\(policy)")
        }
    }

    @Test("LFU forgets an evicted id's count")
    func lfuForgets() {
        // With capacity 2: 1 is requested three times, then evicted by 3 (2 has four requests). When 1
        // comes back its count restarts at 1, so the next miss evicts 1 again and 2 stays, making the
        // final request for 2 a hit. If 1 had kept its old count, it would tie with 2 at four requests
        // and 2, the less recent, would have been evicted instead.
        let trace = [1, 1, 1, 2, 2, 2, 2, 3, 1, 3, 3, 2]
        #expect(CachePolicyReplay.hits(trace: trace, capacity: 2, policy: .lfu) == 7)
    }

    @Test("A cache big enough for every id only misses the first request for each")
    func bigCache() {
        let trace = skewedTrace(count: 5_000, ids: 300, seed: 1)
        let distinct = Set(trace).count
        for policy in Policy.allCases {
            #expect(CachePolicyReplay.hits(trace: trace, capacity: 300, policy: policy) == trace.count - distinct)
        }
    }

    @Test("Random small traces match the array simulation, for every policy")
    func randomSmall() {
        var random = TraceRandom(seed: 67)
        for _ in 0..<400 {
            let ids = Int.random(in: 1...8, using: &random)
            let trace = (0..<Int.random(in: 0...40, using: &random)).map { _ in Int.random(in: 0..<ids, using: &random) }
            let capacity = Int.random(in: 1...5, using: &random)
            for policy in Policy.allCases {
                let expected = reference(trace, capacity, policy)
                let actual = CachePolicyReplay.hits(trace: trace, capacity: capacity, policy: policy)
                if actual != expected {
                    Issue.record("\(policy), capacity \(capacity), trace \(trace): expected \(expected), got \(actual)")
                    return
                }
            }
        }
    }

    @Test("A medium skewed trace matches the array simulation")
    func medium() {
        let trace = skewedTrace(count: 10_000, ids: 1_500, seed: 2_026)
        for policy in Policy.allCases {
            #expect(CachePolicyReplay.hits(trace: trace, capacity: 100, policy: policy) == reference(trace, 100, policy), "\(policy)")
        }
    }

    @Test("Loops: one id too many defeats every policy; exactly enough room hits after the first pass")
    func loops() {
        let capacity = 2_000
        let tooBig = (0..<50_000).map { $0 % (capacity + 1) }
        let fits = (0..<50_000).map { $0 % capacity }
        for policy in Policy.allCases {
            #expect(CachePolicyReplay.hits(trace: tooBig, capacity: capacity, policy: policy) == 0, "\(policy)")
            #expect(CachePolicyReplay.hits(trace: fits, capacity: capacity, policy: policy) == 50_000 - capacity, "\(policy)")
        }
    }

    @Test("100,000 skewed requests through a cache of 2,000")
    func large() {
        let trace = skewedTrace(count: 100_000, ids: 30_000, seed: 99)
        // Computed once with the array simulation (in a release build: it takes minutes in a debug one).
        // Popularity drifts, so LFU's old counts work against it.
        let expected: [Policy: Int] = [.fifo: 44_363, .lru: 50_521, .lfu: 11_871]
        for policy in Policy.allCases {
            #expect(CachePolicyReplay.hits(trace: trace, capacity: 2_000, policy: policy) == expected[policy], "\(policy)")
        }
    }
}
