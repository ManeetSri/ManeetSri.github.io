import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run makes the same requests
private struct ThumbnailRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// The obvious model: an array of entries, most recently used first. Every operation is O(n).
private struct ThumbnailModel {
    let budget: Int
    var entries: [(url: String, image: String, bytes: Int)] = []

    var total: Int { entries.reduce(0) { $0 + $1.bytes } }

    mutating func image(for url: String) -> String? {
        guard let index = entries.firstIndex(where: { $0.url == url }) else { return nil }
        let entry = entries.remove(at: index)
        entries.insert(entry, at: 0)
        return entry.image
    }

    mutating func evict(downTo limit: Int) -> [String] {
        var evicted: [String] = []
        while total > limit, let last = entries.popLast() {
            evicted.append(last.url)
        }
        return evicted
    }

    mutating func insert(_ image: String, for url: String, bytes: Int) -> [String] {
        entries.removeAll { $0.url == url }
        guard bytes <= budget else { return [] }
        entries.insert((url, image, bytes), at: 0)
        return evict(downTo: budget)
    }
}

@Suite struct ThumbnailBudgetCacheTests {
    typealias Cache = ThumbnailBudgetCache.Cache<String>

    @Test("The example from the statement")
    func example() {
        let cache = Cache(byteBudget: 100)
        #expect(cache.insert("H", for: "hero.jpg", bytes: 40) == [])
        #expect(cache.insert("A", for: "avatar.png", bytes: 30) == [])
        #expect(cache.insert("L", for: "logo.png", bytes: 20) == [])
        #expect(cache.totalBytes == 90)
        #expect(cache.image(for: "hero.jpg") == "H")
        #expect(cache.insert("B", for: "banner.jpg", bytes: 45) == ["avatar.png", "logo.png"])
        #expect(cache.urlsByRecency == ["banner.jpg", "hero.jpg"])
        #expect(cache.totalBytes == 85)
        #expect(cache.insert("H2", for: "hero.jpg", bytes: 70) == ["banner.jpg"])
        #expect(cache.image(for: "hero.jpg") == "H2")
        #expect(cache.insert("P", for: "poster.jpg", bytes: 150) == [])
        #expect(cache.urlsByRecency == ["hero.jpg"])
        #expect(cache.trim(toBytes: 50) == ["hero.jpg"])
        #expect(cache.count == 0)
        #expect(cache.totalBytes == 0)
    }

    @Test("An empty cache")
    func empty() {
        let cache = Cache(byteBudget: 10)
        #expect(cache.count == 0)
        #expect(cache.totalBytes == 0)
        #expect(cache.image(for: "missing.png") == nil)
        #expect(cache.urlsByRecency == [])
        #expect(cache.trim(toBytes: 0) == [])
    }

    @Test("A miss doesn't change the order")
    func missKeepsOrder() {
        let cache = Cache(byteBudget: 10)
        cache.insert("1", for: "a", bytes: 3)
        cache.insert("2", for: "b", bytes: 3)
        #expect(cache.image(for: "c") == nil)
        #expect(cache.urlsByRecency == ["b", "a"])
        #expect(cache.insert("3", for: "c", bytes: 5) == ["a"])
    }

    @Test("Replacing an image counts as a use, and never evicts the new image")
    func replace() {
        let cache = Cache(byteBudget: 100)
        cache.insert("old", for: "a", bytes: 50)
        cache.insert("b", for: "b", bytes: 30)
        #expect(cache.insert("smaller", for: "a", bytes: 10) == [])
        #expect(cache.urlsByRecency == ["a", "b"])
        #expect(cache.totalBytes == 40)
        #expect(cache.count == 2)
        #expect(cache.insert("bigger", for: "a", bytes: 90) == ["b"])
        #expect(cache.urlsByRecency == ["a"])
        #expect(cache.image(for: "a") == "bigger")
        #expect(cache.totalBytes == 90)
    }

    @Test("An image of exactly the budget pushes out everything else")
    func exactlyBudget() {
        let cache = Cache(byteBudget: 64)
        for index in 0..<8 {
            cache.insert("\(index)", for: "tile\(index)", bytes: 8)
        }
        #expect(cache.totalBytes == 64)
        #expect(cache.insert("full", for: "wallpaper", bytes: 64) == (0..<8).map { "tile\($0)" })
        #expect(cache.urlsByRecency == ["wallpaper"])
    }

    @Test("A too-big image isn't cached, and drops the stale image for its URL")
    func tooBig() {
        let cache = Cache(byteBudget: 20)
        cache.insert("small", for: "photo", bytes: 5)
        cache.insert("other", for: "icon", bytes: 5)
        #expect(cache.insert("huge", for: "photo", bytes: 21) == [])
        #expect(cache.image(for: "photo") == nil)
        #expect(cache.urlsByRecency == ["icon"])
        #expect(cache.totalBytes == 5)
        #expect(cache.count == 1)
    }

    @Test("trim evicts oldest first, and does nothing when already under the limit")
    func trim() {
        let cache = Cache(byteBudget: 100)
        cache.insert("1", for: "a", bytes: 10)
        cache.insert("2", for: "b", bytes: 20)
        cache.insert("3", for: "c", bytes: 30)
        #expect(cache.trim(toBytes: 60) == [])
        #expect(cache.trim(toBytes: 59) == ["a"])
        #expect(cache.trim(toBytes: 30) == ["b"])
        #expect(cache.trim(toBytes: 0) == ["c"])
        #expect(cache.count == 0)
        cache.insert("4", for: "d", bytes: 100)
        #expect(cache.urlsByRecency == ["d"], "the cache still works after being emptied")
    }

    @Test("Matches the model through thousands of random operations", arguments: [1, 7, 20, 64, 200])
    func matchesModel(budget: Int) {
        var random = ThumbnailRandom(seed: UInt64(budget))
        let cache = Cache(byteBudget: budget)
        var model = ThumbnailModel(budget: budget)
        let urls = (0..<12).map { "https://cdn.example/\($0).jpg" }
        var firstMismatch: String? = nil
        for step in 0..<3_000 where firstMismatch == nil {
            let url = urls[Int.random(in: 0..<urls.count, using: &random)]
            switch Int.random(in: 0..<10, using: &random) {
            case 0..<4:
                let got = cache.image(for: url), expected = model.image(for: url)
                if got != expected { firstMismatch = "step \(step): image(for: \(url)) gave \(String(describing: got)), expected \(String(describing: expected))" }
            case 4..<9:
                let bytes = Int.random(in: 1...(budget + budget / 4 + 1), using: &random)
                let got = cache.insert("v\(step)", for: url, bytes: bytes), expected = model.insert("v\(step)", for: url, bytes: bytes)
                if got != expected { firstMismatch = "step \(step): insert for \(url), \(bytes) bytes, evicted \(got), expected \(expected)" }
            default:
                let limit = Int.random(in: 0...budget, using: &random)
                let got = cache.trim(toBytes: limit), expected = model.evict(downTo: limit)
                if got != expected { firstMismatch = "step \(step): trim(toBytes: \(limit)) evicted \(got), expected \(expected)" }
            }
            if firstMismatch == nil && (cache.totalBytes != model.total || cache.count != model.entries.count) {
                firstMismatch = "step \(step): totalBytes \(cache.totalBytes) and count \(cache.count), expected \(model.total) and \(model.entries.count)"
            }
        }
        #expect(firstMismatch == nil)
        if firstMismatch == nil {
            #expect(cache.urlsByRecency == model.entries.map(\.url))
        }
    }

    @Test("100,000 inserts with 5,000 images alive")
    func large() {
        let cache = Cache(byteBudget: 50_000)
        var wrongEvictions = 0
        for index in 0..<100_000 {
            let evicted = cache.insert("i\(index)", for: "img\(index)", bytes: 10)
            let expected = index >= 5_000 ? ["img\(index - 5_000)"] : []
            if evicted != expected { wrongEvictions += 1 }
        }
        #expect(wrongEvictions == 0)
        #expect(cache.count == 5_000)
        #expect(cache.totalBytes == 50_000)

        // Use the even ones, so the odd ones become the oldest
        let misses = stride(from: 95_000, to: 100_000, by: 2).filter { cache.image(for: "img\($0)") == nil }.count
        #expect(misses == 0)
        let odd = stride(from: 95_001, to: 100_000, by: 2).map { "img\($0)" }
        #expect(cache.insert("big", for: "big.png", bytes: 25_000) == odd)
        #expect(cache.count == 2_501)

        let even = stride(from: 95_000, to: 100_000, by: 2).map { "img\($0)" }
        #expect(cache.trim(toBytes: 0) == even + ["big.png"])
        #expect(cache.totalBytes == 0)
    }
}
