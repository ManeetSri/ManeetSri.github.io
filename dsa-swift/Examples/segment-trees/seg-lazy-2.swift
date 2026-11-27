// Generated from src/dsa/content/lessons/segment-trees/seg-lazy.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Two kinds of range update. A node's tag means "set every item to assign (if any), then add".
enum Change {
    case assign(Int)
    case add(Int)
}

struct AssignAddTree {
    private var sums: [Int]
    private var assignTag: [Int?]                 // nil: no pending assignment (0 is a real value)
    private var addTag: [Int]
    private let count: Int

    init(count: Int) {
        self.count = count
        sums = Array(repeating: 0, count: 4 * count)
        assignTag = Array(repeating: nil, count: 4 * count)
        addTag = Array(repeating: 0, count: 4 * count)
    }

    mutating func update(_ change: Change, _ left: Int, _ right: Int) {
        update(change, left, right, 1, 0, count - 1)
    }

    mutating func sum(_ left: Int, _ right: Int) -> Int {
        sum(left, right, 1, 0, count - 1)
    }

    // A newer change on top of whatever the node already has pending
    private mutating func apply(_ change: Change, _ node: Int, _ length: Int) {
        switch change {
        case .assign(let value):
            sums[node] = value * length
            assignTag[node] = value
            addTag[node] = 0                      // an assignment wipes out older additions
        case .add(let delta):
            sums[node] += delta * length
            addTag[node] += delta                 // kept on top of any older assignment
        }
    }

    private mutating func push(_ node: Int, _ low: Int, _ mid: Int, _ high: Int) {
        let leftLength = mid - low + 1, rightLength = high - mid
        if let value = assignTag[node] {          // the older part of the tag goes first
            apply(.assign(value), 2 * node, leftLength)
            apply(.assign(value), 2 * node + 1, rightLength)
            assignTag[node] = nil
        }
        if addTag[node] != 0 {                    // then the newer part
            apply(.add(addTag[node]), 2 * node, leftLength)
            apply(.add(addTag[node]), 2 * node + 1, rightLength)
            addTag[node] = 0
        }
    }

    private mutating func update(_ change: Change, _ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) {
        if right < low || high < left { return }
        if left <= low && high <= right {
            apply(change, node, high - low + 1)
            return
        }
        let mid = (low + high) / 2
        push(node, low, mid, high)
        update(change, left, right, 2 * node, low, mid)
        update(change, left, right, 2 * node + 1, mid + 1, high)
        sums[node] = sums[2 * node] + sums[2 * node + 1]
    }

    private mutating func sum(_ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) -> Int {
        if right < low || high < left { return 0 }
        if left <= low && high <= right { return sums[node] }
        let mid = (low + high) / 2
        push(node, low, mid, high)
        return sum(left, right, 2 * node, low, mid) + sum(left, right, 2 * node + 1, mid + 1, high)
    }
}

var tree = AssignAddTree(count: 6)
tree.update(.add(5), 0, 5)                        // [5, 5, 5, 5, 5, 5]
tree.update(.assign(0), 1, 4)                     // [5, 0, 0, 0, 0, 5]
tree.update(.add(2), 3, 5)                        // [5, 0, 0, 2, 2, 7]
print(tree.sum(0, 5), tree.sum(1, 2), tree.sum(3, 4))

// Compare with a plain array over 3,000 random changes and sums
var items = Array(repeating: 0, count: 13)
var checked = AssignAddTree(count: 13)
var state: UInt64 = 42
func next(_ limit: Int) -> Int {
    state = state &* 6364136223846793005 &+ 1442695040888963407
    return Int((state >> 33) % UInt64(limit))
}
var mismatches = 0
for _ in 0..<3_000 {
    let a = next(13), b = next(13)
    let left = min(a, b), right = max(a, b)
    switch next(3) {
    case 0:
        let value = next(7) - 3
        checked.update(.assign(value), left, right)
        for i in left...right { items[i] = value }
    case 1:
        let delta = next(7) - 3
        checked.update(.add(delta), left, right)
        for i in left...right { items[i] += delta }
    default:
        if checked.sum(left, right) != items[left...right].reduce(0, +) { mismatches += 1 }
    }
}
print("mismatches:", mismatches)
