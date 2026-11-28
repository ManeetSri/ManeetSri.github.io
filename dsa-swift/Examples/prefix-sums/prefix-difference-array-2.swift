// Generated from src/dsa/content/lessons/prefix-sums/prefix-difference-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let values = [4, 4, 7, 7, 7, 2]

var diff = [values[0]]
for index in 1..<values.count {
    diff.append(values[index] - values[index - 1])
}
print(diff)

var rebuilt: [Int] = []
var running = 0
for change in diff {
    running += change
    rebuilt.append(running)
}
print(rebuilt)
