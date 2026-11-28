// Generated from src/dsa/content/lessons/dp-knapsack/dpk-last-stone.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Every final weight you can end with, by trying every order of smashes (fine for a handful of stones)
func allEndings(_ stones: [Int]) -> Set<Int> {
    if stones.count <= 1 { return [stones.first ?? 0] }
    var endings: Set<Int> = []
    for i in stones.indices {
        for j in stones.indices where j > i {
            var rest = stones
            rest.remove(at: j)                           // remove the later index first
            rest.remove(at: i)
            let leftover = abs(stones[i] - stones[j])
            endings.formUnion(allEndings(leftover > 0 ? rest + [leftover] : rest))
        }
    }
    return endings
}

let stones = [8, 3, 12, 5, 9]
print("every possible ending:", allEndings(stones).sorted())

// Every split into two piles, as a bitmask: bit i set puts stone i in the first pile
let total = stones.reduce(0, +)
var differences: Set<Int> = []
for mask in 0..<(1 << stones.count) {
    let first = stones.indices.filter { mask & (1 << $0) != 0 }.map { stones[$0] }.reduce(0, +)
    differences.insert(abs(total - 2 * first))
}
print("every pile difference:", differences.sorted())
