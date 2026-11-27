import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GradeBandsTests {
    @Test("Plain grades", arguments: [
        (90, "A"), (95, "A"), (100, "A"),
        (80, "B"), (84, "B"), (86, "B"),
        (70, "C"), (73, "C"),
        (60, "D"), (66, "D"),
        (0, "F"), (45, "F"), (59, "F"),
    ])
    func plain(score: Int, expected: String) {
        #expect(GradeBands.grade(for: score) == expected)
    }

    @Test("A plus when the score ends in 7, 8 or 9", arguments: [
        (87, "B+"), (88, "B+"), (89, "B+"),
        (77, "C+"), (79, "C+"),
        (67, "D+"), (69, "D+"),
    ])
    func plus(score: Int, expected: String) {
        #expect(GradeBands.grade(for: score) == expected)
    }

    @Test("No plus on A or F", arguments: [(97, "A"), (99, "A"), (57, "F"), (9, "F")])
    func noPlus(score: Int, expected: String) {
        #expect(GradeBands.grade(for: score) == expected)
    }

    @Test("Scores outside 0 to 100 are invalid", arguments: [-1, -50, 101, 150, 1_000])
    func invalid(score: Int) {
        #expect(GradeBands.grade(for: score) == "Invalid")
    }
}
