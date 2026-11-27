import Testing
import DSAKit

@Suite struct UnionFindTests {
    /// A tiny deterministic generator, so the random-operation tests do the same thing every run.
    private struct Steps {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The slow, obviously correct model: every element carries a label, and a union relabels a
    /// whole set. O(n) per union, which is fine for checking.
    private struct LabelModel {
        var label: [Int]

        init(count: Int) {
            label = Array(0..<count)
        }

        func connected(_ a: Int, _ b: Int) -> Bool {
            label[a] == label[b]
        }

        mutating func union(_ a: Int, _ b: Int) -> Bool {
            let from = label[b]
            let to = label[a]
            if from == to { return false }
            for index in label.indices where label[index] == from {
                label[index] = to
            }
            return true
        }

        func size(of element: Int) -> Int {
            label.filter { $0 == label[element] }.count
        }

        var componentCount: Int {
            Set(label).count
        }

        /// The sets in increasing order of their smallest element, each sorted, like `groups()`.
        var groups: [[Int]] {
            var groupOfLabel: [Int: Int] = [:]
            var result: [[Int]] = []
            for element in label.indices {
                if let index = groupOfLabel[label[element]] {
                    result[index].append(element)
                } else {
                    groupOfLabel[label[element]] = result.count
                    result.append([element])
                }
            }
            return result
        }
    }

    @Test("Every element starts in a set of its own")
    func singletons() {
        var sets = UnionFind(count: 5)
        #expect(sets.count == 5)
        #expect(sets.componentCount == 5)
        for element in 0..<5 {
            #expect(sets.find(element) == element)
            #expect(sets.size(ofSetContaining: element) == 1)
            #expect(sets.connected(element, element) == true)
        }
        #expect(sets.connected(0, 1) == false)
        #expect(sets.groups() == [[0], [1], [2], [3], [4]])
    }

    @Test("Zero elements and one element")
    func tiny() {
        var empty = UnionFind(count: 0)
        #expect(empty.count == 0)
        #expect(empty.componentCount == 0)
        #expect(empty.groups() == [])
        #expect(empty.description == "UnionFind([])")

        var one = UnionFind(count: 1)
        #expect(one.find(0) == 0)
        #expect(one.union(0, 0) == false)
        #expect(one.componentCount == 1)
        #expect(one.size(ofSetContaining: 0) == 1)
    }

    @Test("Unions join sets, and connected follows them")
    func unions() {
        var sets = UnionFind(count: 6)
        #expect(sets.union(0, 1) == true)
        #expect(sets.union(2, 3) == true)
        #expect(sets.connected(0, 1) == true)
        #expect(sets.connected(3, 2) == true)
        #expect(sets.connected(1, 2) == false)
        #expect(sets.union(1, 3) == true)
        #expect(sets.connected(0, 2) == true)
        #expect(sets.find(0) == sets.find(3))
        #expect(sets.connected(0, 4) == false)
        #expect(sets.connected(4, 5) == false)
        #expect(sets.groups() == [[0, 1, 2, 3], [4], [5]])
        #expect(sets.description == "UnionFind([[0, 1, 2, 3], [4], [5]])")
    }

    @Test("A union inside one set returns false and changes nothing")
    func redundantUnions() {
        var sets = UnionFind(count: 4)
        sets.union(0, 1)
        sets.union(1, 2)
        let before = sets.groups()
        #expect(sets.union(0, 2) == false)
        #expect(sets.union(2, 0) == false)
        #expect(sets.union(1, 1) == false)
        #expect(sets.componentCount == 2)
        #expect(sets.groups() == before)
        #expect(sets.size(ofSetContaining: 2) == 3)
    }

    @Test("componentCount drops only on real unions")
    func componentCounts() {
        var sets = UnionFind(count: 10)
        let pairs = [(0, 1), (2, 3), (1, 0), (4, 5), (3, 2), (0, 3), (6, 7), (8, 9), (7, 9), (5, 9), (2, 1)]
        var expected = 10
        for (a, b) in pairs {
            if sets.union(a, b) {
                expected -= 1
            }
            #expect(sets.componentCount == expected)
        }
        #expect(sets.componentCount == 2)
        #expect(sets.groups() == [[0, 1, 2, 3], [4, 5, 6, 7, 8, 9]])
    }

    @Test("Sizes follow unions, whichever root wins")
    func sizes() {
        var sets = UnionFind(count: 8)
        sets.union(0, 1)
        sets.union(0, 2)                      // {0, 1, 2}
        sets.union(3, 4)                      // {3, 4}
        #expect(sets.size(ofSetContaining: 1) == 3)
        #expect(sets.size(ofSetContaining: 4) == 2)
        sets.union(4, 2)                      // the smaller set joins the bigger one
        for element in 0...4 {
            #expect(sets.size(ofSetContaining: element) == 5)
        }
        #expect(sets.size(ofSetContaining: 7) == 1)
        sets.union(5, 6)
        sets.union(7, 6)
        sets.union(6, 0)
        #expect(sets.size(ofSetContaining: 3) == 8)
        #expect(sets.componentCount == 1)
    }

    @Test("Union by size puts the smaller root under the larger")
    func smallerGoesUnder() {
        var sets = UnionFind(count: 5)
        sets.union(1, 2)
        sets.union(1, 3)
        let bigRoot = sets.find(1)
        sets.union(0, 3)                      // {0} is smaller, so its root changes, not bigRoot
        #expect(sets.find(0) == bigRoot)
        sets.union(4, 2)
        #expect(sets.find(4) == bigRoot)
    }

    @Test("addElement adds a singleton at the next index")
    func addElement() {
        var sets = UnionFind(count: 2)
        sets.union(0, 1)
        #expect(sets.addElement() == 2)
        #expect(sets.count == 3)
        #expect(sets.componentCount == 2)
        #expect(sets.connected(2, 0) == false)
        #expect(sets.union(2, 0) == true)
        #expect(sets.size(ofSetContaining: 2) == 3)

        var grown = UnionFind(count: 0)
        for expected in 0..<100 {
            #expect(grown.addElement() == expected)
            if expected > 0 {
                grown.union(expected, expected - 1)
            }
        }
        #expect(grown.componentCount == 1)
        #expect(grown.size(ofSetContaining: 50) == 100)
    }

    @Test("A copy is independent")
    func valueSemantics() {
        var original = UnionFind(count: 4)
        original.union(0, 1)
        var copy = original
        copy.union(2, 3)
        copy.union(1, 2)
        #expect(copy.componentCount == 1)
        #expect(original.componentCount == 3)
        #expect(original.connected(0, 3) == false)
        #expect(original.groups() == [[0, 1], [2], [3]])
    }

    @Test("description doesn't change the structure")
    func describing() {
        var sets = UnionFind(count: 5)
        sets.union(4, 0)
        sets.union(1, 4)
        #expect(sets.description == "UnionFind([[0, 1, 4], [2], [3]])")
        #expect("\(sets)" == "UnionFind([[0, 1, 4], [2], [3]])")
        #expect(sets.groups() == [[0, 1, 4], [2], [3]])
    }

    @Test("A million elements joined in a chain, both ways round")
    func millionChain() {
        let n = 1_000_000
        var forward = UnionFind(count: n)
        for element in 0..<(n - 1) {
            forward.union(element, element + 1)
        }
        #expect(forward.componentCount == 1)
        #expect(forward.connected(0, n - 1) == true)
        #expect(forward.size(ofSetContaining: n / 2) == n)

        var backward = UnionFind(count: n)
        for element in stride(from: n - 1, to: 0, by: -1) {
            backward.union(element, element - 1)
        }
        #expect(backward.componentCount == 1)
        #expect(backward.find(0) == backward.find(n - 1))
        #expect(backward.union(0, n - 1) == false)
    }

    @Test("Random operations agree with a labels-array model", arguments: [(1, 20), (2, 60), (3, 200), (4, 7)])
    func randomAgainstModel(seed: UInt64, count: Int) {
        var steps = Steps(seed: seed)
        var sets = UnionFind(count: count)
        var model = LabelModel(count: count)
        var mismatches = 0
        for _ in 0..<5_000 {
            let a = steps.next(below: count)
            let b = steps.next(below: count)
            switch steps.next(below: 4) {
            case 0, 1:
                if sets.union(a, b) != model.union(a, b) { mismatches += 1 }
            case 2:
                if sets.connected(a, b) != model.connected(a, b) { mismatches += 1 }
            default:
                if sets.size(ofSetContaining: a) != model.size(of: a) { mismatches += 1 }
            }
            if sets.componentCount != model.componentCount { mismatches += 1 }
        }
        #expect(mismatches == 0)
        #expect(sets.groups() == model.groups)
    }

    @Test("Random unions over many elements stay consistent")
    func randomLarge() {
        let n = 20_000
        var steps = Steps(seed: 99)
        var sets = UnionFind(count: n)
        var model = LabelModel(count: n)
        // Relabelling is O(n), so the model only sees a few hundred unions; finds are checked on samples
        for _ in 0..<300 {
            let a = steps.next(below: n)
            let b = steps.next(below: n)
            #expect(sets.union(a, b) == model.union(a, b))
        }
        for _ in 0..<2_000 {
            let a = steps.next(below: n)
            let b = steps.next(below: n)
            #expect(sets.connected(a, b) == model.connected(a, b))
        }
        #expect(sets.componentCount == model.componentCount)
    }
}
