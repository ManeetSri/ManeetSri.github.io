// Generated from src/dsa/content/lessons/hashing/hash-swift-dictionary.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var slots: [Int?] = Array(repeating: nil, count: 8)

func home(_ key: Int) -> Int {
    key % slots.count
}

func insert(_ key: Int) {
    var index = home(key)
    while slots[index] != nil {
        index = (index + 1) % slots.count
    }
    slots[index] = key
}

func find(_ key: Int) -> Int? {
    var index = home(key)
    while let stored = slots[index] {
        if stored == key {
            return index
        }
        index = (index + 1) % slots.count
    }
    return nil
}

func remove(_ key: Int) {
    guard var hole = find(key) else {
        return
    }
    slots[hole] = nil
    var next = (hole + 1) % slots.count
    while let candidate = slots[next] {              // stop at the end of the run
        let fromHome = (next - home(candidate) + slots.count) % slots.count
        let fromHole = (next - hole + slots.count) % slots.count
        if fromHome >= fromHole {                    // its home is at or before the hole
            slots[hole] = candidate
            slots[next] = nil
            hole = next
        }
        next = (next + 1) % slots.count
    }
}

func show() -> String {
    slots.map { $0.map(String.init) ?? "-" }.joined(separator: " ")
}

for key in [8, 16, 1, 24] {
    insert(key)
}
print(show())
remove(16)
print(show())
print(find(24) ?? -1, find(1) ?? -1, find(16) ?? -1)
