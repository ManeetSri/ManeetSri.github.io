import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UnrolledRecursionsTests {
    // The recursions from the statement, safe for small inputs only
    static func recursiveSurvivor(_ n: Int, _ k: Int) -> Int {
        if n == 1 {
            return 0
        }
        return (recursiveSurvivor(n - 1, k) + k) % n
    }

    static func recursiveHops(_ jumps: [Int], from position: Int, count: Int) -> Int {
        if position >= jumps.count {
            return count
        }
        return recursiveHops(jumps, from: position + jumps[position], count: count + 1)
    }

    // Removes every k-th person from a real circle, for checking small cases
    static func simulatedSurvivor(_ n: Int, _ k: Int) -> Int {
        var circle = Array(0..<n)
        var index = 0
        while circle.count > 1 {
            index = (index + k - 1) % circle.count
            circle.remove(at: index)
        }
        return circle[0]
    }

    @Test("Survivor examples", arguments: [(5, 2, 2), (7, 3, 3), (1, 9, 0), (2, 1, 1), (2, 2, 0), (41, 3, 30), (10, 10, 7)])
    func survivorExamples(n: Int, k: Int, expected: Int) {
        #expect(UnrolledRecursions.survivor(people: n, step: k) == expected)
    }

    @Test("Survivor matches the recursion and a real circle for small n")
    func survivorMatches() {
        var wrong: [String] = []
        for n in 1...60 {
            for k in 1...12 {
                let answer = UnrolledRecursions.survivor(people: n, step: k)
                if answer != Self.recursiveSurvivor(n, k) || answer != Self.simulatedSurvivor(n, k) {
                    wrong.append("n \(n), k \(k)")
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("Survivor for a million people")
    func survivorDeep() {
        #expect(UnrolledRecursions.survivor(people: 1_000_000, step: 1) == 999_999)
        #expect(UnrolledRecursions.survivor(people: 1_000_000, step: 2) == 951_424)
        #expect(UnrolledRecursions.survivor(people: 1_000_000, step: 3) == 637_797)
        #expect(UnrolledRecursions.survivor(people: 1_000_000, step: 1_000_000_000) == 642_254)
    }

    @Test("Hops examples")
    func hopsExamples() {
        #expect(UnrolledRecursions.hops([2, 3, 1, 1, 4]) == 4)
        #expect(UnrolledRecursions.hops([5]) == 1)
        #expect(UnrolledRecursions.hops([]) == 0)
        #expect(UnrolledRecursions.hops([1, 1, 1]) == 3)
        #expect(UnrolledRecursions.hops([3, 9, 9, 1]) == 2)
        #expect(UnrolledRecursions.hops([1_000_000_000, 1]) == 1)
    }

    @Test("Hops match the recursion on many small arrays")
    func hopsMatch() {
        var seed = 7
        for length in 0...80 {
            let jumps = (0..<length).map { _ -> Int in
                seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
                return 1 + seed % 4
            }
            #expect(UnrolledRecursions.hops(jumps) == Self.recursiveHops(jumps, from: 0, count: 0), "jumps \(jumps)")
        }
    }

    @Test("Hops along a million-long array")
    func hopsDeep() {
        #expect(UnrolledRecursions.hops(Array(repeating: 1, count: 1_000_000)) == 1_000_000)
        #expect(UnrolledRecursions.hops(Array(repeating: 2, count: 1_000_000)) == 500_000)
        let mixed = (0..<1_000_000).map { $0 % 3 == 0 ? 1 : 2 }
        // from a multiple of 3, jump 1 to 3m + 1, then 2 to 3m + 3: two hops per three positions
        #expect(UnrolledRecursions.hops(mixed) == 666_667)
    }
}
