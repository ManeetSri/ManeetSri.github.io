import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FriendGroupCountTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The groups counted the slow way: a breadth-first search from every unvisited person.
    private func modelCount(_ n: Int, _ friendships: [[Int]]) -> Int {
        var friends = Array(repeating: [Int](), count: n)
        for pair in friendships {
            friends[pair[0]].append(pair[1])
            friends[pair[1]].append(pair[0])
        }
        var seen = Array(repeating: false, count: n)
        var groups = 0
        for person in 0..<n where !seen[person] {
            groups += 1
            seen[person] = true
            var queue = [person]
            var head = 0
            while head < queue.count {
                let current = queue[head]
                head += 1
                for friend in friends[current] where !seen[friend] {
                    seen[friend] = true
                    queue.append(friend)
                }
            }
        }
        return groups
    }

    @Test("Small examples", arguments: [
        (5, [[0, 1], [1, 2], [3, 4]], 2),
        (6, [[0, 1], [2, 3], [4, 5], [1, 3]], 2),
        (4, [[3, 0], [0, 2], [2, 1]], 1),
        (3, [[0, 1], [1, 2], [2, 0]], 1),
        (7, [[5, 6]], 6),
    ])
    func examples(n: Int, friendships: [[Int]], expected: Int) {
        #expect(FriendGroupCount.count(n, friendships) == expected)
    }

    @Test("Nobody is friends with anybody")
    func noFriendships() {
        #expect(FriendGroupCount.count(1, []) == 1)
        #expect(FriendGroupCount.count(4, []) == 4)
    }

    @Test("Repeated friendships count once")
    func repeated() {
        #expect(FriendGroupCount.count(3, [[0, 1], [1, 0], [0, 1]]) == 2)
        #expect(FriendGroupCount.count(4, [[2, 3], [3, 2], [2, 3], [0, 1], [1, 0]]) == 2)
    }

    @Test("Random friendships match a breadth-first search", arguments: [1, 2, 3, 4, 5, 6])
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        let n = 5 + steps.next(below: 60)
        let friendships = (0..<steps.next(below: n + 10)).map { _ in
            let a = steps.next(below: n)
            var b = steps.next(below: n)
            if b == a { b = (a + 1) % n }
            return [a, b]
        }
        #expect(FriendGroupCount.count(n, friendships) == modelCount(n, friendships))
    }

    @Test("200,000 people in 1,000 groups")
    func large() {
        // Group g holds the people p with p % 1,000 == g, linked in a chain in a scrambled order
        let n = 200_000
        var friendships: [[Int]] = []
        for step in 1..<200 {
            for group in 0..<1_000 {
                friendships.append([group + step * 1_000, group + (step - 1) * 1_000])
            }
        }
        var steps = Steps(seed: 42)
        for index in stride(from: friendships.count - 1, to: 0, by: -1) {
            friendships.swapAt(index, steps.next(below: index + 1))
        }
        #expect(FriendGroupCount.count(n, friendships) == 1_000)
        #expect(FriendGroupCount.count(n, friendships + [[0, 1], [2, 3], [1, 2]]) == 997)
    }
}
