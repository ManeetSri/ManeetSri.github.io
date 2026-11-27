// Generated from src/dsa/content/lessons/heaps/heap-scheduling.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", compacted, plus replaceTop
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var count: Int { items.count }
    var isEmpty: Bool { items.isEmpty }
    func peek() -> Element? { items.first }

    mutating func insert(_ element: Element) {
        items.append(element)
        var child = items.count - 1
        while child > 0 && areInIncreasingOrder(items[child], items[(child - 1) / 2]) {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        siftDownFromTop()
        return top
    }

    /// Replaces the top (the heap must not be empty) with one sift down
    mutating func replaceTop(with element: Element) {
        items[0] = element
        siftDownFromTop()
    }

    private mutating func siftDownFromTop() {
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { return }
            items.swapAt(parent, first)
            parent = first
        }
    }
}

// Rearrange letters so no two neighbours match, or return "" if that's impossible
func reorganise(_ text: String) -> String {
    var counts: [Character: Int] = [:]
    for letter in text {
        counts[letter, default: 0] += 1
    }
    if let most = counts.values.max(), most > (text.count + 1) / 2 {
        return ""                                         // too many copies of one letter
    }
    var heap = Heap<(letter: Character, left: Int)>(areInIncreasingOrder: {
        $0.left != $1.left ? $0.left > $1.left : $0.letter < $1.letter
    })
    for (letter, left) in counts {
        heap.insert((letter, left))
    }
    var result = ""
    var resting: (letter: Character, left: Int)? = nil  // the letter just used sits out one turn
    while let next = heap.pop() {
        result.append(next.letter)
        if let previous = resting, previous.left > 0 {
            heap.insert(previous)                         // its turn out is over
        }
        resting = (next.letter, next.left - 1)
    }
    return result
}

for text in ["aaabbc", "aab", "vvvlo", "aaab"] {
    print("\(text) -> \"\(reorganise(text))\"")
}
