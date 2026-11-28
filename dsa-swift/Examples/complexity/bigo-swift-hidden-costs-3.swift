// Generated from src/dsa/content/lessons/complexity/bigo-swift-hidden-costs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = Array(1...10_000)
var mapCalls = 0
var filterCalls = 0

// Each step builds a whole new array before the next one starts
let chained = numbers
    .map { n -> Int in
        mapCalls += 1
        return n * 3
    }
    .filter { n -> Bool in
        filterCalls += 1
        return n % 2 == 0
    }
    .prefix(3)
print(Array(chained), "map calls:", mapCalls, "filter calls:", filterCalls)

// One loop that stops as soon as it has three
var steps = 0
var firstThree: [Int] = []
for n in numbers {
    steps += 1
    let tripled = n * 3
    if tripled % 2 == 0 {
        firstThree.append(tripled)
        if firstThree.count == 3 {
            break
        }
    }
}
print(firstThree, "loop steps:", steps)
