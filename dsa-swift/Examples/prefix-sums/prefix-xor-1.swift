// Generated from src/dsa/content/lessons/prefix-sums/prefix-xor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let items = [5, 3, 6, 2, 7, 1]
var prefixXor = [0]
for value in items {
    prefixXor.append(prefixXor.last! ^ value)
}
print(prefixXor)
