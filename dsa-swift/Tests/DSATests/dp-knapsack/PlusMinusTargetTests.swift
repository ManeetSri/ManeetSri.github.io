import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SignsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PlusMinusTargetTests {
    private let mod = 1_000_000_007

    /// Brute force: try every sign pattern (bit i set gives numbers[i] a plus sign)
    private func bruteForce(_ numbers: [Int], _ target: Int) -> Int {
        var count = 0
        for mask in 0..<(1 << numbers.count) {
            var value = 0
            for i in numbers.indices {
                value += mask & (1 << i) != 0 ? numbers[i] : -numbers[i]
            }
            if value == target { count += 1 }
        }
        return count
    }

    /// Pascal's triangle modulo 1,000,000,007: choose[n][k] = C(n, k)
    private func pascal(_ size: Int) -> [[Int]] {
        var choose = Array(repeating: Array(repeating: 0, count: size + 1), count: size + 1)
        for n in 0...size {
            choose[n][0] = 1
            for k in stride(from: 1, through: n, by: 1) {
                choose[n][k] = (choose[n - 1][k - 1] + choose[n - 1][k]) % mod
            }
        }
        return choose
    }

    @Test("Examples and edge cases", arguments: [
        ([1, 1, 2, 3], 1, 3),
        ([1, 1, 2, 3], 7, 1),
        ([1, 1, 2, 3], 2, 0),
        ([0, 0, 1], 1, 4),
        ([4, 1, 2], -3, 1),
        ([5], 5, 1),
        ([5], -5, 1),
        ([5], 0, 0),
        ([0], 0, 2),
        ([3, 3], 0, 2),
        ([2, 3, 5], 11, 0),
        ([1, 2, 3, 4], 0, 2),
    ] as [([Int], Int, Int)])
    func examples(numbers: [Int], target: Int, expected: Int) {
        #expect(PlusMinusTarget.ways(numbers, target: target) == expected)
    }

    @Test("Matches brute force on 300 small random lists, including zeros and negative targets")
    func randomSmall() {
        var random = SignsRandom(seed: 494)
        for _ in 0..<300 {
            let n = Int.random(in: 1...12, using: &random)
            let numbers = (0..<n).map { _ in Int.random(in: 0...9, using: &random) }
            let total = numbers.reduce(0, +)
            let target = Int.random(in: -(total + 2)...(total + 2), using: &random)
            #expect(PlusMinusTarget.ways(numbers, target: target) == bruteForce(numbers, target), "\(numbers), target \(target)")
        }
    }

    @Test("200 ones: the answer is a binomial coefficient, modulo 1,000,000,007")
    func ones() {
        let choose = pascal(200)
        let ones = Array(repeating: 1, count: 200)
        for target in [0, 2, -50, 198, 200, -200] {
            #expect(PlusMinusTarget.ways(ones, target: target) == choose[200][(200 + target) / 2], "target \(target)")
        }
        #expect(PlusMinusTarget.ways(ones, target: 201) == 0)
        #expect(PlusMinusTarget.ways(ones, target: 202) == 0)
        #expect(PlusMinusTarget.ways(ones, target: 1) == 0)
    }

    @Test("Zeros double the count, many times over")
    func zeros() {
        let choose = pascal(100)
        var powerOfTwo = 1
        for _ in 0..<30 {
            powerOfTwo = powerOfTwo * 2 % mod
        }
        let numbers = Array(repeating: 1, count: 100) + Array(repeating: 0, count: 30)
        #expect(PlusMinusTarget.ways(numbers, target: 10) == choose[100][55] * powerOfTwo % mod)
        #expect(PlusMinusTarget.ways(Array(repeating: 0, count: 30), target: 0) == powerOfTwo)
    }

    @Test("Two values, many copies: an independent count")
    func twoValues() {
        // a copies of x and b copies of y. Giving i of the x's and j of the y's a plus sign makes
        // x(2i - a) + y(2j - b), and there are C(a, i) × C(b, j) such patterns.
        let choose = pascal(120)
        let (x, a, y, b) = (37, 80, 100, 120)
        let numbers = Array(repeating: x, count: a) + Array(repeating: y, count: b)
        for target in [0, 63, 1_000, -2_960, 14_960, 15_000] {
            var expected = 0
            for i in 0...a {
                for j in 0...b where x * (2 * i - a) + y * (2 * j - b) == target {
                    expected = (expected + choose[a][i] * choose[b][j]) % mod
                }
            }
            #expect(PlusMinusTarget.ways(numbers, target: target) == expected, "target \(target)")
        }
    }
}
