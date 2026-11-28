import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RemainderBucketsTests {
    @Test("Groups by remainder, keeping input order")
    func groups() {
        let result = RemainderBuckets.buckets([7, 3, 10, 4, 6, 1], k: 3)
        #expect(result == [0: [3, 6], 1: [7, 10, 4, 1]])
    }

    @Test("Puts negative numbers in buckets 0..<k")
    func negatives() {
        let result = RemainderBuckets.buckets([-1, -3, -7, 2, 5], k: 3)
        #expect(result == [2: [-1, -7, 2, 5], 0: [-3]])
        #expect(RemainderBuckets.buckets([-10], k: 4) == [2: [-10]])
    }

    @Test("Leaves out remainders with no numbers")
    func noEmptyBuckets() {
        let result = RemainderBuckets.buckets([4, 8, 12], k: 4)
        #expect(result == [0: [4, 8, 12]])
        #expect(result[1] == nil)
    }

    @Test("Uses a single bucket when k is 1")
    func kIsOne() {
        #expect(RemainderBuckets.buckets([5, -2, 0], k: 1) == [0: [5, -2, 0]])
    }

    @Test("Returns an empty dictionary for no numbers")
    func empty() {
        #expect(RemainderBuckets.buckets([], k: 5) == [:])
    }

    @Test("Handles the extremes of the allowed range")
    func extremes() {
        let result = RemainderBuckets.buckets([1_000_000_000, -1_000_000_000], k: 1_000)
        #expect(result == [0: [1_000_000_000, -1_000_000_000]])
        #expect(RemainderBuckets.buckets([-999_999_999], k: 1_000) == [1: [-999_999_999]])
    }

    @Test("Keeps duplicates")
    func duplicates() {
        #expect(RemainderBuckets.buckets([2, 2, 5], k: 3) == [2: [2, 2, 5]])
    }
}
