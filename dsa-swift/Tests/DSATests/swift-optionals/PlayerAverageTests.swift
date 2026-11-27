import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PlayerAverageTests {
    let book: [String: [Int]] = [
        "Ana": [70, 80, 90],
        "Ben": [55],
        "Cleo": [],
        "Dev": [7, 8],
        "Eli": [-4, 4, 3],
    ]

    @Test("Averages a listed player's scores", arguments: [
        ("Ana", 80.0),
        ("Ben", 55.0),
        ("Dev", 7.5),
        ("Eli", 1.0),
    ])
    func averages(player: String, expected: Double) {
        #expect(PlayerAverage.average(for: player, in: book) == expected)
    }

    @Test("Keeps the fractional part")
    func fractional() {
        #expect(PlayerAverage.average(for: "Fay", in: ["Fay": [1, 2]]) == 1.5)
        #expect(PlayerAverage.average(for: "Gus", in: ["Gus": [10, 10, 11, 11]]) == 10.5)
    }

    @Test("Returns nil for a player with no scores")
    func noScores() {
        #expect(PlayerAverage.average(for: "Cleo", in: book) == nil)
    }

    @Test("Returns nil for a player who isn't listed")
    func missingPlayer() {
        #expect(PlayerAverage.average(for: "Zoe", in: book) == nil)
        #expect(PlayerAverage.average(for: "ana", in: book) == nil)
        #expect(PlayerAverage.average(for: "Ana", in: [:]) == nil)
    }

    @Test("Handles many large scores")
    func large() {
        let scores = Array(repeating: 1_000_000, count: 10_000)
        #expect(PlayerAverage.average(for: "Max", in: ["Max": scores]) == 1_000_000.0)
    }
}
