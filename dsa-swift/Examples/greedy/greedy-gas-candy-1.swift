// Generated from src/dsa/content/lessons/greedy/greedy-gas-candy.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let fuel = [4, 1, 2, 6, 1]
let cost = [3, 4, 3, 1, 3]

var tank = 0                       // starting at station 0, allowing a negative tank
var lowest = 0
var start = 0
for i in fuel.indices {
    tank += fuel[i] - cost[i]
    print("after station \(i): \(tank)")
    if tank < lowest {
        lowest = tank
        start = i + 1              // the worst moment so far is right before station i + 1
    }
}
print(tank >= 0 ? "start at \(start)" : "impossible")
