import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A guild member: ties go to whoever has been in the guild longer
private struct GuildMember: LeaderboardDispatch.Entry {
    let name: String
    let points: Int
    let years: Int
    var tieBreak: Int { years }
}

/// A guest uses the default tie-break
private struct Guest: LeaderboardDispatch.Entry {
    let name: String
    let points: Int
}

/// A class whose subclass overrides the tie-break
private class Player: LeaderboardDispatch.Entry {
    let name: String
    let points: Int
    init(name: String, points: Int) {
        self.name = name
        self.points = points
    }
    var tieBreak: Int { 1 }
}

private final class Veteran: Player {
    override var tieBreak: Int { 100 }
}

/// A small deterministic random number generator, so every run tests the same inputs
private struct LeaderboardRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct LeaderboardDispatchTests {
    private let ana = GuildMember(name: "ana", points: 50, years: 3)
    private let bo = GuildMember(name: "bo", points: 50, years: 7)
    private let cy = GuildMember(name: "cy", points: 80, years: 1)
    private let dee = Guest(name: "dee", points: 50)

    private func name(_ entry: any LeaderboardDispatch.Entry) -> String {
        switch entry {
        case let member as GuildMember: return member.name
        case let guest as Guest: return guest.name
        case let player as Player: return player.name
        default: return "?"
        }
    }

    @Test("The examples")
    func examples() {
        #expect(LeaderboardDispatch.top([ana, bo, cy], count: 2).map(\.name) == ["cy", "bo"])
        #expect(LeaderboardDispatch.top([ana, bo, cy], count: 5).map(\.name) == ["cy", "bo", "ana"])
        #expect(LeaderboardDispatch.top(mixed: [dee, ana, cy, bo], count: 3).map(name) == ["cy", "bo", "ana"])
        #expect(LeaderboardDispatch.top(mixed: [dee, ana, cy, bo], count: 4).map(name) == ["cy", "bo", "ana", "dee"])
        #expect(LeaderboardDispatch.top([ana, bo], count: 0).isEmpty)
        #expect(LeaderboardDispatch.top([GuildMember](), count: 3).isEmpty)
    }

    @Test("A type's own tie-break is used by generic code")
    func ownTieBreakGeneric() {
        let members = [
            GuildMember(name: "new", points: 10, years: 0),
            GuildMember(name: "old", points: 10, years: 9),
            GuildMember(name: "mid", points: 10, years: 4),
        ]
        #expect(LeaderboardDispatch.top(members, count: 3).map(\.name) == ["old", "mid", "new"])
    }

    @Test("Guests use the default, and equal keys keep input order")
    func defaultsAndStability() {
        let guests = [Guest(name: "g1", points: 5), Guest(name: "g2", points: 9), Guest(name: "g3", points: 5)]
        #expect(LeaderboardDispatch.top(guests, count: 3).map(\.name) == ["g2", "g1", "g3"])
        let mixed: [any LeaderboardDispatch.Entry] = [Guest(name: "zero", points: 5), GuildMember(name: "one", points: 5, years: 1)]
        #expect(LeaderboardDispatch.top(mixed: mixed, count: 2).map(name) == ["one", "zero"])
        let negative: [any LeaderboardDispatch.Entry] = [GuildMember(name: "minus", points: 5, years: -1), Guest(name: "zero", points: 5)]
        #expect(LeaderboardDispatch.top(mixed: negative, count: 2).map(name) == ["zero", "minus"])
    }

    @Test("A subclass's override wins, through generics and through any")
    func subclassOverride() {
        let players: [Player] = [Player(name: "rookie", points: 7), Veteran(name: "veteran", points: 7), Player(name: "star", points: 9)]
        #expect(LeaderboardDispatch.top(players, count: 3).map(\.name) == ["star", "veteran", "rookie"])
        let mixed: [any LeaderboardDispatch.Entry] = [Guest(name: "guest", points: 7), Player(name: "rookie", points: 7), Veteran(name: "veteran", points: 7)]
        #expect(LeaderboardDispatch.top(mixed: mixed, count: 3).map(name) == ["veteran", "rookie", "guest"])
    }

    @Test("100,000 entries, mixed and concrete, match a sort")
    func large() {
        var random = LeaderboardRandom(seed: 68)
        let members = (0..<100_000).map { i in
            GuildMember(name: "m\(i)", points: Int.random(in: 0...1_000, using: &random), years: Int.random(in: 0...20, using: &random))
        }
        let expected = members.enumerated().sorted { a, b in
            (a.element.points, a.element.years, -a.offset) > (b.element.points, b.element.years, -b.offset)
        }.prefix(25).map(\.element.name)
        #expect(LeaderboardDispatch.top(members, count: 25).map(\.name) == Array(expected))
        let mixed: [any LeaderboardDispatch.Entry] = members.enumerated().map { i, member in
            i.isMultiple(of: 3) ? Guest(name: member.name, points: member.points) as any LeaderboardDispatch.Entry : member
        }
        let mixedExpected = members.enumerated().sorted { a, b in
            let aTie = a.offset.isMultiple(of: 3) ? 0 : a.element.years
            let bTie = b.offset.isMultiple(of: 3) ? 0 : b.element.years
            return (a.element.points, aTie, -a.offset) > (b.element.points, bTie, -b.offset)
        }.prefix(25).map(\.element.name)
        #expect(LeaderboardDispatch.top(mixed: mixed, count: 25).map(name) == Array(mixedExpected))
    }
}
