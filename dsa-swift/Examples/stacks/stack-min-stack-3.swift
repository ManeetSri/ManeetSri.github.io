// Generated from src/dsa/content/lessons/stacks/stack-min-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct LeanMinStack {
    private var items: [Int] = []
    private var minimums: [Int] = []

    mutating func push(_ value: Int) {
        items.append(value)
        if value <= (minimums.last ?? value) {
            minimums.append(value)          // a new minimum, or a tie with it
        }
    }

    @discardableResult
    mutating func pop() -> Int? {
        guard let value = items.popLast() else {
            return nil
        }
        if value == minimums.last {
            minimums.removeLast()
        }
        return value
    }

    var minimum: Int? { minimums.last }
    var savedMinimums: Int { minimums.count }
}

var lean = LeanMinStack()
for value in [3, 7, 9, 2, 2, 6] {
    lean.push(value)
}
print(lean.minimum!, lean.savedMinimums)
lean.pop()
lean.pop()
print(lean.minimum!)
lean.pop()
print(lean.minimum!)
