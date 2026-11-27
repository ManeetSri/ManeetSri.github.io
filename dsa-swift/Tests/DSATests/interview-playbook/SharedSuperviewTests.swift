import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same hierarchies
private struct SuperviewRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SharedSuperviewTests {
    /// A settings screen, plus an alert in a second window
    private let screen: [String: String] = [
        "navBar": "window", "backButton": "navBar", "titleLabel": "navBar",
        "tableView": "window", "cell0": "tableView", "icon": "cell0", "label0": "cell0",
        "cell1": "tableView", "toggle": "cell1",
        "alertLabel": "alertWindow",
    ]

    /// The view and its superviews, nearest first
    private func chain(_ view: String, _ superviewOf: [String: String]) -> [String] {
        var result = [view]
        while let parent = superviewOf[result.last!] { result.append(parent) }
        return result
    }

    /// Brute force: the first of b's superviews (itself included) that is also one of a's
    private func reference(_ a: String, _ b: String, _ superviewOf: [String: String]) -> (shared: String, path: [String])? {
        let upA = chain(a, superviewOf), upB = chain(b, superviewOf)
        guard let shared = upB.first(where: { upA.contains($0) }) else { return nil }
        let left = upA.prefix(while: { $0 != shared }) + [shared]
        let right = upB.prefix(while: { $0 != shared })
        return (shared, Array(left) + right.reversed())
    }

    @Test("Nearest common superview on the settings screen", arguments: [
        ("icon", "toggle", "tableView"),
        ("icon", "label0", "cell0"),
        ("titleLabel", "toggle", "window"),
        ("backButton", "titleLabel", "navBar"),
        ("cell0", "icon", "cell0"),
        ("icon", "cell0", "cell0"),
        ("toggle", "toggle", "toggle"),
        ("window", "label0", "window"),
    ])
    func nearest(a: String, b: String, expected: String) {
        #expect(SharedSuperview.nearestCommonSuperview(a, b, superviewOf: screen) == expected)
        #expect(SharedSuperview.nearestCommonSuperview(b, a, superviewOf: screen) == expected, "the order of a and b doesn't matter")
    }

    @Test("Paths on the settings screen", arguments: [
        ("icon", "toggle", ["icon", "cell0", "tableView", "cell1", "toggle"]),
        ("icon", "label0", ["icon", "cell0", "label0"]),
        ("titleLabel", "toggle", ["titleLabel", "navBar", "window", "tableView", "cell1", "toggle"]),
        ("cell0", "icon", ["cell0", "icon"]),
        ("icon", "cell0", ["icon", "cell0"]),
        ("toggle", "toggle", ["toggle"]),
    ])
    func paths(a: String, b: String, expected: [String]) {
        #expect(SharedSuperview.path(from: a, to: b, superviewOf: screen) == expected)
        #expect(SharedSuperview.path(from: b, to: a, superviewOf: screen) == Array(expected.reversed()))
    }

    @Test("Views in different windows share nothing")
    func differentWindows() {
        #expect(SharedSuperview.nearestCommonSuperview("icon", "alertLabel", superviewOf: screen) == nil)
        #expect(SharedSuperview.nearestCommonSuperview("window", "alertWindow", superviewOf: screen) == nil)
        #expect(SharedSuperview.path(from: "alertLabel", to: "toggle", superviewOf: screen) == nil)
        #expect(SharedSuperview.nearestCommonSuperview("alertLabel", "alertWindow", superviewOf: screen) == "alertWindow")
    }

    @Test("A view that appears nowhere in the dictionary is its own window")
    func unknownView() {
        #expect(SharedSuperview.nearestCommonSuperview("ghost", "ghost", superviewOf: screen) == "ghost")
        #expect(SharedSuperview.path(from: "ghost", to: "ghost", superviewOf: [:]) == ["ghost"])
        #expect(SharedSuperview.nearestCommonSuperview("ghost", "window", superviewOf: screen) == nil)
    }

    @Test("Matches brute force on random view hierarchies")
    func randomHierarchies() {
        var random = SuperviewRandom(seed: 71)
        var firstMismatch: String? = nil
        for _ in 0..<200 where firstMismatch == nil {
            let count = Int.random(in: 1...30, using: &random)
            var superviewOf: [String: String] = [:]
            for index in 1..<max(count, 1) where Int.random(in: 0..<10, using: &random) != 0 {
                superviewOf["v\(index)"] = "v\(Int.random(in: 0..<index, using: &random))"
            }
            for _ in 0..<10 where firstMismatch == nil {
                let a = "v\(Int.random(in: 0..<count, using: &random))"
                let b = "v\(Int.random(in: 0..<count, using: &random))"
                let expected = reference(a, b, superviewOf)
                let shared = SharedSuperview.nearestCommonSuperview(a, b, superviewOf: superviewOf)
                let path = SharedSuperview.path(from: a, to: b, superviewOf: superviewOf)
                if shared != expected?.shared || path != expected?.path {
                    firstMismatch = "\(a) and \(b) in \(superviewOf.sorted { $0.key < $1.key }): got \(String(describing: shared)) and \(String(describing: path)), expected \(String(describing: expected?.shared)) and \(String(describing: expected?.path))"
                }
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("A hierarchy 100,000 views deep")
    func deep() {
        // v0 is the window; v1 ... v99999 each sit inside the one before. A second branch of 50,000
        // views hangs off v50000.
        var superviewOf: [String: String] = [:]
        for index in 1..<100_000 { superviewOf["v\(index)"] = "v\(index - 1)" }
        superviewOf["w0"] = "v50000"
        for index in 1..<50_000 { superviewOf["w\(index)"] = "w\(index - 1)" }

        #expect(SharedSuperview.nearestCommonSuperview("v99999", "w49999", superviewOf: superviewOf) == "v50000")
        #expect(SharedSuperview.nearestCommonSuperview("w49999", "v1", superviewOf: superviewOf) == "v1")
        #expect(SharedSuperview.nearestCommonSuperview("v99999", "v0", superviewOf: superviewOf) == "v0")
        let path = SharedSuperview.path(from: "v99999", to: "w49999", superviewOf: superviewOf)
        #expect(path?.count == 100_000)
        #expect(path?.first == "v99999")
        #expect(path?[49_999] == "v50000")
        #expect(path?.last == "w49999")
        #expect(SharedSuperview.nearestCommonSuperview("v99999", "elsewhere", superviewOf: superviewOf) == nil)
    }
}
