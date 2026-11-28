import DSAKit

// Reference solution: turn penalty routes. A turn's cost depends on the road you arrived by, so a
// place alone isn't enough state. Search over directed roads instead: the state "drove u → v" knows
// both where the car is (v) and which way it faces. Dijkstra over these states, where moving on to
// v → w costs the road's length, plus the penalty when the cross product says it's a left turn, and
// is forbidden when w is u. O(T log T) for T transitions, the sum over places of degree squared.

public enum TurnPenaltyRoutes {
    public static func cheapest(places: [[Int]], roads: [[Int]], from start: Int, to goal: Int,
                                leftTurnPenalty: Int) -> Int? {
        if start == goal { return 0 }
        // Directed road i goes from tail[i] to head[i]; leaving[p] lists the directed roads out of p
        var tail: [Int] = [], head: [Int] = [], length: [Int] = []
        var leaving = [[Int]](repeating: [], count: places.count)
        for road in roads {
            for (from, to) in [(road[0], road[1]), (road[1], road[0])] {
                leaving[from].append(tail.count)
                tail.append(from)
                head.append(to)
                length.append(road[2])
            }
        }

        func isLeftTurn(_ u: Int, _ v: Int, _ w: Int) -> Bool {
            let (inX, inY) = (places[v][0] - places[u][0], places[v][1] - places[u][1])
            let (outX, outY) = (places[w][0] - places[v][0], places[w][1] - places[v][1])
            return inX * outY - inY * outX > 0                  // counterclockwise, with y pointing north
        }

        var best = [Int](repeating: Int.max, count: tail.count)
        var queue = Heap<(cost: Int, road: Int)>(areInIncreasingOrder: { $0.cost < $1.cost })
        for road in leaving[start] {
            best[road] = length[road]
            queue.insert((length[road], road))
        }
        while let (cost, road) = queue.pop() {
            guard cost == best[road] else { continue }           // a stale entry
            let (u, v) = (tail[road], head[road])
            if v == goal { return cost }
            for next in leaving[v] where head[next] != u {       // no U-turns
                let total = cost + length[next] + (isLeftTurn(u, v, head[next]) ? leftTurnPenalty : 0)
                if total < best[next] {
                    best[next] = total
                    queue.insert((total, next))
                }
            }
        }
        return nil
    }
}
