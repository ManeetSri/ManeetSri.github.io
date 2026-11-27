// Generated from src/dsa/content/lessons/greedy/greedy-jump-game.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fewestJumps(_ steps: [Int]) -> Int {
    var jumps = 0
    var reachEnd = 0                   // the last stone reachable with `jumps` jumps
    var farthest = 0                   // the farthest any stone seen so far can reach
    for i in 0..<(steps.count - 1) {   // no jump is needed from the last stone
        farthest = max(farthest, i + steps[i])
        if i == reachEnd {             // this range is used up: one more jump is needed
            if farthest == i { return -1 }      // nothing in the range gets past it
            jumps += 1
            print("  jump \(jumps) can land anywhere from \(reachEnd + 1) to \(min(farthest, steps.count - 1))")
            reachEnd = farthest
        }
    }
    return jumps
}

print(fewestJumps([2, 3, 1, 1, 4, 2, 1, 3, 1]))
print(fewestJumps([1, 1, 1]))
print(fewestJumps([5]))
print(fewestJumps([1, 0, 4]))
