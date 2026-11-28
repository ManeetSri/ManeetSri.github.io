// Generated from src/dsa/content/lessons/divide-conquer/dc-paradigm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Work per level of the recursion tree when each call costs its size: halves vs a lopsided split
func levelTotals(_ n: Int, split: (Int) -> [Int]) -> [Int] {
    var totals: [Int] = []
    var level = [n]
    while !level.isEmpty {
        totals.append(level.filter { $0 > 1 }.reduce(0, +))   // a call on 1 element does no splitting work
        level = level.filter { $0 > 1 }.flatMap(split)
    }
    return totals.filter { $0 > 0 }
}

let halves = levelTotals(16) { [$0 / 2, $0 - $0 / 2] }
let lopsided = levelTotals(16) { [1, $0 - 1] }
print("halves:  ", halves, "total", halves.reduce(0, +))
print("lopsided:", lopsided, "total", lopsided.reduce(0, +))
