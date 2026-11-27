import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run types the same keystrokes
private struct DebounceRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

private enum FieldEvent {
    case change(Int, String)
    case advance(Int)
}

@Suite struct SearchFieldDebounceTests {
    typealias Search = SearchFieldDebounce.Search

    /// Runs the events through a Debouncer, collecting what each advance returns
    private func run(_ events: [FieldEvent], delay: Int) -> [[Search]] {
        let debouncer = SearchFieldDebounce.Debouncer(delay: delay)
        var results: [[Search]] = []
        for event in events {
            switch event {
            case let .change(time, text): debouncer.textChanged(to: text, at: time)
            case let .advance(time): results.append(debouncer.advance(to: time))
            }
        }
        return results
    }

    /// A different way to the same answer, looking at the whole event list at once. Change i's search runs
    /// if the next change comes at or after its fire time, or, for the last change, if some later advance
    /// reaches it. The filters then apply in order, and each search is reported by the first advance
    /// after its change whose time reaches it.
    private func reference(_ events: [FieldEvent], delay: Int) -> [[Search]] {
        let changes: [(index: Int, time: Int, text: String)] = events.enumerated().compactMap { index, event in
            if case let .change(time, text) = event { return (index, time, text) }
            return nil
        }
        let advances: [(index: Int, time: Int)] = events.enumerated().compactMap { index, event in
            if case let .advance(time) = event { return (index, time) }
            return nil
        }
        var results = Array(repeating: [Search](), count: advances.count)
        var lastRun: String? = nil
        for (position, change) in changes.enumerated() {
            let fireTime = change.time + delay
            let ran: Bool
            if position + 1 < changes.count {
                ran = changes[position + 1].time >= fireTime
            } else {
                ran = advances.contains { $0.index > change.index && $0.time >= fireTime }
            }
            guard ran, !change.text.isEmpty, change.text != lastRun else { continue }
            lastRun = change.text
            if let slot = advances.firstIndex(where: { $0.index > change.index && $0.time >= fireTime }) {
                results[slot].append(Search(time: fireTime, query: change.text))
            }
        }
        return results
    }

    @Test("The example from the statement")
    func example() {
        let events: [FieldEvent] = [
            .change(0, "s"), .change(120, "sw"), .change(250, "swi"),
            .advance(500), .advance(550),
            .change(900, "swif"), .change(1_000, "swift"), .change(1_300, "swif"), .change(1_450, "swift"),
            .advance(2_000),
            .change(2_100, ""), .advance(2_500),
            .change(2_600, "swift"), .advance(3_000),
            .change(3_100, "kotlin"), .advance(3_400),
        ]
        let expected: [[Search]] = [
            [],
            [Search(time: 550, query: "swi")],
            [Search(time: 1_300, query: "swift")],
            [],
            [],
            [Search(time: 3_400, query: "kotlin")],
        ]
        #expect(run(events, delay: 300) == expected)
    }

    @Test("Nothing runs before the quiet period ends")
    func waits() {
        let debouncer = SearchFieldDebounce.Debouncer(delay: 200)
        debouncer.textChanged(to: "map", at: 10)
        #expect(debouncer.advance(to: 10) == [])
        #expect(debouncer.advance(to: 209) == [])
        #expect(debouncer.advance(to: 210) == [Search(time: 210, query: "map")])
        #expect(debouncer.advance(to: 10_000) == [], "a search runs once")
    }

    @Test("Continuous typing keeps pushing the search back")
    func burst() {
        let debouncer = SearchFieldDebounce.Debouncer(delay: 100)
        var text = ""
        for (step, letter) in "collectionview".enumerated() {
            text.append(letter)
            debouncer.textChanged(to: text, at: step * 99)
        }
        #expect(debouncer.advance(to: 13 * 99 + 99) == [])
        #expect(debouncer.advance(to: 13 * 99 + 100) == [Search(time: 1_387, query: "collectionview")])
    }

    @Test("A change at exactly the fire time is too late to cancel it")
    func boundary() {
        let debouncer = SearchFieldDebounce.Debouncer(delay: 50)
        debouncer.textChanged(to: "a", at: 0)
        debouncer.textChanged(to: "ab", at: 49)     // cancels "a", which was due at 50
        debouncer.textChanged(to: "abc", at: 98)    // cancels "ab", which was due at 99
        debouncer.textChanged(to: "abcd", at: 148)  // "abc" was due at 148, so it ran first
        #expect(debouncer.advance(to: 150) == [Search(time: 148, query: "abc")])
        #expect(debouncer.advance(to: 197) == [])
        #expect(debouncer.advance(to: 198) == [Search(time: 198, query: "abcd")])
    }

    @Test("Searches that ran during changes wait for the next advance, in order")
    func buffered() {
        let debouncer = SearchFieldDebounce.Debouncer(delay: 10)
        debouncer.textChanged(to: "one", at: 0)
        debouncer.textChanged(to: "two", at: 20)
        debouncer.textChanged(to: "three", at: 40)
        debouncer.textChanged(to: "four", at: 45)
        let searches = debouncer.advance(to: 100)
        #expect(searches == [Search(time: 10, query: "one"), Search(time: 30, query: "two"), Search(time: 55, query: "four")])
    }

    @Test("Empty and repeated queries are skipped, and an empty query doesn't reset the repeat check")
    func filters() {
        let debouncer = SearchFieldDebounce.Debouncer(delay: 5)
        debouncer.textChanged(to: "cat", at: 0)
        debouncer.textChanged(to: "", at: 10)
        debouncer.textChanged(to: "cat", at: 20)
        debouncer.textChanged(to: "cats", at: 30)
        debouncer.textChanged(to: "cat", at: 40)
        #expect(debouncer.advance(to: 50) == [Search(time: 5, query: "cat"), Search(time: 35, query: "cats"), Search(time: 45, query: "cat")])
        debouncer.textChanged(to: "", at: 60)
        #expect(debouncer.advance(to: 70) == [])
    }

    @Test("Same-millisecond changes: only the last one counts")
    func sameTime() {
        let debouncer = SearchFieldDebounce.Debouncer(delay: 1)
        debouncer.textChanged(to: "x", at: 5)
        debouncer.textChanged(to: "xy", at: 5)
        debouncer.textChanged(to: "xyz", at: 5)
        #expect(debouncer.advance(to: 6) == [Search(time: 6, query: "xyz")])
    }

    @Test("Matches the reference on random typing", arguments: [1, 3, 10, 40])
    func randomTyping(delay: Int) {
        var random = DebounceRandom(seed: UInt64(delay))
        let words = ["", "s", "sw", "swi", "swift", "swiftui", "ui", "uikit"]
        var failures = 0
        for _ in 0..<200 where failures == 0 {
            var time = 0
            var events: [FieldEvent] = []
            for _ in 0..<Int.random(in: 0...25, using: &random) {
                time += Int.random(in: 0...(delay * 2), using: &random)
                if Int.random(in: 0..<3, using: &random) == 0 {
                    events.append(.advance(time))
                } else {
                    events.append(.change(time, words[Int.random(in: 0..<words.count, using: &random)]))
                }
            }
            events.append(.advance(time + Int.random(in: 0...(delay * 2), using: &random)))
            let got = run(events, delay: delay), expected = reference(events, delay: delay)
            if got != expected {
                failures += 1
                Issue.record("For events \(events), advance returned \(got), expected \(expected)")
            }
        }
    }

    @Test("100,000 keystrokes")
    func large() {
        var random = DebounceRandom(seed: 2_026)
        let delay = 300
        var events: [FieldEvent] = []
        var time = 0
        var text = ""
        for _ in 0..<100_000 {
            // Mostly fast typing, with the occasional pause long enough for a search
            time += Int.random(in: 0..<10, using: &random) == 0 ? Int.random(in: 250...400, using: &random) : Int.random(in: 30...150, using: &random)
            if text.count > 6 || (Int.random(in: 0..<4, using: &random) == 0 && !text.isEmpty) {
                text.removeLast()
            } else {
                text.append(["a", "b", "c"][Int.random(in: 0..<3, using: &random)])
            }
            events.append(.change(time, text))
            if Int.random(in: 0..<50, using: &random) == 0 {
                time += Int.random(in: 0...500, using: &random)
                events.append(.advance(time))
            }
        }
        events.append(.advance(time + delay))
        // The first reference searches every advance for every change, which is slow at this size, so
        // this uses the same rules with a forward scan
        let got = run(events, delay: delay)
        let expected = fastReference(events, delay: delay)
        #expect(got.count == expected.count)
        #expect(got.flatMap { $0 } == expected.flatMap { $0 })
        #expect(got.map(\.count) == expected.map(\.count))
        #expect(expected.flatMap { $0 }.count > 1_000)
    }

    /// The reference's rules, with the "first advance that reaches it" lookup done by scanning forward from
    /// the first advance after the change.
    private func fastReference(_ events: [FieldEvent], delay: Int) -> [[Search]] {
        var changes: [(index: Int, time: Int, text: String)] = []
        var advances: [(index: Int, time: Int)] = []
        for (index, event) in events.enumerated() {
            switch event {
            case let .change(time, text): changes.append((index, time, text))
            case let .advance(time): advances.append((index, time))
            }
        }
        var results = Array(repeating: [Search](), count: advances.count)
        var lastRun: String? = nil
        var firstAfter = 0
        for (position, change) in changes.enumerated() {
            let fireTime = change.time + delay
            while firstAfter < advances.count && advances[firstAfter].index < change.index { firstAfter += 1 }
            var slot = firstAfter
            while slot < advances.count && advances[slot].time < fireTime { slot += 1 }
            let ran = position + 1 < changes.count ? changes[position + 1].time >= fireTime : slot < advances.count
            guard ran, !change.text.isEmpty, change.text != lastRun else { continue }
            lastRun = change.text
            if slot < advances.count { results[slot].append(Search(time: fireTime, query: change.text)) }
        }
        return results
    }
}
