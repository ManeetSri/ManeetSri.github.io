import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same dictionaries
private struct TypoSearchRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BKTreeTypoSearchTests {
    typealias Tree = BKTreeTypoSearch.Tree

    /// The full edit-distance table, as an independent check on the distances
    private func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        let width = b.count + 1
        var table = [Int](repeating: 0, count: (a.count + 1) * width)     // table[i * width + j]
        for i in 0...a.count { table[i * width] = i }
        for j in 0...b.count { table[j] = j }
        for i in stride(from: 1, through: a.count, by: 1) {
            for j in stride(from: 1, through: b.count, by: 1) {
                table[i * width + j] = min(table[(i - 1) * width + j] + 1, table[i * width + j - 1] + 1,
                                           table[(i - 1) * width + j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1))
            }
        }
        return table[a.count * width + b.count]
    }

    private func tree(_ words: [String]) -> Tree {
        var tree = Tree()
        for word in words { tree.insert(word) }
        return tree
    }

    /// Brute force: every word within the tolerance, closest first, then alphabetically
    private func bruteForce(_ words: [String], _ query: String, _ tolerance: Int) -> [String] {
        Set(words).map { ($0, levenshtein(query, $0)) }.filter { $0.1 <= tolerance }
            .sorted { ($0.1, $0.0) < ($1.1, $1.0) }.map(\.0)
    }

    /// The tree the insertion rule must build, simulated with a dictionary of edges
    private func expectedEdges(_ words: [String]) -> [String: [Int: String]] {
        var edges: [String: [Int: String]] = [:]
        guard let root = words.first else { return edges }
        edges[root] = [:]
        for word in words.dropFirst() where edges[word] == nil {
            var node = root
            while true {
                let d = levenshtein(word, node)
                if let next = edges[node]![d] {
                    node = next
                } else {
                    edges[node]![d] = word
                    edges[word] = [:]
                    break
                }
            }
        }
        return edges
    }

    /// How many distances a correct search computes on this tree: one per node it visits, read off
    /// the tree's own edges
    private func expectedVisits(_ tree: Tree, _ query: String, _ tolerance: Int) -> Int {
        guard let root = tree.root else { return 0 }
        var visits = 0
        var stack = [root]
        while let word = stack.popLast() {
            visits += 1
            let d = levenshtein(query, word)
            for (edge, child) in tree.children(of: word) where abs(edge - d) <= tolerance {
                stack.append(child)
            }
        }
        return visits
    }

    @Test("Levenshtein distances", arguments: [
        ("kitten", "sitting", 3), ("", "abc", 3), ("abc", "", 3), ("", "", 0), ("book", "books", 1),
        ("book", "cake", 4), ("teh", "the", 2), ("flaw", "lawn", 2), ("café", "cafe", 1), ("🙂🙂", "🙂", 1),
    ])
    func distances(a: String, b: String, expected: Int) {
        #expect(BKTreeTypoSearch.distance(a, b) == expected)
        #expect(BKTreeTypoSearch.distance(b, a) == expected)
    }

    @Test("The lesson's tree: book, books, moon, cake, boo, boon")
    func lessonTree() {
        let bk = tree(["book", "books", "moon", "cake", "boo", "boon"])
        #expect(bk.count == 6)
        #expect(bk.root == "book")
        #expect(bk.children(of: "book") == [1: "books", 2: "moon", 4: "cake"])
        #expect(bk.children(of: "books") == [2: "boo"])
        #expect(bk.children(of: "boo") == [1: "boon"])
        #expect(bk.children(of: "boon") == [:])
        #expect(bk.children(of: "cake") == [:])
        #expect(bk.children(of: "missing") == [:])
    }

    @Test("Searching the lesson's tree")
    func lessonSearch() {
        let bk = tree(["book", "books", "moon", "cake", "boo", "boon"])
        #expect(bk.search("bopk", tolerance: 1) == .init(words: ["book"], distancesComputed: 5))
        #expect(bk.search("boo", tolerance: 1) == .init(words: ["boo", "book", "boon"], distancesComputed: 5))
        #expect(bk.search("bake", tolerance: 1) == .init(words: ["cake"], distancesComputed: 3))
        #expect(bk.search("book", tolerance: 0).words == ["book"])
        #expect(bk.search("xyzzy", tolerance: 9).words == ["boo", "book", "books", "boon", "cake", "moon"])
    }

    @Test("Edge cases: an empty tree, duplicates, and Characters that are equal")
    func edgeCases() {
        let empty = Tree()
        #expect(empty.count == 0)
        #expect(empty.root == nil)
        #expect(empty.search("anything", tolerance: 3) == .init(words: [], distancesComputed: 0))

        var bk = tree(["swift", "swift", "shift"])
        #expect(bk.count == 2)
        bk.insert("café")
        bk.insert("cafe\u{301}")                            // the same Characters as "café"
        #expect(bk.count == 3)
        #expect(bk.search("cafe", tolerance: 1).words == ["café"])
        #expect(bk.search("", tolerance: 5).words == ["café", "shift", "swift"])
    }

    @Test("Random dictionaries: the tree's shape, its matches and its distance count are all exact")
    func randomDictionaries() {
        var random = TypoSearchRandom(seed: 74)
        let letters = Array("abcde")
        func word() -> String {
            String((0..<Int.random(in: 0...6, using: &random)).map { _ in letters.randomElement(using: &random)! })
        }
        var firstMismatch: String? = nil
        for _ in 0..<60 where firstMismatch == nil {
            let words = (0..<Int.random(in: 0...60, using: &random)).map { _ in word() }
            let bk = tree(words)
            let edges = expectedEdges(words)
            if bk.count != edges.count { firstMismatch = "count \(bk.count) for \(words), expected \(edges.count)" }
            for (node, children) in edges where firstMismatch == nil && bk.children(of: node) != children {
                firstMismatch = "children of \(node) are \(bk.children(of: node)), expected \(children), for \(words)"
            }
            for _ in 0..<10 where firstMismatch == nil {
                let query = word()
                let tolerance = Int.random(in: 0...3, using: &random)
                let result = bk.search(query, tolerance: tolerance)
                let expected = bruteForce(words, query, tolerance)
                let visits = expectedVisits(bk, query, tolerance)
                if result.words != expected || result.distancesComputed != visits {
                    firstMismatch = "\(query) within \(tolerance) in \(words): got \(result), expected \(expected) with \(visits) distances"
                }
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("A 1,500-word dictionary: small tolerances skip most of it")
    func pruning() {
        var random = TypoSearchRandom(seed: 2_024)
        let letters = Array("etaoinshrdlu")
        var words: [String] = []
        var distinct = Set<String>()
        while distinct.count < 1_500 {
            let word = String((0..<Int.random(in: 4...8, using: &random)).map { _ in letters.randomElement(using: &random)! })
            words.append(word)
            distinct.insert(word)
        }
        let bk = tree(words)
        #expect(bk.count == 1_500)
        var computed = 0
        for index in stride(from: 0, to: words.count, by: 100) {
            // A typo: one letter of a dictionary word replaced
            var typo = Array(words[index])
            typo[typo.count / 2] = "z"
            let query = String(typo)
            let result = bk.search(query, tolerance: 1)
            #expect(result.words == bruteForce(words, query, 1))
            #expect(result.distancesComputed == expectedVisits(bk, query, 1))
            computed += result.distancesComputed
        }
        // By brute force, every search would compute 1,500 distances
        let searches = (words.count + 99) / 100
        #expect(computed < searches * 1_500 / 2)
    }
}
