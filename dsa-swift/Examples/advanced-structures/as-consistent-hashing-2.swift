// Generated from src/dsa/content/lessons/advanced-structures/as-consistent-hashing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fnv1a(_ text: String) -> UInt64 {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for byte in text.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 0x0000_0100_0000_01B3
    }
    return hash
}

func mix(_ x: UInt64) -> UInt64 {
    var z = x
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
}

func stableHash(_ text: String) -> UInt64 { mix(fnv1a(text)) }

struct HashRing {
    let virtualNodes: Int
    private var points: [(position: UInt64, server: String)] = []    // sorted by position

    init(virtualNodes: Int) {
        self.virtualNodes = virtualNodes
    }

    // Each server appears at several places on the ring: "A#0", "A#1", …
    mutating func add(_ server: String) {
        for i in 0..<virtualNodes {
            points.append((stableHash("\(server)#\(i)"), server))
        }
        points.sort { $0.position < $1.position }
    }

    mutating func remove(_ server: String) {
        points.removeAll { $0.server == server }
    }

    // The first point at or after the key's position, going clockwise; past the end, wrap to the start
    func server(for key: String) -> String {
        let position = stableHash(key)
        var low = 0
        var high = points.count
        while low < high {                       // lower bound: the first point ≥ position
            let mid = (low + high) / 2
            if points[mid].position < position { low = mid + 1 } else { high = mid }
        }
        return points[low == points.count ? 0 : low].server
    }
}

func loads(_ ring: HashRing, _ keys: [String]) -> String {
    var count: [String: Int] = [:]
    for key in keys {
        count[ring.server(for: key), default: 0] += 1
    }
    return count.keys.sorted().map { "\($0) \(count[$0]!)" }.joined(separator: ", ")
}

let keys = (0..<10_000).map { "user\($0)" }

for v in [1, 100] {
    var ring = HashRing(virtualNodes: v)
    for server in ["A", "B", "C", "D"] {
        ring.add(server)
    }
    print("\(v) point(s) per server: \(loads(ring, keys))")
}

var ring = HashRing(virtualNodes: 100)
for server in ["A", "B", "C", "D"] {
    ring.add(server)
}
let before = keys.map { ring.server(for: $0) }
ring.add("E")
let after = keys.map { ring.server(for: $0) }
var movedFrom: [String: Int] = [:]
for i in keys.indices where before[i] != after[i] {
    movedFrom[before[i], default: 0] += 1
    precondition(after[i] == "E")                // every key that moved went to the new server
}
let moved = movedFrom.values.reduce(0, +)
print("adding E moved \(moved) keys, all to E, taken from:",
      movedFrom.keys.sorted().map { "\($0) \(movedFrom[$0]!)" }.joined(separator: ", "))
print("after adding E: \(loads(ring, keys))")

ring.remove("B")
let withoutB = keys.map { ring.server(for: $0) }
let changed = keys.indices.filter { after[$0] != withoutB[$0] }
print("removing B moved \(changed.count) keys, all of them B's:", changed.allSatisfy { after[$0] == "B" })
