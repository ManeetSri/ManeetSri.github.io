// Problem: Thumbnail cache with a byte budget (M71 · iOS-flavoured DSA questions)

public enum ThumbnailBudgetCache {
    /// Caches images by URL, keeping their total size within `byteBudget` bytes. When an insert takes the
    /// total over budget, it evicts least recently used images until everything fits. Reading or
    /// inserting an image counts as using it.
    ///
    /// Aim for O(1) per operation, plus O(1) for each image evicted.
    public final class Cache<Image> {
        /// The most bytes the cache holds at once. At least 1.
        public let byteBudget: Int

        public init(byteBudget: Int) {
            self.byteBudget = byteBudget
        }

        /// The total size of the cached images.
        public var totalBytes: Int {
            // Write your solution here, then run:
            // swift test --filter ThumbnailBudgetCacheTests
            return 0
        }

        /// The number of cached images.
        public var count: Int {
            return 0
        }

        /// The image cached for `url`, or nil. A hit makes `url` the most recently used.
        public func image(for url: String) -> Image? {
            return nil
        }

        /// Caches `image` (of `bytes` bytes) for `url`, replacing any older image for that URL, and makes
        /// it the most recently used. Then evicts least recently used images until the total fits the
        /// budget, and returns their URLs in the order they were evicted.
        ///
        /// An image bigger than the whole budget isn't cached at all: any older image for `url` is
        /// removed, nothing else changes, and the result is empty.
        @discardableResult
        public func insert(_ image: Image, for url: String, bytes: Int) -> [String] {
            return []
        }

        /// Handles a memory warning: evicts least recently used images until the total is at most
        /// `limit` bytes, and returns their URLs in the order they were evicted.
        @discardableResult
        public func trim(toBytes limit: Int) -> [String] {
            return []
        }

        /// Every cached URL, most recently used first.
        public var urlsByRecency: [String] {
            return []
        }
    }
}
