import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GenericPicksTests {
    private struct Height: Comparable, Hashable {
        var centimetres: Int

        static func < (lhs: Height, rhs: Height) -> Bool {
            lhs.centimetres < rhs.centimetres
        }
    }

    @Test("largest works with numbers, text and characters")
    func largestBuiltIn() {
        #expect(GenericPicks.largest([3, 9, 4]) == 9)
        #expect(GenericPicks.largest([-5, -2, -8]) == -2)
        #expect(GenericPicks.largest([2.5, -1.0, 2.25]) == 2.5)
        #expect(GenericPicks.largest(["pear", "apple", "zucchini"]) == "zucchini")
        #expect(GenericPicks.largest(Array("swift")) == "w")
    }

    @Test("largest works with your own Comparable type")
    func largestCustom() {
        let heights = [Height(centimetres: 150), Height(centimetres: 182), Height(centimetres: 170)]
        #expect(GenericPicks.largest(heights) == Height(centimetres: 182))
    }

    @Test("largest of one item and of no items")
    func largestEdges() {
        #expect(GenericPicks.largest([7]) == 7)
        #expect(GenericPicks.largest([Int]()) == nil)
        #expect(GenericPicks.largest([String]()) == nil)
    }

    @Test("mostFrequent finds the commonest value")
    func mostFrequent() {
        #expect(GenericPicks.mostFrequent([1, 3, 3, 2, 1, 3]) == 3)
        #expect(GenericPicks.mostFrequent(["cat", "dog", "dog"]) == "dog")
        #expect(GenericPicks.mostFrequent([false, true, true]) == true)
        #expect(GenericPicks.mostFrequent([7]) == 7)
    }

    @Test("Ties go to the value that appears first")
    func mostFrequentTies() {
        #expect(GenericPicks.mostFrequent(["b", "a", "a", "b"]) == "b")
        #expect(GenericPicks.mostFrequent([4, 5, 6]) == 4)
        #expect(GenericPicks.mostFrequent(Array("mississippi")) == "i")
        #expect(GenericPicks.mostFrequent([2, 1, 1, 2, 3, 3]) == 2)
    }

    @Test("mostFrequent works with your own Hashable type")
    func mostFrequentCustom() {
        let heights = [Height(centimetres: 160), Height(centimetres: 175), Height(centimetres: 175)]
        #expect(GenericPicks.mostFrequent(heights) == Height(centimetres: 175))
    }

    @Test("mostFrequent of no items is nil")
    func mostFrequentEmpty() {
        #expect(GenericPicks.mostFrequent([Int]()) == nil)
    }

    @Test("Stays fast on 100,000 items")
    func large() {
        let numbers = (0..<100_000).map { $0 % 1_000 } + [999]
        #expect(GenericPicks.largest(numbers) == 999)
        #expect(GenericPicks.mostFrequent(numbers) == 999)
    }
}
