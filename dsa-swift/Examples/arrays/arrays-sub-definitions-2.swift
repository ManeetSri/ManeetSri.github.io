// Generated from src/dsa/content/lessons/arrays/arrays-sub-definitions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [1, 2, 3]
var subsequences: [[Int]] = []
for mask in 0..<(1 << numbers.count) {
    var picked: [Int] = []
    for index in numbers.indices where mask & (1 << index) != 0 {
        picked.append(numbers[index])
    }
    subsequences.append(picked)
}
print(subsequences)
print(subsequences.count)
