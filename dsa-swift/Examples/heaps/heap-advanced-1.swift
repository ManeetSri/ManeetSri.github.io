// Generated from src/dsa/content/lessons/heaps/heap-advanced.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A binomial heap's shape is n in binary: hasTree[k] is true when the heap holds a tree of order k.
// Inserting adds a single node (order 0), and equal orders link, carrying like binary addition.
var hasTree: [Bool] = []
var links = 0

func insertOne() {
    var order = 0
    while order < hasTree.count && hasTree[order] {
        hasTree[order] = false                   // two trees of this order link into one…
        links += 1
        order += 1                               // …of the next order up: the carry
    }
    if order == hasTree.count { hasTree.append(false) }
    hasTree[order] = true
}

for n in 1...13 {
    insertOne()
    let orders = hasTree.indices.filter { hasTree[$0] }.map { "B\($0)" }
    if [1, 2, 3, 4, 7, 8, 13].contains(n) {
        print("n = \(n) (\(String(n, radix: 2)) in binary): \(orders.reversed().joined(separator: ", "))")
    }
}
print("links for 13 inserts: \(links)")

hasTree = []
links = 0
for _ in 0..<1_000_000 {
    insertOne()
}
print("links for 1000000 inserts: \(links), fewer than 1 per insert")
