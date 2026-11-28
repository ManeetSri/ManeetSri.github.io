// Reference solution: The quietest city within reach. Every city needs its distance to every other,
// and there are at most 200 cities, so Floyd–Warshall: allow each city k in turn as a stop in the
// middle of every route. Then count, for each city, the others within the limit, and keep the first
// city with the smallest count. O(n³) time, O(n²) space.

public enum QuietestCityWithinReach {
    public static func city(cityCount n: Int, roads: [[Int]], maxDistance: Int) -> Int {
        let infinity = Int.max / 2
        var dist = Array(repeating: Array(repeating: infinity, count: n), count: n)
        for i in 0..<n {
            dist[i][i] = 0
        }
        for road in roads {
            let length = min(dist[road[0]][road[1]], road[2])   // keep the shorter of parallel roads
            dist[road[0]][road[1]] = length
            dist[road[1]][road[0]] = length
        }
        for k in 0..<n {
            for i in 0..<n where dist[i][k] < infinity {
                for j in 0..<n where dist[i][k] + dist[k][j] < dist[i][j] {
                    dist[i][j] = dist[i][k] + dist[k][j]
                }
            }
        }
        var best = 0
        var fewest = Int.max
        for city in 0..<n {
            let neighbours = (0..<n).filter { $0 != city && dist[city][$0] <= maxDistance }.count
            if neighbours < fewest {                    // strict: ties keep the smaller number
                fewest = neighbours
                best = city
            }
        }
        return best
    }
}
