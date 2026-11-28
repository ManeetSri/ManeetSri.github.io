import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct ChainRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CheapestMatrixBracketingTests {
    /// Reads a bracketing such as "((A1 A2) A3)" and returns what it costs, or nil if it isn't a full
    /// bracketing of A1, A2, … in order, written with single spaces and no other characters.
    private func cost(of text: String, dims: [Int]) -> Int? {
        let characters = Array(text)
        var position = 0
        var nextMatrix = 1

        func parse() -> (rows: Int, cols: Int, cost: Int)? {
            guard position < characters.count else { return nil }
            if characters[position] == "(" {
                position += 1
                guard let left = parse(), position < characters.count, characters[position] == " " else { return nil }
                position += 1
                guard let right = parse(), position < characters.count, characters[position] == ")" else { return nil }
                position += 1
                guard left.cols == right.rows else { return nil }
                return (left.rows, right.cols, left.cost + right.cost + left.rows * left.cols * right.cols)
            }
            guard characters[position] == "A" else { return nil }
            position += 1
            var digits = ""
            while position < characters.count, characters[position].isNumber {
                digits.append(characters[position])
                position += 1
            }
            guard let index = Int(digits), index == nextMatrix, index < dims.count else { return nil }
            nextMatrix += 1
            return (dims[index - 1], dims[index], 0)
        }

        guard let product = parse(), position == characters.count, nextMatrix == dims.count else { return nil }
        return product.cost
    }

    /// Tries every bracketing by recursion. Exponential, so only for short chains.
    private func bruteForce(_ dims: [Int], _ i: Int, _ j: Int) -> Int {
        if i == j { return 0 }
        var best = Int.max
        for k in i..<j {
            best = min(best, bruteForce(dims, i, k) + bruteForce(dims, k + 1, j) + dims[i] * dims[k + 1] * dims[j + 1])
        }
        return best
    }

    /// The same recurrence, top-down with a memo, for long chains
    private func reference(_ dims: [Int]) -> Int {
        let n = dims.count - 1
        var memo = Array(repeating: Array(repeating: -1, count: n), count: n)
        func best(_ i: Int, _ j: Int) -> Int {
            if i == j { return 0 }
            if memo[i][j] >= 0 { return memo[i][j] }
            var answer = Int.max
            for k in i..<j {
                answer = min(answer, best(i, k) + best(k + 1, j) + dims[i] * dims[k + 1] * dims[j + 1])
            }
            memo[i][j] = answer
            return answer
        }
        return best(0, n - 1)
    }

    @Test("Examples", arguments: [
        ([10, 30, 5, 60], 4_500),
        ([10, 30, 5, 60, 10], 5_000),
        ([40, 20, 30, 10, 30], 26_000),
        ([5, 10, 2, 8], 180),
        ([2, 3, 4], 24),
        ([7, 3], 0),
    ] as [([Int], Int)])
    func examples(dims: [Int], expected: Int) {
        #expect(CheapestMatrixBracketing.minimumCost(dims: dims) == expected)
        #expect(cost(of: CheapestMatrixBracketing.bracketing(dims: dims), dims: dims) == expected)
    }

    @Test("Bracketings with only one cheapest answer", arguments: [
        ([10, 30, 5, 60], "((A1 A2) A3)"),
        ([10, 30, 5, 60, 10], "((A1 A2) (A3 A4))"),
        ([2, 3, 4], "(A1 A2)"),
        ([7, 3], "A1"),
    ] as [([Int], String)])
    func exactBracketing(dims: [Int], expected: String) {
        #expect(CheapestMatrixBracketing.bracketing(dims: dims) == expected)
    }

    @Test("Matches brute force on 300 short chains")
    func randomSmall() {
        var random = ChainRandom(seed: 56)
        for _ in 0..<300 {
            let dims = (0...Int.random(in: 1...8, using: &random)).map { _ in Int.random(in: 1...20, using: &random) }
            let expected = bruteForce(dims, 0, dims.count - 2)
            #expect(CheapestMatrixBracketing.minimumCost(dims: dims) == expected, "dims: \(dims)")
            #expect(cost(of: CheapestMatrixBracketing.bracketing(dims: dims), dims: dims) == expected, "dims: \(dims)")
        }
    }

    @Test("160 matrices")
    func large() {
        var random = ChainRandom(seed: 300)
        let dims = (0...160).map { _ in Int.random(in: 1...100, using: &random) }
        let expected = reference(dims)
        #expect(CheapestMatrixBracketing.minimumCost(dims: dims) == expected)
        #expect(cost(of: CheapestMatrixBracketing.bracketing(dims: dims), dims: dims) == expected)

        // Equal sizes: every bracketing costs the same, (n - 1) multiplications of 7 · 7 · 7
        let square = Array(repeating: 7, count: 161)
        #expect(CheapestMatrixBracketing.minimumCost(dims: square) == 159 * 343)
        #expect(cost(of: CheapestMatrixBracketing.bracketing(dims: square), dims: square) == 159 * 343)
    }
}
