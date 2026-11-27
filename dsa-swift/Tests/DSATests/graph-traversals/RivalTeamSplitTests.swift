import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RivalTeamSplitTests {
    /// Checks that teams gives everyone team 0 or 1, with every pair of rivals on different teams
    private func expectSplit(_ teams: [Int]?, people: Int, rivalries: [[Int]]) {
        guard let teams else {
            Issue.record("a split exists, but teams returned nil")
            return
        }
        #expect(teams.count == people, "expected a team for each of the \(people) people")
        guard teams.count == people else { return }
        #expect(teams.allSatisfy { $0 == 0 || $0 == 1 }, "teams must be 0 or 1")
        #expect(rivalries.allSatisfy { teams[$0[0]] != teams[$0[1]] }, "two rivals are on the same team")
    }

    @Test("Splits are found", arguments: [
        (4, [[0, 1], [1, 2], [2, 3], [3, 0]]),
        (5, [[0, 1], [0, 2], [0, 3], [0, 4]]),
        (6, [[0, 1], [2, 3], [4, 5]]),
        (7, [[0, 1], [0, 2], [1, 3], [1, 4], [2, 5], [5, 6]]),
        (6, [[0, 3], [0, 4], [0, 5], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5]]),
        (4, [[0, 1], [0, 1], [1, 0]]),
    ])
    func splits(people: Int, rivalries: [[Int]]) {
        expectSplit(RivalTeamSplit.teams(people, rivalries: rivalries), people: people, rivalries: rivalries)
    }

    @Test("Nobody has a rival")
    func noRivals() {
        expectSplit(RivalTeamSplit.teams(1, rivalries: []), people: 1, rivalries: [])
        expectSplit(RivalTeamSplit.teams(4, rivalries: []), people: 4, rivalries: [])
    }

    @Test("Odd cycles make a split impossible", arguments: [
        (3, [[0, 1], [1, 2], [2, 0]]),
        (5, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0]]),
        (6, [[0, 1], [1, 2], [3, 4], [4, 5], [5, 3]]),
        (2, [[1, 1]]),
        (4, [[0, 1], [1, 2], [2, 3], [3, 0], [0, 2]]),
    ])
    func impossible(people: Int, rivalries: [[Int]]) {
        #expect(RivalTeamSplit.teams(people, rivalries: rivalries) == nil)
    }

    @Test("Long cycles of 100,000 and 99,999 people")
    func longCycles() {
        let even = 100_000
        let evenRing = (0..<even).map { [$0, ($0 + 1) % even] }
        expectSplit(RivalTeamSplit.teams(even, rivalries: evenRing), people: even, rivalries: evenRing)

        let odd = 99_999
        let oddRing = (0..<odd).map { [$0, ($0 + 1) % odd] }
        let oddSplit = RivalTeamSplit.teams(odd, rivalries: oddRing) != nil
        #expect(!oddSplit, "a loop of 99,999 rivals can't be split")
    }

    @Test("A long line, closed into an even or an odd loop")
    func longLine() {
        let count = 100_000
        let line = (0..<(count - 1)).map { [$0, $0 + 1] }
        expectSplit(RivalTeamSplit.teams(count, rivalries: line + [[0, count - 1]]), people: count, rivalries: line + [[0, count - 1]])
        let oddSplit = RivalTeamSplit.teams(count, rivalries: line + [[0, count - 2]]) != nil
        #expect(!oddSplit, "a loop of 99,999 rivals can't be split")
    }

    @Test("50,000 separate pairs, then one odd triangle among them")
    func manyGroups() {
        let count = 100_000
        let pairs = (0..<(count / 2)).map { [2 * $0, 2 * $0 + 1] }
        expectSplit(RivalTeamSplit.teams(count, rivalries: pairs), people: count, rivalries: pairs)
        // 99,996 – 99,997 and 99,998 – 99,999 become a triangle with 99,996 – 99,998 and 99,997 – 99,998
        let triangle = pairs + [[99_996, 99_998], [99_997, 99_998]]
        let triangleSplit = RivalTeamSplit.teams(count, rivalries: triangle) != nil
        #expect(!triangleSplit, "three people who are all rivals can't be split")
    }
}
