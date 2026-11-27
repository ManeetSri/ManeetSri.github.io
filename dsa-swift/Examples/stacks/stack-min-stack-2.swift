// Generated from src/dsa/content/lessons/stacks/stack-min-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct MinStack {
    private var entries: [(value: Int, minimum: Int)] = []

    mutating func push(_ value: Int) {
        let minimum = min(value, entries.last?.minimum ?? value)
        entries.append((value, minimum))
    }

    @discardableResult
    mutating func pop() -> Int? {
        entries.popLast()?.value
    }

    var top: Int? { entries.last?.value }
    var minimum: Int? { entries.last?.minimum }
}

var stack = MinStack()
for value in [5, 2, 8, 1] {
    stack.push(value)
    print("push \(value): minimum \(stack.minimum!)")
}
while let value = stack.pop() {
    print("pop \(value): minimum \(stack.minimum.map(String.init) ?? "none")")
}
