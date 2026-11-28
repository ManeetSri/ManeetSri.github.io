import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PriceFeedCorrectionsTests {
    typealias Feed = PriceFeedCorrections.Feed

    @Test("The statement's example")
    func example() {
        var feed = Feed()
        feed.record(time: 1, price: 100)
        feed.record(time: 3, price: 90)
        #expect(feed.latest == 90)
        #expect(feed.highest == 100)
        #expect(feed.lowest == 90)
        feed.record(time: 2, price: 120)                 // arrives late
        #expect(feed.latest == 90)
        #expect(feed.highest == 120)
        feed.record(time: 2, price: 95)                  // corrects time 2
        #expect(feed.highest == 100)
        feed.record(time: 1, price: 85)                  // corrects time 1
        #expect(feed.highest == 95)
        #expect(feed.lowest == 85)
    }

    @Test("An empty feed has no prices")
    func empty() {
        let feed = Feed()
        #expect(feed.latest == nil)
        #expect(feed.highest == nil)
        #expect(feed.lowest == nil)
    }

    @Test("Correcting the latest time changes the latest price")
    func correctLatest() {
        var feed = Feed()
        feed.record(time: 10, price: 5)
        feed.record(time: 10, price: 7)
        #expect(feed.latest == 7)
        #expect(feed.highest == 7)
        #expect(feed.lowest == 7)
    }

    @Test("A price held at two times survives correcting one of them")
    func sharedPrice() {
        var feed = Feed()
        feed.record(time: 1, price: 50)
        feed.record(time: 2, price: 50)
        feed.record(time: 3, price: 10)
        feed.record(time: 1, price: 20)                  // 50 is still held at time 2
        #expect(feed.highest == 50)
        feed.record(time: 2, price: 30)                  // now 50 is gone
        #expect(feed.highest == 30)
        #expect(feed.lowest == 10)
    }

    @Test("Negative times and prices")
    func negatives() {
        var feed = Feed()
        feed.record(time: -5, price: -3)
        feed.record(time: -9, price: 4)
        #expect(feed.latest == -3)
        #expect(feed.highest == 4)
        #expect(feed.lowest == -3)
    }

    @Test("Copies of a feed are independent")
    func valueSemantics() {
        var feed = Feed()
        feed.record(time: 1, price: 10)
        var copy = feed
        copy.record(time: 1, price: 99)
        #expect(feed.highest == 10)
        #expect(copy.highest == 99)
    }

    @Test("Matches a brute-force scan on small random input")
    func againstBruteForce() {
        var state: UInt64 = 5
        func next(_ limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
        var feed = Feed()
        var prices: [Int: Int] = [:]
        var wrong = 0
        for _ in 0..<3_000 {
            let time = next(60)
            let price = next(1_000)
            feed.record(time: time, price: price)
            prices[time] = price
            let latestTime = prices.keys.max()!
            if feed.latest != prices[latestTime] { wrong += 1 }
            if feed.highest != prices.values.max() || feed.lowest != prices.values.min() { wrong += 1 }
        }
        #expect(wrong == 0)
    }

    @Test("100,000 records with corrections, querying after each one")
    func large() {
        let n = 50_000
        var feed = Feed()
        var wrong = 0
        // First pass: time t has price t, recorded in a scrambled order
        for k in 0..<n {
            let time = (k * 7_919) % n
            feed.record(time: time, price: time)
            if feed.highest == nil || feed.lowest == nil { wrong += 1 }
        }
        if feed.highest != n - 1 || feed.lowest != 0 || feed.latest != n - 1 { wrong += 1 }
        // Second pass: correct each time t, from the top down, to price -t. After correcting time t,
        // the highest is t - 1 (the largest price not yet corrected) and the lowest is -(n - 1).
        for time in stride(from: n - 1, through: 1, by: -1) {
            feed.record(time: time, price: -time)
            if feed.highest != time - 1 || feed.lowest != -(n - 1) { wrong += 1 }
        }
        #expect(wrong == 0)
        #expect(feed.latest == -(n - 1))
        #expect(feed.highest == 0)
    }
}
