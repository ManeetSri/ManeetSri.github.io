// Generated from src/dsa/content/lessons/bits/bits-xor-tricks.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func xorSwap(_ items: inout [Int], _ i: Int, _ j: Int) {
    items[i] ^= items[j]
    items[j] ^= items[i]
    items[i] ^= items[j]
}

var items = [10, 20, 30]
xorSwap(&items, 0, 2)
print(items)
xorSwap(&items, 1, 1)
print(items)
