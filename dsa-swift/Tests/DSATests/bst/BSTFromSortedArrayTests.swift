import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTFromSortedArrayTests {
    /// The height of `root` if every node's subtrees differ in height by at most one, or nil if some
    /// node is out of balance. Trees taller than `limit` count as unbalanced without a full check, so
    /// a long chain can't overflow the stack.
    static func balancedHeight(_ root: TreeNode?, limit: Int = 64) -> Int? {
        guard let root else { return 0 }
        guard root.height <= limit else { return nil }
        func check(_ node: TreeNode?) -> Int? {
            guard let node else { return 0 }
            guard let left = check(node.left), let right = check(node.right), abs(left - right) <= 1 else {
                return nil
            }
            return 1 + Swift.max(left, right)
        }
        return check(root)
    }

    @Test("Small arrays", arguments: [
        [1], [1, 2], [1, 2, 3], [-10, -3, 0, 5, 9], [2, 4, 6, 8, 10, 12, 14], [Int.min, 0, Int.max],
    ])
    func small(values: [Int]) {
        let root = BSTFromSortedArray.build(values)
        #expect(root?.inorder == values)
        #expect(Self.balancedHeight(root) != nil)
    }

    @Test("No values give the empty tree")
    func empty() {
        #expect(BSTFromSortedArray.build([]) == nil)
    }

    @Test("Every size from 1 to 100 is balanced and as short as possible")
    func everySize() {
        var wrong: [Int] = []
        for count in 1...100 {
            let values = Array(1...count)
            let root = BSTFromSortedArray.build(values)
            let shortest = Int.bitWidth - count.leadingZeroBitCount     // levels needed for count nodes
            if root?.inorder != values || Self.balancedHeight(root) == nil || root?.height != shortest {
                wrong.append(count)
            }
        }
        #expect(wrong == [], "the sizes that came out wrong")
    }

    @Test("200,000 values")
    func large() {
        let values = (0..<200_000).map { $0 * 5 - 300_000 }
        let root = BSTFromSortedArray.build(values)
        let sorted = root?.inorder == values
        #expect(sorted)
        #expect(Self.balancedHeight(root) == 18)
    }
}
