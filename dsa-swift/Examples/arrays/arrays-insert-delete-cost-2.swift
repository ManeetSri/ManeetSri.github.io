// Generated from src/dsa/content/lessons/arrays/arrays-insert-delete-cost.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var active = ["ant", "bee", "cat", "dog", "eel"]

// O(1) removal: move the last element into the hole
func swapRemove(at index: Int, from items: inout [String]) -> String {
    items.swapAt(index, items.count - 1)
    return items.removeLast()
}

print(swapRemove(at: 1, from: &active))
print(active)
