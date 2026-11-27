// Generated from src/dsa/content/lessons/advanced-structures/as-swift-collections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A fixed hash with well-mixed bits (SplitMix64's steps)
func hash(_ key: Int) -> UInt64 {
    var z = UInt64(bitPattern: Int64(key)) &+ 0x9E37_79B9_7F4A_7C15
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
}

// One of a node's 16 slots: empty, a single entry, or a child node one level down
enum Slot {
    case empty
    case entry(key: Int, value: String)
    case node(TrieNode)
}

// An immutable node. Each level uses the next 4 bits of the key's hash to choose a slot.
final class TrieNode {
    static var created = 0
    let slots: [Slot]

    init(_ slots: [Slot]) {
        self.slots = slots
        TrieNode.created += 1
    }
}

// A simplified persistent hash trie: the idea behind TreeDictionary, without its compression
struct HashTrieMap {
    private(set) var root = TrieNode(Array(repeating: .empty, count: 16))

    subscript(key: Int) -> String? {
        var node = root
        var bits = hash(key)
        while true {
            switch node.slots[Int(bits & 15)] {
            case .empty: return nil
            case .entry(let k, let v): return k == key ? v : nil
            case .node(let child): node = child
            }
            bits >>= 4                           // the next level uses the next 4 bits
        }
    }

    // A new version with key set to value: copies the nodes on one path, shares the rest
    func updating(_ key: Int, to value: String) -> HashTrieMap {
        var result = self
        result.root = Self.insert(key, value, hash(key), into: root, shift: 0)
        return result
    }

    private static func insert(_ key: Int, _ value: String, _ h: UInt64, into node: TrieNode, shift: UInt64) -> TrieNode {
        let index = Int((h >> shift) & 15)
        var slots = node.slots                   // the copy: one node's 16 slots
        switch slots[index] {
        case .empty:
            slots[index] = .entry(key: key, value: value)
        case .entry(let k, _) where k == key:    // the same key: replace its value
            slots[index] = .entry(key: key, value: value)
        case .entry(let k, let v):               // two keys share these bits: push both a level down
            let empty = TrieNode(Array(repeating: .empty, count: 16))
            let withOld = insert(k, v, hash(k), into: empty, shift: shift + 4)
            slots[index] = .node(insert(key, value, h, into: withOld, shift: shift + 4))
        case .node(let child):
            slots[index] = .node(insert(key, value, h, into: child, shift: shift + 4))
        }
        return TrieNode(slots)
    }
}

var map = HashTrieMap()
for key in 0..<1_000 {
    map = map.updating(key, to: "v\(key)")
}
TrieNode.created = 0
let edited = map.updating(42, to: "changed")
print("old 42:", map[42]!, " new 42:", edited[42]!, " missing:", edited[5_000] ?? "nil")
print("nodes created by one update:", TrieNode.created)

var sharedSlots = 0
for i in 0..<16 {
    if case .node(let a) = map.root.slots[i], case .node(let b) = edited.root.slots[i], a === b {
        sharedSlots += 1
    }
}
print("top-level children shared by both versions:", sharedSlots, "of 16")

// A Dictionary keeps old versions too, but the first write to a shared copy copies every entry
let before: [Int: String] = Dictionary(uniqueKeysWithValues: (0..<1_000).map { ($0, "v\($0)") })
var after = before
after[42] = "changed"                            // copies all 1,000 entries, then changes one
print("Dictionary versions:", before[42]!, after[42]!)
