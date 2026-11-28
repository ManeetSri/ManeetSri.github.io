import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RotatedArraySearchTests {
    static let sample = [40, 50, 60, 70, 10, 20, 30]

    @Test("Finds values on both sides of the break", arguments: [
        (10, 4), (40, 0), (70, 3), (30, 6), (50, 1), (20, 5),
    ])
    func finds(target: Int, expected: Int) {
        #expect(RotatedArraySearch.index(of: target, in: Self.sample) == expected)
    }

    @Test("Missing values give nil", arguments: [5, 15, 35, 45, 75, 0, 100])
    func missing(target: Int) {
        #expect(RotatedArraySearch.index(of: target, in: Self.sample) == nil)
    }

    @Test("Not rotated at all, and rotated by one less than the length")
    func extremesOfRotation() {
        let sorted = [1, 4, 6, 9, 12]
        #expect(RotatedArraySearch.index(of: 9, in: sorted) == 3)
        #expect(RotatedArraySearch.index(of: 5, in: sorted) == nil)
        let almost = [12, 1, 4, 6, 9]
        #expect(RotatedArraySearch.index(of: 12, in: almost) == 0)
        #expect(RotatedArraySearch.index(of: 1, in: almost) == 1)
        #expect(RotatedArraySearch.index(of: 9, in: almost) == 4)
    }

    @Test("Empty, one and two values")
    func tiny() {
        #expect(RotatedArraySearch.index(of: 1, in: []) == nil)
        #expect(RotatedArraySearch.index(of: 1, in: [1]) == 0)
        #expect(RotatedArraySearch.index(of: 2, in: [1]) == nil)
        #expect(RotatedArraySearch.index(of: 1, in: [3, 1]) == 1)
        #expect(RotatedArraySearch.index(of: 3, in: [3, 1]) == 0)
        #expect(RotatedArraySearch.index(of: 2, in: [3, 1]) == nil)
    }

    @Test("Negative values")
    func negatives() {
        let numbers = [5, 9, -8, -3, 0]
        #expect(RotatedArraySearch.index(of: -3, in: numbers) == 3)
        #expect(RotatedArraySearch.index(of: 9, in: numbers) == 1)
        #expect(RotatedArraySearch.index(of: -1, in: numbers) == nil)
    }

    @Test("Every rotation of every size up to 10")
    func exhaustive() {
        var firstMismatch: String? = nil
        for count in 0...10 {
            let sorted = (0..<count).map { $0 * 2 }
            for shift in 0..<Swift.max(count, 1) {
                let rotated = Array(sorted[shift...] + sorted[..<shift])
                for target in -1...(2 * count) {
                    if RotatedArraySearch.index(of: target, in: rotated) != rotated.firstIndex(of: target) {
                        firstMismatch = firstMismatch ?? "target \(target) in \(rotated)"
                    }
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer is wrong")
    }

    @Test("10,000 searches in a million values, with the break in 2,000 places")
    func large() {
        let n = 1_000_000
        // With the smallest value at index p, numbers[i] is i for i ≥ p and n + i for i < p:
        // the sorted values p, p + 1, …, n + p - 1, rotated. Moving p on by one changes one element.
        var numbers = Array(0..<n)
        var wrong = 0
        for p in 0..<n {
            if p > 0 {
                numbers[p - 1] = n + p - 1
            }
            guard p % 500 == 0 else { continue }
            var queries: [(target: Int, expected: Int?)] = [(p, p), (p - 1, nil), (n + p, nil), (n - 1, n - 1)]
            if p > 0 {
                queries.append((n, 0))
                queries.append((n + p - 1, p - 1))
            }
            for (target, expected) in queries where RotatedArraySearch.index(of: target, in: numbers) != expected {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
