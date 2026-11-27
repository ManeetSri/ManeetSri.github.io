// Generated from src/dsa/content/lessons/design-structures/ds-snapshot-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SnapshotArray {
    private var history: [[(snapshot: Int, value: Int)]]   // per index: its changes, oldest first
    private var snapshotsTaken = 0

    init(count: Int) {
        history = Array(repeating: [], count: count)
    }

    mutating func set(_ value: Int, at index: Int) {
        // A change now belongs to snapshot number snapshotsTaken: the next one to be taken
        if let last = history[index].last, last.snapshot == snapshotsTaken {
            history[index][history[index].count - 1].value = value   // changed again: overwrite
        } else {
            history[index].append((snapshotsTaken, value))
        }
    }

    mutating func snapshot() -> Int {
        snapshotsTaken += 1                        // O(1): nothing is copied
        return snapshotsTaken - 1
    }

    func value(at index: Int, snapshot id: Int) -> Int {
        let changes = history[index]
        var low = 0
        var high = changes.count                   // find the first change after snapshot `id`
        while low < high {
            let middle = low + (high - low) / 2
            if changes[middle].snapshot <= id { low = middle + 1 } else { high = middle }
        }
        return low == 0 ? 0 : changes[low - 1].value   // the change before it, or never set
    }

    func changes(at index: Int) -> [(snapshot: Int, value: Int)] {
        history[index]
    }
}

var seats = SnapshotArray(count: 4)
seats.set(7, at: 0)
seats.set(9, at: 2)
print("snapshot", seats.snapshot())
seats.set(8, at: 0)
seats.set(5, at: 0)                                // replaces 8: no snapshot ever saw it
print("snapshot", seats.snapshot())
print("snapshot", seats.snapshot())                // nothing changed: costs nothing
seats.set(0, at: 2)                                // belongs to snapshot 3, not taken yet
print(seats.changes(at: 0))
print(seats.changes(at: 2))
print((0..<3).map { seats.value(at: 0, snapshot: $0) })
print((0..<3).map { seats.value(at: 2, snapshot: $0) })
print(seats.value(at: 3, snapshot: 2))
