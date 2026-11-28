import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TemplateRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct TemplateQueryRunnerTests {
    private func run(_ text: String) -> String {
        TemplateQueryRunner.run(Array(text.utf8))
    }

    @Test("The examples")
    func examples() {
        #expect(run("5 3\n4 -2 7 1 10\n1 3\n2 5\n4 4\n") == "9\n16\n1\n")
        #expect(run("1 2\n-1000000000\n1 1\n1 1\n") == "-1000000000\n-1000000000\n")
        #expect(run("3 0\n1 2 3\n") == "")
    }

    @Test("Any whitespace separates tokens, and the last line may lack a newline")
    func untidyInput() {
        #expect(run("4\t2\r\n  1 2\n\n3\t4\r\n1 4\r\n 2   3") == "10\n5\n")
        #expect(run("  2 1 5 6 1 2") == "11\n")
    }

    @Test("Negative values and sums that cancel")
    func negatives() {
        #expect(run("6 4\n-5 5 -5 5 -5 5\n1 6\n1 5\n2 2\n3 6\n") == "0\n-5\n5\n0\n")
    }

    @Test("200,000 values and 200,000 queries")
    func large() {
        var random = TemplateRandom(seed: 6_900)
        let n = 200_000
        let q = 200_000
        let values = (0..<n).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        var prefix = [0]
        for value in values {
            prefix.append(prefix[prefix.count - 1] + value)
        }
        var queries = (0..<q).map { _ in
            let a = Int.random(in: 1...n, using: &random)
            let b = Int.random(in: 1...n, using: &random)
            return (min(a, b), max(a, b))
        }
        queries.append((1, n))          // the whole range
        var input = "\(n) \(queries.count)\n" + values.map(String.init).joined(separator: " ") + "\n"
        var expected = ""
        for (left, right) in queries {
            input += "\(left) \(right)\n"
            expected += "\(prefix[right] - prefix[left - 1])\n"
        }
        #expect(TemplateQueryRunner.run(Array(input.utf8)) == expected)
    }
}
