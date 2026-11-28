import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTIteratorDesignTests {
    typealias InorderIterator = BSTIteratorDesign.InorderIterator

    /// 40 at the root; 20 and 60; 10, 30, 50 and 70; then 15 (right of 10) and 45 (left of 50).
    static let sample: [Int?] = [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45]

    /// Calls `next()` until it returns nil, but at most `limit` times, so a broken iterator can't
    /// loop for ever.
    static func drain(_ iterator: inout InorderIterator, limit: Int) -> [Int] {
        var values: [Int] = []
        while values.count < limit, let value = iterator.next() {
            values.append(value)
        }
        return values
    }

    @Test("Returns every value in increasing order, then nil")
    func sampleOrder() {
        var iterator = InorderIterator(TreeNode.make(Self.sample))
        #expect(Self.drain(&iterator, limit: 20) == [10, 15, 20, 30, 40, 45, 50, 60, 70])
        #expect(iterator.next() == nil)
        #expect(!iterator.hasNext)
        #expect(iterator.peek() == nil)
    }

    @Test("peek and hasNext don't move the iterator on")
    func peekAndHasNext() {
        var iterator = InorderIterator(TreeNode.make([5, 3, 8, nil, 4]))
        #expect(iterator.hasNext)
        #expect(iterator.peek() == 3)
        #expect(iterator.peek() == 3)
        #expect(iterator.next() == 3)
        #expect(iterator.peek() == 4)
        #expect(iterator.hasNext)
        #expect(iterator.next() == 4)
        #expect(iterator.next() == 5)
        #expect(iterator.hasNext)
        #expect(iterator.peek() == 8)
        #expect(iterator.next() == 8)
        #expect(!iterator.hasNext)
        #expect(iterator.next() == nil)
    }

    @Test("The empty tree and a single node")
    func tiny() {
        var empty = InorderIterator(nil)
        #expect(!empty.hasNext)
        #expect(empty.peek() == nil)
        #expect(empty.next() == nil)
        var single = InorderIterator(TreeNode(7))
        #expect(single.hasNext)
        #expect(single.next() == 7)
        #expect(!single.hasNext)
    }

    @Test("Works anywhere an IteratorProtocol does")
    func iteratorProtocol() {
        let firstThree = Array(IteratorSequence(InorderIterator(TreeNode.make(Self.sample))).prefix(3))
        #expect(firstThree == [10, 15, 20])
    }

    @Test("A copy of the iterator carries on independently")
    func copies() {
        var first = InorderIterator(TreeNode.make(Self.sample))
        #expect(first.next() == 10)
        var second = first
        #expect(second.next() == 15)
        #expect(second.next() == 20)
        #expect(first.next() == 15)
    }

    @Test("Chains of 1,000 nodes leaning left and leaning right")
    func chains() {
        let right = TreeNode(1)
        let left = TreeNode(1_000)
        var rightEnd = right
        var leftEnd = left
        for value in 2...1_000 {
            rightEnd.right = TreeNode(value)
            rightEnd = rightEnd.right!
            leftEnd.left = TreeNode(1_001 - value)
            leftEnd = leftEnd.left!
        }
        var fromRight = InorderIterator(right)
        var fromLeft = InorderIterator(left)
        let rightCorrect = Self.drain(&fromRight, limit: 2_000) == Array(1...1_000)
        let leftCorrect = Self.drain(&fromLeft, limit: 2_000) == Array(1...1_000)
        #expect(rightCorrect)
        #expect(leftCorrect)
    }

    @Test("A balanced tree of 131,071 nodes")
    func large() throws {
        let n = 131_071
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let mid = (low + high) / 2
            return TreeNode(mid * 2, left: build(low, mid), right: build(mid + 1, high))
        }
        let root = try #require(build(0, n))
        var iterator = InorderIterator(root)
        #expect(iterator.peek() == 0)
        let correct = Self.drain(&iterator, limit: n + 1) == (0..<n).map { $0 * 2 }
        #expect(correct)
        #expect(!iterator.hasNext)
    }
}
