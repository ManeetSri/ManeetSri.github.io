// Reference solution: Jobs with a cooldown. Simulate, greedily: in each slot, run the kind with the
// most jobs left among those not cooling down. A max-heap holds the ready kinds by jobs left; a queue
// holds the cooling kinds with the slot they're ready again (kinds join it in the order they ran, so
// their ready slots increase). When nothing is ready, jump straight to the next ready slot instead of
// stepping through idle slots one by one. O(n log m) for n jobs of m kinds.

import DSAKit

public enum CooldownScheduler {
    public static func fewestSlots(_ jobs: [String], cooldown: Int) -> Int {
        var remaining: [String: Int] = [:]
        for job in jobs {
            remaining[job, default: 0] += 1
        }
        var ready = Heap.maxHeap(remaining.values)          // jobs left per kind; names don't matter
        var cooling = Deque<(left: Int, readyAt: Int)>()
        var slot = 0                                        // the next slot to fill
        while !ready.isEmpty || !cooling.isEmpty {
            if ready.isEmpty, let next = cooling.first, next.readyAt > slot {
                slot = next.readyAt                         // idle until the first kind cools down
            }
            while let next = cooling.first, next.readyAt <= slot {
                ready.insert(next.left)
                cooling.popFirst()
            }
            let left = ready.pop()! - 1                     // run one job of the busiest kind
            if left > 0 {
                cooling.append((left, slot + cooldown + 1))
            }
            slot += 1
        }
        return slot
    }
}
