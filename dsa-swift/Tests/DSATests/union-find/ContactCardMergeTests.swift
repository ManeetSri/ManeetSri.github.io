import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ContactCardMergeTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The slow, obvious merge: keep joining any two cards that share an email until none do.
    private func modelMerge(_ cards: [[String]]) -> [[String]] {
        var people = cards.map { (name: $0[0], emails: Set($0.dropFirst())) }
        var merged = true
        while merged {
            merged = false
            search: for i in people.indices {
                for j in people.indices where j > i && !people[i].emails.isDisjoint(with: people[j].emails) {
                    people[i].emails.formUnion(people[j].emails)
                    people.remove(at: j)
                    merged = true
                    break search
                }
            }
        }
        return people
            .map { [$0.name] + $0.emails.sorted() }
            .sorted { $0[0] != $1[0] ? $0[0] < $1[0] : $0[1] < $1[1] }
    }

    @Test("The example from the statement")
    func example() {
        let cards = [
            ["Priya", "priya@home.net", "p.shah@work.com"],
            ["Tom", "tom@mail.org"],
            ["Priya", "priya.s@uni.edu"],
            ["Priya", "p.shah@work.com", "shah.p@club.org"],
            ["Tom", "tommy@games.io", "tom@mail.org"],
        ]
        #expect(ContactCardMerge.merge(cards) == [
            ["Priya", "p.shah@work.com", "priya@home.net", "shah.p@club.org"],
            ["Priya", "priya.s@uni.edu"],
            ["Tom", "tom@mail.org", "tommy@games.io"],
        ])
    }

    @Test("Cards link through a chain of shared emails")
    func chain() {
        let cards = [
            ["Ana", "a@x.com", "b@x.com"],
            ["Ana", "c@x.com", "d@x.com"],
            ["Ana", "b@x.com", "c@x.com"],
        ]
        #expect(ContactCardMerge.merge(cards) == [["Ana", "a@x.com", "b@x.com", "c@x.com", "d@x.com"]])
    }

    @Test("The same name alone doesn't merge cards")
    func sameNameDifferentPeople() {
        let cards = [["Sam", "sam1@x.com"], ["Sam", "sam2@x.com"], ["Sam", "sam0@x.com"]]
        #expect(ContactCardMerge.merge(cards) == [["Sam", "sam0@x.com"], ["Sam", "sam1@x.com"], ["Sam", "sam2@x.com"]])
    }

    @Test("Repeated emails appear once")
    func repeatedEmails() {
        let cards = [["Lee", "lee@x.com", "lee@x.com"], ["Lee", "lee@x.com"]]
        #expect(ContactCardMerge.merge(cards) == [["Lee", "lee@x.com"]])
        #expect(ContactCardMerge.merge([["Kim", "kim@x.com"]]) == [["Kim", "kim@x.com"]])
    }

    @Test("No cards")
    func empty() {
        #expect(ContactCardMerge.merge([]) == [])
    }

    @Test("Random cards match the slow merge", arguments: Array(1...10))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        let names = ["Ava", "Ben", "Cai", "Dev"]
        // Each person owns a few emails; every card holds one to three of one person's emails
        let people = 6
        let cards = (0..<(5 + steps.next(below: 25))).map { _ -> [String] in
            let person = steps.next(below: people)
            let emails = (0..<(1 + steps.next(below: 3))).map { _ in "p\(person)e\(steps.next(below: 5))@mail.com" }
            return [names[person % names.count]] + emails
        }
        #expect(ContactCardMerge.merge(cards) == modelMerge(cards))
    }

    @Test("20,000 cards that merge into 200 people")
    func large() {
        var cards: [[String]] = []
        var expected: [[String]] = []
        for group in 0..<200 {
            let name = "Name\(group % 7)"
            for card in 0..<100 {
                cards.append([name, "g\(group)e\(card)@mail.com", "g\(group)e\(card + 1)@mail.com"])
            }
            expected.append([name] + (0...100).map { "g\(group)e\($0)@mail.com" }.sorted())
        }
        var steps = Steps(seed: 3)
        for index in stride(from: cards.count - 1, to: 0, by: -1) {
            cards.swapAt(index, steps.next(below: index + 1))
        }
        expected.sort { $0[0] != $1[0] ? $0[0] < $1[0] : $0[1] < $1[1] }
        #expect(ContactCardMerge.merge(cards) == expected)
    }
}
