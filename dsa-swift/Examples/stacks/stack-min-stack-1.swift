// Generated from src/dsa/content/lessons/stacks/stack-min-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct BrokenMinStack {
    private var items: [Int] = []
    private(set) var minimum: Int?

    mutating func push(_ value: Int) {
        items.append(value)
        minimum = min(value, minimum ?? value)
    }

    mutating func pop() -> Int? {
        items.popLast()          // but what should minimum become now?
    }
}

var broken = BrokenMinStack()
broken.push(5)
broken.push(2)
broken.push(8)
_ = broken.pop()
_ = broken.pop()                 // removes the 2
print(broken.minimum ?? 0)
