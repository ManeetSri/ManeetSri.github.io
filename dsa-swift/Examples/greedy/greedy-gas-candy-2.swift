// Generated from src/dsa/content/lessons/greedy/greedy-gas-candy.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func circuitStart(fuel: [Int], cost: [Int]) -> Int {
    var total = 0                  // the gain over a whole lap
    var tank = 0                   // fuel since the current candidate start
    var start = 0
    for i in fuel.indices {
        let gain = fuel[i] - cost[i]
        total += gain
        tank += gain
        if tank < 0 {              // can't reach station i + 1 from `start`
            print("  stuck after station \(i): try starting at \(i + 1)")
            start = i + 1
            tank = 0
        }
    }
    return total >= 0 ? start : -1
}

print(circuitStart(fuel: [4, 1, 2, 6, 1], cost: [3, 4, 3, 1, 3]))
print(circuitStart(fuel: [2, 2], cost: [3, 2]))
