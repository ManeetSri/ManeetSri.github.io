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

let keys = (0..<10_000).map { "user\($0)" }

// The obvious way: server number = hash % number of servers
for (before, after) in [(4, 5), (10, 11), (10, 9)] {
    let moved = keys.filter { stableHash($0) % UInt64(before) != stableHash($0) % UInt64(after) }.count
    print("\(before) → \(after) servers: \(moved) of \(keys.count) keys move")
}
