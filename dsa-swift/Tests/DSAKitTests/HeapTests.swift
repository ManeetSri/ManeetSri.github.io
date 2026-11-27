import Testing
import DSAKit

@Suite struct HeapTests {
    /// A tiny deterministic generator, so the mixed-operation tests do the same thing every run.
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

    /// True when no element of `items` comes before its parent, using 0-based index maths.
    private func isHeap<T>(_ items: [T], by areInIncreasingOrder: (T, T) -> Bool) -> Bool {
        for child in items.indices.dropFirst() where areInIncreasingOrder(items[child], items[(child - 1) / 2]) {
            return false
        }
        return true
    }

    /// Pops everything, top first.
    private func drain<T>(_ heap: Heap<T>) -> [T] {
        var heap = heap
        var result: [T] = []
        while let top = heap.pop() {
            result.append(top)
        }
        return result
    }

    @Test("A new heap is empty")
    func startsEmpty() {
        var heap = Heap<Int>()
        #expect(heap.isEmpty)
        #expect(heap.count == 0)
        #expect(heap.peek() == nil)
        #expect(heap.top == nil)
        #expect(heap.pop() == nil)
        #expect(heap.unordered == [])
        #expect(Heap.maxHeap([Int]()).isEmpty)
        var strings = Heap<String>(areInIncreasingOrder: <)
        #expect(strings.pop() == nil)
    }

    @Test("A single element is the top until it's popped")
    func single() {
        var heap = Heap<Int>()
        heap.insert(42)
        #expect(heap.count == 1)
        #expect(heap.peek() == 42)
        #expect(heap.pop() == 42)
        #expect(heap.isEmpty)
        #expect(heap.pop() == nil)
    }

    @Test("A min-heap pops in increasing order")
    func minHeap() {
        var heap = Heap<Int>.minHeap()
        for value in [5, 3, 8, 1, 9, 2] {
            heap.insert(value)
            #expect(isHeap(heap.unordered, by: <))
        }
        #expect(heap.peek() == 1)
        #expect(drain(heap) == [1, 2, 3, 5, 8, 9])
    }

    @Test("A max-heap pops in decreasing order")
    func maxHeap() {
        var heap = Heap<Int>.maxHeap()
        for value in [5, 3, 8, 1, 9, 2] {
            heap.insert(value)
        }
        #expect(heap.peek() == 9)
        #expect(isHeap(heap.unordered, by: >))
        #expect(drain(heap) == [9, 8, 5, 3, 2, 1])
        let strings: Heap = .maxHeap(["pear", "apple", "fig"])
        #expect(drain(strings) == ["pear", "fig", "apple"])
    }

    @Test("Duplicates all come out")
    func duplicates() {
        var heap: Heap = [4, 1, 4, 1, 4, 2, 2]
        #expect(heap.count == 7)
        #expect(drain(heap) == [1, 1, 2, 2, 4, 4, 4])
        heap = Heap(Array(repeating: 7, count: 50))
        #expect(heap.count == 50)
        #expect(drain(heap) == Array(repeating: 7, count: 50))
    }

    @Test("A custom comparator orders tuples by priority")
    func customComparator() {
        typealias Task = (priority: Int, name: String)
        var tasks = Heap<Task>(areInIncreasingOrder: { $0.priority < $1.priority })
        tasks.insert((3, "write tests"))
        tasks.insert((1, "fix crash"))
        tasks.insert((2, "review"))
        tasks.insert((5, "tidy up"))
        #expect(tasks.peek()?.name == "fix crash")
        #expect(drain(tasks).map(\.name) == ["fix crash", "review", "write tests", "tidy up"])

        // Ties broken by a second key give one fixed order
        let queued = [(2, "b"), (1, "z"), (2, "a"), (1, "y")]
        let byPriorityThenName = Heap(queued, areInIncreasingOrder: { ($0.0, $0.1) < ($1.0, $1.1) })
        #expect(drain(byPriorityThenName).map(\.1) == ["y", "z", "a", "b"])
    }

    @Test("Heapify gives a valid heap that pops like repeated inserts", arguments: [0, 1, 2, 3, 7, 8, 100, 1_001])
    func heapifyMatchesInserts(count: Int) {
        var steps = Steps(seed: UInt64(count + 1))
        let values = (0..<count).map { _ in steps.next(below: 50) }
        let heapified = Heap(values)
        var inserted = Heap<Int>()
        for value in values {
            inserted.insert(value)
        }
        #expect(isHeap(heapified.unordered, by: <))
        #expect(heapified.count == count)
        #expect(drain(heapified) == drain(inserted))
        #expect(drain(heapified) == values.sorted())
        let maxHeapified = Heap(values, areInIncreasingOrder: >)
        #expect(isHeap(maxHeapified.unordered, by: >))
        #expect(drain(maxHeapified) == values.sorted(by: >))
    }

    @Test("replaceTop swaps the top for a new element")
    func replaceTop() {
        var heap: Heap = [3, 6, 9]
        #expect(heap.replaceTop(with: 7) == 3)
        #expect(heap.peek() == 6)
        #expect(heap.replaceTop(with: 1) == 6)
        #expect(heap.peek() == 1)
        #expect(drain(heap) == [1, 7, 9])
        var empty = Heap<Int>()
        #expect(empty.replaceTop(with: 5) == nil)
        #expect(empty.peek() == 5)
        #expect(empty.count == 1)
    }

    @Test("Copies are independent")
    func valueSemantics() {
        var original: Heap = [2, 1, 3]
        var copy = original
        copy.insert(0)
        #expect(copy.peek() == 0)
        #expect(original.peek() == 1)
        original.pop()
        #expect(original.count == 2)
        #expect(copy.count == 4)
        #expect(drain(copy) == [0, 1, 2, 3])
    }

    @Test("removeAll, reserveCapacity and the description")
    func housekeeping() {
        var heap: Heap = [5, 1, 3]
        #expect(heap.description == "Heap([1, 5, 3])")
        heap.removeAll(keepingCapacity: true)
        #expect(heap.isEmpty)
        heap.reserveCapacity(100)
        for value in (0..<100).reversed() {
            heap.insert(value)
        }
        #expect(heap.count == 100)
        #expect(heap.peek() == 0)
        heap.removeAll()
        #expect(heap.pop() == nil)
        #expect(Heap<String>.minHeap(["b", "a"]).description == "Heap([\"a\", \"b\"])")
    }

    @Test("Grows past many array resizes and stays a heap")
    func growth() {
        var heap = Heap<Int>.maxHeap()
        for value in 0..<5_000 {
            heap.insert((value * 7_919) % 5_000)
        }
        #expect(heap.count == 5_000)
        #expect(isHeap(heap.unordered, by: >))
        #expect(drain(heap) == Array((0..<5_000).reversed()))
    }

    @Test("Heap sort", arguments: [
        [Int](),
        [1],
        [2, 1],
        [5, 2, 9, 1, 6, 3],
        [3, 3, 1, 3, 1],
        [-4, 10, 0, -4, 7, 7, 2],
        Array(1...20),
        Array((1...20).reversed()),
    ])
    func heapSort(values: [Int]) {
        var ascending = values
        ascending.heapSort()
        #expect(ascending == values.sorted())
        var descending = values
        descending.heapSort(by: >)
        #expect(descending == values.sorted(by: >))
    }

    @Test("Heap sort on larger inputs and custom types")
    func heapSortLarge() {
        var scrambled = (0..<20_000).map { ($0 * 7_919) % 20_000 }
        scrambled.heapSort()
        #expect(scrambled == Array(0..<20_000))
        var words = ["kiwi", "fig", "banana", "apple", "cherry"]
        words.heapSort(by: { $0.count < $1.count || ($0.count == $1.count && $0 < $1) })
        #expect(words == ["fig", "kiwi", "apple", "banana", "cherry"])
    }

    @Test("100,000 random operations agree with a sorted-array model")
    func randomOperations() {
        var steps = Steps(seed: 2_024)
        var heap = Heap<Int>()
        var model: [Int] = []                       // sorted in decreasing order: the smallest is last
        var mismatches = 0
        for _ in 0..<100_000 {
            let roll = steps.next(below: 100)
            let insertChance = model.count < 1_500 ? 60 : 40
            if roll < insertChance {
                let value = steps.next(below: 10_000) - 5_000
                heap.insert(value)
                // Binary search for the first position whose value is smaller than `value`
                var low = 0
                var high = model.count
                while low < high {
                    let mid = (low + high) / 2
                    if model[mid] >= value { low = mid + 1 } else { high = mid }
                }
                model.insert(value, at: low)
            } else if roll < insertChance + 5 {
                let value = steps.next(below: 10_000) - 5_000
                let old = heap.replaceTop(with: value)
                if old != model.popLast() { mismatches += 1 }
                var low = 0
                var high = model.count
                while low < high {
                    let mid = (low + high) / 2
                    if model[mid] >= value { low = mid + 1 } else { high = mid }
                }
                model.insert(value, at: low)
            } else {
                if heap.pop() != model.popLast() { mismatches += 1 }
            }
            if heap.peek() != model.last || heap.count != model.count { mismatches += 1 }
        }
        #expect(mismatches == 0)
        #expect(isHeap(heap.unordered, by: <))
    }
}
