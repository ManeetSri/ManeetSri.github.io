// Reference solution: Which stations can reach which. Build the transitive closure with the
// Floyd–Warshall loops, using "or" and "and" instead of min and +: after round k, reach[i][j] says
// whether j can be reached from i using only stations 0...k in between. Then each query is a lookup.
// O(n³ + q) time, O(n²) space. (A BFS from every station, O(n · (n + m)), works too.)

public enum TransitReachability {
    public static func canReach(stationCount n: Int, connections: [[Int]], queries: [[Int]]) -> [Bool] {
        var reach = Array(repeating: Array(repeating: false, count: n), count: n)
        for i in 0..<n {
            reach[i][i] = true
        }
        for connection in connections {
            reach[connection[0]][connection[1]] = true
        }
        for k in 0..<n {
            for i in 0..<n where reach[i][k] {
                for j in 0..<n where reach[k][j] {
                    reach[i][j] = true
                }
            }
        }
        return queries.map { reach[$0[0]][$0[1]] }
    }
}
