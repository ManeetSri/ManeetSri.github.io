import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NumberPyramidTests {
    @Test("Height 3")
    func heightThree() {
        #expect(NumberPyramid.rows(3) == ["..1..", ".121.", "12321"])
    }

    @Test("Height 1 is a single 1")
    func heightOne() {
        #expect(NumberPyramid.rows(1) == ["1"])
    }

    @Test("Height 2")
    func heightTwo() {
        #expect(NumberPyramid.rows(2) == [".1.", "121"])
    }

    @Test("Height 0 has no rows")
    func heightZero() {
        #expect(NumberPyramid.rows(0) == [])
    }

    @Test("Height 5")
    func heightFive() {
        #expect(NumberPyramid.rows(5) == [
            "....1....",
            "...121...",
            "..12321..",
            ".1234321.",
            "123454321",
        ])
    }

    @Test("Every row is 2 × height − 1 characters wide", arguments: 1...9)
    func widths(height: Int) {
        let rows = NumberPyramid.rows(height)
        #expect(rows.count == height)
        #expect(rows.allSatisfy { $0.count == 2 * height - 1 })
    }

    @Test("The tallest pyramid ends with the full climb")
    func heightNine() {
        let rows = NumberPyramid.rows(9)
        #expect(rows.first == "........1........")
        #expect(rows.last == "12345678987654321")
    }
}
