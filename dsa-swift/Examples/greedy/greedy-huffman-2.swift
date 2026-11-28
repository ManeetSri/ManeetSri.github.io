// Generated from src/dsa/content/lessons/greedy/greedy-huffman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A small binary heap, as built in M39: insert and pop are O(log n)
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool
    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    var count: Int { items.count }
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
        var parent = 0
        while true {
            let left = 2 * parent + 1, right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { return top }
            items.swapAt(parent, first)
            parent = first
        }
    }
}

final class HuffmanNode {
    let weight: Int
    let order: Int                     // creation order, to break ties the same way every run
    let symbol: Character?             // only leaves have a symbol
    let left: HuffmanNode?
    let right: HuffmanNode?
    init(weight: Int, order: Int, symbol: Character? = nil, left: HuffmanNode? = nil, right: HuffmanNode? = nil) {
        self.weight = weight
        self.order = order
        self.symbol = symbol
        self.left = left
        self.right = right
    }
}

func buildTree(_ text: String) -> HuffmanNode? {
    var counts: [Character: Int] = [:]
    for symbol in text {
        counts[symbol, default: 0] += 1
    }
    var heap = Heap<HuffmanNode>(areInIncreasingOrder: { ($0.weight, $0.order) < ($1.weight, $1.order) })
    var made = 0
    for symbol in counts.keys.sorted() {           // sorted, so the result doesn't depend on dictionary order
        heap.insert(HuffmanNode(weight: counts[symbol]!, order: made, symbol: symbol))
        made += 1
    }
    while heap.count > 1 {
        let lightest = heap.pop()!, next = heap.pop()!
        print("merge \(lightest.weight) and \(next.weight) into \(lightest.weight + next.weight)")
        heap.insert(HuffmanNode(weight: lightest.weight + next.weight, order: made, left: lightest, right: next))
        made += 1
    }
    return heap.pop()
}

// Read each code off the path from the root: left adds a 0, right adds a 1
func codes(_ root: HuffmanNode?) -> [Character: String] {
    var table: [Character: String] = [:]
    func walk(_ node: HuffmanNode?, _ path: String) {
        guard let node else { return }
        if let symbol = node.symbol {
            table[symbol] = path.isEmpty ? "0" : path       // a lone symbol still needs one bit
            return
        }
        walk(node.left, path + "0")
        walk(node.right, path + "1")
    }
    walk(root, "")
    return table
}

// Walk down from the root, one bit per step; at a leaf, output its symbol and start again
func decode(_ bits: String, _ root: HuffmanNode) -> String {
    if let symbol = root.symbol {                         // a one-symbol tree: every bit is that symbol
        return String(repeating: symbol, count: bits.count)
    }
    var result = ""
    var node = root
    for bit in bits {
        node = (bit == "0" ? node.left : node.right)!     // inner nodes always have two children
        if let symbol = node.symbol {
            result.append(symbol)
            node = root
        }
    }
    return result
}

let text = "abracadabra"
let root = buildTree(text)!
let table = codes(root)
for symbol in table.keys.sorted() {
    print(symbol, table[symbol]!)
}
let bits = text.map { table[$0]! }.joined()
print(bits.count, "bits instead of", text.count * 3)
print(bits)
print(decode(bits, root))
