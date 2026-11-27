import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ShiftGroupsTests {
    @Test("Groups shifted words in order of first appearance")
    func example() {
        let words = ["ace", "bdf", "az", "yz", "ba", "xzb", "q", "c"]
        #expect(ShiftGroups.groups(of: words) == [["ace", "bdf", "xzb"], ["az", "ba"], ["yz"], ["q", "c"]])
    }

    @Test("Shifting wraps from z back to a")
    func wraps() {
        #expect(ShiftGroups.groups(of: ["xyz", "abc", "zab"]) == [["xyz", "abc", "zab"]])
        #expect(ShiftGroups.groups(of: ["za", "ab", "yz"]) == [["za", "ab", "yz"]])
    }

    @Test("Words of different lengths never share a group")
    func lengths() {
        // "ab" and "abc" have the same gaps so far, but different lengths
        #expect(ShiftGroups.groups(of: ["ab", "abc", "bc", "bcd"]) == [["ab", "bc"], ["abc", "bcd"]])
        #expect(ShiftGroups.groups(of: ["a", "aa", "aaa", "b", "bb"]) == [["a", "b"], ["aa", "bb"], ["aaa"]])
    }

    @Test("Keeps duplicates, and handles empty and single inputs")
    func edgeCases() {
        #expect(ShiftGroups.groups(of: []) == [])
        #expect(ShiftGroups.groups(of: ["swift"]) == [["swift"]])
        #expect(ShiftGroups.groups(of: ["abc", "abc", "bcd"]) == [["abc", "abc", "bcd"]])
    }

    @Test("A gap of 13 isn't the same as a gap of -13 written backwards")
    func gapsAreDirected() {
        // "an": gap 13. "na": gap -13, which wraps to 13 too, so they are shifts of each other
        #expect(ShiftGroups.groups(of: ["an", "na"]) == [["an", "na"]])
        // "ab" (gap 1) and "ba" (gap 25) are not
        #expect(ShiftGroups.groups(of: ["ab", "ba"]) == [["ab"], ["ba"]])
    }

    @Test("Stays fast on 50,000 words")
    func large() throws {
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        // Word w shifts the pattern "adgk" (or "acf" for odd w) forward by w % 26
        let words = (0..<50_000).map { w -> String in
            let pattern = w.isMultiple(of: 2) ? [0, 3, 6, 10] : [0, 2, 5]
            return String(pattern.map { letters[($0 + w) % 26] })
        }
        let groups = ShiftGroups.groups(of: words)
        try #require(groups.count == 2)
        #expect(groups[0].count == 25_000)
        #expect(groups[1].count == 25_000)
        #expect(groups[0].first == "adgk")
        #expect(groups[1].first == "bdg")
        #expect(groups[1].last == words[49_999])
    }
}
