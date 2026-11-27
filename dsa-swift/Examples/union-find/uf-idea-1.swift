// Generated from src/dsa/content/lessons/union-find/uf-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var label = Array(0..<6)            // everyone starts in a group of their own

func union(_ a: Int, _ b: Int) {
    let from = label[a]
    let to = label[b]
    for index in label.indices where label[index] == from {
        label[index] = to           // move a's whole group across
    }
}

union(0, 1)
union(2, 3)
print(label)
union(1, 3)
print(label)
print("0 and 3 together?", label[0] == label[3])
