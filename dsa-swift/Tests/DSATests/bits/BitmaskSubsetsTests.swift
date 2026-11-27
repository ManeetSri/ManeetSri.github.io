import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BitmaskSubsetsTests {
    @Test("Lists subsets in mask order", arguments: [
        ([7, 8], [[], [7], [8], [7, 8]]),
        ([1, 2, 3], [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]),
        ([4], [[], [4]]),
        ([-1, 0], [[], [-1], [0], [-1, 0]]),
    ])
    func maskOrder(items: [Int], expected: [[Int]]) {
        #expect(BitmaskSubsets.subsets(of: items) == expected)
    }

    @Test("An empty array has one subset: the empty one")
    func empty() {
        #expect(BitmaskSubsets.subsets(of: []) == [[]])
    }

    @Test("Repeated values are separate positions")
    func duplicates() {
        #expect(BitmaskSubsets.subsets(of: [5, 5]) == [[], [5], [5], [5, 5]])
    }

    @Test("There are 2ⁿ subsets", arguments: 0...10)
    func count(n: Int) {
        #expect(BitmaskSubsets.subsets(of: Array(0..<n)).count == 1 << n)
    }

    @Test("All 65,536 subsets of 16 items match their masks")
    func sixteenItems() {
        let items = Array(100..<116)
        let result = BitmaskSubsets.subsets(of: items)
        #expect(result.count == 1 << 16)
        var firstWrongMask: Int? = nil
        for (mask, subset) in result.enumerated() {
            let expected = items.indices.filter { mask & (1 << $0) != 0 }.map { items[$0] }
            if subset != expected {
                firstWrongMask = firstWrongMask ?? mask
            }
        }
        #expect(firstWrongMask == nil, "the first mask whose subset is wrong")
    }
}
