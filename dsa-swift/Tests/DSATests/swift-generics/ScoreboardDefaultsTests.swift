import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ScoreboardDefaultsTests {
    typealias Scoreboard = ScoreboardDefaults.Scoreboard
    typealias ArcadeBoard = ScoreboardDefaults.ArcadeBoard
    typealias GolfCard = ScoreboardDefaults.GolfCard

    /// A conforming type from outside the module that replaces the default ranking.
    private struct Reversed: Scoreboard {
        var scores: [Int]
        func ranking() -> [Int] { scores.reversed() }
    }

    @Test("The default ranking puts high scores first")
    func defaultRanking() {
        let board = ArcadeBoard(scores: [12, 40, 7, 33])
        #expect(board.ranking() == [40, 33, 12, 7])
        #expect(board.bestScore == 40)
        #expect(board.topScores(2) == [40, 33])
    }

    @Test("Golf ranks the lowest score first")
    func golfRanking() {
        let card = GolfCard(scores: [72, 68, 75, 70])
        #expect(card.ranking() == [68, 70, 72, 75])
        #expect(card.bestScore == 68)
        #expect(card.topScores(3) == [68, 70, 72])
    }

    @Test("totalScore adds every score")
    func totals() {
        #expect(ArcadeBoard(scores: [12, 40, 7, 33]).totalScore == 92)
        #expect(GolfCard(scores: [72, 68]).totalScore == 140)
        #expect(ArcadeBoard(scores: [-5, 5, -10]).totalScore == -10)
    }

    @Test("topScores handles counts outside the range")
    func topScoresEdges() {
        let board = ArcadeBoard(scores: [3, 9, 4])
        #expect(board.topScores(10) == [9, 4, 3])
        #expect(board.topScores(0) == [])
        #expect(board.topScores(-2) == [])
    }

    @Test("An empty board")
    func empty() {
        let board = ArcadeBoard(scores: [])
        #expect(board.ranking() == [])
        #expect(board.totalScore == 0)
        #expect(board.bestScore == nil)
        #expect(board.topScores(3) == [])
        #expect(GolfCard(scores: []).bestScore == nil)
    }

    @Test("Equal scores are all kept")
    func duplicates() {
        #expect(ArcadeBoard(scores: [5, 9, 5, 9]).ranking() == [9, 9, 5, 5])
        #expect(GolfCard(scores: [5, 9, 5]).topScores(2) == [5, 5])
    }

    @Test("Through any Scoreboard, each type still uses its own ranking")
    func existentials() {
        let boards: [any Scoreboard] = [
            ArcadeBoard(scores: [1, 3, 2]),
            GolfCard(scores: [1, 3, 2]),
            Reversed(scores: [1, 3, 2]),
        ]
        #expect(boards.map { $0.bestScore } == [3, 1, 2])
        #expect(boards.map { $0.topScores(2) } == [[3, 2], [1, 2], [2, 3]])
        #expect(boards.map { $0.totalScore } == [6, 6, 6])
    }

    @Test("A plain array of Ints is a scoreboard too")
    func arrays() {
        let scores = [12, 40, 7, 33]
        #expect(scores.scores == [12, 40, 7, 33])
        #expect(scores.ranking() == [40, 33, 12, 7])
        #expect(scores.bestScore == 40)
        #expect(scores.totalScore == 92)
        #expect([Int]().bestScore == nil)
        let board: any Scoreboard = [8, 1, 6]
        #expect(board.topScores(1) == [8])
    }
}
