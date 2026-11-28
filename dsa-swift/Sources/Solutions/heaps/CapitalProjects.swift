// Reference solution: Grow the studio's capital. Greedy: each time, take the most profitable contract
// the studio can already afford. Capital never goes down, so whatever is affordable now stays
// affordable, and taking the biggest profit first can only unlock more. Sort contracts by requirement;
// as capital grows, a pointer moves newly affordable contracts into a max-heap of profits.
// O(n log n) time, O(n) space.

import DSAKit

public enum CapitalProjects {
    public static func bestFinalCapital(start: Int, maxContracts k: Int, requirements: [Int], profits: [Int]) -> Int {
        let byRequirement = requirements.indices.sorted { requirements[$0] < requirements[$1] }
        var affordable = Heap<Int>.maxHeap()                // profits of contracts we could take now
        var capital = start
        var nextContract = 0
        for _ in 0..<k {
            while nextContract < byRequirement.count && requirements[byRequirement[nextContract]] <= capital {
                affordable.insert(profits[byRequirement[nextContract]])
                nextContract += 1
            }
            guard let profit = affordable.pop() else { break }   // nothing affordable is left
            capital += profit
        }
        return capital
    }
}
