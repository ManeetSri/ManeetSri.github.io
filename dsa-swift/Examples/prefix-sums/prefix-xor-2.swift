// Generated from src/dsa/content/lessons/prefix-sums/prefix-xor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let items = [5, 3, 6, 2, 7, 1]
var prefixXor = [0]
for value in items {
    prefixXor.append(prefixXor.last! ^ value)
}

func rangeXor(from start: Int, through end: Int) -> Int {
    prefixXor[end + 1] ^ prefixXor[start]
}

print(rangeXor(from: 1, through: 3), 3 ^ 6 ^ 2)
print(rangeXor(from: 0, through: 5))
print(rangeXor(from: 4, through: 4))
