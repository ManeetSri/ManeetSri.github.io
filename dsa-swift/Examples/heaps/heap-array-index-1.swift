// Generated from src/dsa/content/lessons/heaps/heap-array-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let heap = [1, 3, 2, 7, 4, 5, 9]

for i in heap.indices {
    let left = 2 * i + 1
    let right = 2 * i + 2
    var line = "index \(i) holds \(heap[i])"
    if i > 0 {
        line += ", parent \(heap[(i - 1) / 2])"
    }
    if left < heap.count {
        line += ", children \(heap[left])"
    }
    if right < heap.count {
        line += " and \(heap[right])"
    }
    print(line)
}
