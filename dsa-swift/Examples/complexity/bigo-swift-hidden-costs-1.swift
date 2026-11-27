// Generated from src/dsa/content/lessons/complexity/bigo-swift-hidden-costs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = Array(0..<1_000)
let lookups = Array(500..<1_500)

var comparisons = 0
var found = 0
for target in lookups {
    if numbers.contains(where: { value in
        comparisons += 1
        return value == target
    }) {
        found += 1
    }
}
print("array: found \(found), comparisons \(comparisons)")

let numberSet = Set(numbers)
found = lookups.filter { numberSet.contains($0) }.count
print("set: found \(found), one hash lookup each")
