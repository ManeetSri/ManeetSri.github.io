import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NearbyRepeatTests {
    @Test("Finds a repeat close enough", arguments: [
        ([4, 1, 7, 4], 3),
        ([4, 1, 7, 4], 10),
        ([2, 2], 1),
        ([9, 5, 3, 5, 9], 2),
        ([1, 2, 3, 1, 2, 3, 3], 1),
        ([-6, 0, -6], 2),
    ])
    func finds(values: [Int], distance: Int) {
        #expect(NearbyRepeat.hasRepeat(in: values, within: distance))
    }

    @Test("Says no when every repeat is too far apart, or there are none", arguments: [
        ([4, 1, 7, 4], 2),
        ([1, 2, 3, 1, 2, 3], 2),
        ([5, 5], 0),
        ([1, 2, 3, 4], 100),
        ([Int](), 3),
        ([8], 1),
    ])
    func rejects(values: [Int], distance: Int) {
        #expect(!NearbyRepeat.hasRepeat(in: values, within: distance))
    }

    @Test("Compares against the nearest earlier copy, not the first one")
    func nearestCopy() {
        // The two 7s at positions 0 and 5 are too far apart, but 5 and 7 are close
        #expect(NearbyRepeat.hasRepeat(in: [7, 1, 2, 3, 4, 7, 9, 7], within: 2))
        #expect(!NearbyRepeat.hasRepeat(in: [7, 1, 2, 3, 4, 7, 9, 8, 7], within: 2))
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        func bruteForce(_ values: [Int], _ distance: Int) -> Bool {
            for j in values.indices {
                for i in 0..<j where values[i] == values[j] && j - i <= distance {
                    return true
                }
            }
            return false
        }
        var mismatches = 0
        for seed in 0..<500 {
            let values = (0..<(seed % 11)).map { ($0 * 3 + seed * 7) % 6 }
            let distance = seed % 5
            if NearbyRepeat.hasRepeat(in: values, within: distance) != bruteForce(values, distance) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays fast on 100,000 values with a huge distance")
    func large() {
        let distinct = Array(0..<100_000)
        #expect(!NearbyRepeat.hasRepeat(in: distinct, within: 100_000))
        #expect(NearbyRepeat.hasRepeat(in: distinct + [0], within: 100_000))
        #expect(!NearbyRepeat.hasRepeat(in: distinct + [0], within: 99_999))
    }
}
