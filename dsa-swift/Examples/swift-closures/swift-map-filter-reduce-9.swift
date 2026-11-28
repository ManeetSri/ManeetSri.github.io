// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 8, 5, 2, 7]

var total = 0
for number in numbers {
    if number % 2 == 1 {          // skips some elements: filter
        let square = number * number  // changes each one: map
        total += square           // combines them: reduce
    }
}
print(total)

let alsoTotal = numbers
    .filter { $0 % 2 == 1 }
    .map { $0 * $0 }
    .reduce(0, +)
print(alsoTotal)
