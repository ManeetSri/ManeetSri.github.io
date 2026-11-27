import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MiniSocialFeedTests {
    typealias Network = MiniSocialFeed.Network

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The obvious slow version: every post in one list, scanned from the newest.
    private struct Model {
        var posts: [(user: Int, id: Int)] = []
        var following: [Int: Set<Int>] = [:]

        mutating func follow(_ follower: Int, _ followee: Int) {
            if follower != followee { following[follower, default: []].insert(followee) }
        }

        func feed(for user: Int, limit: Int, olderThan cursor: Int?) -> [Int] {
            let visible = (following[user] ?? []).union([user])
            var end = posts.count
            if let cursor {
                end = posts.firstIndex { $0.id == cursor } ?? 0
            }
            var result: [Int] = []
            var index = end - 1
            while index >= 0 && result.count < limit {
                if visible.contains(posts[index].user) { result.append(posts[index].id) }
                index -= 1
            }
            return result
        }
    }

    @Test("Following adds someone's posts to your feed, newest first; unfollowing removes them")
    func example() {
        var network = Network()
        network.post(101, by: 1)
        #expect(network.feed(for: 1) == [101])
        network.follow(follower: 1, followee: 2)
        network.post(201, by: 2)
        network.post(102, by: 1)
        network.post(202, by: 2)
        #expect(network.feed(for: 1) == [202, 102, 201, 101])
        #expect(network.feed(for: 2) == [202, 201])
        network.unfollow(follower: 1, followee: 2)
        #expect(network.feed(for: 1) == [102, 101])
    }

    @Test("A user with no posts who follows nobody has an empty feed")
    func emptyFeed() {
        var network = Network()
        #expect(network.feed(for: 5) == [])
        network.post(1, by: 6)
        #expect(network.feed(for: 5) == [])
        #expect(network.feed(for: 6, limit: 0) == [])
    }

    @Test("The feed holds at most `limit` posts, 10 by default")
    func limits() {
        var network = Network()
        for id in 1...25 {
            network.post(id, by: 3)
        }
        #expect(network.feed(for: 3) == Array((16...25).reversed()))
        #expect(network.feed(for: 3, limit: 3) == [25, 24, 23])
        #expect(network.feed(for: 3, limit: 100).count == 25)
    }

    @Test("Following yourself or following twice changes nothing")
    func followEdgeCases() {
        var network = Network()
        network.follow(follower: 1, followee: 1)
        network.post(10, by: 1)
        #expect(network.feed(for: 1) == [10])
        network.unfollow(follower: 1, followee: 1)
        #expect(network.feed(for: 1) == [10], "you always see your own posts")
        network.follow(follower: 1, followee: 2)
        network.follow(follower: 1, followee: 2)
        network.post(20, by: 2)
        network.unfollow(follower: 1, followee: 2)
        #expect(network.feed(for: 1) == [10])
        network.unfollow(follower: 1, followee: 3)
        #expect(network.feed(for: 1) == [10])
    }

    @Test("Following again brings back old posts")
    func refollow() {
        var network = Network()
        network.post(1, by: 2)
        network.post(2, by: 2)
        network.follow(follower: 1, followee: 2)
        #expect(network.feed(for: 1) == [2, 1])
        network.unfollow(follower: 1, followee: 2)
        #expect(network.feed(for: 1) == [])
        network.follow(follower: 1, followee: 2)
        #expect(network.feed(for: 1) == [2, 1])
    }

    @Test("A cursor pages through the feed with no gaps or repeats")
    func paging() {
        var network = Network()
        network.follow(follower: 7, followee: 8)
        network.follow(follower: 7, followee: 9)
        var all: [Int] = []
        for id in 1...23 {
            network.post(id * 10, by: [7, 8, 9, 10][id % 4])        // user 10's posts never show
            if id % 4 != 3 { all.append(id * 10) }
        }
        #expect(network.feed(for: 7, limit: 5, olderThan: 230) == [220, 210, 200, 180, 170])
        var paged: [Int] = []
        var cursor: Int? = nil
        for _ in 0..<10 {
            let page = network.feed(for: 7, limit: 5, olderThan: cursor)
            paged += page
            guard let last = page.last else { break }
            cursor = last
        }
        #expect(paged == all.reversed())
    }

    @Test("Thousands of mixed calls match a simple model", arguments: [1, 2, 3])
    func matchesModel(seed: Int) {
        var steps = Steps(seed: UInt64(seed) &* 1_009)
        var network = Network()
        var model = Model()
        var nextID = 1
        for step in 0..<4_000 {
            let user = steps.next(below: 8)
            switch steps.next(below: 10) {
            case 0, 1, 2, 3:
                network.post(nextID, by: user)
                model.posts.append((user, nextID))
                nextID += 1
            case 4, 5:
                let other = steps.next(below: 8)
                network.follow(follower: user, followee: other)
                model.follow(user, other)
            case 6:
                let other = steps.next(below: 8)
                network.unfollow(follower: user, followee: other)
                model.following[user]?.remove(other)
            default:
                let limit = steps.next(below: 13)
                let cursor = model.posts.isEmpty || steps.next(below: 2) == 0 ? nil : model.posts[steps.next(below: model.posts.count)].id
                let expected = model.feed(for: user, limit: limit, olderThan: cursor)
                if network.feed(for: user, limit: limit, olderThan: cursor) != expected {
                    Issue.record("feed(for: \(user), limit: \(limit), olderThan: \(String(describing: cursor))) is wrong at step \(step)")
                    return
                }
            }
        }
    }

    @Test("Quiet followees don't make the feed slow", .timeLimit(.minutes(1)))
    func quietFollowees() {
        var network = Network()
        network.post(1, by: 1)
        network.post(2, by: 0)
        network.follow(follower: 0, followee: 1)
        network.follow(follower: 0, followee: 2)            // user 2 never posts
        for id in 3..<200_003 {
            network.post(id, by: 3 + id % 997)               // a firehose from everyone else
        }
        var correct = true
        for _ in 0..<20_000 where network.feed(for: 0) != [2, 1] {
            correct = false
        }
        #expect(correct)
    }

    @Test("Paging through 100,000 posts from 500 followees", .timeLimit(.minutes(1)))
    func large() {
        var network = Network()
        for followee in 1...500 {
            network.follow(follower: 0, followee: followee)
        }
        for id in 0..<100_000 {
            network.post(id, by: 1 + id % 500)
        }
        var paged: [Int] = []
        var cursor: Int? = nil
        for _ in 0..<1_001 {
            let page = network.feed(for: 0, limit: 100, olderThan: cursor)
            paged += page
            guard let last = page.last else { break }
            cursor = last
        }
        #expect(paged.count == 100_000)
        #expect(paged == Array((0..<100_000).reversed()))
    }
}
