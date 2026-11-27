// Reference solution: Build the grid in Borůvka rounds. Each round, one pass over the lines finds every
// grid's cheapest outgoing line, comparing by cost and then by position in the list so no two lines
// tie; then all of them are built at once with union-find, which ignores a line picked by both its
// grids. Rounds stop when no line joins two different grids, which also handles towns that can never
// be connected. Every round at least halves the grids that still have a way out, so there are
// O(log towns) rounds of O(lines) work: O(lines log towns) time, O(towns) extra space.

import DSAKit

public enum BoruvkaGridRounds {
    public static func plan(towns: Int, lines: [[Int]]) -> (cost: Int, gridsAfterRound: [Int]) {
        /// Line a comes before line b: by cost, then by position in the list
        func cheaper(_ a: Int, _ b: Int) -> Bool {
            lines[a][2] != lines[b][2] ? lines[a][2] < lines[b][2] : a < b
        }
        var grids = UnionFind(count: towns)
        var cost = 0
        var history: [Int] = []
        while true {
            // cheapest[root]: the index of the cheapest line leaving that root's grid, or -1
            var cheapest = Array(repeating: -1, count: towns)
            for index in lines.indices {
                let rootA = grids.find(lines[index][0])
                let rootB = grids.find(lines[index][1])
                if rootA == rootB { continue }                      // inside one grid
                if cheapest[rootA] == -1 || cheaper(index, cheapest[rootA]) { cheapest[rootA] = index }
                if cheapest[rootB] == -1 || cheaper(index, cheapest[rootB]) { cheapest[rootB] = index }
            }
            var built = false
            for index in cheapest where index != -1 && grids.union(lines[index][0], lines[index][1]) {
                cost += lines[index][2]
                built = true
            }
            if !built { break }                                     // no line joins two grids
            history.append(grids.componentCount)
        }
        return (cost, history)
    }
}
