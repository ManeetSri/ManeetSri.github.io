// Generated from src/dsa/content/lessons/prefix-sums/prefix-1d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let items = [3, 1, 4, 1, 5, 9, 2]
var prefix = [0]
for value in items {
    prefix.append(prefix.last! + value)
}
print(prefix)
print(items.count, prefix.count)
