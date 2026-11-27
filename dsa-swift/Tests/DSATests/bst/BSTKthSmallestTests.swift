import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTKthSmallestTests {
    /// 40 at the root; 20 and 60; 10, 30, 50 and 70; then 15 (right of 10) and 45 (left of 50).
    static let sample: [Int?] = [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45]

    /// A balanced BST holding `values` (sorted), middle value at the root.
    static func balanced(_ values: [Int]) -> TreeNode? {
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let mid = (low + high) / 2
            return TreeNode(values[mid], left: build(low, mid), right: build(mid + 1, high))
        }
        return build(0, values.count)
    }

    @Test("Each k in a small tree", arguments: zip(1...9, [10, 15, 20, 30, 40, 45, 50, 60, 70]))
    func sample(k: Int, expected: Int) {
        #expect(BSTKthSmallest.value(k, in: TreeNode.make(Self.sample)) == expected)
    }

    @Test("A single node")
    func single() {
        #expect(BSTKthSmallest.value(1, in: TreeNode(-4)) == -4)
    }

    @Test("Negative values and extremes")
    func negatives() {
        let root = TreeNode.make([0, -50, Int.max, Int.min, -7])
        #expect(BSTKthSmallest.value(1, in: root) == Int.min)
        #expect(BSTKthSmallest.value(2, in: root) == -50)
        #expect(BSTKthSmallest.value(3, in: root) == -7)
        #expect(BSTKthSmallest.value(4, in: root) == 0)
        #expect(BSTKthSmallest.value(5, in: root) == Int.max)
    }

    @Test("Chains of 500 leaning left and leaning right")
    func chains() {
        let right = TreeNode(1)
        let left = TreeNode(500)
        var rightEnd = right
        var leftEnd = left
        for value in 2...500 {
            rightEnd.right = TreeNode(value)
            rightEnd = rightEnd.right!
            leftEnd.left = TreeNode(501 - value)
            leftEnd = leftEnd.left!
        }
        for k in [1, 2, 250, 499, 500] {
            #expect(BSTKthSmallest.value(k, in: right) == k)
            #expect(BSTKthSmallest.value(k, in: left) == k)
        }
    }

    @Test("A balanced tree of 150,000 nodes")
    func large() {
        let values = (0..<150_000).map { $0 * 3 - 100_000 }
        let root = Self.balanced(values)
        var wrong = 0
        for k in [1, 2, 3, 75_000, 149_999, 150_000] + Array(stride(from: 1, through: 150_000, by: 4_999)) {
            if BSTKthSmallest.value(k, in: root) != values[k - 1] {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
