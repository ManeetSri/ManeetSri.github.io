// Reference solution: Mini social feed. The follow graph is `[Int: Set<Int>]`, and each user's
// posts are an array of (time, id) pairs stamped by one global clock, so every array is sorted.
// A feed is a k-way merge, newest first: a max-heap holds the newest unseen post of each author,
// and each pop pushes that author's next older post. With a cursor, a binary search per author
// finds where to start. For a user following f people, `feed` is O(f log n + f + limit × log f);
// `post`, `follow` and `unfollow` are O(1) on average.

import DSAKit

public enum MiniSocialFeed {
    public struct Network {
        private var following: [Int: Set<Int>] = [:]
        private var posts: [Int: [(time: Int, id: Int)]] = [:]
        private var timeOfPost: [Int: Int] = [:]
        private var clock = 0

        public init() {}

        public mutating func post(_ postID: Int, by user: Int) {
            posts[user, default: []].append((clock, postID))
            timeOfPost[postID] = clock
            clock += 1
        }

        public mutating func follow(follower: Int, followee: Int) {
            guard follower != followee else { return }          // everyone sees their own posts anyway
            following[follower, default: []].insert(followee)
        }

        public mutating func unfollow(follower: Int, followee: Int) {
            following[follower]?.remove(followee)
        }

        public func feed(for user: Int, limit: Int = 10, olderThan cursor: Int? = nil) -> [Int] {
            guard limit > 0 else { return [] }
            let cutoff = cursor.map { timeOfPost[$0] ?? Int.min } ?? Int.max
            var authors = following[user] ?? []
            authors.insert(user)

            // One entry per author: the position of their newest post older than the cutoff
            var starts: [(time: Int, author: Int, position: Int)] = []
            for author in authors {
                guard let list = posts[author] else { continue }
                let end = list.partitionPoint { $0.time >= cutoff }
                if end > 0 {
                    starts.append((list[end - 1].time, author, end - 1))
                }
            }
            var newest = Heap(starts, areInIncreasingOrder: { $0.time > $1.time })   // O(f) heapify

            var result: [Int] = []
            while result.count < limit, let top = newest.pop() {
                let list = posts[top.author]!
                result.append(list[top.position].id)
                if top.position > 0 {
                    newest.insert((list[top.position - 1].time, top.author, top.position - 1))
                }
            }
            return result
        }
    }
}
