// Generated from src/dsa/content/lessons/swift-generics/swift-generic-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largest<T: Comparable>(_ items: [T]) -> T? {
    guard var best = items.first else { return nil }
    for item in items where item > best {
        best = item
    }
    return best
}

struct ClockTime: Comparable {
    var hour: Int
    var minute: Int

    static func < (lhs: ClockTime, rhs: ClockTime) -> Bool {
        (lhs.hour, lhs.minute) < (rhs.hour, rhs.minute)
    }
}

print(largest([3, 9, 4]) ?? 0)
print(largest(["pear", "apple", "zucchini"]) ?? "")
print(largest([2.5, -1.0]) ?? 0)
let latest = largest([ClockTime(hour: 9, minute: 15), ClockTime(hour: 21, minute: 0)])!
print(latest.hour, latest.minute)
print(largest([Int]()) == nil)
