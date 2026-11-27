// Generated from src/dsa/content/lessons/complexity/bigo-amortised.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A model array that starts with room for 1 element and doubles when full
var capacity = 1
var count = 0
var total = 0
var costs: [Int] = []
for _ in 1...17 {
    var cost = 1                  // writing the new element
    if count == capacity {
        cost += count             // copying every element to the new block
        capacity *= 2
    }
    count += 1
    total += cost
    costs.append(cost)
}
print(costs)
print("total \(total) for \(count) appends")
