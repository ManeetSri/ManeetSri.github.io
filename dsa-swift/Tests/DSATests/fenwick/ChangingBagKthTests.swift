import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BagRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct ChangingBagKthTests {
    /// Keeps the bag as a sorted array. O(n) per change, but clearly right.
    private func reference(_ operations: [[Int]]) -> [Int] {
        var bag: [Int] = []
        var answers: [Int] = []
        for operation in operations {
            switch operation[0] {
            case 0:
                let position = bag.firstIndex { $0 > operation[1] } ?? bag.count
                bag.insert(operation[1], at: position)
            case 1:
                if let position = bag.firstIndex(of: operation[1]) { bag.remove(at: position) }
            default:
                answers.append(operation[1] <= bag.count ? bag[operation[1] - 1] : -1)
            }
        }
        return answers
    }

    /// A fast reference using DSAKit's FenwickTree and its lowerBound(prefix:), which has its own tests.
    private func fastReference(_ operations: [[Int]]) -> [Int] {
        var counts = FenwickTree(count: 1_000_001)          // position v counts the copies of v
        var copies = [Int: Int]()
        var size = 0
        var answers: [Int] = []
        for operation in operations {
            switch operation[0] {
            case 0:
                counts.add(1, at: operation[1])
                copies[operation[1], default: 0] += 1
                size += 1
            case 1:
                if copies[operation[1], default: 0] > 0 {
                    counts.add(-1, at: operation[1])
                    copies[operation[1], default: 0] -= 1
                    size -= 1
                }
            default:
                answers.append(operation[1] <= size ? counts.lowerBound(prefix: operation[1]) : -1)
            }
        }
        return answers
    }

    @Test("The example from the statement")
    func example() {
        let operations = [[0, 5], [0, 2], [0, 9], [2, 2], [0, 2], [2, 2], [1, 2], [1, 7], [2, 3], [2, 4]]
        #expect(ChangingBagKth.process(operations) == [5, 2, 9, -1])
    }

    @Test("Small cases", arguments: [
        ([[2, 1]], [-1]),
        ([[0, 1], [2, 1], [1, 1], [2, 1], [1, 1], [2, 1]], [1, -1, -1]),
        ([[0, 1_000_000], [0, 1], [2, 1], [2, 2], [2, 3]], [1, 1_000_000, -1]),
        ([[0, 4], [0, 4], [0, 4], [1, 4], [2, 1], [2, 2], [2, 3]], [4, 4, -1]),
        ([[0, 8], [0, 3], [0, 6], [0, 1], [2, 1], [2, 2], [2, 3], [2, 4]], [1, 3, 6, 8]),
        ([], []),
    ] as [([[Int]], [Int])])
    func small(operations: [[Int]], expected: [Int]) {
        #expect(ChangingBagKth.process(operations) == expected)
    }

    @Test("Matches a sorted array on 300 small random sequences")
    func randomSmall() {
        var random = BagRandom(seed: 67)
        for _ in 0..<300 {
            let operations = (0..<Int.random(in: 1...40, using: &random)).map { _ -> [Int] in
                switch Int.random(in: 0..<3, using: &random) {
                case 0: return [0, Int.random(in: 1...12, using: &random)]
                case 1: return [1, Int.random(in: 1...12, using: &random)]
                default: return [2, Int.random(in: 1...10, using: &random)]
                }
            }
            #expect(ChangingBagKth.process(operations) == reference(operations))
        }
    }

    @Test("200,000 operations on a bag of up to 100,000 numbers")
    func large() {
        // A sorted array would shift up to 100,000 numbers on every change
        var random = BagRandom(seed: 2_033)
        var operations: [[Int]] = []
        for step in 0..<200_000 {
            if step < 100_000 || step % 3 == 0 {
                operations.append([0, Int.random(in: 1...1_000_000, using: &random)])
            } else if step % 3 == 1 {
                operations.append([1, Int.random(in: 1...1_000_000, using: &random)])
            } else {
                operations.append([2, Int.random(in: 1...110_000, using: &random)])
            }
        }
        let expected = fastReference(operations)
        #expect(expected.contains(-1) && expected.contains { $0 > 0 })   // both kinds of answer occur
        #expect(ChangingBagKth.process(operations) == expected)
    }
}
