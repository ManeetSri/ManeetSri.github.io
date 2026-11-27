// Generated from src/dsa/content/lessons/design-structures/ds-twitter.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", compacted
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    mutating func insert(_ element: Element) {
        items.append(element)
        var child = items.count - 1
        while child > 0 && areInIncreasingOrder(items[child], items[(child - 1) / 2]) {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { return top }
            items.swapAt(parent, first)
            parent = first
        }
    }
}

struct MiniTwitter {
    private var following: [Int: Set<Int>] = [:]               // follower -> people they follow
    private var tweets: [Int: [(time: Int, id: Int)]] = [:]     // author -> tweets, oldest first
    private var clock = 0                                       // one counter orders every tweet

    mutating func post(_ tweetID: Int, by user: Int) {
        tweets[user, default: []].append((clock, tweetID))
        clock += 1
    }

    mutating func follow(_ followee: Int, by follower: Int) {
        guard follower != followee else { return }
        following[follower, default: []].insert(followee)
    }

    mutating func unfollow(_ followee: Int, by follower: Int) {
        following[follower]?.remove(followee)
    }

    func feed(for user: Int, limit: Int = 10) -> [Int] {
        // Newest on top: each entry is an author's newest tweet not yet taken
        var newest = Heap<(time: Int, author: Int, index: Int)>(areInIncreasingOrder: { $0.time > $1.time })
        for author in (following[user] ?? []).union([user]) {
            if let list = tweets[author], let last = list.last {
                newest.insert((last.time, author, list.count - 1))
            }
        }
        var result: [Int] = []
        var pops = 0
        while result.count < limit, let top = newest.pop() {
            pops += 1
            let list = tweets[top.author]!
            result.append(list[top.index].id)
            if top.index > 0 {                                 // that author's next older tweet
                newest.insert((list[top.index - 1].time, top.author, top.index - 1))
            }
        }
        print("  (\(pops) pops)")
        return result
    }
}

let maneet = 1, ana = 2, sam = 3
var app = MiniTwitter()
app.post(10, by: maneet)
app.post(20, by: ana)
app.post(21, by: ana)
app.post(30, by: sam)
app.post(11, by: maneet)
app.post(31, by: sam)

app.follow(ana, by: maneet)
print(app.feed(for: maneet))
app.follow(sam, by: maneet)
print(app.feed(for: maneet))
print(app.feed(for: maneet, limit: 3))
app.unfollow(ana, by: maneet)
print(app.feed(for: maneet))
print(app.feed(for: sam))
