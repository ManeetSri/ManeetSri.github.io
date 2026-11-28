// Generated from src/dsa/content/lessons/segment-trees/seg-generic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The best run inside a range: a struct summary, with nil as the identity
struct SegmentTree<Element> {
    private var storage: [Element]
    let count: Int
    private let identity: Element
    private let merge: (Element, Element) -> Element

    init(_ values: [Element], identity: Element, merge: @escaping (Element, Element) -> Element) {
        count = values.count
        self.identity = identity
        self.merge = merge
        storage = Array(repeating: identity, count: values.count) + values
        for node in stride(from: count - 1, through: 1, by: -1) {
            storage[node] = merge(storage[2 * node], storage[2 * node + 1])
        }
    }

    func query(_ range: Range<Int>) -> Element {
        var left = range.lowerBound + count, right = range.upperBound + count
        var fromLeft = identity, fromRight = identity
        while left < right {
            if left % 2 == 1 { fromLeft = merge(fromLeft, storage[left]); left += 1 }
            if right % 2 == 1 { right -= 1; fromRight = merge(storage[right], fromRight) }
            left /= 2
            right /= 2
        }
        return merge(fromLeft, fromRight)
    }
}

struct Piece {
    var total: Int                                // the whole block
    var prefix: Int                               // best run starting at its left end
    var suffix: Int                               // best run ending at its right end
    var best: Int                                 // best run anywhere inside
}

func combine(_ a: Piece?, _ b: Piece?) -> Piece? {
    guard let a else { return b }                 // nil is the identity
    guard let b else { return a }
    return Piece(total: a.total + b.total,
                 prefix: max(a.prefix, a.total + b.prefix),
                 suffix: max(b.suffix, b.total + a.suffix),
                 best: max(a.best, b.best, a.suffix + b.prefix))
}

let values = [2, -5, 3, 4, -1, 6, -8, 1]
let leaves: [Piece?] = values.map { Piece(total: $0, prefix: $0, suffix: $0, best: $0) }
let tree = SegmentTree(leaves, identity: nil, merge: combine)
print(tree.query(0..<8)!.best, tree.query(0..<2)!.best, tree.query(6..<8)!.best, tree.query(3..<7)!.best)
print(tree.query(2..<2) == nil)
