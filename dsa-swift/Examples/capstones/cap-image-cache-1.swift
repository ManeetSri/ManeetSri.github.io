// Generated from src/dsa/content/lessons/capstones/cap-image-cache.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A least-recently-used store with a budget in bytes. Entries sit in arrays and link to each other
/// by index, so a generic Key and Value need no dummy values: slot 0 is the head, slot 1 the tail.
struct LRUStore<Key: Hashable, Value> {
    let budget: Int
    let promotesOnRead: Bool                 // false turns it into a FIFO store, for comparison
    private(set) var totalCost = 0
    private(set) var evicted: [Key] = []
    private var slotOf: [Key: Int] = [:]
    private var keys: [Key?] = [nil, nil]
    private var values: [Value?] = [nil, nil]
    private var costs = [0, 0]
    private var previous = [0, 0]
    private var next = [1, 1]                // head -> tail
    private var freeSlots: [Int] = []

    init(budget: Int, promotesOnRead: Bool = true) {
        self.budget = budget
        self.promotesOnRead = promotesOnRead
    }

    private mutating func unlink(_ slot: Int) {
        next[previous[slot]] = next[slot]
        previous[next[slot]] = previous[slot]
    }

    private mutating func linkAtFront(_ slot: Int) {
        previous[slot] = 0
        next[slot] = next[0]
        previous[next[0]] = slot
        next[0] = slot
    }

    /// O(1): a hit moves the entry to the front
    mutating func value(for key: Key) -> Value? {
        guard let slot = slotOf[key] else { return nil }
        if promotesOnRead {
            unlink(slot)
            linkAtFront(slot)
        }
        return values[slot]
    }

    /// O(1) amortised, plus one step per eviction. Refuses anything bigger than the whole budget.
    @discardableResult
    mutating func insert(_ value: Value, for key: Key, cost: Int) -> Bool {
        guard cost <= budget else { return false }
        if let slot = slotOf[key] {                       // an update: replace in place
            totalCost += cost - costs[slot]
            values[slot] = value
            costs[slot] = cost
            unlink(slot)
            linkAtFront(slot)
        } else {
            let slot: Int
            if let reused = freeSlots.popLast() {
                slot = reused
                keys[slot] = key
                values[slot] = value
                costs[slot] = cost
            } else {
                slot = keys.count
                keys.append(key)
                values.append(value)
                costs.append(cost)
                previous.append(0)
                next.append(0)
            }
            slotOf[key] = slot
            linkAtFront(slot)
            totalCost += cost
        }
        trim(toCost: budget)
        return true
    }

    /// Evicts least recently used entries until the total fits. A memory warning calls this too.
    mutating func trim(toCost limit: Int) {
        while totalCost > limit {
            let oldest = previous[1]
            unlink(oldest)
            totalCost -= costs[oldest]
            evicted.append(keys[oldest]!)
            slotOf[keys[oldest]!] = nil
            keys[oldest] = nil
            values[oldest] = nil                          // release the image now, not later
            freeSlots.append(oldest)
        }
    }

    var keysByRecency: [Key] {
        var result: [Key] = []
        var slot = next[0]
        while slot != 1 {
            result.append(keys[slot]!)
            slot = next[slot]
        }
        return result
    }
}

/// Stands in for loading and decoding an image: slow in real life, so the cache matters
func decode(_ name: String) async -> String {
    "<\(name) pixels>"
}

actor ImageCache {
    private var store: LRUStore<String, String>
    private(set) var decodes = 0

    init(budgetKB: Int) {
        store = LRUStore(budget: budgetKB)
    }

    func image(named name: String, sizeKB: Int) async -> String {
        if let cached = store.value(for: name) {
            return cached
        }
        decodes += 1
        let image = await decode(name)
        store.insert(image, for: name, cost: sizeKB)
        return image
    }

    func didReceiveMemoryWarning() {
        store.trim(toCost: store.budget / 2)
    }

    var summary: String {
        "\(store.keysByRecency) \(store.totalCost)KB, evicted \(store.evicted)"
    }
}

// A feed: an avatar (10 KB) shown with every post, posts of 30 KB, and one 150 KB panorama
let cache = ImageCache(budgetKB: 100)
let sizes = ["avatar": 10, "post1": 30, "post2": 30, "post3": 30, "post4": 30, "panorama": 150]
for name in ["avatar", "post1", "post2", "avatar", "post3", "post4", "avatar", "post1", "panorama"] {
    _ = await cache.image(named: name, sizeKB: sizes[name]!)
}
print(await cache.summary)
print("decodes:", await cache.decodes)
await cache.didReceiveMemoryWarning()
print("after memory warning:", await cache.summary)

// The same kind of feed, longer, with and without moving entries on a hit
func hits(promotesOnRead: Bool) -> Int {
    var store = LRUStore<String, Int>(budget: 100, promotesOnRead: promotesOnRead)
    var count = 0
    for post in 1...20 {
        for name in ["avatar", "post\(post)"] {
            if store.value(for: name) != nil {
                count += 1
            } else {
                store.insert(0, for: name, cost: name == "avatar" ? 10 : 30)
            }
        }
    }
    return count
}
print("hits out of 40, LRU:", hits(promotesOnRead: true), "FIFO:", hits(promotesOnRead: false))
