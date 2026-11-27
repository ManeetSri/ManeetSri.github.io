// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let children = [[1, 2], [3], [4, 5], [], [], []]
var queue = [0]
var head = 0
var order: [Int] = []
while head < queue.count {
    let node = queue[head]
    head += 1                      // O(1): removeFirst() would shift every element left
    order.append(node)
    queue.append(contentsOf: children[node])
}
print(order)
