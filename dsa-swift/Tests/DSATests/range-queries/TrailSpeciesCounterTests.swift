import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same surveys
private struct TrailRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TrailSpeciesCounterTests {
    /// A set per segment: slow, but clearly right.
    private func reference(_ sightings: [Int], _ segment: [Int]) -> Int {
        Set(sightings[segment[0]...segment[1]]).count
    }

    @Test("Examples", arguments: [
        ([3, 1, 3, 2, 1, 3, 4, 2], [[0, 4], [5, 7], [1, 3], [2, 6], [0, 7]], [3, 3, 3, 4, 4]),
        ([900_000_000, 5, 900_000_000, 5], [[0, 3], [1, 2], [3, 3]], [2, 2, 1]),
        ([7, 7, 7, 7], [[0, 3], [2, 2]], [1, 1]),
        ([1, 2, 3], [], []),
        ([0], [[0, 0], [0, 0]], [1, 1]),
        ([1_000_000_000, 0, 1_000_000_000], [[0, 0], [0, 1], [0, 2], [1, 2]], [1, 2, 2, 2]),
    ] as [([Int], [[Int]], [Int])])
    func examples(sightings: [Int], segments: [[Int]], expected: [Int]) {
        #expect(TrailSpeciesCounter.distinctSpecies(sightings: sightings, segments: segments) == expected)
    }

    @Test("Random small surveys match a set per segment")
    func randomSmall() {
        var random = TrailRandom(seed: 62)
        for _ in 0..<300 {
            let n = Int.random(in: 1...30, using: &random)
            let speciesRange = Int.random(in: 1...8, using: &random)
            // A few huge ids among small ones, so uncompressed ids would need an enormous array
            let sightings = (0..<n).map { _ -> Int in
                let id = Int.random(in: 0..<speciesRange, using: &random)
                return id % 3 == 0 ? 1_000_000_000 - id : id
            }
            let segments = (0..<Int.random(in: 0...40, using: &random)).map { _ -> [Int] in
                let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
                return [min(a, b), max(a, b)]
            }
            let expected = segments.map { reference(sightings, $0) }
            let actual = TrailSpeciesCounter.distinctSpecies(sightings: sightings, segments: segments)
            if actual != expected {
                Issue.record("sightings \(sightings), segments \(segments): expected \(expected), got \(actual)")
                return
            }
        }
    }

    @Test("Repeated and identical segments get the same answers")
    func repeatedSegments() {
        let sightings = [5, 1, 5, 2, 2, 9, 1, 5]
        let segments = [[0, 7], [2, 4], [0, 7], [2, 4], [7, 7], [0, 0], [0, 7]]
        #expect(TrailSpeciesCounter.distinctSpecies(sightings: sightings, segments: segments) == [4, 2, 4, 2, 1, 1, 4])
    }

    @Test("30,000 points and 30,000 segments")
    func large() {
        var random = TrailRandom(seed: 2_026)
        let n = 30_000
        let sightings = (0..<n).map { _ in Int.random(in: 0..<2_000, using: &random) * 499_979 }
        let segments = (0..<30_000).map { _ -> [Int] in
            let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
            return [min(a, b), max(a, b)]
        }
        let answers = TrailSpeciesCounter.distinctSpecies(sightings: sightings, segments: segments)
        #expect(answers.count == segments.count)
        guard answers.count == segments.count else { return }
        for index in stride(from: 0, to: segments.count, by: 151) {
            #expect(answers[index] == reference(sightings, segments[index]))
        }
    }

    @Test("Every point a different species")
    func allDifferent() {
        let n = 20_000
        let sightings = (0..<n).map { $0 * 37 + 1_000 }
        var random = TrailRandom(seed: 9)
        let segments = (0..<20_000).map { _ -> [Int] in
            let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
            return [min(a, b), max(a, b)]
        }
        let expected = segments.map { $0[1] - $0[0] + 1 }
        #expect(TrailSpeciesCounter.distinctSpecies(sightings: sightings, segments: segments) == expected)
    }
}
