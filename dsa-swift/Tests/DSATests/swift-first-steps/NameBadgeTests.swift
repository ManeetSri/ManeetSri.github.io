import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NameBadgeTests {
    @Test("Boxes a short name")
    func shortName() {
        #expect(NameBadge.badge(for: "Ada") == "+-----+\n| Ada |\n+-----+")
    }

    @Test("The border grows with the name", arguments: [
        ("X", "+---+\n| X |\n+---+"),
        ("Maneet", "+--------+\n| Maneet |\n+--------+"),
        ("Ada Lovelace", "+--------------+\n| Ada Lovelace |\n+--------------+"),
    ])
    func borderMatchesName(name: String, expected: String) {
        #expect(NameBadge.badge(for: name) == expected)
    }

    @Test("An empty name still gets a box")
    func emptyName() {
        #expect(NameBadge.badge(for: "") == "+--+\n|  |\n+--+")
    }

    @Test("Every line has the same width")
    func linesLineUp() {
        let lines = NameBadge.badge(for: "Grace Hopper").split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines.count == 3)
        #expect(lines.allSatisfy { $0.count == "Grace Hopper".count + 4 })
    }
}
