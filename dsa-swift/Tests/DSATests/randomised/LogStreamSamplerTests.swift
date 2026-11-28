import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64), so every run makes the same "random" choices
private struct SamplerRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite struct LogStreamSamplerTests {
    /// Samples `0..<n` with the given capacity, `runs` times, and returns each run's sample.
    private func samples(n: Int, capacity: Int, runs: Int, seed: UInt64) -> [[Int]] {
        var random = SamplerRandom(seed: seed)
        return (0..<runs).map { _ in
            let sampler = LogStreamSampler.Sampler<Int>(capacity: capacity)
            for item in 0..<n {
                sampler.offer(item, using: &random)
            }
            return sampler.sample
        }
    }

    @Test("Until the sample is full, it holds every item in order")
    func fillsInOrder() {
        var random = SamplerRandom(seed: 1)
        let sampler = LogStreamSampler.Sampler<String>(capacity: 3)
        #expect(sampler.seen == 0)
        #expect(sampler.sample == [])
        sampler.offer("a", using: &random)
        sampler.offer("b", using: &random)
        #expect(sampler.seen == 2)
        #expect(sampler.sample == ["a", "b"])
        sampler.offer("c", using: &random)
        #expect(sampler.sample == ["a", "b", "c"])
        sampler.offer("d", using: &random)
        #expect(sampler.seen == 4)
        #expect(sampler.sample.count == 3)
        #expect(Set(sampler.sample).isSubset(of: ["a", "b", "c", "d"]))
        #expect(sampler.capacity == 3)
    }

    @Test("Samples are distinct items from the stream, never more than the capacity")
    func validSamples() {
        for (n, capacity) in [(10, 3), (5, 5), (4, 7), (100, 1), (50, 49)] {
            for sample in samples(n: n, capacity: capacity, runs: 200, seed: UInt64(n * 31 + capacity)) {
                let valid = sample.count == min(n, capacity) && Set(sample).count == sample.count
                    && sample.allSatisfy { (0..<n).contains($0) }
                if !valid {
                    Issue.record("sampling 0..<\(n) with capacity \(capacity) gave \(sample)")
                    return
                }
            }
        }
    }

    @Test("Each of 10 items is sampled with probability 3/10")
    func uniformItems() {
        var counts = [Int](repeating: 0, count: 10)
        var bothEnds = 0
        for sample in samples(n: 10, capacity: 3, runs: 30_000, seed: 67) {
            for item in sample where (0..<10).contains(item) {
                counts[item] += 1
            }
            if sample.contains(0) && sample.contains(9) { bothEnds += 1 }
        }
        for (item, count) in counts.enumerated() {
            #expect(abs(count - 9_000) < 450, "item \(item) was sampled \(count) times; a fair sampler gives about 9,000")
        }
        // Every set of 3 is equally likely, so the first and last items are sampled together with
        // probability 8 / C(10, 3) = 1/15: about 2,000 times
        #expect(abs(bothEnds - 2_000) < 250, "items 0 and 9 were sampled together \(bothEnds) times; expected about 2,000")
    }

    @Test("With capacity 1, each item of a stream is equally likely")
    func capacityOne() {
        var counts = [Int](repeating: 0, count: 5)
        for sample in samples(n: 5, capacity: 1, runs: 50_000, seed: 15) {
            if let item = sample.first, (0..<5).contains(item) { counts[item] += 1 }
        }
        for (item, count) in counts.enumerated() {
            #expect(abs(count - 10_000) < 500, "item \(item) was picked \(count) times; a fair sampler gives about 10,000")
        }
    }

    @Test("Early and late parts of a long stream are sampled equally")
    func longStream() {
        var buckets = [Int](repeating: 0, count: 10)
        for sample in samples(n: 1_000, capacity: 10, runs: 1_000, seed: 2_026) {
            for item in sample where (0..<1_000).contains(item) {
                buckets[item / 100] += 1
            }
        }
        for (bucket, count) in buckets.enumerated() {
            #expect(abs(count - 1_000) < 180, "items \(bucket * 100)..<\(bucket * 100 + 100) were sampled \(count) times; expected about 1,000")
        }
    }

    @Test("The same seed gives the same sample")
    func reproducible() {
        let first = samples(n: 500, capacity: 20, runs: 1, seed: 99)[0]
        let second = samples(n: 500, capacity: 20, runs: 1, seed: 99)[0]
        let other = samples(n: 500, capacity: 20, runs: 1, seed: 100)[0]
        #expect(first == second)
        #expect(first != other)
    }

    @Test("300,000 offers keep exactly the capacity")
    func large() {
        var random = SamplerRandom(seed: 5)
        let sampler = LogStreamSampler.Sampler<Int>(capacity: 100)
        for item in 0..<300_000 {
            sampler.offer(item, using: &random)
        }
        #expect(sampler.seen == 300_000)
        #expect(sampler.sample.count == 100)
        #expect(Set(sampler.sample).count == 100)
        // Most of a fair sample comes from the bulk of the stream, not the first 100 items
        #expect(sampler.sample.filter { $0 < 100 }.count < 5)
    }
}
