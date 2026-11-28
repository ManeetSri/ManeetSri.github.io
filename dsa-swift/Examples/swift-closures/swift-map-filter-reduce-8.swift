// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let scores = [72, 38, 50, 91, 45]

let bonusTotal = scores
    .filter { $0 >= 50 }      // keep the passes: [72, 50, 91]
    .map { $0 + 5 }           // add a bonus: [77, 55, 96]
    .reduce(0, +)             // add them up
print(bonusTotal)
