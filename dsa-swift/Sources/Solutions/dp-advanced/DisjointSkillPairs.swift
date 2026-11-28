// Reference solution: Pairs with no shared skill. A partner for x must use only skills x lacks, so it
// must be a submask of full ^ x. Count how many volunteers have each exact mask, then turn those counts
// into submask totals with sum over subsets: for each bit, every mask containing it adds the count of
// the same mask without it. Then each volunteer looks up count[full ^ x]. That counts ordered pairs,
// plus each volunteer with no skills pairing with itself, so subtract those and halve.
// O(k · 2^k + n) time and O(2^k) space, for k skills and n volunteers.

public enum DisjointSkillPairs {
    public static func countPairs(_ skills: [Int], skillCount: Int) -> Int {
        let size = 1 << skillCount
        let full = size - 1
        var count = [Int](repeating: 0, count: size)
        for x in skills { count[x] += 1 }
        for bit in 0..<skillCount {
            for mask in 0..<size where mask & (1 << bit) != 0 {
                count[mask] += count[mask ^ (1 << bit)]
            }
        }
        var ordered = 0
        for x in skills {
            ordered += count[full ^ x]
        }
        let noSkills = skills.filter { $0 == 0 }.count
        return (ordered - noSkills) / 2
    }
}
