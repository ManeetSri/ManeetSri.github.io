import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct ChoreRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct EqualChoreTeamsTests {
    /// Whether `teams` is a fair split of `minutes` among k teams
    private func isFair(_ teams: [Int], _ minutes: [Int], _ k: Int) -> Bool {
        guard teams.count == minutes.count, teams.allSatisfy({ (0..<k).contains($0) }) else { return false }
        var totals = Array(repeating: 0, count: k)
        for (team, length) in zip(teams, minutes) {
            totals[team] += length
        }
        return Set(totals).count == 1
    }

    /// Whether any fair split exists, trying every way to hand out the chores (small inputs only)
    private func exists(_ minutes: [Int], _ k: Int) -> Bool {
        let total = minutes.reduce(0, +)
        guard total % k == 0 else { return false }
        let target = total / k
        var totals = Array(repeating: 0, count: k)
        func place(_ i: Int) -> Bool {
            if i == minutes.count { return totals.allSatisfy { $0 == target } }
            for team in 0..<k where totals[team] + minutes[i] <= target {
                totals[team] += minutes[i]
                if place(i + 1) { return true }
                totals[team] -= minutes[i]
            }
            return false
        }
        return place(0)
    }

    @Test("The examples")
    func examples() {
        let first = [4, 3, 2, 3, 5, 2, 1]
        let split = EqualChoreTeams.assign(first, teams: 4)
        #expect(split.map { isFair($0, first, 4) } == true, "expected a fair split, got \(String(describing: split))")
        #expect(EqualChoreTeams.assign([1, 2, 3, 4], teams: 3) == nil)
        #expect(EqualChoreTeams.assign([2, 2, 2, 2, 3, 4, 5], teams: 4) == nil)
        #expect(EqualChoreTeams.assign([6], teams: 1) == [0])
        let ones = EqualChoreTeams.assign([1, 1, 1, 1], teams: 4)
        #expect(ones.map { $0.sorted() } == [0, 1, 2, 3])
    }

    @Test("One team always works; too many teams never do")
    func edges() {
        let chores = [9, 4, 7, 1]
        #expect(EqualChoreTeams.assign(chores, teams: 1) == [0, 0, 0, 0])
        #expect(EqualChoreTeams.assign([5, 5], teams: 2).map { $0.sorted() } == [0, 1])
        #expect(EqualChoreTeams.assign([5, 6], teams: 2) == nil)
        #expect(EqualChoreTeams.assign([10_000, 1, 9_999], teams: 2).map { isFair($0, [10_000, 1, 9_999], 2) } == true)
    }

    @Test("Random small lists match trying every split", arguments: [1, 2, 3])
    func matchesBrute(seed: UInt64) {
        var random = ChoreRandom(seed: seed)
        for _ in 0..<150 {
            let n = Int.random(in: 1...9, using: &random)
            let k = Int.random(in: 1...min(n, 4), using: &random)
            let minutes = (0..<n).map { _ in Int.random(in: 1...6, using: &random) }
            let result = EqualChoreTeams.assign(minutes, teams: k)
            let possible = exists(minutes, k)
            let right = possible ? result.map { isFair($0, minutes, k) } == true : result == nil
            #expect(right, possible ? "\(minutes) into \(k) teams has a fair split, got \(String(describing: result))" : "\(minutes) can't be split into \(k) teams")
            if !right { return }
        }
    }

    @Test("Sixteen chores, with and without a fair split")
    func sixteen() {
        // Eight pairs that each add up to 17
        let pairs = [1, 16, 2, 15, 3, 14, 4, 13, 5, 12, 6, 11, 7, 10, 8, 9]
        #expect(EqualChoreTeams.assign(pairs, teams: 8).map { isFair($0, pairs, 8) } == true)
        #expect(EqualChoreTeams.assign(pairs, teams: 4).map { isFair($0, pairs, 4) } == true)
        #expect(EqualChoreTeams.assign(pairs, teams: 2).map { isFair($0, pairs, 2) } == true)
        // 15 sevens and an 11: the total, 116, divides by 4, but no team can make exactly 29
        let sevens = Array(repeating: 7, count: 15) + [11]
        #expect(EqualChoreTeams.assign(sevens, teams: 4) == nil)
        // The total (96) divides by 6 and every chore fits in 16, but each of the six 7s needs 9 more
        // minutes, and only three teams' worth of 9s (6 + 3, 6 + 3, 5 + 4) can be made
        let awkward = [8, 8, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 5, 4, 3, 3]
        #expect(EqualChoreTeams.assign(awkward, teams: 6) == nil)
        // A big split that does exist
        let mixed = [9, 9, 8, 8, 7, 7, 6, 6, 5, 5, 4, 4, 3, 3, 2, 2]
        #expect(EqualChoreTeams.assign(mixed, teams: 4).map { isFair($0, mixed, 4) } == true)
        #expect(EqualChoreTeams.assign(mixed, teams: 8).map { isFair($0, mixed, 8) } == true)
    }
}
