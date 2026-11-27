import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AssociatedItemContainersTests {
    typealias Container = AssociatedItemContainers.Container
    typealias Shelf = AssociatedItemContainers.Shelf
    typealias DistinctShelf = AssociatedItemContainers.DistinctShelf

    /// A container from outside the module whose Item is Character, inferred from its methods.
    private struct Initials: Container {
        private var letters: [Character] = []

        mutating func add(_ item: Character) {
            if item.isUppercase {
                letters.append(item)
            }
        }

        var count: Int { letters.count }

        func item(at index: Int) -> Character? {
            letters.indices.contains(index) ? letters[index] : nil
        }
    }

    @Test("A shelf keeps every item in order")
    func shelf() {
        var shelf = Shelf<String>()
        shelf.add("tea")
        shelf.add("cake")
        shelf.add("tea")
        #expect(shelf.count == 3)
        #expect(shelf.item(at: 0) == "tea")
        #expect(shelf.item(at: 1) == "cake")
        #expect(shelf.item(at: 2) == "tea")
    }

    @Test("Asking for a missing index gives nil")
    func missingIndex() {
        var shelf = Shelf<Int>()
        #expect(shelf.item(at: 0) == nil)
        shelf.add(4)
        #expect(shelf.item(at: 1) == nil)
        #expect(shelf.item(at: -1) == nil)
        #expect(DistinctShelf<Int>().item(at: 0) == nil)
    }

    @Test("A distinct shelf ignores items it already holds")
    func distinctShelf() {
        var shelf = DistinctShelf<Int>()
        for value in [3, 1, 3, 4, 1, 5] {
            shelf.add(value)
        }
        #expect(shelf.count == 4)
        #expect(AssociatedItemContainers.items(of: shelf) == [3, 1, 4, 5])
        #expect(shelf.item(at: 3) == 5)
        #expect(shelf.item(at: 4) == nil)
    }

    @Test("items and lastItem work for any container")
    func itemsAndLast() {
        var shelf = Shelf<String>()
        #expect(AssociatedItemContainers.items(of: shelf) == [])
        #expect(AssociatedItemContainers.lastItem(of: shelf) == nil)
        shelf.add("a")
        shelf.add("b")
        #expect(AssociatedItemContainers.items(of: shelf) == ["a", "b"])
        #expect(AssociatedItemContainers.lastItem(of: shelf) == "b")

        var initials = Initials()
        for letter in "Maneet Kumar Srivastav" {
            initials.add(letter)
        }
        #expect(AssociatedItemContainers.items(of: initials) == ["M", "K", "S"])
        #expect(AssociatedItemContainers.lastItem(of: initials) == "S")
    }

    @Test("occurrences counts equal items")
    func occurrences() {
        var shelf = Shelf<String>()
        AssociatedItemContainers.addAll(["x", "y", "x", "x"], to: &shelf)
        #expect(AssociatedItemContainers.occurrences(of: "x", in: shelf) == 3)
        #expect(AssociatedItemContainers.occurrences(of: "z", in: shelf) == 0)

        var distinct = DistinctShelf<String>()
        AssociatedItemContainers.addAll(["x", "y", "x", "x"], to: &distinct)
        #expect(AssociatedItemContainers.occurrences(of: "x", in: distinct) == 1)
    }

    @Test("addAll adds in order, through the container's own rules")
    func addAll() {
        var shelf = Shelf<Int>()
        AssociatedItemContainers.addAll([5, 6], to: &shelf)
        AssociatedItemContainers.addAll([], to: &shelf)
        AssociatedItemContainers.addAll([7], to: &shelf)
        #expect(AssociatedItemContainers.items(of: shelf) == [5, 6, 7])

        var initials = Initials()
        AssociatedItemContainers.addAll(["A", "b", "C"], to: &initials)
        #expect(initials.count == 2)
    }

    @Test("Containers of different types can hold the same items")
    func sameItems() {
        var shelf = Shelf<Int>()
        var distinct = DistinctShelf<Int>()
        #expect(AssociatedItemContainers.holdSameItems(shelf, distinct))
        AssociatedItemContainers.addAll([1, 2, 3], to: &shelf)
        AssociatedItemContainers.addAll([1, 2, 2, 3, 1], to: &distinct)
        #expect(AssociatedItemContainers.holdSameItems(shelf, distinct))
        shelf.add(1)
        #expect(!AssociatedItemContainers.holdSameItems(shelf, distinct))
        #expect(!AssociatedItemContainers.holdSameItems(distinct, shelf))
    }

    @Test("Same count, different items or order")
    func differentItems() {
        var first = Shelf<Character>()
        var second = Shelf<Character>()
        AssociatedItemContainers.addAll(["A", "B"], to: &first)
        AssociatedItemContainers.addAll(["B", "A"], to: &second)
        #expect(!AssociatedItemContainers.holdSameItems(first, second))
        var initials = Initials()
        AssociatedItemContainers.addAll(["A", "B"], to: &initials)
        #expect(AssociatedItemContainers.holdSameItems(first, initials))
    }

    @Test("A large distinct shelf")
    func large() {
        var shelf = DistinctShelf<Int>()
        AssociatedItemContainers.addAll((0..<50_000).map { $0 % 1_000 }, to: &shelf)
        #expect(shelf.count == 1_000)
        #expect(AssociatedItemContainers.lastItem(of: shelf) == 999)
    }
}
