// Generated from src/dsa/content/lessons/interview-playbook/int-ios-flavoured.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct TokenBucket {
    let capacity: Int          // the biggest burst allowed
    let refillEvery: Int       // milliseconds to earn one token back
    private var tokens: Int
    private var lastRefill: Int

    init(capacity: Int, refillEvery: Int, now: Int) {
        self.capacity = capacity
        self.refillEvery = refillEvery
        tokens = capacity
        lastRefill = now
    }

    mutating func allow(at time: Int) -> Bool {
        let earned = (time - lastRefill) / refillEvery
        if earned > 0 {
            tokens = min(capacity, tokens + earned)
            lastRefill += earned * refillEvery     // keep the part of a token not yet earned
        }
        guard tokens > 0 else { return false }
        tokens -= 1
        return true
    }
}

var bucket = TokenBucket(capacity: 3, refillEvery: 1000, now: 0)
let requests = [0, 10, 20, 30, 1000, 1500, 2600, 2700, 5000]
print(requests.map { bucket.allow(at: $0) })
