import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ExtraCableTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// True when the cables join computers 0..<n into one tree, checked with a breadth-first search.
    private func isTree(_ n: Int, _ cables: [[Int]]) -> Bool {
        guard cables.count == n - 1 else { return false }
        var links = Array(repeating: [Int](), count: n)
        for cable in cables {
            links[cable[0]].append(cable[1])
            links[cable[1]].append(cable[0])
        }
        var seen = Array(repeating: false, count: n)
        seen[0] = true
        var queue = [0]
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            for next in links[current] where !seen[next] {
                seen[next] = true
                queue.append(next)
            }
        }
        return queue.count == n
    }

    /// The answer the slow way: the latest cable whose removal leaves a tree.
    private func modelAnswer(_ cables: [[Int]]) -> [Int] {
        for index in cables.indices.reversed() {
            var rest = cables
            rest.remove(at: index)
            if isTree(cables.count, rest) { return cables[index] }
        }
        return []
    }

    @Test("Small networks", arguments: [
        ([[0, 1], [1, 2], [2, 0]], [2, 0]),
        ([[0, 1], [1, 2], [2, 3], [3, 1], [0, 4]], [3, 1]),
        ([[1, 0], [2, 0], [3, 1], [2, 3]], [2, 3]),
        ([[0, 1], [0, 2], [2, 1]], [2, 1]),
        ([[0, 4], [3, 4], [0, 3], [1, 2], [2, 4]], [0, 3]),
    ])
    func examples(cables: [[Int]], expected: [Int]) {
        #expect(ExtraCable.find(cables) == expected)
    }

    @Test("Two computers joined twice")
    func doubleCable() {
        #expect(ExtraCable.find([[0, 1], [1, 0]]) == [1, 0])
        #expect(ExtraCable.find([[1, 0], [0, 1]]) == [0, 1])
    }

    @Test("Random trees with one extra cable match the slow check", arguments: Array(1...12))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        let n = 3 + steps.next(below: 25)
        // A random tree: computer i joins one of the computers before it, then the labels are shuffled
        var labels = Array(0..<n)
        for index in stride(from: n - 1, to: 0, by: -1) {
            labels.swapAt(index, steps.next(below: index + 1))
        }
        var cables = (1..<n).map { i in [labels[i], labels[steps.next(below: i)]] }
        var a = steps.next(below: n)
        var b = steps.next(below: n)
        while a == b {
            a = steps.next(below: n)
            b = steps.next(below: n)
        }
        cables.insert([a, b], at: steps.next(below: cables.count + 1))
        for index in stride(from: cables.count - 1, to: 0, by: -1) {
            cables.swapAt(index, steps.next(below: index + 1))
        }
        #expect(ExtraCable.find(cables) == modelAnswer(cables))
    }

    @Test("100,000 computers in one big loop")
    func bigLoop() {
        let n = 100_000
        let cables = [[n - 1, 0]] + (0..<(n - 1)).map { [$0, $0 + 1] }
        #expect(ExtraCable.find(cables) == [n - 2, n - 1])
    }
}
