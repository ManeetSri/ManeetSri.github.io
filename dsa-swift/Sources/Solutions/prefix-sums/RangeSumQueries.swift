// Reference solution: Range sum queries. A prefix array with a leading 0, so prefix[i] is the sum of
// the first i values and every range is one subtraction. O(n) to build, O(1) per query, O(n) space.

public enum RangeSumQueries {
    public struct Table {
        private let prefix: [Int]

        public init(_ values: [Int]) {
            var prefix = [0]
            prefix.reserveCapacity(values.count + 1)
            for value in values {
                prefix.append(prefix[prefix.count - 1] + value)
            }
            self.prefix = prefix
        }

        public func sum(from start: Int, through end: Int) -> Int {
            prefix[end + 1] - prefix[start]
        }
    }
}
