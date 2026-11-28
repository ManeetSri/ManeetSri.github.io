import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RumourSpreadTests {
    @Test("Counts the minutes until everyone knows", arguments: [
        (["KUU", "UU.", ".UU"], 4),
        (["KU", "UU"], 2),
        (["UUK", "U.U", "UUU"], 4),
        (["KUUUK"], 2),
        (["K", "U", "U", "U"], 3),
        (["UUUUU", "UUKUU", "UUUUU"], 3),
        (["K.K", "UUU", "K.K"], 2),
    ])
    func spreads(seating: [String], expected: Int) {
        #expect(RumourSpread.minutesUntilEveryoneKnows(seating) == expected)
    }

    @Test("Returns 0 when nobody is unaware", arguments: [
        ["KK", "K."],
        ["...", "..."],
        ["K"],
        [String](),
    ])
    func nothingToDo(seating: [String]) {
        #expect(RumourSpread.minutesUntilEveryoneKnows(seating) == 0)
    }

    @Test("Returns -1 when someone never hears", arguments: [
        ["K.U"],
        ["UU", "UU"],
        ["KU.", "...", "..U"],
        ["U"],
    ])
    func neverHears(seating: [String]) {
        #expect(RumourSpread.minutesUntilEveryoneKnows(seating) == -1)
    }

    @Test("Rumours from several people spread at the same time")
    func severalSources() {
        // Alone, the first K would need 6 minutes; with both, the rumour meets in the middle
        #expect(RumourSpread.minutesUntilEveryoneKnows(["KUUUUUK"]) == 3)
        #expect(RumourSpread.minutesUntilEveryoneKnows(["KUUUUUU", "UUUUUUK"]) == 3)
    }

    @Test("Empty desks force a detour")
    func detour() {
        let seating = [
            "KU.UU",
            ".U.U.",
            ".UUU.",
        ]
        // K → (0,1) → (1,1) → (2,1) → (2,2) → (2,3) → (1,3) → (0,3) → (0,4)
        #expect(RumourSpread.minutesUntilEveryoneKnows(seating) == 8)
    }

    @Test("Stays fast on a 300 × 300 office")
    func large() {
        let size = 300
        var corner = Array(repeating: String(repeating: "U", count: size), count: size)
        corner[0] = "K" + String(repeating: "U", count: size - 1)
        #expect(RumourSpread.minutesUntilEveryoneKnows(corner) == 2 * (size - 1))

        var centre = Array(repeating: String(repeating: "U", count: size), count: size)
        centre[150] = String(repeating: "U", count: 150) + "K" + String(repeating: "U", count: size - 151)
        #expect(RumourSpread.minutesUntilEveryoneKnows(centre) == 150 + 150)

        var walledOff = corner
        walledOff[size - 2] = String(repeating: ".", count: size)     // a row of empty desks
        #expect(RumourSpread.minutesUntilEveryoneKnows(walledOff) == -1)
    }
}
