// Reference solution: Generic picks. Both functions make one or two passes: O(n) time.
// largest needs only Comparable (O(1) space); mostFrequent needs Hashable for its counts (O(k) space
// for k distinct values).

public enum GenericPicks {
    public static func largest<T: Comparable>(_ items: [T]) -> T? {
        guard var best = items.first else { return nil }
        for item in items.dropFirst() where item > best {
            best = item
        }
        return best
    }

    // Count everything first, then walk the array in its original order, so that among equally
    // frequent values the one that appears first wins.
    public static func mostFrequent<T: Hashable>(_ items: [T]) -> T? {
        var counts: [T: Int] = [:]
        for item in items {
            counts[item, default: 0] += 1
        }
        var best: T?
        var bestCount = 0
        for item in items {
            let count = counts[item, default: 0]
            if count > bestCount {
                best = item
                bestCount = count
            }
        }
        return best
    }
}
