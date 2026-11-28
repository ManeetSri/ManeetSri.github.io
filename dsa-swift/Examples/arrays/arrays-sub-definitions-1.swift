// Generated from src/dsa/content/lessons/arrays/arrays-sub-definitions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [1, 2, 3]
var subarrays: [[Int]] = []
for start in numbers.indices {
    for end in start..<numbers.count {
        subarrays.append(Array(numbers[start...end]))
    }
}
print(subarrays)
print(subarrays.count, numbers.count * (numbers.count + 1) / 2)
