// Generated from src/dsa/content/lessons/hashing/hash-collisions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Slot {
    case empty
    case occupied(Int)
    case deleted                  // a tombstone: "something was here"
}

var slots: [Slot] = Array(repeating: .empty, count: 7)
slots[3] = .occupied(10)          // 10 is at home
slots[4] = .occupied(17)          // 17's home is 3 too, so it probed on to 4

func contains(_ key: Int) -> Bool {
    var index = key % slots.count
    while true {
        switch slots[index] {
        case .empty:
            return false          // the probe sequence has ended
        case .occupied(let stored) where stored == key:
            return true
        default:
            index = (index + 1) % slots.count    // a different key or a tombstone: keep going
        }
    }
}

slots[3] = .empty                 // delete 10 by emptying its slot
print("emptied:", contains(17))
slots[3] = .deleted               // delete 10 with a tombstone instead
print("tombstone:", contains(17))
