import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WeakParentTreeTests {
    typealias Node = WeakParentTree.Node

    /// Builds   1
    ///         / \
    ///        2   3
    ///        |
    ///        4
    private func sampleTree() -> (root: Node, two: Node, three: Node, four: Node) {
        let root = Node(1)
        let two = Node(2)
        let three = Node(3)
        let four = Node(4)
        root.addChild(two)
        root.addChild(three)
        two.addChild(four)
        return (root, two, three, four)
    }

    @Test("addChild links parent and child")
    func addChildLinks() {
        let tree = sampleTree()
        #expect(tree.root.children.map(\.value) == [2, 3])
        #expect(tree.two.children.map(\.value) == [4])
        #expect(tree.two.parent === tree.root)
        #expect(tree.four.parent === tree.two)
        #expect(tree.root.parent == nil)
    }

    @Test("Depth counts the steps up to the root")
    func depths() {
        let tree = sampleTree()
        #expect(tree.root.depth == 0)
        #expect(tree.two.depth == 1)
        #expect(tree.three.depth == 1)
        #expect(tree.four.depth == 2)
    }

    @Test("pathToRoot lists values from the node up to the root")
    func paths() {
        let tree = sampleTree()
        #expect(tree.four.pathToRoot == [4, 2, 1])
        #expect(tree.three.pathToRoot == [3, 1])
        #expect(tree.root.pathToRoot == [1])
    }

    @Test("root finds the topmost ancestor")
    func roots() {
        let tree = sampleTree()
        #expect(tree.four.root === tree.root)
        #expect(tree.root.root === tree.root)
    }

    @Test("A lone node is its own root at depth 0")
    func loneNode() {
        let node = Node(7)
        #expect(node.depth == 0)
        #expect(node.pathToRoot == [7])
        #expect(node.root === node)
        #expect(node.children.isEmpty)
    }

    @Test("A parent keeps its children alive")
    func parentKeepsChildren() {
        let root = Node(1)
        do {
            let child = Node(2)
            root.addChild(child)
        }
        #expect(root.children.count == 1)
        #expect(root.children.first?.parent === root)
    }

    @Test("A child doesn't keep its parent alive")
    func childDoesNotKeepParent() {
        let leaf = Node(3)
        weak var weakRoot: Node?
        do {
            let root = Node(1)
            let middle = Node(2)
            root.addChild(middle)
            middle.addChild(leaf)
            weakRoot = root
            #expect(leaf.depth == 2)
        }
        #expect(weakRoot == nil, "The root leaked: is the parent pointer weak?")
        #expect(leaf.parent == nil)
        #expect(leaf.depth == 0)
        #expect(leaf.pathToRoot == [3])
    }

    @Test("A whole tree is freed when its root is released")
    func wholeTreeFreed() {
        weak var weakRoot: Node?
        weak var weakLeaf: Node?
        do {
            let tree = sampleTree()
            weakRoot = tree.root
            weakLeaf = tree.four
        }
        #expect(weakRoot == nil)
        #expect(weakLeaf == nil)
    }

    @Test("Adding a child that already has a parent moves it")
    func moveChild() {
        let tree = sampleTree()
        tree.three.addChild(tree.four)
        #expect(tree.two.children.isEmpty)
        #expect(tree.three.children.map(\.value) == [4])
        #expect(tree.four.parent === tree.three)
        #expect(tree.four.pathToRoot == [4, 3, 1])
    }

    @Test("Works on a deep chain")
    func deepChain() {
        let root = Node(0)
        var bottom = root
        for value in 1...1_000 {
            let next = Node(value)
            bottom.addChild(next)
            bottom = next
        }
        #expect(bottom.depth == 1_000)
        #expect(bottom.root === root)
        #expect(bottom.pathToRoot.count == 1_001)
        #expect(bottom.pathToRoot.first == 1_000)
        #expect(bottom.pathToRoot.last == 0)
    }
}
