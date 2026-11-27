// Reference solution: Fewest refuelling stops. Drive as far as the tank allows, remembering every station you
// passed in a max-heap of litres. When you can't reach the next station (or the target), pretend you had
// stopped at the best station behind you: pop the largest amount and add it. Each pop is one stop, and
// taking the largest is safe by an exchange argument: any plan that stops at a smaller passed station
// instead can swap it for the larger one and get at least as far. If the heap runs dry first, the target
// is out of reach. A DP over "farthest reach with k stops" is also correct, in O(n^2).
// O(n log n) time, O(n) space.

import DSAKit

public enum FewestRefuelStops {
    public static func fewestStops(target: Int, startFuel: Int, stations: [[Int]]) -> Int {
        var passed = Heap<Int>.maxHeap()
        var reach = startFuel                 // the farthest position the fuel so far can reach
        var stops = 0
        var next = 0                          // the next station not yet passed
        while reach < target {
            while next < stations.count, stations[next][0] <= reach {
                passed.insert(stations[next][1])
                next += 1
            }
            guard let best = passed.pop() else { return -1 }
            reach += best
            stops += 1
        }
        return stops
    }
}
