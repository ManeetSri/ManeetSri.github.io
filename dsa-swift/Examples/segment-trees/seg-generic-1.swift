// Generated from src/dsa/content/lessons/segment-trees/seg-generic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A generic segment tree: an associative merge and its identity, left-to-right order kept
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
        var left = range.lowerBound + count
        var right = range.upperBound + count
        var fromLeft = identity                   // pieces from the left end, in order
        var fromRight = identity                  // pieces from the right end, in order
        while left < right {
            if left % 2 == 1 {
                fromLeft = merge(fromLeft, storage[left])        // new piece goes after
                left += 1
            }
            if right % 2 == 1 {
                right -= 1
                fromRight = merge(storage[right], fromRight)     // new piece goes before
            }
            left /= 2
            right /= 2
        }
        return merge(fromLeft, fromRight)
    }

    mutating func update(at index: Int, to value: Element) {
        var node = index + count
        storage[node] = value
        while node > 1 {
            node /= 2
            storage[node] = merge(storage[2 * node], storage[2 * node + 1])
        }
    }
}

var sums = SegmentTree([5, 3, 7, 9, 6, 4, 1, 2], identity: 0, merge: +)
print(sums.query(2..<7))
sums.update(at: 3, to: 1)
print(sums.query(2..<7))

let highest = SegmentTree([4, -2, 8, 0, -7], identity: Int.min, merge: max)
print(highest.query(0..<2), highest.query(3..<5), highest.query(1..<1))

var words = SegmentTree(["a", "b", "c", "d", "e", "f"], identity: "", merge: +)
print(words.query(1..<5))
words.update(at: 2, to: "C")
print(words.query(0..<6))
