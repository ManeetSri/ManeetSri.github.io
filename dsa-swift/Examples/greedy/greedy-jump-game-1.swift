// Generated from src/dsa/content/lessons/greedy/greedy-jump-game.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func canReachEnd(_ steps: [Int]) -> Bool {
    var farthest = 0                              // every stone up to here is reachable
    for i in steps.indices {
        if i > farthest {
            print("  stone \(i) is out of reach")
            return false
        }
        farthest = max(farthest, i + steps[i])
        print("  stone \(i): farthest is now \(farthest)")
    }
    return true
}

print(canReachEnd([3, 1, 0, 2, 0, 1]))
print(canReachEnd([2, 1, 0, 3]))
