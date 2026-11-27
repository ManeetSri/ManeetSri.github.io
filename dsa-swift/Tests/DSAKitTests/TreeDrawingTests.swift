import Testing
import DSAKit

@Suite struct TreeDrawingTests {
    @Test("A single node is just its value")
    func single() {
        #expect(TreeNode(5).diagram == "5")
        #expect(TreeNode(-12).diagram == "-12")
    }

    @Test("The course's running example")
    func runningExample() throws {
        let root = try #require(TreeNode.make([1, 2, 3, 4, 5, nil, 6, nil, nil, 7]))
        let expected = [
            "    ┌── 6",
            "┌── 3",
            "1",
            "│   ┌── 5",
            "│   │   └── 7",
            "└── 2",
            "    └── 4",
        ]
        #expect(root.diagram == expected.joined(separator: "\n"))
    }

    @Test("Children line up under values of any width")
    func wideValues() throws {
        let root = try #require(TreeNode.make([100, 7, 2500, nil, nil, 3, 41]))
        let expected = [
            "    ┌── 41",
            "┌── 2500",
            "│   └── 3",
            "100",
            "└── 7",
        ]
        #expect(root.diagram == expected.joined(separator: "\n"))
        #expect(TreeNode.make([-1, -2, 5])?.diagram == "┌── 5\n-1\n└── -2")
    }

    @Test("Chains to the left, to the right, and zigzagging")
    func chains() {
        #expect(TreeNode.make([3, 2, nil, 1])?.diagram == "3\n└── 2\n    └── 1")
        #expect(TreeNode.make([1, nil, 2, nil, 3])?.diagram == "    ┌── 3\n┌── 2\n1")
        #expect(TreeNode.make([1, 2, nil, nil, 3])?.diagram == "1\n│   ┌── 3\n└── 2")
    }

    @Test("One line per node, from the rightmost node to the leftmost")
    func reverseInorder() throws {
        let root = try #require(TreeNode.make([8, 4, 12, 2, 6, 10, 14, 1, 3, 5, 7, 9, 11, 13, 15]))
        let lines = root.diagram.split(separator: "\n")
        #expect(lines.count == 15)
        let values = lines.map { line in Int(line.split(separator: " ").last!)! }
        #expect(values == Array((1...15).reversed()))
    }

    @Test("A 2,000-node chain draws without trouble")
    func deepChain() {
        let root = TreeNode(1)
        var current = root
        for value in 2...2_000 {
            let next = TreeNode(value)
            current.left = next
            current = next
        }
        let lines = root.diagram.split(separator: "\n", omittingEmptySubsequences: false)
        #expect(lines.count == 2_000)
        #expect(lines.last == Substring(String(repeating: "    ", count: 1_998) + "└── 2000"))
    }
}
