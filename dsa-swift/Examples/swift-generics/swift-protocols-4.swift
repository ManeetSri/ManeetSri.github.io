// Generated from src/dsa/content/lessons/swift-generics/swift-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol IntStack {
    mutating func push(_ value: Int)
    mutating func pop() -> Int?
    var isEmpty: Bool { get }
}

struct EndStack: IntStack {
    private var items: [Int] = []

    mutating func push(_ value: Int) {
        items.append(value)
    }

    mutating func pop() -> Int? {
        items.popLast()
    }

    var isEmpty: Bool {
        items.isEmpty
    }
}

struct FrontStack: IntStack {
    private var items: [Int] = []

    mutating func push(_ value: Int) {
        items.insert(value, at: 0)
    }

    mutating func pop() -> Int? {
        isEmpty ? nil : items.removeFirst()
    }

    var isEmpty: Bool {
        items.isEmpty
    }
}

var stacks: [any IntStack] = [EndStack(), FrontStack()]
for index in stacks.indices {
    for value in [1, 2, 3] {
        stacks[index].push(value)
    }
    var popped: [Int] = []
    while let top = stacks[index].pop() {
        popped.append(top)
    }
    print(popped)
}
