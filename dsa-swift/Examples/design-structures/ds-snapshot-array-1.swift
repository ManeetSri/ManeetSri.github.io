// Generated from src/dsa/content/lessons/design-structures/ds-snapshot-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct CopyingSnapshotArray {
    private var current: [Int]
    private var snapshots: [[Int]] = []
    private(set) var copied = 0                    // elements copied so far, to see the cost

    init(count: Int) {
        current = Array(repeating: 0, count: count)
    }

    mutating func set(_ value: Int, at index: Int) {
        current[index] = value
    }

    mutating func snapshot() -> Int {
        snapshots.append(current)                  // the whole array, every time
        copied += current.count
        return snapshots.count - 1
    }

    func value(at index: Int, snapshot id: Int) -> Int {
        snapshots[id][index]
    }
}

var seats = CopyingSnapshotArray(count: 10_000)
for hour in 0..<24 {
    seats.set(hour, at: hour)                      // one seat changes per hour...
    _ = seats.snapshot()
}
print(seats.value(at: 5, snapshot: 3), seats.value(at: 5, snapshot: 5))
print("elements copied:", seats.copied)            // ...but every snapshot copies all 10,000
