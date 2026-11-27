import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same operations
private struct GaugeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RainGaugeBlocksTests {
    @Test("The first example")
    func firstExample() {
        let gauges = RainGaugeBlocks.Gauges(readings: [4, 8, 1, 7, 3, 9, 2, 6, 5, 0])
        #expect(gauges.total(1, 8) == 41)
        #expect(gauges.heaviest(1, 8) == 9)
        gauges.set(5, to: 20)
        #expect(gauges.total(1, 8) == 52)
        #expect(gauges.heaviest(0, 4) == 8)
        #expect(gauges.heaviest(4, 9) == 20)
        gauges.set(5, to: 1)
        #expect(gauges.heaviest(4, 9) == 6, "lowering the block's largest reading must lower its maximum")
        #expect(gauges.total(0, 9) == 45 - 9 + 1)
    }

    @Test("Small rows")
    func small() {
        let three = RainGaugeBlocks.Gauges(readings: [3, 3, 3])
        three.set(1, to: 0)
        #expect(three.total(0, 2) == 6)
        #expect(three.heaviest(1, 1) == 0)
        #expect(three.heaviest(0, 2) == 3)

        let one = RainGaugeBlocks.Gauges(readings: [12])
        #expect(one.heaviest(0, 0) == 12)
        one.set(0, to: 5)
        #expect(one.total(0, 0) == 5)
        #expect(one.heaviest(0, 0) == 5)
    }

    @Test("The short last block", arguments: [10, 11, 15, 17, 26])
    func shortLastBlock(n: Int) {
        let gauges = RainGaugeBlocks.Gauges(readings: Array(0..<n))
        #expect(gauges.total(0, n - 1) == n * (n - 1) / 2)
        #expect(gauges.heaviest(n - 2, n - 1) == n - 1)
        gauges.set(n - 1, to: 0)
        #expect(gauges.heaviest(0, n - 1) == n - 2)
        #expect(gauges.heaviest(n - 1, n - 1) == 0)
        #expect(gauges.total(n - 3, n - 1) == (n - 3) + (n - 2))
    }

    @Test("Random operations match a plain array, for many sizes")
    func randomSmall() {
        var random = GaugeRandom(seed: 62)
        for n in 1...40 {
            var model = (0..<n).map { _ in Int.random(in: 0...100, using: &random) }
            let gauges = RainGaugeBlocks.Gauges(readings: model)
            for _ in 0..<150 {
                let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
                let left = min(a, b), right = max(a, b)
                switch Int.random(in: 0..<3, using: &random) {
                case 0:
                    let reading = Int.random(in: 0...100, using: &random)
                    model[a] = reading
                    gauges.set(a, to: reading)
                case 1:
                    let expected = model[left...right].reduce(0, +)
                    let actual = gauges.total(left, right)
                    if actual != expected {
                        Issue.record("n = \(n), total(\(left), \(right)): expected \(expected), got \(actual)")
                        return
                    }
                default:
                    let expected = model[left...right].max()!
                    let actual = gauges.heaviest(left, right)
                    if actual != expected {
                        Issue.record("n = \(n), heaviest(\(left), \(right)): expected \(expected), got \(actual)")
                        return
                    }
                }
            }
        }
    }

    @Test("20,000 gauges and 20,000 operations")
    func large() {
        var random = GaugeRandom(seed: 2_026)
        let n = 20_000
        var model = (0..<n).map { _ in Int.random(in: 0...1_000_000, using: &random) }
        let gauges = RainGaugeBlocks.Gauges(readings: model)
        var checked = 0
        for step in 0..<20_000 {
            if step % 3 == 0 {
                let index = Int.random(in: 0..<n, using: &random)
                // Mostly lower readings, so block maximums often have to be found again
                let reading = Int.random(in: 0...(step % 2 == 0 ? 1_000 : 1_000_000), using: &random)
                model[index] = reading
                gauges.set(index, to: reading)
            } else {
                let left = Int.random(in: 0..<(n / 8), using: &random)
                let right = Int.random(in: (n - n / 8)..<n, using: &random)
                let total = gauges.total(left, right)
                let heaviest = gauges.heaviest(left, right)
                if step % 101 == 1 {                          // check a sample against the plain array
                    let expectedTotal = model[left...right].reduce(0, +)
                    let expectedHeaviest = model[left...right].max()!
                    if total != expectedTotal || heaviest != expectedHeaviest {
                        Issue.record("step \(step), \(left)...\(right): expected total \(expectedTotal) and heaviest \(expectedHeaviest), got \(total) and \(heaviest)")
                        return
                    }
                    checked += 1
                }
            }
        }
        #expect(checked > 50)
        #expect(gauges.total(0, n - 1) == model.reduce(0, +))
        #expect(gauges.heaviest(0, n - 1) == model.max()!)
    }
}
