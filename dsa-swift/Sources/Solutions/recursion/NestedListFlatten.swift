// Reference solution: Flatten a nested list. Both functions visit every item once: O(n) time for n
// items in total, and O(d) stack space for nesting depth d. flatten appends into one shared array
// rather than joining arrays at every level, which would copy numbers again and again.

public enum NestedListFlatten {
    public indirect enum Item: Equatable {
        case number(Int)
        case list([Item])
    }

    public static func flatten(_ item: Item) -> [Int] {
        var result: [Int] = []
        func collect(_ item: Item) {
            switch item {
            case .number(let value):
                result.append(value)            // base case: a single number
            case .list(let items):
                for child in items {            // an empty list makes no calls
                    collect(child)
                }
            }
        }
        collect(item)
        return result
    }

    public static func depth(_ item: Item) -> Int {
        switch item {
        case .number:
            return 0
        case .list(let items):
            var deepest = 0
            for child in items {
                deepest = max(deepest, depth(child))
            }
            return 1 + deepest
        }
    }
}
