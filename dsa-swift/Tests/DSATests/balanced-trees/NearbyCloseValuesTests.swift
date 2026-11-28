import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NearbyCloseValuesTests {
    /// The obvious O(n · k) check, for comparing on small inputs.
    private func bruteForce(_ values: [Int], _ k: Int, _ t: Int) -> Bool {
        for i in values.indices {
            for j in (i + 1)..<min(values.count, i + k + 1) where abs(values[i] - values[j]) <= t {
                return true
            }
        }
        return false
    }

    @Test("Examples from the statement", arguments: [
        ([8, 3, 14, 6], 3, 2, true),
        ([8, 3, 14, 6], 2, 2, false),
        ([1, 9, 17, 25, 2], 3, 1, false),
        ([1, 9, 17, 25, 2], 4, 1, true),
        ([5, 5], 1, 0, true),
        ([4, -4, 4], 1, 7, false),
    ])
    func examples(values: [Int], k: Int, t: Int, expected: Bool) {
        #expect(NearbyCloseValues.exists(in: values, maxIndexGap: k, maxValueGap: t) == expected)
    }

    @Test("Too few values, or no room in the window")
    func edges() {
        #expect(NearbyCloseValues.exists(in: [], maxIndexGap: 3, maxValueGap: 3) == false)
        #expect(NearbyCloseValues.exists(in: [7], maxIndexGap: 3, maxValueGap: 3) == false)
        #expect(NearbyCloseValues.exists(in: [7, 7, 7], maxIndexGap: 0, maxValueGap: 5) == false)
    }

    @Test("t = 0 asks for a repeat within k places")
    func repeats() {
        #expect(NearbyCloseValues.exists(in: [1, 2, 3, 1], maxIndexGap: 3, maxValueGap: 0) == true)
        #expect(NearbyCloseValues.exists(in: [1, 2, 3, 1], maxIndexGap: 2, maxValueGap: 0) == false)
        #expect(NearbyCloseValues.exists(in: [1, 2, 3, 4], maxIndexGap: 3, maxValueGap: 0) == false)
    }

    @Test("Values at the ends of the allowed range")
    func extremes() {
        let big = 1_000_000_000
        #expect(NearbyCloseValues.exists(in: [-big, big], maxIndexGap: 1, maxValueGap: 2 * big) == true)
        #expect(NearbyCloseValues.exists(in: [-big, big], maxIndexGap: 1, maxValueGap: 2 * big - 1) == false)
        #expect(NearbyCloseValues.exists(in: [big, -big, big], maxIndexGap: 2, maxValueGap: 0) == true)
    }

    @Test("Matches the brute force on small random inputs")
    func againstBruteForce() {
        var state: UInt64 = 11
        func next(_ limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
        var wrong: [String] = []
        for _ in 0..<2_000 {
            let values = (0..<next(12)).map { _ in next(60) - 30 }
            let k = next(6)
            let t = next(6)
            if NearbyCloseValues.exists(in: values, maxIndexGap: k, maxValueGap: t) != bruteForce(values, k, t) {
                wrong.append("\(values), k \(k), t \(t)")
            }
        }
        #expect(wrong.isEmpty, "first failure: \(wrong.first ?? "")")
    }

    @Test("60,000 values with a window as wide as the array, too many for O(n · k)")
    func large() {
        let n = 60_000
        // Multiples of 10 in a scrambled order: every gap is at least 10
        let values = (0..<n).map { ($0 * 7_919) % n * 10 }
        #expect(NearbyCloseValues.exists(in: values, maxIndexGap: n, maxValueGap: 9) == false)
        #expect(NearbyCloseValues.exists(in: values, maxIndexGap: n, maxValueGap: 10) == true)

        // One close pair, 45,000 places apart
        var spaced = (0..<n).map { $0 * 10 }
        spaced[54_000] = spaced[9_000] + 3
        #expect(NearbyCloseValues.exists(in: spaced, maxIndexGap: 44_999, maxValueGap: 5) == false)
        #expect(NearbyCloseValues.exists(in: spaced, maxIndexGap: 45_000, maxValueGap: 5) == true)
    }
}
