import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct EquationConsistencyTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The slow check: give every group of equal variables one label by flood fill, then test the "!=".
    private func modelCanSatisfy(_ equations: [[String]]) -> Bool {
        var equal: [String: [String]] = [:]
        for equation in equations {
            equal[equation[0], default: []].append(equation[1] == "==" ? equation[2] : equation[0])
            equal[equation[2], default: []].append(equation[1] == "==" ? equation[0] : equation[2])
        }
        var label: [String: Int] = [:]
        for start in equal.keys.sorted() where label[start] == nil {
            label[start] = label.count
            var stack = [start]
            while let name = stack.popLast() {
                for other in equal[name, default: []] where label[other] == nil {
                    label[other] = label[start]
                    stack.append(other)
                }
            }
        }
        return equations.allSatisfy { $0[1] == "==" || label[$0[0]] != label[$0[2]] }
    }

    @Test("Satisfiable", arguments: [
        [["a", "==", "b"], ["b", "!=", "c"]],
        [["x", "!=", "y"]],
        [["x", "==", "x"]],
        [["speed", "==", "rate"], ["rate", "!=", "time"], ["time", "==", "t"]],
        [["a", "!=", "b"], ["b", "!=", "c"], ["c", "!=", "a"]],
        [["p", "==", "q"], ["r", "==", "s"], ["p", "!=", "s"]],
    ])
    func satisfiable(equations: [[String]]) {
        #expect(EquationConsistency.canSatisfy(equations) == true)
    }

    @Test("Contradictory", arguments: [
        [["a", "==", "b"], ["b", "!=", "a"]],
        [["a", "==", "b"], ["b", "==", "c"], ["a", "!=", "c"]],
        [["x", "!=", "x"]],
        [["a", "!=", "c"], ["a", "==", "b"], ["b", "==", "c"]],     // the "!=" comes first
        [["m", "==", "n"], ["o", "==", "p"], ["n", "==", "o"], ["p", "!=", "m"]],
    ])
    func contradictory(equations: [[String]]) {
        #expect(EquationConsistency.canSatisfy(equations) == false)
    }

    @Test("No equations at all")
    func empty() {
        #expect(EquationConsistency.canSatisfy([]) == true)
    }

    @Test("Random systems match a flood-fill check", arguments: Array(1...12))
    func random(seed: UInt64) {
        var steps = Steps(seed: seed)
        let names = ["a", "b", "c", "d", "e", "f", "g", "h", "ab", "cd"]
        let equations = (0..<(1 + steps.next(below: 12))).map { _ in
            [names[steps.next(below: names.count)], steps.next(below: 3) == 0 ? "!=" : "==", names[steps.next(below: names.count)]]
        }
        #expect(EquationConsistency.canSatisfy(equations) == modelCanSatisfy(equations))
    }

    @Test("A chain of 100,000 equalities")
    func longChain() {
        let n = 100_000
        let chain = (0..<(n - 1)).map { ["v\($0)", "==", "v\($0 + 1)"] }
        #expect(EquationConsistency.canSatisfy([["v0", "!=", "v\(n - 1)"]] + chain) == false)
        #expect(EquationConsistency.canSatisfy(chain + [["v0", "!=", "w"], ["w", "==", "z"]]) == true)
    }
}
