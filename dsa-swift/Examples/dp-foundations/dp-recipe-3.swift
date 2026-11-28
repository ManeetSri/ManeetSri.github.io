// Generated from src/dsa/content/lessons/dp-foundations/dp-recipe.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Which totals can be bought exactly with boxes of 6, 9 and 20 eggs?
let boxes = [6, 9, 20]
let limit = 50

// 1. State: possible[t] = true if exactly t eggs can be bought
var possible = Array(repeating: false, count: limit + 1)
// 3. Base case: zero eggs, by buying nothing
possible[0] = true
// 4. Order: t increases, because possible[t] reads smaller totals
for t in stride(from: 1, through: limit, by: 1) {
    // 2. Transition: is there a box whose removal leaves a possible total?
    for box in boxes where box <= t && possible[t - box] {
        possible[t] = true
    }
}
// 5. Answer: here, every total that can't be made
print((1...limit).filter { !possible[$0] })
