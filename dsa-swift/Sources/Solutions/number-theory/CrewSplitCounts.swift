// Reference solution: Ways to split tasks among crews. Unnamed crews are Stirling numbers of the second
// kind, S(n, k) = k·S(n−1, k) + S(n−1, k−1); named crews multiply by k!; any number of crews is the Bell
// number, a row sum of S; round tables are unsigned Stirling numbers of the first kind,
// c(n, k) = (n−1)·c(n−1, k) + c(n−1, k−1). Everything mod 1,000,000,007, built once in O(N²); O(1) queries.

public enum CrewSplitCounts {
    public struct Planner {
        private static let modulus = 1_000_000_007
        private var second: [[Int]]               // S(n, k)
        private var first: [[Int]]                // c(n, k)
        private var bell: [Int]
        private var factorial: [Int]

        public init(maxTasks: Int) {
            let p = Planner.modulus
            let size = maxTasks + 1
            second = Array(repeating: Array(repeating: 0, count: size), count: size)
            first = second
            second[0][0] = 1
            first[0][0] = 1
            for n in stride(from: 1, through: maxTasks, by: 1) {
                for k in 1...n {
                    second[n][k] = (k * second[n - 1][k] + second[n - 1][k - 1]) % p
                    first[n][k] = ((n - 1) * first[n - 1][k] + first[n - 1][k - 1]) % p
                }
            }
            bell = second.map { row in row.reduce(0) { ($0 + $1) % p } }
            factorial = [1]
            for k in stride(from: 1, through: maxTasks, by: 1) {
                factorial.append(factorial[k - 1] * k % p)
            }
        }

        public func unnamedCrews(tasks n: Int, crews k: Int) -> Int {
            second[n][k]
        }

        public func namedCrews(tasks n: Int, crews k: Int) -> Int {
            second[n][k] * factorial[k] % Planner.modulus
        }

        public func anyCrews(tasks n: Int) -> Int {
            bell[n]
        }

        public func roundTables(people n: Int, tables k: Int) -> Int {
            first[n][k]
        }
    }
}
