// Reference solution: Cheapest matrix bracketing. Interval DP: cost[i][j] is the fewest multiplications
// for matrices i...j, and the last multiplication splits them at some k into (i...k)(k+1...j), costing
// dims[i] · dims[k + 1] · dims[j + 1] on top of the two parts. Ranges are filled shortest first, the
// best k is kept in split[i][j], and the bracketing is rebuilt recursively from it.
// O(n³) time, O(n²) space for n matrices.

public enum CheapestMatrixBracketing {
    public static func minimumCost(dims: [Int]) -> Int {
        let (cost, _) = solve(dims)
        return cost[0][dims.count - 2]
    }

    public static func bracketing(dims: [Int]) -> String {
        let (_, split) = solve(dims)
        func bracket(_ i: Int, _ j: Int) -> String {
            if i == j { return "A\(i + 1)" }
            let k = split[i][j]
            return "(" + bracket(i, k) + " " + bracket(k + 1, j) + ")"
        }
        return bracket(0, dims.count - 2)
    }

    /// The cost and best-split tables for every range of matrices
    private static func solve(_ dims: [Int]) -> (cost: [[Int]], split: [[Int]]) {
        let n = dims.count - 1
        var cost = Array(repeating: Array(repeating: 0, count: n), count: n)
        var split = Array(repeating: Array(repeating: 0, count: n), count: n)
        if n >= 2 {
            for length in 2...n {
                for i in 0...(n - length) {
                    let j = i + length - 1
                    cost[i][j] = Int.max
                    for k in i..<j {
                        let total = cost[i][k] + cost[k + 1][j] + dims[i] * dims[k + 1] * dims[j + 1]
                        if total < cost[i][j] {
                            cost[i][j] = total
                            split[i][j] = k
                        }
                    }
                }
            }
        }
        return (cost, split)
    }
}
