// Reference solution: Fuel stops on a ring road. If the total of fuel[i] - cost[i] is negative, no
// start works. Otherwise drive from a candidate start, and whenever the tank goes negative after
// station i, no station from the candidate up to i can be a start (each was reached with a
// non-negative tank and still failed), so the candidate becomes i + 1. The last candidate comes right
// after the lowest point of the running total, which is the smallest station that works.
// O(n) time, O(1) space.

public enum RingRoadFuelStart {
    public static func startStation(fuel: [Int], cost: [Int]) -> Int {
        var total = 0
        var tank = 0
        var start = 0
        for i in fuel.indices {
            let gain = fuel[i] - cost[i]
            total += gain
            tank += gain
            if tank < 0 {
                start = i + 1
                tank = 0
            }
        }
        return total >= 0 ? start : -1
    }
}
