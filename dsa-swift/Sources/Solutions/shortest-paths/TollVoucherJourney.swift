// Reference solution: Cheapest drive with toll vouchers. The vouchers matter, so they go into the
// state: a vertex is (city, vouchers used). From (city, used), a road with toll t leads to
// (next, used) for t, or to (next, used + 1) for free while vouchers remain. Every cost is
// non-negative, so Dijkstra over the n · (k + 1) states, stopping when any state of the last city is
// popped. O(m · k · log(n · k)) time, O(n · k) space.

import DSAKit

public enum TollVoucherJourney {
    public static func cheapestCost(cityCount n: Int, roads: [[Int]], vouchers k: Int) -> Int {
        var graph: [[(to: Int, toll: Int)]] = Array(repeating: [], count: n)
        for road in roads {
            graph[road[0]].append((road[1], road[2]))
            graph[road[1]].append((road[0], road[2]))
        }
        let layers = k + 1
        var cost = Array(repeating: Int.max, count: n * layers)   // state (city, used) at city * layers + used
        cost[0] = 0
        var heap = Heap<(cost: Int, city: Int, used: Int)>(areInIncreasingOrder: { $0.cost < $1.cost })
        heap.insert((0, 0, 0))
        while let (current, city, used) = heap.pop() {
            if current > cost[city * layers + used] { continue }  // stale entry
            if city == n - 1 { return current }
            for (next, toll) in graph[city] {
                let paid = next * layers + used
                if current + toll < cost[paid] {
                    cost[paid] = current + toll
                    heap.insert((current + toll, next, used))
                }
                if used < k && current < cost[paid + 1] {          // spend a voucher on this road
                    cost[paid + 1] = current
                    heap.insert((current, next, used + 1))
                }
            }
        }
        return -1
    }
}
