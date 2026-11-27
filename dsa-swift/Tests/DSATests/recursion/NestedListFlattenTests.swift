import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NestedListFlattenTests {
    typealias Item = NestedListFlatten.Item

    // [1, [2, [3]], 4]
    static var mixed: Item {
        .list([.number(1), .list([.number(2), .list([.number(3)])]), .number(4)])
    }

    @Test("Flattens a single number")
    func singleNumber() {
        #expect(NestedListFlatten.flatten(.number(5)) == [5])
        #expect(NestedListFlatten.depth(.number(5)) == 0)
    }

    @Test("Handles empty lists")
    func emptyLists() {
        #expect(NestedListFlatten.flatten(.list([])) == [])
        #expect(NestedListFlatten.depth(.list([])) == 1)
        let nestedEmpty = Item.list([.list([.list([])])])
        #expect(NestedListFlatten.flatten(nestedEmpty) == [])
        #expect(NestedListFlatten.depth(nestedEmpty) == 3)
    }

    @Test("Flattens a flat list")
    func flatList() {
        let item = Item.list([.number(3), .number(-1), .number(4)])
        #expect(NestedListFlatten.flatten(item) == [3, -1, 4])
        #expect(NestedListFlatten.depth(item) == 1)
    }

    @Test("Keeps left-to-right order through nesting")
    func mixedNesting() {
        #expect(NestedListFlatten.flatten(Self.mixed) == [1, 2, 3, 4])
        #expect(NestedListFlatten.depth(Self.mixed) == 3)
    }

    @Test("Skips empty lists between numbers")
    func emptyBetween() {
        let item = Item.list([.list([]), .number(7), .list([.list([]), .number(8)]), .list([])])
        #expect(NestedListFlatten.flatten(item) == [7, 8])
        #expect(NestedListFlatten.depth(item) == 3)
    }

    @Test("Depth counts only the deepest branch")
    func deepestBranch() {
        let item = Item.list([
            .list([.number(1)]),
            .list([.list([.list([.number(2)])])]),
            .number(3),
        ])
        #expect(NestedListFlatten.flatten(item) == [1, 2, 3])
        #expect(NestedListFlatten.depth(item) == 4)
    }

    @Test("Handles nesting 100 levels deep")
    func deepChain() {
        var item = Item.number(42)
        for _ in 0..<100 {
            item = .list([item])
        }
        #expect(NestedListFlatten.flatten(item) == [42])
        #expect(NestedListFlatten.depth(item) == 100)
    }

    @Test("Handles 5,000 numbers in groups")
    func manyNumbers() {
        let groups = (0..<50).map { group in
            Item.list((0..<100).map { .number(group * 100 + $0) })
        }
        let item = Item.list(groups)
        #expect(NestedListFlatten.flatten(item) == Array(0..<5_000))
        #expect(NestedListFlatten.depth(item) == 2)
    }
}
