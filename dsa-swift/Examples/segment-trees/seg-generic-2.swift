// Generated from src/dsa/content/lessons/segment-trees/seg-generic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A tuple monoid: the cheapest price in a range and the earliest day it happens
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

typealias Cheapest = (price: Int, day: Int)
func cheaper(_ a: Cheapest, _ b: Cheapest) -> Cheapest {
    if a.price != b.price { return a.price < b.price ? a : b }
    return a.day < b.day ? a : b                  // a tie goes to the earlier day
}

let prices = [7, 3, 9, 3, 5, 8]
let days = SegmentTree<Cheapest>(prices.enumerated().map { (price: $0.element, day: $0.offset) },
                                 identity: (Int.max, Int.max), merge: cheaper)
print(days.query(0..<6).day, days.query(2..<6).day, days.query(4..<6).day)
