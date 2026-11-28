import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The columns worked out with a recursive walk and a dictionary of columns, a different method from
/// the solution: each column collects (row, value) pairs and is sorted on its own.
private func referenceColumns(_ root: TreeNode?) -> [[Int]] {
    var byColumn: [Int: [(row: Int, value: Int)]] = [:]
    func walk(_ node: TreeNode?, column: Int, row: Int) {
        guard let node else { return }
        byColumn[column, default: []].append((row, node.value))
        walk(node.left, column: column - 1, row: row + 1)
        walk(node.right, column: column + 1, row: row + 1)
    }
    walk(root, column: 0, row: 0)
    return byColumn.keys.sorted().map { column in
        byColumn[column]!.sorted { ($0.row, $0.value) < ($1.row, $1.value) }.map(\.value)
    }
}

/// A binary search tree of `count` pseudo-random values below `limit` (the same every run).
private func randomTree(count: Int, limit: Int, seed: UInt64) -> TreeNode? {
    var state = seed
    var root: TreeNode? = nil
    for _ in 0..<count {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        let value = Int(state >> 33) % limit
        guard var node = root else {
            root = TreeNode(value)
            continue
        }
        while true {
            if value < node.value {
                guard let left = node.left else { node.left = TreeNode(value); break }
                node = left
            } else {
                guard let right = node.right else { node.right = TreeNode(value); break }
                node = right
            }
        }
    }
    return root
}

/// Where two long arrays first differ, so a failing test doesn't print 100,000 values.
private func firstDifference<T: Equatable>(_ actual: [T], _ expected: [T]) -> String? {
    guard actual != expected else { return nil }
    let index = actual.indices.first { $0 >= expected.count || actual[$0] != expected[$0] } ?? actual.count
    func show(_ values: [T]) -> String {
        guard index < values.count else { return "nothing" }
        let text = "\(values[index])"
        return text.count > 80 ? text.prefix(80) + "…" : text
    }
    let got = show(actual)
    let wanted = show(expected)
    return "\(actual.count) values instead of \(expected.count); first difference at index \(index): got \(got), expected \(wanted)"
}

@Suite struct VerticalColumnsTests {
    @Test("Small trees", arguments: [
        ([1, 2, 3, 4, 5, nil, 6, nil, nil, 7], [[4], [2, 7], [1, 5], [3], [6]]),
        ([3, 9, 20, nil, nil, 15, 7], [[9], [3, 15], [20], [7]]),
        ([1, nil, 2, nil, 3], [[1], [2], [3]]),
        ([1, 2, nil, 3], [[3], [2], [1]]),
        ([1, 2, nil, nil, 3], [[2], [1, 3]]),
        ([7], [[7]]),
    ] as [([Int?], [[Int]])])
    func small(levelOrder: [Int?], expected: [[Int]]) {
        #expect(VerticalColumns.columns(TreeNode.make(levelOrder)) == expected)
    }

    @Test("Nodes sharing a row and column go in increasing order of value")
    func sameCell() {
        #expect(VerticalColumns.columns(TreeNode.make([10, 20, 30, 40, 60, 50, 70])) == [[40], [20], [10, 50, 60], [30], [70]])
        // Level order would list 9 before 2; the rule says 2 first
        #expect(VerticalColumns.columns(TreeNode.make([8, 3, 5, nil, 9, 2])) == [[3], [8, 2, 9], [5]])
    }

    @Test("Rows come before values: a higher node goes first even when its value is bigger")
    func rowsFirst() {
        #expect(VerticalColumns.columns(TreeNode.make([100, 5, 7, nil, 1])) == [[5], [100, 1], [7]])
    }

    @Test("Duplicates and negatives")
    func duplicates() {
        #expect(VerticalColumns.columns(TreeNode.make([2, 2, 2, 2, 2])) == [[2], [2], [2, 2], [2]])
        #expect(VerticalColumns.columns(TreeNode.make([0, -3, -1, nil, -2, -4])) == [[-3], [0, -4, -2], [-1]])
    }

    @Test("The empty tree")
    func empty() {
        #expect(VerticalColumns.columns(nil) == [])
    }

    @Test("A complete tree of 100,000 nodes")
    func largeComplete() {
        // In a complete tree with values 1...n in level order, the path to node i is written in i's
        // binary digits after the leading 1: 0 for left, 1 for right. Its row is the number of those digits.
        let n = 100_000
        var cells: [(column: Int, row: Int, value: Int)] = []
        for value in 1...n {
            var column = 0
            var row = 0
            var bit = (Int.bitWidth - 1 - value.leadingZeroBitCount) - 1
            while bit >= 0 {
                column += (value >> bit) & 1 == 1 ? 1 : -1
                row += 1
                bit -= 1
            }
            cells.append((column, row, value))
        }
        cells.sort { ($0.column, $0.row, $0.value) < ($1.column, $1.row, $1.value) }
        var expected: [[Int]] = []
        var last: Int? = nil
        for cell in cells {
            if cell.column != last {
                expected.append([])
                last = cell.column
            }
            expected[expected.count - 1].append(cell.value)
        }
        let columns = VerticalColumns.columns(TreeNode.make(Array(1...n)))
        // Node 65,536 is furthest left (column -16) and node 65,535 furthest right (column 15)
        #expect(columns.count == 32)
        #expect(columns.first?.first == 65_536)
        #expect(firstDifference(columns, expected) == nil)
    }

    @Test("A random tree of 100,000 nodes with many repeated values")
    func largeRandom() {
        let root = randomTree(count: 100_000, limit: 1_000, seed: 36)
        #expect(firstDifference(VerticalColumns.columns(root), referenceColumns(root)) == nil)
    }
}
