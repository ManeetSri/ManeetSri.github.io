// Reference solution: Find a profit loop. Bellman–Ford with every trader starting at 0, as if a new
// trader had a free trade to each, so a negative loop anywhere is found. Record each trader's parent
// on every improvement. If round n still improves trader v, then v is on or after a negative loop;
// walking parents n times from v is guaranteed to land on the loop itself, and walking from there
// until a trader repeats reads the loop backwards. O(n · m) time, O(n) space.

public enum ProfitLoopFinder {
    public static func findLoop(traderCount n: Int, trades: [[Int]]) -> [Int] {
        var balance = Array(repeating: 0, count: n)
        var parent = Array(repeating: -1, count: n)
        var improved = -1
        for _ in 0..<n {                                // n − 1 rounds, plus one to detect a loop
            improved = -1
            for trade in trades where balance[trade[0]] + trade[2] < balance[trade[1]] {
                balance[trade[1]] = balance[trade[0]] + trade[2]
                parent[trade[1]] = trade[0]
                improved = trade[1]
            }
            if improved == -1 { return [] }             // a quiet round: no loop can pay
        }
        var trader = improved
        for _ in 0..<n {
            trader = parent[trader]                     // step back until we're inside the loop
        }
        var loop = [trader]
        var current = parent[trader]
        while current != trader {
            loop.append(current)
            current = parent[current]
        }
        return loop.reversed()                          // parents point backwards along the loop
    }
}
