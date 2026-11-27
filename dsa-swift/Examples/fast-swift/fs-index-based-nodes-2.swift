// Generated from src/dsa/content/lessons/fast-swift/fs-index-based-nodes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct IntList {
    private struct Node {
        var value: Int
        var next: Int
    }

    private var nodes: [Node] = []
    private var head = -1
    private var freeHead = -1          // unused slots, linked through `next`

    var slotCount: Int { nodes.count }

    mutating func pushFront(_ value: Int) {
        let node = Node(value: value, next: head)
        if freeHead != -1 {            // reuse a slot
            let slot = freeHead
            freeHead = nodes[slot].next
            nodes[slot] = node
            head = slot
        } else {                       // no free slot: grow the array
            nodes.append(node)
            head = nodes.count - 1
        }
    }

    mutating func popFront() -> Int? {
        guard head != -1 else { return nil }
        let slot = head
        head = nodes[slot].next
        nodes[slot].next = freeHead    // the slot joins the free list
        freeHead = slot
        return nodes[slot].value
    }

    var values: [Int] {
        var result: [Int] = []
        var current = head
        while current != -1 {
            result.append(nodes[current].value)
            current = nodes[current].next
        }
        return result
    }
}

var list = IntList()
for value in [3, 2, 1] {
    list.pushFront(value)
}
print(list.values, "slots:", list.slotCount)
print(list.popFront() ?? -1, list.popFront() ?? -1)
list.pushFront(20)
list.pushFront(10)
print(list.values, "slots:", list.slotCount)

var copy = list
copy.pushFront(0)
print(list.values, copy.values)
