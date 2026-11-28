import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same files
private struct EditBudgetRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct MyersEditBudgetTests {
    /// Brute force through the LCS table: the fewest edits are n + m - 2 × LCS
    private func editsByLCS(_ a: [String], _ b: [String]) -> Int {
        var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in stride(from: 1, through: a.count, by: 1) {
            for j in stride(from: 1, through: b.count, by: 1) {
                table[i][j] = a[i - 1] == b[j - 1] ? table[i - 1][j - 1] + 1 : max(table[i - 1][j], table[i][j - 1])
            }
        }
        return a.count + b.count - 2 * table[a.count][b.count]
    }

    private let old = ["import UIKit", "", "struct Feed {", "    var posts: [Post]", "}", ""]
    private let new = ["import SwiftUI", "", "struct Feed {", "    var posts: [Post]", "    var isLoading = false", "}"]

    @Test("The statement's examples")
    func examples() {
        // Replace the import (2 edits), add a property (1), drop the trailing blank line (1)
        #expect(MyersEditBudget.distance(from: old, to: new, limit: 10) == 4)
        #expect(MyersEditBudget.distance(from: old, to: new, limit: 4) == 4)
        #expect(MyersEditBudget.distance(from: old, to: new, limit: 3) == nil)
        #expect(MyersEditBudget.distance(from: ["a", "b", "c", "a", "b", "b", "a"], to: ["c", "b", "a", "b", "a", "c"], limit: 100) == 5)
        #expect(MyersEditBudget.distance(from: old, to: old, limit: 0) == 0)
    }

    @Test("Empty files", arguments: [
        ([], [], 0, 0 as Int?),
        ([], ["a", "b"], 5, 2),
        (["a", "b", "c"], [], 5, 3),
        (["a", "b", "c"], [], 2, nil),
        ([], ["x"], 0, nil),
    ] as [([String], [String], Int, Int?)])
    func emptyFiles(old: [String], new: [String], limit: Int, expected: Int?) {
        #expect(MyersEditBudget.distance(from: old, to: new, limit: limit) == expected)
    }

    @Test("A changed line costs two edits; a moved line costs two as well")
    func changesAndMoves() {
        #expect(MyersEditBudget.distance(from: ["a", "b", "c"], to: ["a", "x", "c"], limit: 9) == 2)
        #expect(MyersEditBudget.distance(from: ["a", "b", "c"], to: ["b", "c", "a"], limit: 9) == 2)
        #expect(MyersEditBudget.distance(from: ["a", "b"], to: ["b", "a"], limit: 9) == 2)
        #expect(MyersEditBudget.distance(from: ["a", "a", "a"], to: ["a", "a"], limit: 9) == 1)
    }

    @Test("Matches the LCS table on random small files, with every limit")
    func randomSmall() {
        var random = EditBudgetRandom(seed: 74)
        let lines = ["}", "", "return x", "let y = 1"]
        var firstMismatch: String? = nil
        for _ in 0..<500 where firstMismatch == nil {
            let a = (0..<Int.random(in: 0...12, using: &random)).map { _ in lines.randomElement(using: &random)! }
            let b = (0..<Int.random(in: 0...12, using: &random)).map { _ in lines.randomElement(using: &random)! }
            let exact = editsByLCS(a, b)
            for limit in [0, exact - 1, exact, exact + 1, 30] where limit >= 0 {
                let got = MyersEditBudget.distance(from: a, to: b, limit: limit)
                let expected: Int? = exact <= limit ? exact : nil
                if got != expected {
                    firstMismatch = "\(a) to \(b) with limit \(limit): got \(String(describing: got)), expected \(String(describing: expected))"
                    break
                }
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("Two 100,000-line files with 30 scattered edits")
    func largeSimilar() {
        // Unique lines, so the fewest edits are exactly the deletions plus the insertions made here
        var random = EditBudgetRandom(seed: 2_024)
        let old = (0..<100_000).map { "line \($0)" }
        var new = old
        var edits = 0
        for round in 0..<10 {
            var at = Int.random(in: 0..<new.count, using: &random)
            while !new[at].hasPrefix("line ") {                       // only touch original lines
                at = Int.random(in: 0..<new.count, using: &random)
            }
            switch round % 3 {
            case 0:
                new.remove(at: at)                                   // a deleted line
                edits += 1
            case 1:
                new.insert("added \(round)", at: at)                 // an inserted line
                edits += 1
            default:
                new[at] = "changed \(round)"                          // a changed line: one of each
                edits += 2
            }
        }
        for round in 10..<30 {
            new.insert("added \(round)", at: Int.random(in: 0...new.count, using: &random))
            edits += 1
        }
        #expect(MyersEditBudget.distance(from: old, to: new, limit: 100) == edits)
        #expect(MyersEditBudget.distance(from: old, to: new, limit: edits) == edits)
        #expect(MyersEditBudget.distance(from: old, to: new, limit: edits - 1) == nil)
    }

    @Test("Files that are nothing alike give up quickly")
    func largeDifferent() {
        let old = (0..<50_000).map { "old \($0)" }
        let new = (0..<50_000).map { "new \($0)" }
        #expect(MyersEditBudget.distance(from: old, to: new, limit: 200) == nil)
    }

    @Test("Long runs of identical lines, like closing braces")
    func repeatedLines() {
        let old = Array(repeating: "}", count: 60_000)
        var new = old
        new.insert("// note", at: 20_000)
        new.insert("// note", at: 40_000)
        new.append("// end")
        #expect(MyersEditBudget.distance(from: old, to: new, limit: 10) == 3)
        #expect(MyersEditBudget.distance(from: new, to: old, limit: 10) == 3)
        #expect(MyersEditBudget.distance(from: old, to: Array(old.dropLast(5)), limit: 10) == 5)
    }
}
