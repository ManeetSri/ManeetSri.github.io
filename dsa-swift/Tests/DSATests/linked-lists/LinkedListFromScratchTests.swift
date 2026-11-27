import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias List = LinkedListFromScratch.List

/// Checks every read-only view of the list against the array it should match.
private func expectMatches(_ list: List<Int>, _ expected: [Int], sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(Array(list) == expected, sourceLocation: sourceLocation)
    #expect(list.count == expected.count, "count", sourceLocation: sourceLocation)
    #expect(list.isEmpty == expected.isEmpty, "isEmpty", sourceLocation: sourceLocation)
    #expect(list.first == expected.first, "first", sourceLocation: sourceLocation)
    #expect(list.last == expected.last, "last", sourceLocation: sourceLocation)
}

@Suite struct LinkedListFromScratchTests {
    @Test("A new list is empty")
    func empty() {
        expectMatches(List<Int>(), [])
    }

    @Test("append and prepend")
    func appendPrepend() {
        let list = List<Int>()
        list.append(2)
        expectMatches(list, [2])
        list.append(3)
        list.prepend(1)
        expectMatches(list, [1, 2, 3])

        let other = List<Int>()
        other.prepend(5)
        expectMatches(other, [5])
        other.append(6)
        expectMatches(other, [5, 6])
    }

    @Test("init from an array keeps the order")
    func fromArray() {
        expectMatches(List([4, 5, 6]), [4, 5, 6])
    }

    @Test("insert(_:at:) at every position", arguments: 0...3)
    func insert(index: Int) {
        let list = List([1, 2, 3])
        #expect(list.insert(9, at: index))
        var expected = [1, 2, 3]
        expected.insert(9, at: index)
        expectMatches(list, expected)
        list.append(100)
        expectMatches(list, expected + [100])
    }

    @Test("insert(_:at:) refuses positions outside 0...count", arguments: [-1, 4, 10])
    func insertOutOfRange(index: Int) {
        let list = List([1, 2, 3])
        #expect(!list.insert(9, at: index))
        expectMatches(list, [1, 2, 3])
    }

    @Test("insert into an empty list")
    func insertEmpty() {
        let list = List<Int>()
        #expect(list.insert(7, at: 0))
        expectMatches(list, [7])
    }

    @Test("remove(at:) at every position keeps the tail right", arguments: 0...2)
    func remove(index: Int) {
        let list = List([1, 2, 3])
        var expected = [1, 2, 3]
        let removed = expected.remove(at: index)
        #expect(list.remove(at: index) == removed)
        expectMatches(list, expected)
        list.append(4)
        expectMatches(list, expected + [4])
    }

    @Test("remove(at:) returns nil for positions outside 0..<count", arguments: [-1, 3, 50])
    func removeOutOfRange(index: Int) {
        let list = List([1, 2, 3])
        #expect(list.remove(at: index) == nil)
        expectMatches(list, [1, 2, 3])
        #expect(List<Int>().remove(at: 0) == nil)
    }

    @Test("removeFirst empties the list one element at a time")
    func removeFirst() {
        let list = List(["a", "b"])
        #expect(list.removeFirst() == "a")
        #expect(list.removeFirst() == "b")
        #expect(list.removeFirst() == nil)
        #expect(list.isEmpty && list.count == 0 && list.last == nil)
        list.append("c")
        #expect(Array(list) == ["c"])
        #expect(list.first == "c" && list.last == "c")
    }

    @Test("value(at:) and firstIndex(of:)")
    func search() {
        let list = List([4, 8, 15, 8])
        #expect(list.value(at: 0) == 4)
        #expect(list.value(at: 3) == 8)
        #expect(list.value(at: 4) == nil)
        #expect(list.value(at: -1) == nil)
        #expect(list.firstIndex(of: 8) == 1)
        #expect(list.firstIndex(of: 99) == nil)
        #expect(List<Int>().firstIndex(of: 1) == nil)
    }

    @Test("removeAll(equalTo:) removes every match, including at the ends", arguments: [
        ([1, 2, 1, 3, 1], 1, [2, 3], 3),
        ([7, 7, 7], 7, [], 3),
        ([1, 2, 3], 4, [1, 2, 3], 0),
        ([5, 1, 2], 5, [1, 2], 1),
        ([1, 2, 5], 5, [1, 2], 1),
        ([], 5, [], 0),
    ])
    func removeAll(values: [Int], target: Int, expected: [Int], removed: Int) {
        let list = List(values)
        #expect(list.removeAll(equalTo: target) == removed)
        expectMatches(list, expected)
        list.append(42)
        expectMatches(list, expected + [42])
    }

    @Test("reverse", arguments: [[Int](), [1], [1, 2], [1, 2, 3, 4, 5]])
    func reverse(values: [Int]) {
        let list = List(values)
        list.reverse()
        expectMatches(list, values.reversed())
        list.append(99)
        expectMatches(list, values.reversed() + [99])
    }

    @Test("for-in and Sequence methods work, and every loop starts from the head")
    func sequence() {
        let list = List([3, 1, 4])
        var seen: [Int] = []
        for value in list {
            seen.append(value)
        }
        #expect(seen == [3, 1, 4])
        #expect(list.map { $0 * 10 } == [30, 10, 40])
        #expect(list.contains(4))
        #expect(Array(list) == [3, 1, 4])
    }

    @Test("It's a class: two names for one list see the same changes")
    func referenceSemantics() {
        let list = List([1])
        let sameList = list
        sameList.append(2)
        #expect(Array(list) == [1, 2])
    }

    @Test("Matches an array through a long mix of operations")
    func matchesArray() {
        let list = List<Int>()
        var model: [Int] = []
        var seed = 7
        for step in 0..<2_000 {
            seed = (seed * 1_103 + 12_345) % 65_536
            let index = model.isEmpty ? 0 : seed % (model.count + 1)
            switch seed % 7 {
            case 0, 1:
                list.append(step)
                model.append(step)
            case 2:
                list.prepend(step)
                model.insert(step, at: 0)
            case 3:
                list.insert(step, at: index)
                model.insert(step, at: index)
            case 4:
                let removed = list.remove(at: index)
                #expect(removed == (index < model.count ? model.remove(at: index) : nil))
            case 5:
                #expect(list.removeFirst() == (model.isEmpty ? nil : model.removeFirst()))
            default:
                if step % 50 == 0 {
                    list.reverse()
                    model.reverse()
                }
            }
            if list.count != model.count || list.last != model.last {
                Issue.record("count or last went wrong at step \(step)")
                return
            }
        }
        #expect(Array(list) == model)
    }

    @Test("append, prepend, count and last stay O(1) for 100,000 elements")
    func large() {
        let list = List<Int>()
        for value in 0..<100_000 {
            list.append(value)
            _ = list.count
            _ = list.last
        }
        for value in 1...1_000 {
            list.prepend(-value)
        }
        #expect(list.count == 101_000)
        #expect(list.first == -1_000)
        #expect(list.last == 99_999)
        list.reverse()
        #expect(list.first == 99_999 && list.last == -1_000)
    }
}
