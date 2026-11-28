// Generated from src/dsa/content/lessons/prefix-sums/prefix-1d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let items = [3, 1, 4, 1, 5, 9, 2]
var prefix = [0]
for value in items {
    prefix.append(prefix.last! + value)
}

func rangeSum(_ prefix: [Int], from start: Int, through end: Int) -> Int {
    prefix[end + 1] - prefix[start]
}

print(rangeSum(prefix, from: 2, through: 5))
print(rangeSum(prefix, from: 0, through: 6))
print(rangeSum(prefix, from: 4, through: 4))
