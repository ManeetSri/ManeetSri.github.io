// Generated from src/dsa/content/lessons/swift-types/swift-indirect-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

indirect enum IntList {
    case empty
    case node(Int, IntList)
}

func sum(_ list: IntList) -> Int {
    switch list {
    case .empty:
        return 0
    case let .node(value, rest):
        return value + sum(rest)
    }
}

let numbers = IntList.node(1, .node(2, .node(3, .empty)))
print(sum(numbers))
