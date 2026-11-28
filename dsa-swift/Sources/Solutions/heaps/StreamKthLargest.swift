// Reference solution: Kth highest score in a stream. Keep only the k highest scores so far, in a
// min-heap. Its top is the lowest of them: the kth highest overall. A new score that beats the top
// replaces it; anything else can never be in the top k again. O(log k) per score, O(k) space.

import DSAKit

public enum StreamKthLargest {
    public struct KthLargestTracker {
        private let k: Int
        private var best = Heap<Int>.minHeap()           // the k highest scores, lowest on top

        public init(k: Int) {
            self.k = k
        }

        public mutating func add(_ score: Int) -> Int? {
            if best.count < k {
                best.insert(score)
            } else if let lowest = best.peek(), score > lowest {
                best.replaceTop(with: score)
            }
            return best.count == k ? best.peek() : nil
        }
    }
}
