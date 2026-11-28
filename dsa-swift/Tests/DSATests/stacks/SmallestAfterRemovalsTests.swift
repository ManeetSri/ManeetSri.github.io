import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SmallestAfterRemovalsTests {
    @Test("Leaves the smallest number", arguments: [
        ("4721", 1, "421"),
        ("4721", 2, "21"),
        ("1593", 2, "13"),
        ("10200", 1, "200"),
        ("123456", 3, "123"),
        ("987", 1, "87"),
        ("5337", 2, "33"),
        ("112", 1, "11"),
    ])
    func smallest(digits: String, k: Int, expected: String) {
        #expect(SmallestAfterRemovals.smallest(digits, removing: k) == expected)
    }

    @Test("Removing nothing keeps the number, minus leading zeros")
    func removeNothing() {
        #expect(SmallestAfterRemovals.smallest("2024", removing: 0) == "2024")
        #expect(SmallestAfterRemovals.smallest("0042", removing: 0) == "42")
    }

    @Test("Gives 0 when everything, or everything but zeros, is removed")
    func zero() {
        #expect(SmallestAfterRemovals.smallest("9", removing: 1) == "0")
        #expect(SmallestAfterRemovals.smallest("345", removing: 3) == "0")
        #expect(SmallestAfterRemovals.smallest("100", removing: 1) == "0")
        #expect(SmallestAfterRemovals.smallest("0000", removing: 2) == "0")
    }

    @Test("Matches trying every choice on small inputs")
    func matchesBruteForce() {
        // Tries every set of k positions to remove, keeping the smallest result
        func bruteForce(_ digits: String, _ k: Int) -> String {
            let characters = Array(digits)
            var best: String? = nil
            for mask in 0..<(1 << characters.count) where mask.nonzeroBitCount == k {
                let kept = characters.indices.filter { mask & (1 << $0) == 0 }.map { characters[$0] }
                let trimmed = String(kept.drop { $0 == "0" })
                let candidate = trimmed.isEmpty ? "0" : trimmed
                if best == nil || (candidate.count, candidate) < (best!.count, best!) {
                    best = candidate
                }
            }
            return best!
        }
        var firstMismatch: String? = nil
        for seed in 0..<300 {
            let length = seed % 8 + 1
            let digits = String((0..<length).map { Character(String(($0 * 7 + seed * 3) % 10)) })
            let k = seed % (length + 1)
            if SmallestAfterRemovals.smallest(digits, removing: k) != bruteForce(digits, k) {
                firstMismatch = firstMismatch ?? "\(digits) removing \(k)"
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("Stays fast on 100,000 digits")
    func large() {
        // 987654321 repeated, then a 0. Keeping 10 digits: the best is nine of the 1s, then the 0
        let digits = String(repeating: "987654321", count: 11_111) + "0"
        #expect(SmallestAfterRemovals.smallest(digits, removing: 99_990) == "1111111110")
        // 123456789 repeated: the 1s starting the second and third blocks pull out the 9 digits
        let rising = String(repeating: "123456789", count: 11_111)
        let result = SmallestAfterRemovals.smallest(rising, removing: 9)
        #expect(result.count == 99_990)
        #expect(result.hasPrefix("112345678123456789"))
    }
}
