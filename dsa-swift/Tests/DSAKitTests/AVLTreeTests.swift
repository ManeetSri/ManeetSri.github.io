import Foundation
import Testing
@testable import DSAKit

@Suite struct AVLTreeTests {
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

    /// The tree's shape in level order, with nil for each missing child of a node that exists and
    /// trailing nils removed (the same form TreeNode.make takes).
    private func shape(_ tree: AVLTree<Int>) -> [Int?] {
        var result: [Int?] = []
        var queue: [AVLCore<Int, Void>.Node?] = [tree.core.root]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            if let node {
                result.append(node.key)
                queue.append(node.left)
                queue.append(node.right)
            } else {
                result.append(nil)
            }
        }
        while let last = result.last, last == nil {
            result.removeLast()
        }
        return result
    }

    /// The largest height an AVL tree with n nodes can have, rounded up a little: 1.44 log2(n + 2).
    private func heightBound(_ n: Int) -> Double {
        1.44 * log2(Double(n + 2))
    }

    @Test("A new tree is empty")
    func empty() {
        var tree = AVLTree<Int>()
        #expect(tree.isEmpty)
        #expect(tree.count == 0)
        #expect(tree.height == 0)
        #expect(tree.min() == nil)
        #expect(tree.max() == nil)
        #expect(tree.floor(5) == nil)
        #expect(tree.ceiling(5) == nil)
        #expect(!tree.contains(5))
        #expect(tree.remove(5) == nil)
        #expect(Array(tree) == [])
        #expect(tree.isBalanced)
        #expect(tree.description == "AVLTree([])")
    }

    @Test("A single element is the min, the max and the root")
    func single() {
        var tree: AVLTree = [7]
        #expect(tree.count == 1)
        #expect(tree.height == 1)
        #expect(tree.min() == 7)
        #expect(tree.max() == 7)
        #expect(tree.contains(7))
        #expect(tree.remove(7) == 7)
        #expect(tree.isEmpty)
        #expect(tree.height == 0)
        #expect(tree.isBalanced)
    }

    @Test("Each of the four insert cases rotates to the same balanced shape", arguments: [
        [3, 2, 1],     // left-left: one right rotation
        [1, 2, 3],     // right-right: one left rotation
        [3, 1, 2],     // left-right: rotate the child left, then the root right
        [1, 3, 2],     // right-left: rotate the child right, then the root left
    ])
    func fourCases(order: [Int]) {
        let tree = AVLTree(order)
        #expect(shape(tree) == [2, 1, 3])
        #expect(tree.height == 2)
        #expect(tree.isBalanced)
    }

    @Test("A longer sequence rotates where the lesson says it does")
    func lessonSequence() {
        var tree = AVLTree<Int>()
        for value in [10, 20, 30, 40, 50] {
            tree.insert(value)
        }
        #expect(shape(tree) == [20, 10, 40, nil, nil, 30, 50])
        tree.insert(25)                                   // right-left at the root
        #expect(shape(tree) == [30, 20, 40, 10, 25, nil, 50])
        #expect(tree.isBalanced)
    }

    @Test("Inserting a duplicate returns false and changes nothing")
    func duplicates() {
        var tree: AVLTree = [5, 3, 8]
        #expect(tree.insert(3) == false)
        #expect(tree.insert(4) == true)
        #expect(tree.count == 4)
        let literal: AVLTree = [3, 1, 3, 2, 1]
        #expect(Array(literal) == [1, 2, 3])
        #expect(literal.count == 3)
    }

    @Test("Removing a node with two children uses its successor")
    func removeTwoChildren() {
        var tree: AVLTree = [2, 1, 3]
        #expect(tree.remove(2) == 2)
        #expect(shape(tree) == [3, 1])
        #expect(tree.isBalanced)
    }

    @Test("A removal can need a single rotation when the taller child is level")
    func removeWithLevelChild() {
        var tree: AVLTree = [2, 1, 4, 3, 5]
        tree.remove(1)                                    // 2 is now right-heavy by 2; 4 has balance 0
        #expect(shape(tree) == [4, 2, 5, nil, 3])
        #expect(tree.isBalanced)
    }

    @Test("A removal can need a double rotation")
    func removeDoubleRotation() {
        var tree: AVLTree = [5, 2, 8, 1, 4, 9, 3]
        tree.remove(9)                                    // 8 empties; 5 is left-heavy with a right-heavy child
        #expect(shape(tree) == [4, 2, 5, 1, 3, nil, 8])
        #expect(tree.isBalanced)
    }

    @Test("Removals can rebalance more than one level")
    func removeCascade() {
        // A sparsest AVL tree of height 5 (Fibonacci shape); removing from its short side forces
        // rotations at two levels on the way up.
        var tree: AVLTree = [8, 5, 11, 3, 7, 10, 12, 2, 4, 6, 9, 1]
        #expect(tree.height == 5)
        #expect(tree.isBalanced)
        tree.remove(12)
        #expect(tree.isBalanced)
        #expect(tree.height == 4)
        #expect(Array(tree) == Array(1...11))
    }

    @Test("100,000 sorted inserts stay within the AVL height bound", arguments: [false, true])
    func sortedInserts(descending: Bool) {
        let n = 100_000
        var tree = AVLTree<Int>()
        for i in 0..<n {
            tree.insert(descending ? n - i : i)
        }
        #expect(tree.count == n)
        #expect(Double(tree.height) <= heightBound(n))
        #expect(tree.height <= 18)                        // sorted input builds an almost perfect tree
        #expect(tree.isBalanced)
        #expect(tree.min() == (descending ? 1 : 0))
        #expect(tree.max() == (descending ? n : n - 1))
    }

    @Test("Thousands of random inserts and removes match a Set, and the invariants hold throughout")
    func randomOperations() {
        var steps = Steps(seed: 38)
        var tree = AVLTree<Int>()
        var model = Set<Int>()
        var mismatches = 0
        var broken = 0
        for round in 1...20_000 {
            let value = steps.next(below: 2_000)
            switch steps.next(below: 3) {
            case 0, 1:
                if tree.insert(value) != model.insert(value).inserted { mismatches += 1 }
            default:
                if tree.remove(value) != model.remove(value) { mismatches += 1 }
            }
            if tree.contains(value) != model.contains(value) { mismatches += 1 }
            if round % 1_000 == 0 {
                if !tree.isBalanced { broken += 1 }
                if Array(tree) != model.sorted() { mismatches += 1 }
                if Double(tree.height) > heightBound(tree.count) { broken += 1 }
            }
        }
        #expect(mismatches == 0)
        #expect(broken == 0)
        #expect(tree.count == model.count)
    }

    @Test("Removing everything in a scrambled order keeps the tree valid to the end")
    func drainScrambled() {
        let n = 3_000
        var tree = AVLTree(0..<n)
        var broken = 0
        for i in 0..<n {
            let value = (i * 1_237) % n                   // 1,237 and 3,000 share no factor: every value once
            if tree.remove(value) != value { broken += 1 }
            if i % 100 == 0 && !tree.isBalanced { broken += 1 }
        }
        #expect(broken == 0)
        #expect(tree.isEmpty)
        #expect(tree.height == 0)
    }

    @Test("floor and ceiling at, between and beyond the elements")
    func floorAndCeiling() {
        let tree: AVLTree = [10, 20, 30, 40]
        #expect(tree.floor(5) == nil)
        #expect(tree.ceiling(5) == 10)
        #expect(tree.floor(10) == 10)
        #expect(tree.ceiling(10) == 10)
        #expect(tree.floor(25) == 20)
        #expect(tree.ceiling(25) == 30)
        #expect(tree.floor(40) == 40)
        #expect(tree.floor(45) == 40)
        #expect(tree.ceiling(45) == nil)
    }

    @Test("floor and ceiling agree with a sorted array on random data")
    func floorCeilingRandom() {
        var steps = Steps(seed: 7)
        var tree = AVLTree<Int>()
        for _ in 0..<1_500 {
            tree.insert(steps.next(below: 10_000))
        }
        let sorted = Array(tree)
        var wrong = 0
        for query in stride(from: -5, through: 10_005, by: 7) {
            let floor = sorted.last { $0 <= query }
            let ceiling = sorted.first { $0 >= query }
            if tree.floor(query) != floor || tree.ceiling(query) != ceiling { wrong += 1 }
        }
        #expect(wrong == 0)
    }

    @Test("Copies are independent: changing one never changes another")
    func valueSemantics() {
        let original: AVLTree = [1, 2, 3]
        var inserted = original
        inserted.insert(4)
        var removed = original
        removed.remove(2)
        var cleared = original
        cleared.removeAll()
        #expect(Array(original) == [1, 2, 3])
        #expect(Array(inserted) == [1, 2, 3, 4])
        #expect(Array(removed) == [1, 3])
        #expect(cleared.isEmpty)
        #expect(original.isBalanced && inserted.isBalanced && removed.isBalanced)

        var big = AVLTree(0..<1_000)
        let snapshot = big
        for value in 0..<500 {
            big.remove(value * 2)
        }
        #expect(snapshot.count == 1_000)
        #expect(snapshot.isBalanced)
        #expect(big.count == 500)
        #expect(big.isBalanced)
    }

    @Test("Changing a tree inside a loop over it doesn't change the loop")
    func mutateWhileIterating() {
        var tree: AVLTree = [1, 2, 3, 4, 5]
        var seen: [Int] = []
        for value in tree {
            seen.append(value)
            tree.insert(value + 100)
            tree.remove(value)
        }
        #expect(seen == [1, 2, 3, 4, 5])
        #expect(Array(tree) == [101, 102, 103, 104, 105])
        #expect(tree.isBalanced)
    }

    @Test("Works with any Comparable element, iterating in sorted order")
    func strings() {
        var words: AVLTree = ["pear", "apple", "fig"]
        words.insert("kiwi")
        #expect(Array(words) == ["apple", "fig", "kiwi", "pear"])
        #expect(words.floor("grape") == "fig")
        #expect(words.ceiling("grape") == "kiwi")
        #expect(words.description == "AVLTree([\"apple\", \"fig\", \"kiwi\", \"pear\"])")
    }

    @Test("Equal trees hold the same elements, whatever their shapes")
    func equality() {
        let a = AVLTree([1, 2, 3, 4, 5])
        let b = AVLTree([5, 4, 3, 2, 1])
        #expect(a == b)
        #expect(a != AVLTree([1, 2, 3]))
        #expect(AVLTree<Int>() == AVLTree<Int>())
    }
}
