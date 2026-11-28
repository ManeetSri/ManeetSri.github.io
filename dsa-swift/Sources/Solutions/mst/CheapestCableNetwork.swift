// Reference solution: The cheapest cable network. Kruskal's algorithm: sort the options by cost and
// take each one that joins two cities not yet connected, skipping any that would close a loop. The
// network is complete after n - 1 cables; if the options run out first, some city can't be reached.
// O(E log E) time for E options (the sort dominates), O(n + E) space.

import DSAKit

public enum CheapestCableNetwork {
    public static func minimumCost(_ n: Int, _ options: [[Int]]) -> Int {
        var cities = UnionFind(count: n)
        var total = 0
        var cables = 0
        for option in options.sorted(by: { $0[2] < $1[2] }) where cables < n - 1 {
            if cities.union(option[0], option[1]) {
                total += option[2]
                cables += 1
            }
        }
        return cables == n - 1 ? total : -1
    }
}
