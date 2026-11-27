import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64), so every run makes the same "random" choices
private struct CoverRandom: RandomNumberGenerator {
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

@Suite struct CircleCoverEstimateTests {
    /// The standard error the theory predicts for a true area inside a box of area `box`
    private func theoreticalError(area: Double, box: Double, samples: Int) -> Double {
        let p = area / box
        return box * (p * (1 - p) / Double(samples)).squareRoot()
    }

    /// Checks an estimate against the true area: within 5 standard errors, with a standard error
    /// within 10% of the theory
    private func check(_ circles: [[Double]], area: Double, box: Double, samples: Int, seed: UInt64) {
        var random = CoverRandom(seed: seed)
        let result = CircleCoverEstimate.estimate(circles: circles, samples: samples, using: &random)
        let expectedError = theoreticalError(area: area, box: box, samples: samples)
        #expect(abs(result.standardError - expectedError) < 0.1 * expectedError,
                "standard error \(result.standardError), theory says \(expectedError)")
        #expect(abs(result.area - area) < 5 * expectedError,
                "estimate \(result.area) is more than 5 standard errors from \(area)")
    }

    @Test("One circle: about π")
    func unitCircle() {
        check([[0, 0, 1]], area: Double.pi, box: 4, samples: 200_000, seed: 1)
    }

    @Test("Two overlapping circles: 2π minus their lens")
    func lens() {
        let lens = 2 * Double.pi / 3 - 3.0.squareRoot() / 2
        check([[0, 0, 1], [1, 0, 1]], area: 2 * Double.pi - lens, box: 6, samples: 200_000, seed: 2)
    }

    @Test("A circle inside another counts once")
    func nested() {
        check([[0, 0, 2], [0.5, 0, 0.5]], area: 4 * Double.pi, box: 16, samples: 100_000, seed: 3)
    }

    @Test("Far-apart circles: a big, mostly empty box")
    func farApart() {
        // Two unit circles 10 apart: the box is 12 × 2
        check([[0, 0, 1], [10, 0, 1]], area: 2 * Double.pi, box: 24, samples: 200_000, seed: 4)
        // Three circles of different sizes, none touching
        let area = Double.pi * (4 + 1 + 0.25)
        check([[-5, -5, 2], [5, 5, 1], [0, 0, 0.5]], area: area, box: 13 * 13, samples: 300_000, seed: 5)
    }

    @Test("No circles, or no samples")
    func empty() {
        var random = CoverRandom(seed: 6)
        let none = CircleCoverEstimate.estimate(circles: [], samples: 1_000, using: &random)
        #expect(none.area == 0 && none.standardError == 0)
        let zero = CircleCoverEstimate.estimate(circles: [[0, 0, 1]], samples: 0, using: &random)
        #expect(zero.area == 0 && zero.standardError == 0)
    }

    @Test("The same seed gives the same estimate; another seed gives another")
    func reproducible() {
        let circles: [[Double]] = [[0, 0, 1], [1, 1, 1], [-1, 0.5, 0.7]]
        var first = CoverRandom(seed: 42)
        var second = CoverRandom(seed: 42)
        var other = CoverRandom(seed: 43)
        let a = CircleCoverEstimate.estimate(circles: circles, samples: 50_000, using: &first)
        let b = CircleCoverEstimate.estimate(circles: circles, samples: 50_000, using: &second)
        let c = CircleCoverEstimate.estimate(circles: circles, samples: 50_000, using: &other)
        #expect(a.area == b.area && a.standardError == b.standardError)
        #expect(a.area != c.area)
    }

    @Test("Four times the samples halves the standard error")
    func errorShrinks() {
        let circles: [[Double]] = [[0, 0, 3], [2, 1, 2]]
        var random = CoverRandom(seed: 9)
        let small = CircleCoverEstimate.estimate(circles: circles, samples: 100_000, using: &random)
        let large = CircleCoverEstimate.estimate(circles: circles, samples: 400_000, using: &random)
        #expect(small.standardError > 0)
        #expect(abs(large.standardError / small.standardError - 0.5) < 0.05)
        #expect(abs(large.area - small.area) < 5 * small.standardError)
    }
}
