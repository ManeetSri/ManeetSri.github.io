import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same folders
private struct FolderRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FolderPathListingTests {
    /// Straightforward version: recursion, passing each folder's path down as a String.
    /// Only used on shallow trees.
    private func reference(_ names: [String], _ parents: [Int]) -> String {
        var children = Array(repeating: [Int](), count: names.count)
        for folder in 1..<names.count {
            children[parents[folder]].append(folder)
        }
        var lines: [String] = []
        func visit(_ folder: Int, _ path: String) {
            lines.append(path)
            for child in children[folder] {
                visit(child, path + "/" + names[child])
            }
        }
        visit(0, names[0])
        return lines.map { $0 + "\n" }.joined()
    }

    @Test("Examples", arguments: [
        (["home"], [-1], "home\n"),
        (["home", "docs", "pics", "cv"], [-1, 0, 0, 1], "home\nhome/docs\nhome/docs/cv\nhome/pics\n"),
        (["a", "b", "c", "d"], [-1, 0, 1, 2], "a\na/b\na/b/c\na/b/c/d\n"),
        (["r", "x", "y", "z"], [-1, 0, 0, 0], "r\nr/x\nr/y\nr/z\n"),
        (["app", "src", "tests", "main.swift", "util", "io.swift"], [-1, 0, 0, 1, 1, 4],
         "app\napp/src\napp/src/main.swift\napp/src/util\napp/src/util/io.swift\napp/tests\n"),
    ] as [([String], [Int], String)])
    func examples(names: [String], parents: [Int], expected: String) {
        #expect(FolderPathListing.listing(names: names, parents: parents) == expected)
    }

    @Test("Subfolders are listed in number order, even when they were added to different parents in between")
    func childOrder() {
        let names = ["r", "a", "b", "a1", "b1", "a2"]
        let parents = [-1, 0, 0, 1, 2, 1]
        #expect(FolderPathListing.listing(names: names, parents: parents) == "r\nr/a\nr/a/a1\nr/a/a2\nr/b\nr/b/b1\n")
    }

    @Test("Matches the straightforward version on 300 small random trees")
    func randomSmall() {
        var random = FolderRandom(seed: 68)
        for _ in 0..<300 {
            let n = Int.random(in: 1...30, using: &random)
            let names = (0..<n).map { "f\($0)" }
            let parents = (0..<n).map { $0 == 0 ? -1 : Int.random(in: 0..<$0, using: &random) }
            #expect(FolderPathListing.listing(names: names, parents: parents) == reference(names, parents))
        }
    }

    @Test("100,000 folders in a random tree")
    func largeRandom() {
        var random = FolderRandom(seed: 2_026)
        let n = 100_000
        let names = (0..<n).map { "n" + String($0, radix: 36) }
        let parents = (0..<n).map { $0 == 0 ? -1 : Int.random(in: 0..<$0, using: &random) }
        #expect(FolderPathListing.listing(names: names, parents: parents) == reference(names, parents))
    }

    @Test("100,000 folders directly inside the root")
    func wide() {
        let n = 100_000
        let names = ["root"] + (1..<n).map { String($0) }
        let parents = [-1] + Array(repeating: 0, count: n - 1)
        var expected = "root\n"
        for folder in 1..<n {
            expected += "root/\(folder)\n"
        }
        #expect(FolderPathListing.listing(names: names, parents: parents) == expected)
    }

    @Test("A chain 3,000 folders deep (about 22 million characters of output)")
    func deepChain() {
        let n = 3_000
        let names = (0..<n).map { "d" + String($0 % 1_000 + 1_000) }      // always 5 characters
        let parents = (0..<n).map { $0 - 1 }                               // parents[0] is -1
        var path = ""
        var expected = ""
        expected.reserveCapacity(6 * n * (n + 1) / 2)
        for folder in 0..<n {
            path += folder == 0 ? names[0] : "/" + names[folder]
            expected += path
            expected += "\n"
        }
        let result = FolderPathListing.listing(names: names, parents: parents)
        #expect(result.utf8.count == expected.utf8.count)
        #expect(result == expected)
    }
}
