import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FencePostCountTests {
    @Test("A straight fence has one more post than metres", arguments: [
        (1, 2),
        (3, 4),
        (10, 11),
        (250, 251),
    ])
    func straight(metres: Int, expected: Int) {
        #expect(FencePostCount.straight(metres: metres) == expected)
    }

    @Test("A closed pen has as many posts as metres round", arguments: [
        (1, 1, 4),
        (3, 2, 10),
        (2, 3, 10),
        (5, 5, 20),
        (10, 1, 22),
    ])
    func closedPen(length: Int, width: Int, expected: Int) {
        #expect(FencePostCount.closedPen(length: length, width: width) == expected)
    }

    @Test("A pen doesn't get the straight fence's extra post")
    func penHasNoExtraPost() {
        // Four straight sides of 1 metre would need 2 posts each, but the corners are shared.
        #expect(FencePostCount.closedPen(length: 1, width: 1) == 4)
        #expect(FencePostCount.closedPen(length: 1, width: 1) != 4 * FencePostCount.straight(metres: 1))
    }

    @Test("Handles the longest fences allowed")
    func longest() {
        #expect(FencePostCount.straight(metres: 1_000_000) == 1_000_001)
        #expect(FencePostCount.closedPen(length: 1_000_000, width: 1_000_000) == 4_000_000)
    }
}
