// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 5, 2]

var total = 0
for number in numbers {
    total = total + number
}
print(total)

let alsoTotal = numbers.reduce(0) { runningTotal, number in
    runningTotal + number
}
print(alsoTotal)
