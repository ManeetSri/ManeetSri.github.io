// Generated from src/dsa/content/lessons/hashing/hash-collisions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var slots: [Int?] = Array(repeating: nil, count: 7)

func insert(_ key: Int) {
    var index = key % slots.count
    while slots[index] != nil {
        index = (index + 1) % slots.count     // taken: try the next slot
    }
    slots[index] = key
}

func contains(_ key: Int) -> Bool {
    var index = key % slots.count
    while let stored = slots[index] {         // an empty slot ends the search
        if stored == key {
            return true
        }
        index = (index + 1) % slots.count
    }
    return false
}

for key in [10, 3, 17, 5] {
    insert(key)
}
print(slots.map { $0.map(String.init) ?? "-" })
print(contains(17), contains(24))
