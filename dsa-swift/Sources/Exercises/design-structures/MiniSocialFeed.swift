// Problem: Mini social feed (M72 · Design a Twitter feed)

public enum MiniSocialFeed {
    /// A tiny social network: users post, follow each other, and read a feed of the newest posts
    /// from themselves and the people they follow.
    public struct Network {
        // Write your solution here, then run:
        // swift test --filter MiniSocialFeedTests
        // Add whatever private storage you need. You may `import DSAKit` and use its Heap.

        /// Creates an empty network.
        public init() {
        }

        /// `user` publishes a post with the id `postID`. Ids are never reused.
        public mutating func post(_ postID: Int, by user: Int) {
        }

        /// `follower` starts following `followee`. Following yourself, or someone you already
        /// follow, changes nothing.
        public mutating func follow(follower: Int, followee: Int) {
        }

        /// `follower` stops following `followee`. Unfollowing someone you don't follow changes nothing.
        public mutating func unfollow(follower: Int, followee: Int) {
        }

        /// The ids of the `limit` newest posts by `user` and everyone `user` follows now, newest
        /// first. With a cursor, only posts older than the post `cursor` count.
        public func feed(for user: Int, limit: Int = 10, olderThan cursor: Int? = nil) -> [Int] {
            return []
        }
    }
}
