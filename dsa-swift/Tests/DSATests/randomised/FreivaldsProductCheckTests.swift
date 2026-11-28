import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64), so every run makes the same "random" choices
private struct SpotCheckRandom: RandomNumberGenerator {
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

@Suite struct FreivaldsProductCheckTests {
    private let a = [[2, 0, 1], [1, 3, 0], [0, 1, 4]]
    private let b = [[1, 2, 0], [0, 1, 1], [3, 0, 2]]
    private let product = [[5, 4, 2], [1, 5, 3], [12, 1, 9]]

    private func multiply(_ x: [[Int]], _ y: [[Int]]) -> [[Int]] {
        let n = x.count
        var result = Array(repeating: Array(repeating: 0, count: n), count: n)
        for i in 0..<n {
            for k in 0..<n where x[i][k] != 0 {
                for j in 0..<n {
                    result[i][j] += x[i][k] * y[k][j]
                }
            }
        }
        return result
    }

    private func times(_ m: [[Int]], _ v: [Int]) -> [Int] {
        m.map { row in zip(row, v).reduce(0) { $0 + $1.0 * $1.1 } }
    }

    /// Whether `r` really proves A × B ≠ C
    private func isWitness(_ r: [Int], _ a: [[Int]], _ b: [[Int]], _ c: [[Int]]) -> Bool {
        r.count == a.count && r.allSatisfy { $0 == 0 || $0 == 1 } && times(a, times(b, r)) != times(c, r)
    }

    @Test("The examples")
    func examples() {
        var random = SpotCheckRandom(seed: 99)
        #expect(FreivaldsProductCheck.findWitness(a, b, product, trials: 20, using: &random) == nil)
        var wrong = product
        wrong[1][2] = 4
        let witness = FreivaldsProductCheck.findWitness(a, b, wrong, trials: 20, using: &random)
        #expect(witness.map { isWitness($0, a, b, wrong) } == true, "expected a real witness, got \(String(describing: witness))")
        #expect(witness.flatMap { $0.count == 3 ? $0[2] : nil } == 1, "only vectors with a 1 in position 2 expose this error")
        #expect(FreivaldsProductCheck.findWitness(a, b, wrong, trials: 0, using: &random) == nil)
    }

    @Test("A correct product is never rejected", arguments: [1, 2, 3, 4, 5])
    func neverRejectsCorrect(seed: UInt64) {
        var random = SpotCheckRandom(seed: seed)
        var data = SpotCheckRandom(seed: seed * 31)
        for _ in 0..<20 {
            let n = Int.random(in: 1...12, using: &data)
            let x = (0..<n).map { _ in (0..<n).map { _ in Int.random(in: -1_000...1_000, using: &data) } }
            let y = (0..<n).map { _ in (0..<n).map { _ in Int.random(in: -1_000...1_000, using: &data) } }
            #expect(FreivaldsProductCheck.findWitness(x, y, multiply(x, y), trials: 30, using: &random) == nil)
        }
    }

    @Test("Wrong products are caught, with a real witness")
    func catchesWrong() {
        var random = SpotCheckRandom(seed: 7)
        var data = SpotCheckRandom(seed: 8)
        for trial in 0..<40 {
            let n = Int.random(in: 1...10, using: &data)
            let x = (0..<n).map { _ in (0..<n).map { _ in Int.random(in: -9...9, using: &data) } }
            let y = (0..<n).map { _ in (0..<n).map { _ in Int.random(in: -9...9, using: &data) } }
            var c = multiply(x, y)
            c[Int.random(in: 0..<n, using: &data)][Int.random(in: 0..<n, using: &data)] += trial.isMultiple(of: 2) ? 1 : -1_000
            let witness = FreivaldsProductCheck.findWitness(x, y, c, trials: 50, using: &random)
            #expect(witness.map { isWitness($0, x, y, c) } == true, "trial \(trial)")
        }
    }

    @Test("Errors that an all-ones vector would miss are still caught")
    func cancellingErrors() {
        let identity = [[1, 0], [0, 1]]
        let m = [[3, 4], [5, 6]]
        // The errors in row 0 cancel for r = [1, 1], so a fixed all-ones check passes them
        let wrong = [[4, 3], [5, 6]]
        var random = SpotCheckRandom(seed: 11)
        let witness = FreivaldsProductCheck.findWitness(identity, m, wrong, trials: 40, using: &random)
        #expect(witness.map { isWitness($0, identity, m, wrong) } == true)
    }

    @Test("One trial catches a one-entry error about half the time")
    func singleTrialRate() {
        var wrong = product
        wrong[1][2] = 4
        var random = SpotCheckRandom(seed: 2_026)
        var caught = 0
        var vectors = Set<[Int]>()
        for _ in 0..<2_000 {
            if let witness = FreivaldsProductCheck.findWitness(a, b, wrong, trials: 1, using: &random) {
                if isWitness(witness, a, b, wrong) { caught += 1 }
                vectors.insert(witness)
            }
        }
        #expect(caught > 850 && caught < 1_150, "caught \(caught) of 2,000; a random vector catches it about 1,000 times")
        #expect(vectors.count == 4, "the four vectors with a 1 in position 2 should all appear as witnesses")
    }

    @Test("300 × 300 matrices")
    func large() {
        var data = SpotCheckRandom(seed: 300)
        let n = 300
        let x = (0..<n).map { _ in (0..<n).map { _ in Int.random(in: -1_000...1_000, using: &data) } }
        // B moves column π(j) of the identity to column j and scales it, so A × B is quick to write down:
        // column j of the product is column π(j) of A, times scale[j]
        let permutation = Array(0..<n).shuffled(using: &data)
        let scale = (0..<n).map { _ in Int.random(in: -1_000...1_000, using: &data) }
        var y = Array(repeating: Array(repeating: 0, count: n), count: n)
        for j in 0..<n {
            y[permutation[j]][j] = scale[j]
        }
        let correct = x.map { row in (0..<n).map { j in row[permutation[j]] * scale[j] } }
        var random = SpotCheckRandom(seed: 301)
        #expect(FreivaldsProductCheck.findWitness(x, y, correct, trials: 10, using: &random) == nil)
        var wrong = correct
        wrong[n - 1][n - 1] += 1
        let witness = FreivaldsProductCheck.findWitness(x, y, wrong, trials: 40, using: &random)
        #expect(witness.map { isWitness($0, x, y, wrong) } == true)
    }
}
