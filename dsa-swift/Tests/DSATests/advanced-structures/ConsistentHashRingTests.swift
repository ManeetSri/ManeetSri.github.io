import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// FNV-1a with a mixing step: a fixed, well-spread hash for the tests.
private func stableHash(_ text: String) -> UInt64 {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for byte in text.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 0x0000_0100_0000_01B3
    }
    var z = hash
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
}

/// A terrible hash with only 8 values, so positions collide all the time.
private func tinyHash(_ text: String) -> UInt64 {
    stableHash(text) % 8
}

/// Every virtual node's position and server.
private func allPoints(_ servers: [String], _ virtualNodes: Int, _ hash: (String) -> UInt64) -> [(UInt64, String)] {
    servers.flatMap { name in (0..<virtualNodes).map { (hash("\(name)#\($0)"), name) } }
}

/// The owner by the statement's rules, found by checking every virtual node.
private func owner(_ key: String, servers: [String], virtualNodes: Int, hash: (String) -> UInt64) -> String? {
    owner(key, points: allPoints(servers, virtualNodes, hash), hash: hash)
}

private func owner(_ key: String, points: [(UInt64, String)], hash: (String) -> UInt64) -> String? {
    guard !points.isEmpty else { return nil }
    let position = hash(key)
    let atOrAfter = points.filter { $0.0 >= position }
    let candidates = atOrAfter.isEmpty ? points : atOrAfter
    return candidates.min { ($0.0, $0.1) < ($1.0, $1.1) }!.1
}

@Suite struct ConsistentHashRingTests {
    @Test("An empty ring owns nothing; a single server owns everything")
    func emptyAndSingle() {
        let ring = ConsistentHashRing.Ring(virtualNodes: 3, hash: stableHash)
        #expect(ring.server(for: "photo1") == nil)
        #expect(ring.servers == [])
        #expect(ring.addServer("alpha"))
        #expect((0..<100).allSatisfy { ring.server(for: "key\($0)") == "alpha" })
    }

    @Test("The ring from the statement, with positions from 0 to 99")
    func statementExample() {
        let positions: [String: UInt64] = ["A#0": 10, "B#0": 40, "C#0": 75, "D#0": 60,
                                           "k5": 5, "k40": 40, "k41": 41, "k90": 90, "k55": 55]
        let ring = ConsistentHashRing.Ring(virtualNodes: 1) { positions[$0] ?? 0 }
        ring.addServer("C")
        ring.addServer("A")
        ring.addServer("B")
        #expect(["k5", "k40", "k41", "k90", "k55"].map { ring.server(for: $0) ?? "none" } == ["A", "B", "C", "A", "C"])
        ring.addServer("D")
        #expect(["k5", "k40", "k41", "k90", "k55"].map { ring.server(for: $0) ?? "none" } == ["A", "B", "D", "A", "D"])
        ring.removeServer("A")
        #expect(["k5", "k40", "k41", "k90", "k55"].map { ring.server(for: $0) ?? "none" } == ["B", "B", "D", "B", "D"])
        #expect(ring.servers == ["B", "C", "D"])
    }

    @Test("Adding or removing twice is reported and ignored")
    func duplicates() {
        let ring = ConsistentHashRing.Ring(virtualNodes: 10, hash: stableHash)
        #expect(ring.addServer("x"))
        #expect(!ring.addServer("x"))
        #expect(ring.addServer("w"))
        #expect(ring.servers == ["w", "x"])
        #expect(!ring.removeServer("y"))
        #expect(ring.removeServer("x"))
        #expect(!ring.removeServer("x"))
        #expect(ring.servers == ["w"])
        #expect(ring.server(for: "anything") == "w")
        #expect(ring.removeServer("w"))
        #expect(ring.server(for: "anything") == nil)
    }

    @Test("Ties between positions go to the smallest server name", arguments: [1, 3, 5])
    func ties(virtualNodes: Int) {
        let names = ["delta", "alpha", "charlie", "bravo", "echo"]
        let ring = ConsistentHashRing.Ring(virtualNodes: virtualNodes, hash: tinyHash)
        for name in names {
            ring.addServer(name)
        }
        let points = allPoints(names, virtualNodes, tinyHash)
        for i in 0..<300 {
            let key = "item\(i)"
            let expected = owner(key, points: points, hash: tinyHash)
            if ring.server(for: key) != expected {
                Issue.record("\(key) should belong to \(expected ?? "nil")")
                return
            }
        }
    }

    @Test("Matches the rules as servers come and go", arguments: [1, 4, 25])
    func matchesModel(virtualNodes: Int) {
        let ring = ConsistentHashRing.Ring(virtualNodes: virtualNodes, hash: stableHash)
        var servers: [String] = []
        let keys = (0..<250).map { "user\($0)" }
        for step in 0..<40 {
            let name = "s\((step * 7) % 13)"
            if servers.contains(name) {
                ring.removeServer(name)
                servers.removeAll { $0 == name }
            } else {
                ring.addServer(name)
                servers.append(name)
            }
            #expect(ring.servers == servers.sorted())
            let points = allPoints(servers, virtualNodes, stableHash)
            for key in keys where ring.server(for: key) != owner(key, points: points, hash: stableHash) {
                Issue.record("\(key) is on the wrong server after step \(step)")
                return
            }
        }
    }

    @Test("Only the new server's keys move when it joins, and only the old server's when it leaves")
    func minimalMovement() {
        let ring = ConsistentHashRing.Ring(virtualNodes: 100, hash: stableHash)
        for name in ["A", "B", "C", "D"] {
            ring.addServer(name)
        }
        let keys = (0..<10_000).map { "user\($0)" }
        let before = keys.map { ring.server(for: $0) ?? "none" }
        ring.addServer("E")
        let after = keys.map { ring.server(for: $0) ?? "none" }
        let moved = keys.indices.filter { before[$0] != after[$0] }
        #expect(moved.allSatisfy { after[$0] == "E" })
        #expect(moved.count > 1_500 && moved.count < 2_500, "about a fifth of the keys move to E")
        ring.removeServer("B")
        let withoutB = keys.map { ring.server(for: $0) ?? "none" }
        #expect(keys.indices.allSatisfy { after[$0] == withoutB[$0] || after[$0] == "B" })
        #expect(!withoutB.contains("B"))
    }

    @Test("500 servers with 100 virtual nodes each, and 100,000 lookups")
    func large() {
        let ring = ConsistentHashRing.Ring(virtualNodes: 100, hash: stableHash)
        let names = (0..<500).map { "cache-\($0)" }
        for name in names {
            ring.addServer(name)
        }
        var load: [String: Int] = [:]
        for i in 0..<100_000 {
            load[ring.server(for: "photo\(i)") ?? "none", default: 0] += 1
        }
        #expect(load.count == 500)
        #expect((load.values.max() ?? 0) < 400, "virtual nodes keep every server near 200 keys")
        let points = allPoints(names, 100, stableHash)
        for i in stride(from: 0, to: 100_000, by: 2_000) {
            let key = "photo\(i)"
            #expect(ring.server(for: key) == owner(key, points: points, hash: stableHash))
        }
        ring.removeServer("cache-7")
        ring.addServer("cache-500")
        #expect(ring.servers.count == 500)
    }
}
