// Generated from src/dsa/content/lessons/advanced-structures/as-rope.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// An immutable rope: leaves hold short runs of characters, and inner nodes join two ropes
final class Rope {
    static let leafSize = 8
    static var created = 0                       // nodes made, to measure the cost of edits

    let left: Rope?
    let right: Rope?
    let chunk: [Character]                       // only leaves hold characters
    let count: Int                               // characters in this whole rope
    let depth: Int

    init(chunk: ArraySlice<Character>) {         // a leaf
        left = nil
        right = nil
        self.chunk = Array(chunk)
        count = chunk.count
        depth = 0
        Rope.created += 1
    }

    init(_ left: Rope, _ right: Rope) {          // an inner node: left's text, then right's
        self.left = left
        self.right = right
        chunk = []
        count = left.count + right.count
        depth = 1 + max(left.depth, right.depth)
        Rope.created += 1
    }

    // A balanced rope from an array of characters: halve it until the pieces fit in a leaf
    static func build(_ characters: ArraySlice<Character>) -> Rope {
        if characters.count <= leafSize { return Rope(chunk: characters) }
        let middle = characters.startIndex + characters.count / 2
        return Rope(build(characters[..<middle]), build(characters[middle...]))
    }

    // Join two ropes in O(1), skipping empty ones
    static func concat(_ a: Rope, _ b: Rope) -> Rope {
        if a.count == 0 { return b }
        if b.count == 0 { return a }
        return Rope(a, b)
    }

    // The character at index: go left if it's among the left's characters, otherwise go right
    func character(at index: Int) -> Character {
        var node = self
        var index = index
        while let left = node.left, let right = node.right {
            if index < left.count {
                node = left
            } else {
                index -= left.count                  // skip the left's characters
                node = right
            }
        }
        return node.chunk[index]
    }

    // Two ropes: the first index characters, and the rest. Only the nodes on one path are rebuilt.
    func split(at index: Int) -> (Rope, Rope) {
        guard let left, let right else {
            return (Rope(chunk: chunk[..<index]), Rope(chunk: chunk[index...]))
        }
        if index <= left.count {
            let (a, b) = left.split(at: index)
            return (a, Rope.concat(b, right))
        }
        let (a, b) = right.split(at: index - left.count)
        return (Rope.concat(left, a), b)
    }

    func inserting(_ text: String, at index: Int) -> Rope {
        let (before, after) = split(at: index)
        return Rope.concat(Rope.concat(before, Rope.build(ArraySlice(Array(text)))), after)
    }

    func removing(from start: Int, count: Int) -> Rope {
        let (before, rest) = split(at: start)
        let (_, after) = rest.split(at: count)
        return Rope.concat(before, after)
    }

    var leaves: [[Character]] {
        if let left, let right { return left.leaves + right.leaves }
        return chunk.isEmpty ? [] : [chunk]
    }

    var text: String {
        String(leaves.joined())
    }
}

let original = Rope.build(ArraySlice(Array("Hello, world!")))
let edited = original.inserting("brave new ", at: 7)
let trimmed = edited.removing(from: 5, count: 1)
print(original.text, "|", edited.text, "|", trimmed.text)
print("character 7 of each:", original.character(at: 7), edited.character(at: 7), trimmed.character(at: 7))

// Type 1,000 characters into the middle of a 100,000-character document
var flat = Array(repeating: Character("."), count: 100_000)
var rope = Rope.build(ArraySlice(flat))
var shifted = 0
Rope.created = 0
for k in 0..<1_000 {
    let position = 50_000 + k
    shifted += flat.count - position             // what insert(_:at:) moves along
    flat.insert("x", at: position)
    rope = rope.inserting("x", at: position)
}
print("array: \(shifted) characters shifted")
print("rope: \(Rope.created) nodes created, depth now \(rope.depth)")
print("same text:", rope.text == String(flat))

let rebalanced = Rope.build(ArraySlice(Array(rope.leaves.joined())))
print("depth after rebalancing:", rebalanced.depth, " character 50,500:", rebalanced.character(at: 50_500))
