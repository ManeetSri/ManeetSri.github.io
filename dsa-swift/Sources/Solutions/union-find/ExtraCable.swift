// Reference solution: The extra cable. Add the cables in order with union-find. The tree's cables
// all join computers that weren't connected yet; the first cable whose ends are already connected
// closes the one cycle, and it's the latest of the cycle's cables in the input, so it's the answer.
// O(n α(n)) time, O(n) space.

import DSAKit

public enum ExtraCable {
    public static func find(_ cables: [[Int]]) -> [Int] {
        var network = UnionFind(count: cables.count)
        for cable in cables where !network.union(cable[0], cable[1]) {
            return cable
        }
        return []
    }
}
