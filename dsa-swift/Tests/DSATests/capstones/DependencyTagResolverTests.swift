import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same tag lists
private struct TagResolverRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DependencyTagResolverTests {
    typealias Rule = DependencyTagResolver.Rule

    private let tags = ["0.9.0", "0.10.0", "1.0.0", "1.2.0", "1.10.0", "1.9.3", "v1.10.1", "2.0.0", "nightly"]

    @Test("The statement's examples", arguments: [
        ([Rule.upToNextMajor(from: "1.2.0")], "1.10.1" as String?),
        ([.upToNextMinor(from: "1.9.0")], "1.9.3"),
        ([.upToNextMajor(from: "0.9.0")], "0.10.0"),
        ([.upToNextMinor(from: "0.9.0")], "0.9.0"),
        ([.exact("1.10.1")], "1.10.1"),
        ([.upToNextMajor(from: "1.2.0"), .upToNextMinor(from: "1.9.0")], "1.9.3"),
        ([.upToNextMajor(from: "1.2.0"), .upToNextMajor(from: "2.0.0")], nil),
        ([], "2.0.0"),
        ([.upToNextMajor(from: "3.0.0")], nil),
        ([.exact("1.1.0")], nil),
    ])
    func examples(rules: [Rule], expected: String?) {
        #expect(DependencyTagResolver.resolve(tags: tags, rules: rules) == expected)
    }

    @Test("Versions compare number by number, not as text")
    func numericOrder() {
        #expect(DependencyTagResolver.resolve(tags: ["1.9.0", "1.10.0", "1.2.0"], rules: []) == "1.10.0")
        #expect(DependencyTagResolver.resolve(tags: ["2.0.0", "10.0.0", "9.99.99"], rules: []) == "10.0.0")
        #expect(DependencyTagResolver.resolve(tags: ["0.0.9", "0.0.10", "0.0.1"], rules: []) == "0.0.10")
        #expect(DependencyTagResolver.resolve(tags: ["1.0.10", "1.1.0"], rules: []) == "1.1.0")
    }

    @Test("Valid tags, written with or without a v", arguments: [
        ("1.2.3", "1.2.3"), ("v1.2.3", "1.2.3"), ("0.0.0", "0.0.0"), ("v0.0.0", "0.0.0"),
        ("10.20.30", "10.20.30"), ("1.0.0", "1.0.0"), ("v100.0.7", "100.0.7"),
        ("9223372036854775807.0.0", "9223372036854775807.0.0"),
    ])
    func validTag(tag: String, expected: String) {
        #expect(DependencyTagResolver.resolve(tags: [tag], rules: []) == expected)
    }

    @Test("Tags that aren't versions are ignored", arguments: [
        "nightly", "", "v", "1", "1.2", "1.2.3.4", "1..3", ".1.2", "1.2.", "1.02.3", "01.2.3", "1.2.03",
        "00.1.1", "V1.2.3", "vv1.2.3", " 1.2.3", "1.2.3 ", "+1.2.3", "1.-2.3", "1.2.3-beta", "1.2.3+build",
        "１.2.3", "1.٢.3", "1.2.x", "release-1.2.3", "9223372036854775808.0.0", "1.2.99999999999999999999",
    ])
    func invalidTag(tag: String) {
        #expect(DependencyTagResolver.resolve(tags: [tag], rules: []) == nil, "\(tag) isn't a version")
        #expect(DependencyTagResolver.resolve(tags: [tag, "0.1.0"], rules: []) == "0.1.0", "\(tag) mustn't win")
    }

    @Test("The same version tagged twice comes back once, without the v")
    func duplicateTags() {
        #expect(DependencyTagResolver.resolve(tags: ["v1.4.0", "1.4.0"], rules: [.exact("1.4.0")]) == "1.4.0")
        #expect(DependencyTagResolver.resolve(tags: [], rules: []) == nil)
    }

    @Test("Range edges: the lower bound is allowed, the upper bound isn't")
    func rangeEdges() {
        let tags = ["1.4.9", "1.5.0", "1.5.7", "1.6.0", "2.0.0"]
        #expect(DependencyTagResolver.resolve(tags: tags, rules: [.upToNextMinor(from: "1.5.0")]) == "1.5.7")
        #expect(DependencyTagResolver.resolve(tags: tags, rules: [.upToNextMinor(from: "1.5.7")]) == "1.5.7")
        #expect(DependencyTagResolver.resolve(tags: tags, rules: [.upToNextMinor(from: "1.5.8")]) == nil)
        #expect(DependencyTagResolver.resolve(tags: tags, rules: [.upToNextMajor(from: "1.4.9")]) == "1.6.0")
        #expect(DependencyTagResolver.resolve(tags: tags, rules: [.upToNextMajor(from: "2.0.0")]) == "2.0.0")
        #expect(DependencyTagResolver.resolve(tags: tags, rules: [.exact("1.5.0"), .upToNextMinor(from: "1.5.0")]) == "1.5.0")
    }

    @Test("Next release after 1.0.0", arguments: [
        ("1.2.0", ["Heap.insert", "Heap.pop"], ["Heap.insert", "Heap.pop"], "1.2.1"),
        ("1.2.0", ["Heap.insert", "Heap.pop"], ["Heap.insert", "Heap.pop", "Heap.replaceTop"], "1.3.0"),
        ("1.2.0", ["Heap.insert", "Heap.peek"], ["Heap.insert", "Heap.top"], "2.0.0"),
        ("1.2.0", ["Heap.insert", "Heap.peek"], ["Heap.insert"], "2.0.0"),
        ("3.9.12", [], [], "3.9.13"),
        ("3.9.12", [], ["Trie.insert"], "3.10.0"),
        ("1.10.9", ["A"], ["B", "C"], "2.0.0"),
    ])
    func nextAfterOne(current: String, old: [String], new: [String], expected: String) {
        #expect(DependencyTagResolver.nextRelease(after: current, oldAPI: Set(old), newAPI: Set(new)) == expected)
    }

    @Test("Next release before 1.0.0: breaking bumps the minor number, anything else the patch", arguments: [
        ("0.4.2", ["A", "B"], ["A", "B"], "0.4.3"),
        ("0.4.2", ["A", "B"], ["A", "B", "C"], "0.4.3"),
        ("0.4.2", ["A", "B"], ["A"], "0.5.0"),
        ("0.0.0", [], [], "0.0.1"),
        ("0.9.9", ["A"], ["B"], "0.10.0"),
    ])
    func nextBeforeOne(current: String, old: [String], new: [String], expected: String) {
        #expect(DependencyTagResolver.nextRelease(after: current, oldAPI: Set(old), newAPI: Set(new)) == expected)
    }

    @Test("Matches a brute force on random tags and rules")
    func randomResolution() {
        var random = TagResolverRandom(seed: 74)
        typealias Version = (Int, Int, Int)
        func text(_ v: Version) -> String { "\(v.0).\(v.1).\(v.2)" }
        func random3() -> Version {
            (Int.random(in: 0...2, using: &random), Int.random(in: 0...11, using: &random), Int.random(in: 0...3, using: &random))
        }
        var firstMismatch: String? = nil
        for _ in 0..<300 where firstMismatch == nil {
            let versions = (0..<Int.random(in: 0...12, using: &random)).map { _ in random3() }
            let tags = versions.map { (Bool.random(using: &random) ? "v" : "") + text($0) } + ["latest", "1.2"]
            var rules: [Rule] = []
            var allowed: [(Version) -> Bool] = []
            for _ in 0..<Int.random(in: 0...2, using: &random) {
                let low = random3()
                switch Int.random(in: 0..<3, using: &random) {
                case 0:
                    rules.append(.upToNextMajor(from: text(low)))
                    allowed.append { v in v >= low && v < (low.0 + 1, 0, 0) }
                case 1:
                    rules.append(.upToNextMinor(from: text(low)))
                    allowed.append { v in v >= low && v < (low.0, low.1 + 1, 0) }
                default:
                    rules.append(.exact(text(low)))
                    allowed.append { v in v == low }
                }
            }
            let best = versions.filter { v in allowed.allSatisfy { $0(v) } }.max { $0 < $1 }
            let expected = best.map(text)
            let got = DependencyTagResolver.resolve(tags: tags, rules: rules)
            if got != expected {
                firstMismatch = "tags \(tags), rules \(rules): got \(String(describing: got)), expected \(String(describing: expected))"
            }
        }
        #expect(firstMismatch == nil)
    }
}
