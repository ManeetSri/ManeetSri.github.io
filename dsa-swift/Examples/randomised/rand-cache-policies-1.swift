// Generated from src/dsa/content/lessons/randomised/rand-cache-policies.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Replaying one access trace through four eviction policies, with a cache of 3 items
enum Policy: CaseIterable { case fifo, lru, lfu, optimal }

func hits(_ trace: [Character], capacity: Int, policy: Policy) -> Int {
    var cached: [Character] = []                 // FIFO: insertion order; LRU: least recent first
    var uses: [Character: Int] = [:]             // LFU: uses since the item entered the cache
    var lastUse: [Character: Int] = [:]          // LFU tie-break: least recently used goes first
    var hitCount = 0
    for (time, key) in trace.enumerated() {
        if let index = cached.firstIndex(of: key) {
            hitCount += 1
            if policy == .lru {                  // a hit makes it the most recent
                cached.remove(at: index)
                cached.append(key)
            }
        } else {
            if cached.count == capacity {
                let victim: Int
                switch policy {
                case .fifo, .lru:
                    victim = 0                   // the oldest, or the least recently used
                case .lfu:
                    victim = cached.indices.min { (uses[cached[$0]]!, lastUse[cached[$0]]!) < (uses[cached[$1]]!, lastUse[cached[$1]]!) }!
                case .optimal:                   // the item needed furthest in the future, or never
                    func nextUse(_ item: Character) -> Int {
                        trace[(time + 1)...].firstIndex(of: item) ?? Int.max
                    }
                    victim = cached.indices.max { nextUse(cached[$0]) < nextUse(cached[$1]) }!
                }
                uses[cached[victim]] = nil
                cached.remove(at: victim)
            }
            cached.append(key)
        }
        uses[key, default: 0] += 1
        lastUse[key] = time
    }
    return hitCount
}

let traces: [(name: String, requests: String)] = [
    ("locality", "ABCABDABEABFACAB"),
    ("loop of 4", "ABCDABCDABCDABCD"),
    ("shift", "AAAABBBBCDCDCDCD"),
]
print("trace       FIFO  LRU  LFU  OPT")
for (name, requests) in traces {
    let trace = Array(requests)
    let row = Policy.allCases.map { policy in
        let count = String(hits(trace, capacity: 3, policy: policy))
        return String(repeating: " ", count: 5 - count.count) + count
    }
    print(name + String(repeating: " ", count: 10 - name.count) + row.joined() + "  of \(trace.count)")
}
