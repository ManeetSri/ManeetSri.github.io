import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Reuse = CreationalReusePool

/// A stand-in for a table view cell: it remembers what it showed and how often it was prepared
private final class Cell: CreationalReusePool.Reusable {
    let serial: Int
    var text: String?
    var selected = false
    private(set) var preparedCount = 0

    init(serial: Int) {
        self.serial = serial
    }

    func prepareForReuse() {
        preparedCount += 1
        selected = false
    }
}

@Suite struct CreationalReusePoolTests {
    /// A pool with "text" and "photo" registered, numbering the cells it makes
    private func makePool(maxIdle: Int = 8) -> Reuse.Pool<Cell> {
        let pool = Reuse.Pool<Cell>(maxIdlePerIdentifier: maxIdle)
        var serial = 0
        let make = { () -> Cell in
            serial += 1
            return Cell(serial: serial)
        }
        pool.register("text", make: make)
        pool.register("photo", make: make)
        return pool
    }

    @Test("Makes a new element when nothing is waiting, without preparing it")
    func createsWhenEmpty() throws {
        let pool = makePool()
        let first = try pool.dequeue("text")
        let second = try pool.dequeue("text")
        #expect(first !== second)
        #expect(pool.created == 2)
        #expect(first.preparedCount == 0)
        #expect(second.preparedCount == 0)
    }

    @Test("Hands back an enqueued element after preparing it for reuse")
    func reusesAfterPreparing() throws {
        let pool = makePool()
        let cell = try pool.dequeue("text")
        cell.text = "Row 1"
        cell.selected = true
        pool.enqueue(cell, for: "text")
        #expect(pool.idleCount(for: "text") == 1)

        let reused = try pool.dequeue("text")
        #expect(reused === cell)
        #expect(reused.preparedCount == 1)
        #expect(!reused.selected)
        #expect(pool.created == 1)
        #expect(pool.idleCount(for: "text") == 0)
    }

    @Test("The most recently enqueued element comes back first")
    func lastInFirstOut() throws {
        let pool = makePool()
        let a = try pool.dequeue("text")
        let b = try pool.dequeue("text")
        pool.enqueue(a, for: "text")
        pool.enqueue(b, for: "text")
        #expect(try pool.dequeue("text") === b)
        #expect(try pool.dequeue("text") === a)
    }

    @Test("Scrolling through 1,000 rows with 10 on screen makes only 10 cells")
    func scrolling() throws {
        let pool = makePool()
        var onScreen: [Cell] = []
        for row in 0..<1_000 {
            if onScreen.count == 10 {
                pool.enqueue(onScreen.removeFirst(), for: "text")
            }
            let cell = try pool.dequeue("text")
            cell.text = "Row \(row)"
            onScreen.append(cell)
        }
        #expect(pool.created == 10)
        #expect(Set(onScreen.map(\.serial)).count == 10)
        #expect(onScreen.last?.text == "Row 999")
    }

    @Test("Each identifier has its own queue")
    func identifiersAreSeparate() throws {
        let pool = makePool()
        let text = try pool.dequeue("text")
        pool.enqueue(text, for: "text")

        let photo = try pool.dequeue("photo")
        #expect(photo !== text)
        #expect(pool.created == 2)
        #expect(pool.idleCount(for: "text") == 1)
        #expect(pool.idleCount(for: "photo") == 0)
    }

    @Test("Dequeuing an identifier nobody registered throws")
    func unregistered() {
        let pool = makePool()
        #expect(throws: Reuse.PoolError.unregistered("video")) {
            try pool.dequeue("video")
        }
    }

    @Test("Elements enqueued for an unregistered identifier are dropped")
    func enqueueUnregistered() throws {
        let pool = makePool()
        let cell = try pool.dequeue("text")
        pool.enqueue(cell, for: "video")
        #expect(pool.idleCount(for: "video") == 0)
        #expect(pool.idleCount(for: "text") == 0)
    }

    @Test("Keeps no more idle elements than its limit")
    func idleLimit() throws {
        let pool = makePool(maxIdle: 2)
        let cells = try (0..<3).map { _ in try pool.dequeue("text") }
        cells.forEach { pool.enqueue($0, for: "text") }
        #expect(pool.idleCount(for: "text") == 2)
        #expect(pool.created == 3)
    }

    @Test("Enqueuing the same element twice keeps it once")
    func doubleEnqueue() throws {
        let pool = makePool()
        let cell = try pool.dequeue("text")
        pool.enqueue(cell, for: "text")
        pool.enqueue(cell, for: "text")
        #expect(pool.idleCount(for: "text") == 1)

        let first = try pool.dequeue("text")
        let second = try pool.dequeue("text")
        #expect(first === cell)
        #expect(second !== cell)
        #expect(pool.created == 2)
    }

    @Test("Draining lets go of every idle element")
    func drain() throws {
        let pool = makePool()
        let a = try pool.dequeue("text")
        let b = try pool.dequeue("text")
        let c = try pool.dequeue("photo")
        pool.enqueue(a, for: "text")
        pool.enqueue(b, for: "text")
        pool.enqueue(c, for: "photo")
        #expect(pool.idleCount(for: "text") == 2)

        pool.drain()
        #expect(pool.idleCount(for: "text") == 0)
        #expect(pool.idleCount(for: "photo") == 0)
        let fresh = try pool.dequeue("text")
        #expect(fresh !== a && fresh !== b)
        #expect(pool.created == 4)
    }
}
